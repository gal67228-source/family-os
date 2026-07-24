import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../calendar/domain/calendar_event.dart';
import '../../shopping/domain/recurring_product.dart';
import '../../shopping/domain/shopping_item.dart';
import '../../tasks/domain/family_task.dart';
import '../data/notification_settings_repository.dart';
import '../domain/notification_settings.dart';

typedef NotificationRouteHandler = void Function(String route);

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'family_os_reminders';
  static const String _channelName = 'תזכורות Family OS';
  static const String _channelDescription = 'התראות על אירועים, משימות וקניות';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final NotificationSettingsRepository _settingsRepository =
      NotificationSettingsRepository();

  NotificationRouteHandler? _routeHandler;
  bool _initialized = false;
  Future<void>? _initializationFuture;

  bool get isInitialized => _initialized;

  Future<void> initialize({
    NotificationRouteHandler? onOpenRoute,
  }) {
    _routeHandler = onOpenRoute ?? _routeHandler;

    if (_initialized) {
      return Future<void>.value();
    }

    return _initializationFuture ??= _initializeInternal();
  }

  Future<void> _initializeInternal() async {
    tz.initializeTimeZones();

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: darwin,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? route = response.payload;
        if (route != null && route.isNotEmpty) {
          _routeHandler?.call(route);
        }
      },
    );

    _initialized = true;
    _initializationFuture = null;
  }

  Future<bool> notificationsEnabled() async {
    await initialize();

    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          true;
    }

    if (Platform.isIOS) {
      final NotificationsEnabledOptions? options = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();

      return options?.isEnabled ?? false;
    }

    return true;
  }

  Future<int> pendingNotificationCount() async {
    await initialize();
    final List<PendingNotificationRequest> pending =
        await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  Future<bool> requestPermissions() async {
    await initialize();
    bool granted = true;

    if (Platform.isAndroid) {
      granted = await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    }

    if (Platform.isIOS) {
      granted = await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          true;
    }

    return granted;
  }

  Future<NotificationSettings> loadSettings() {
    return _settingsRepository.load();
  }

  Future<void> saveSettings(NotificationSettings settings) {
    return _settingsRepository.save(settings);
  }

  Future<void> showTestNotification() async {
    await initialize();
    await _plugin.show(
      999999,
      'Family OS',
      'ההתראות פועלות בהצלחה 🎉',
      _details(),
      payload: '/today',
    );
  }

  Future<void> scheduleEventReminder(
    CalendarEvent event,
  ) async {
    await initialize();
    final NotificationSettings settings = await _settingsRepository.load();

    if (!settings.enabled || !settings.eventReminders) {
      return;
    }

    await _scheduleEvent(event);
  }

  Future<void> scheduleTaskReminder(FamilyTask task) async {
    await initialize();
    final NotificationSettings settings = await _settingsRepository.load();

    if (!settings.enabled || !settings.taskReminders) {
      return;
    }

    await _scheduleTask(task);
  }

  Future<void> sync({
    required List<CalendarEvent> events,
    required List<FamilyTask> tasks,
    required List<RecurringProduct> recurringProducts,
    required List<ShoppingItem> shoppingItems,
  }) async {
    await initialize();

    final NotificationSettings settings = await _settingsRepository.load();

    await _plugin.cancelAll();

    if (!settings.enabled) {
      return;
    }

    if (settings.eventReminders) {
      for (final CalendarEvent event in events) {
        try {
          await _scheduleEvent(event);
        } catch (_) {
          // A malformed event must not prevent other reminders.
        }
      }
    }

    if (settings.taskReminders) {
      for (final FamilyTask task in tasks) {
        try {
          await _scheduleTask(task);
        } catch (_) {
          // A malformed task must not prevent other reminders.
        }
      }
    }

    if (settings.shoppingReminders) {
      for (final RecurringProduct product in recurringProducts) {
        try {
          await _scheduleRecurringProduct(product);
        } catch (_) {
          // A malformed product must not prevent other reminders.
        }
      }
    }

    if (settings.dailySummary) {
      await _scheduleDailySummary(
        settings: settings,
        events: events,
        tasks: tasks,
        shoppingItems: shoppingItems,
      );
    }
  }

  Future<void> _scheduleEvent(CalendarEvent event) async {
    if (event.reminder == CalendarReminder.none) {
      return;
    }

    final Duration offset = switch (event.reminder) {
      CalendarReminder.none => Duration.zero,
      CalendarReminder.tenMinutes => const Duration(minutes: 10),
      CalendarReminder.thirtyMinutes => const Duration(minutes: 30),
      CalendarReminder.oneHour => const Duration(hours: 1),
      CalendarReminder.oneDay => const Duration(days: 1),
      CalendarReminder.oneWeek => const Duration(days: 7),
    };

    final DateTime now = DateTime.now();
    DateTime occurrence = event.isAllDay
        ? DateTime(
            event.start.year,
            event.start.month,
            event.start.day,
            9,
          )
        : event.start;

    if (event.recurrence != CalendarRecurrence.none &&
        occurrence.isBefore(now)) {
      occurrence = _nextEventOccurrence(
        event.copyWith(start: occurrence),
        now,
      );
    }

    DateTime scheduled = occurrence.subtract(offset);

    // If the chosen reminder lead time already passed but the event itself
    // is still upcoming, remind at the actual event time instead.
    if (!scheduled.isAfter(now) && occurrence.isAfter(now)) {
      scheduled = occurrence;
    }

    // An all-day event created for today should still produce a useful
    // reminder shortly after saving.
    if (event.isAllDay &&
        _sameDate(event.start, now) &&
        !scheduled.isAfter(now)) {
      scheduled = now.add(const Duration(seconds: 8));
    }

    if (!scheduled.isAfter(now)) {
      return;
    }

    await _schedule(
      id: _stableId('event-${event.id}'),
      title: scheduled == occurrence ? 'האירוע מתחיל עכשיו' : 'אירוע מתקרב',
      body: event.title,
      date: scheduled,
      payload: '/calendar/edit/${event.id}',
    );
  }

  DateTime _nextEventOccurrence(
    CalendarEvent event,
    DateTime after,
  ) {
    DateTime candidate = event.start;
    final int interval =
        event.recurrenceInterval < 1 ? 1 : event.recurrenceInterval;

    while (!candidate.isAfter(after)) {
      candidate = switch (event.recurrence) {
        CalendarRecurrence.none => candidate,
        CalendarRecurrence.daily => candidate.add(Duration(days: interval)),
        CalendarRecurrence.weekly =>
          candidate.add(Duration(days: interval * 7)),
        CalendarRecurrence.monthly => DateTime(
            candidate.year,
            candidate.month + interval,
            candidate.day,
            candidate.hour,
            candidate.minute,
          ),
        CalendarRecurrence.yearly => DateTime(
            candidate.year + interval,
            candidate.month,
            candidate.day,
            candidate.hour,
            candidate.minute,
          ),
      };

      if (event.recurrence == CalendarRecurrence.none) {
        break;
      }
    }

    return candidate;
  }

  Future<void> _scheduleTask(FamilyTask task) async {
    if (task.isCompleted || task.reminder == TaskReminder.none) {
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime due = task.hasDueTime
        ? task.dueDate
        : DateTime(
            task.dueDate.year,
            task.dueDate.month,
            task.dueDate.day,
            9,
          );

    DateTime scheduled = due.subtract(task.reminder.offset);

    // If the chosen "before" time already passed but the task is still
    // upcoming, notify at the actual due time instead of dropping it.
    if (!scheduled.isAfter(now) && due.isAfter(now)) {
      scheduled = due;
    }

    // A task saved for today without an explicit time should still receive
    // a useful notification shortly after it is created.
    if (!task.hasDueTime &&
        _sameDate(task.dueDate, now) &&
        !scheduled.isAfter(now)) {
      scheduled = now.add(const Duration(seconds: 8));
    }

    if (!scheduled.isAfter(now)) {
      return;
    }

    await _schedule(
      id: _stableId('task-${task.id}'),
      title: task.reminder == TaskReminder.atTime
          ? 'הגיע הזמן למשימה'
          : 'משימה מתקרבת',
      body: task.title,
      date: scheduled,
      payload: '/tasks',
    );
  }

  Future<void> _scheduleRecurringProduct(
    RecurringProduct product,
  ) async {
    DateTime scheduled;

    if (product.lastAddedAt == null) {
      scheduled = DateTime.now().add(const Duration(seconds: 10));
    } else {
      final DateTime next = product.cadence.nextDate(product.lastAddedAt!);
      scheduled = DateTime(
        next.year,
        next.month,
        next.day,
        9,
      );
    }

    if (!scheduled.isAfter(DateTime.now())) {
      scheduled = DateTime.now().add(const Duration(seconds: 10));
    }

    await _schedule(
      id: _stableId('shopping-${product.id}'),
      title: 'הגיע הזמן לקנות',
      body: product.name,
      date: scheduled,
      payload: '/shopping',
    );
  }

  Future<void> _scheduleDailySummary({
    required NotificationSettings settings,
    required List<CalendarEvent> events,
    required List<FamilyTask> tasks,
    required List<ShoppingItem> shoppingItems,
  }) async {
    final DateTime now = DateTime.now();
    final int todayEvents = events
        .where((CalendarEvent event) => _sameDate(event.start, now))
        .length;
    final int todayTasks = tasks
        .where(
          (FamilyTask task) =>
              !task.isCompleted && _sameDate(task.dueDate, now),
        )
        .length;
    final int shoppingCount =
        shoppingItems.where((ShoppingItem item) => !item.isChecked).length;

    final String body = '$todayEvents אירועים · $todayTasks משימות · '
        '$shoppingCount פריטים לקנייה';

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.dailySummaryHour,
      settings.dailySummaryMinute,
    );

    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _stableId('daily-summary'),
      'בוקר טוב 👋',
      body,
      scheduled,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: '/today',
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
  }) async {
    final DateTime now = DateTime.now();
    final Duration delay = date.difference(now);

    if (delay <= const Duration(seconds: 15)) {
      await _plugin.show(
        id,
        title,
        body,
        _details(),
        payload: payload,
      );
      return;
    }

    final tz.TZDateTime scheduled = tz.TZDateTime.from(
      date,
      tz.local,
    );

    AndroidScheduleMode mode = AndroidScheduleMode.inexactAllowWhileIdle;

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool exactAllowed =
          await android?.canScheduleExactNotifications() ?? false;

      if (exactAllowed) {
        mode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      _details(),
      androidScheduleMode: mode,
      payload: payload,
    );
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: 'ic_notification',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  int _stableId(String value) {
    int hash = 0;
    for (final int code in value.codeUnits) {
      hash = ((hash * 31) + code) & 0x7fffffff;
    }
    return hash;
  }
}
