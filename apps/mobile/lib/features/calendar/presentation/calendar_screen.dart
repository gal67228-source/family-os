import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../application/calendar_controller.dart';
import '../domain/calendar_event.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  static const List<String> _months = <String>[
    'ינואר',
    'פברואר',
    'מרץ',
    'אפריל',
    'מאי',
    'יוני',
    'יולי',
    'אוגוסט',
    'ספטמבר',
    'אוקטובר',
    'נובמבר',
    'דצמבר',
  ];

  static const List<String> _weekdays = <String>[
    'א׳',
    'ב׳',
    'ג׳',
    'ד׳',
    'ה׳',
    'ו׳',
    'ש׳',
  ];

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  bool _occursOn(CalendarEvent event, DateTime day) {
    final DateTime startDay =
        DateTime(event.start.year, event.start.month, event.start.day);
    final DateTime target = DateTime(day.year, day.month, day.day);

    if (event.recurrence == CalendarRecurrence.none) {
      final DateTime endDay =
          DateTime(event.end.year, event.end.month, event.end.day);
      return !target.isBefore(startDay) && !target.isAfter(endDay);
    }

    if (target.isBefore(startDay)) {
      return false;
    }

    switch (event.recurrence) {
      case CalendarRecurrence.none:
        return false;
      case CalendarRecurrence.daily:
        return true;
      case CalendarRecurrence.weekly:
        return target.weekday == startDay.weekday;
      case CalendarRecurrence.monthly:
        return target.day == startDay.day;
      case CalendarRecurrence.yearly:
        return target.month == startDay.month && target.day == startDay.day;
    }
  }

  List<CalendarEvent> _eventsForDay(
    List<CalendarEvent> events,
    DateTime day,
  ) {
    return events.where((CalendarEvent event) => _occursOn(event, day)).toList()
      ..sort(
        (CalendarEvent first, CalendarEvent second) =>
            first.start.compareTo(second.start),
      );
  }

  List<DateTime?> _monthCells() {
    final DateTime first = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final int leading = first.weekday % 7;
    final int days =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    final List<DateTime?> result =
        List<DateTime?>.filled(leading, null, growable: true);

    result.addAll(
      List<DateTime>.generate(
        days,
        (int index) =>
            DateTime(_visibleMonth.year, _visibleMonth.month, index + 1),
      ),
    );

    while (result.length % 7 != 0) {
      result.add(null);
    }

    return result;
  }

  void _moveMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  void _goToToday() {
    final DateTime now = DateTime.now();
    setState(() {
      _visibleMonth = DateTime(now.year, now.month);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  String _timeLabel(CalendarEvent event) {
    if (event.isAllDay) {
      return 'כל היום';
    }

    final String startHour = event.start.hour.toString().padLeft(2, '0');
    final String startMinute = event.start.minute.toString().padLeft(2, '0');
    final String endHour = event.end.hour.toString().padLeft(2, '0');
    final String endMinute = event.end.minute.toString().padLeft(2, '0');

    return '$startHour:$startMinute–$endHour:$endMinute';
  }

  String _selectedDateLabel() {
    const List<String> weekdayNames = <String>[
      'ראשון',
      'שני',
      'שלישי',
      'רביעי',
      'חמישי',
      'שישי',
      'שבת',
    ];

    return '${weekdayNames[_selectedDay.weekday % 7]}, '
        '${_selectedDay.day} ${_months[_selectedDay.month - 1]}';
  }

  IconData _eventIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.birthday:
        return Icons.cake_rounded;
      case CalendarEventType.appointment:
        return Icons.medical_services_rounded;
      case CalendarEventType.school:
        return Icons.school_rounded;
      case CalendarEventType.work:
        return Icons.work_rounded;
      case CalendarEventType.car:
        return Icons.directions_car_rounded;
      case CalendarEventType.shopping:
        return Icons.shopping_cart_rounded;
      case CalendarEventType.vacation:
        return Icons.beach_access_rounded;
      case CalendarEventType.family:
        return Icons.groups_rounded;
      case CalendarEventType.other:
        return Icons.event_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final CalendarState state = ref.watch(calendarControllerProvider);
    final List<CalendarEvent> events =
        ref.watch(activeFamilyCalendarEventsProvider);
    final List<CalendarEvent> selectedEvents =
        _eventsForDay(events, _selectedDay);
    final List<DateTime?> cells = _monthCells();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text(
            'יומן משפחתי',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          centerTitle: false,
          actions: <Widget>[
            IconButton(
              tooltip: 'חיפוש',
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(
            '/calendar/new?date=${_selectedDay.toIso8601String()}',
          ),
          backgroundColor: const Color(0xFF6D3BE7),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded, size: 30),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${_months[_visibleMonth.month - 1]} '
                              '${_visibleMonth.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'היומן המשפחתי שלכם',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: _goToToday,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.softPurple,
                          foregroundColor: const Color(0xFF6D3BE7),
                        ),
                        child: const Text('היום'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () => _moveMonth(1),
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${_months[_visibleMonth.month - 1]} '
                                '${_visibleMonth.year}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _moveMonth(-1),
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            for (final String day in _weekdays)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 0.88,
                          ),
                          itemCount: cells.length,
                          itemBuilder: (BuildContext context, int index) {
                            final DateTime? day = cells[index];

                            if (day == null) {
                              return const SizedBox.shrink();
                            }

                            final List<CalendarEvent> dayEvents =
                                _eventsForDay(events, day);
                            final bool selected = _sameDay(day, _selectedDay);
                            final bool today = _sameDay(day, DateTime.now());

                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => setState(() => _selectedDay = day),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Column(
                                  children: <Widget>[
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 38,
                                      height: 38,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFF6D3BE7)
                                            : today
                                                ? AppColors.softPurple
                                                : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          fontWeight: selected || today
                                              ? FontWeight.w900
                                              : FontWeight.w500,
                                          color: selected
                                              ? Colors.white
                                              : today
                                                  ? const Color(0xFF6D3BE7)
                                                  : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Wrap(
                                      spacing: 3,
                                      runSpacing: 2,
                                      alignment: WrapAlignment.center,
                                      children: dayEvents
                                          .take(3)
                                          .map(
                                            (CalendarEvent event) => Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Color(event.colorValue),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _selectedDateLabel(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6D3BE7),
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedEvents.isEmpty)
                    AppCard(
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 62,
                            height: 62,
                            decoration: const BoxDecoration(
                              color: AppColors.softPurple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.event_available_rounded,
                              color: Color(0xFF6D3BE7),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'אין אירועים ביום הזה',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'אפשר להוסיף אירוע חדש בעזרת כפתור הפלוס',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    for (final CalendarEvent event in selectedEvents)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          onTap: () =>
                              context.push('/calendar/edit/${event.id}'),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 6,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Color(event.colorValue),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(event.colorValue)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _eventIcon(event.type),
                                  color: Color(event.colorValue),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${_timeLabel(event)} · '
                                      '${event.type.label}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (event.location.isNotEmpty) ...<Widget>[
                                      const SizedBox(height: 3),
                                      Row(
                                        children: <Widget>[
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 15,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.location,
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 14),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
      ),
    );
  }
}
