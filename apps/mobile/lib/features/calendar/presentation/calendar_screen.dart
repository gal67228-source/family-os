import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../application/calendar_controller.dart';
import '../domain/calendar_event.dart';
import '../../tasks/application/task_controller.dart';
import '../../tasks/domain/family_task.dart';

enum _CalendarViewMode { month, week, day, agenda }

extension on _CalendarViewMode {
  String get label {
    switch (this) {
      case _CalendarViewMode.month:
        return 'חודש';
      case _CalendarViewMode.week:
        return 'שבוע';
      case _CalendarViewMode.day:
        return 'יום';
      case _CalendarViewMode.agenda:
        return 'רשימה';
    }
  }

  IconData get icon {
    switch (this) {
      case _CalendarViewMode.month:
        return Icons.calendar_month_rounded;
      case _CalendarViewMode.week:
        return Icons.view_week_rounded;
      case _CalendarViewMode.day:
        return Icons.view_day_rounded;
      case _CalendarViewMode.agenda:
        return Icons.view_agenda_rounded;
    }
  }
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;
  _CalendarViewMode _viewMode = _CalendarViewMode.month;
  String _query = '';
  final Set<CalendarEventType> _typeFilters = <CalendarEventType>{};

  static const List<String> _monthNames = <String>[
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

  static const List<String> _weekdayNames = <String>[
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
    _selectToday();
  }

  void _selectToday() {
    final DateTime now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  bool _eventOccursOn(CalendarEvent event, DateTime day) {
    final DateTime eventStart = DateTime(
      event.start.year,
      event.start.month,
      event.start.day,
    );
    final DateTime eventEnd = DateTime(
      event.end.year,
      event.end.month,
      event.end.day,
    );
    final DateTime target = DateTime(day.year, day.month, day.day);

    if (target.isBefore(eventStart)) {
      return false;
    }

    if (event.recurrenceEnd != null) {
      final DateTime recurrenceEnd = DateTime(
        event.recurrenceEnd!.year,
        event.recurrenceEnd!.month,
        event.recurrenceEnd!.day,
      );
      if (target.isAfter(recurrenceEnd)) {
        return false;
      }
    }

    final int interval =
        event.recurrenceInterval < 1 ? 1 : event.recurrenceInterval;
    final int daysDifference = target.difference(eventStart).inDays;

    switch (event.recurrence) {
      case CalendarRecurrence.none:
        return !target.isAfter(eventEnd);
      case CalendarRecurrence.daily:
        return daysDifference % interval == 0;
      case CalendarRecurrence.weekly:
        return target.weekday == eventStart.weekday &&
            (daysDifference ~/ 7) % interval == 0;
      case CalendarRecurrence.monthly:
        final int monthDifference = (target.year - eventStart.year) * 12 +
            target.month -
            eventStart.month;
        return target.day == eventStart.day && monthDifference % interval == 0;
      case CalendarRecurrence.yearly:
        final int yearDifference = target.year - eventStart.year;
        return target.month == eventStart.month &&
            target.day == eventStart.day &&
            yearDifference % interval == 0;
    }
  }

  List<CalendarEvent> _filteredEvents(
    List<CalendarEvent> events,
  ) {
    final String normalizedQuery = _query.trim().toLowerCase();

    final List<CalendarEvent> result = events.where(
      (CalendarEvent event) {
        final bool typeMatches =
            _typeFilters.isEmpty || _typeFilters.contains(event.type);
        final bool queryMatches = normalizedQuery.isEmpty ||
            event.title.toLowerCase().contains(normalizedQuery) ||
            event.location.toLowerCase().contains(normalizedQuery) ||
            event.notes.toLowerCase().contains(normalizedQuery);

        return typeMatches && queryMatches;
      },
    ).toList();

    result.sort(
      (CalendarEvent first, CalendarEvent second) =>
          first.start.compareTo(second.start),
    );

    return result;
  }

  List<CalendarEvent> _eventsForDay(
    List<CalendarEvent> events,
    DateTime day,
  ) {
    return events
        .where(
          (CalendarEvent event) => _eventOccursOn(event, day),
        )
        .toList()
      ..sort(
        (CalendarEvent first, CalendarEvent second) =>
            first.start.compareTo(second.start),
      );
  }

  List<DateTime?> _monthCells() {
    final DateTime firstDay = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final int leading = firstDay.weekday % 7;
    final int days = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    final List<DateTime?> result = <DateTime?>[];

    for (int index = 0; index < leading; index++) {
      result.add(null);
    }

    for (int day = 1; day <= days; day++) {
      result.add(
        DateTime(_visibleMonth.year, _visibleMonth.month, day),
      );
    }

    while (result.length % 7 != 0) {
      result.add(null);
    }

    return result;
  }

  DateTime _startOfWeek(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day - (value.weekday % 7),
    );
  }

  List<DateTime> _weekDays() {
    final DateTime start = _startOfWeek(_selectedDay);
    return List<DateTime>.generate(
      7,
      (int index) => start.add(Duration(days: index)),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
      _selectedDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    });
  }

  void _goToday() {
    setState(_selectToday);
  }

  Future<void> _openSearch() async {
    final TextEditingController controller =
        TextEditingController(text: _query);

    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('חיפוש ביומן'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'כותרת, מיקום או הערה',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onSubmitted: (String value) {
              Navigator.pop(dialogContext, value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, ''),
              child: const Text('נקה'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('חפש'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value != null && mounted) {
      setState(() => _query = value);
    }
  }

  Future<void> _openFilters() async {
    final Set<CalendarEventType> draft =
        Set<CalendarEventType>.from(_typeFilters);

    final Set<CalendarEventType>? selected =
        await showModalBottomSheet<Set<CalendarEventType>>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setSheetState,
          ) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'סינון לפי סוג אירוע',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CalendarEventType.values.map(
                        (CalendarEventType type) {
                          return FilterChip(
                            label: Text(type.label),
                            selected: draft.contains(type),
                            onSelected: (bool value) {
                              setSheetState(() {
                                if (value) {
                                  draft.add(type);
                                } else {
                                  draft.remove(type);
                                }
                              });
                            },
                          );
                        },
                      ).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(
                              context,
                              <CalendarEventType>{},
                            ),
                            child: const Text('נקה הכול'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, draft),
                            child: const Text('החל סינון'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _typeFilters
          ..clear()
          ..addAll(selected);
      });
    }
  }

  bool _taskOccursOn(FamilyTask task, DateTime day) {
    return task.dueDate.year == day.year &&
        task.dueDate.month == day.month &&
        task.dueDate.day == day.day;
  }

  List<FamilyTask> _tasksForDay(
    List<FamilyTask> tasks,
    DateTime day,
  ) {
    final List<FamilyTask> result = tasks
        .where(
          (FamilyTask task) => !task.isCompleted && _taskOccursOn(task, day),
        )
        .toList()
      ..sort(
        (FamilyTask first, FamilyTask second) =>
            first.dueDate.compareTo(second.dueDate),
      );
    return result;
  }

  String _taskTimeLabel(FamilyTask task) {
    if (!task.hasDueTime) {
      return 'ללא שעה';
    }
    return '${task.dueDate.hour.toString().padLeft(2, '0')}:'
        '${task.dueDate.minute.toString().padLeft(2, '0')}';
  }

  String _timeLabel(CalendarEvent event) {
    if (event.isAllDay) {
      return 'כל היום';
    }

    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(event.start.hour)}:${two(event.start.minute)}';
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
    final CalendarState calendarState = ref.watch(calendarControllerProvider);
    final List<CalendarEvent> familyEvents =
        ref.watch(activeFamilyCalendarEventsProvider);
    final List<CalendarEvent> events = _filteredEvents(familyEvents);
    final List<FamilyTask> calendarTasks = ref.watch(activeFamilyTasksProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.softPurple,
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF6D3BE7),
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'יומן משפחתי',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'אירוע חדש',
              onPressed: () {
                context.push(
                  '/calendar/new?date=${_selectedDay.toIso8601String()}',
                );
              },
              icon: const Icon(
                Icons.add_circle_rounded,
                color: Color(0xFF6D3BE7),
                size: 28,
              ),
            ),
            IconButton(
              tooltip: 'חיפוש',
              onPressed: _openSearch,
              icon: Badge(
                isLabelVisible: _query.isNotEmpty,
                child: const Icon(Icons.search_rounded),
              ),
            ),
            IconButton(
              tooltip: 'סינון',
              onPressed: _openFilters,
              icon: Badge(
                isLabelVisible: _typeFilters.isNotEmpty,
                label: Text('${_typeFilters.length}'),
                child: const Icon(Icons.filter_alt_rounded),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 74),
          child: FloatingActionButton.extended(
            onPressed: () {
              context.push(
                '/calendar/new?date=${_selectedDay.toIso8601String()}',
              );
            },
            backgroundColor: const Color(0xFF6D3BE7),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('אירוע חדש'),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: calendarState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                      child: Column(
                        children: <Widget>[
                          SegmentedButton<_CalendarViewMode>(
                            segments: _CalendarViewMode.values.map(
                              (_CalendarViewMode mode) {
                                return ButtonSegment<_CalendarViewMode>(
                                  value: mode,
                                  icon: Icon(mode.icon, size: 17),
                                  label: Text(mode.label),
                                );
                              },
                            ).toList(),
                            selected: <_CalendarViewMode>{_viewMode},
                            showSelectedIcon: false,
                            onSelectionChanged: (Set<_CalendarViewMode> value) {
                              setState(() => _viewMode = value.first);
                            },
                          ),
                          if (calendarTasks.any(
                            (FamilyTask task) => !task.isCompleted,
                          )) ...<Widget>[
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Chip(
                                avatar: const Icon(
                                  Icons.task_alt_rounded,
                                  size: 17,
                                ),
                                label: Text(
                                  '${calendarTasks.where(
                                        (FamilyTask task) => !task.isCompleted,
                                      ).length} משימות ביומן',
                                ),
                              ),
                            ),
                          ],
                          if (_query.isNotEmpty ||
                              _typeFilters.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 6),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.tune_rounded,
                                  size: 17,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'מוצגים ${events.length} אירועים',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _query = '';
                                      _typeFilters.clear();
                                    });
                                  },
                                  child: const Text('נקה'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      child: switch (_viewMode) {
                        _CalendarViewMode.month => _MonthView(
                            visibleMonth: _visibleMonth,
                            selectedDay: _selectedDay,
                            monthNames: _monthNames,
                            weekdayNames: _weekdayNames,
                            monthCells: _monthCells(),
                            events: events,
                            tasks: calendarTasks,
                            eventsForDay: _eventsForDay,
                            tasksForDay: _tasksForDay,
                            onSelectDay: (DateTime value) {
                              setState(() => _selectedDay = value);
                            },
                            onChangeMonth: _changeMonth,
                            onToday: _goToday,
                            eventIcon: _eventIcon,
                            timeLabel: _timeLabel,
                          ),
                        _CalendarViewMode.week => _WeekView(
                            days: _weekDays(),
                            selectedDay: _selectedDay,
                            events: events,
                            tasks: calendarTasks,
                            eventsForDay: _eventsForDay,
                            tasksForDay: _tasksForDay,
                            onSelectDay: (DateTime value) {
                              setState(() => _selectedDay = value);
                            },
                            eventIcon: _eventIcon,
                            timeLabel: _timeLabel,
                          ),
                        _CalendarViewMode.day => _DayView(
                            day: _selectedDay,
                            events: _eventsForDay(
                              events,
                              _selectedDay,
                            ),
                            tasks: _tasksForDay(
                              calendarTasks,
                              _selectedDay,
                            ),
                            eventIcon: _eventIcon,
                            taskTimeLabel: _taskTimeLabel,
                            timeLabel: _timeLabel,
                          ),
                        _CalendarViewMode.agenda => _AgendaView(
                            events: events,
                            tasks: calendarTasks
                                .where(
                                  (FamilyTask task) => !task.isCompleted,
                                )
                                .toList(),
                            eventIcon: _eventIcon,
                            taskTimeLabel: _taskTimeLabel,
                            timeLabel: _timeLabel,
                          ),
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.visibleMonth,
    required this.selectedDay,
    required this.monthNames,
    required this.weekdayNames,
    required this.monthCells,
    required this.events,
    required this.tasks,
    required this.eventsForDay,
    required this.tasksForDay,
    required this.onSelectDay,
    required this.onChangeMonth,
    required this.onToday,
    required this.eventIcon,
    required this.timeLabel,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final List<String> monthNames;
  final List<String> weekdayNames;
  final List<DateTime?> monthCells;
  final List<CalendarEvent> events;
  final List<FamilyTask> tasks;
  final List<CalendarEvent> Function(
    List<CalendarEvent>,
    DateTime,
  ) eventsForDay;
  final List<FamilyTask> Function(
    List<FamilyTask>,
    DateTime,
  ) tasksForDay;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<int> onChangeMonth;
  final VoidCallback onToday;
  final IconData Function(CalendarEventType) eventIcon;
  final String Function(CalendarEvent) timeLabel;

  bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    final List<CalendarEvent> selectedEvents =
        eventsForDay(events, selectedDay);
    final List<FamilyTask> selectedTasks = tasksForDay(tasks, selectedDay);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onChangeMonth(1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                      Expanded(
                        child: Text(
                          '${monthNames[visibleMonth.month - 1]} '
                          '${visibleMonth.year}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      TextButton(
                        onPressed: onToday,
                        child: const Text('היום'),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onChangeMonth(-1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      for (final String weekday in weekdayNames)
                        Expanded(
                          child: Center(
                            child: Text(
                              weekday,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: monthCells.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      final DateTime? day = monthCells[index];

                      if (day == null) {
                        return const SizedBox.shrink();
                      }

                      final bool selected = _sameDay(day, selectedDay);
                      final bool today = _sameDay(day, DateTime.now());
                      final List<CalendarEvent> dayEvents =
                          eventsForDay(events, day);
                      final List<FamilyTask> dayTasks = tasksForDay(tasks, day);

                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onSelectDay(day),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 31,
                              height: 31,
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
                                  fontSize: 13,
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
                            SizedBox(
                              height: 5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  ...dayEvents.take(2).map(
                                    (CalendarEvent event) {
                                      return Container(
                                        width: 4,
                                        height: 4,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(event.colorValue),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    },
                                  ),
                                  if (dayTasks.isNotEmpty)
                                    Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${selectedDay.day} '
                  '${monthNames[selectedDay.month - 1]}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6D3BE7),
                      ),
                ),
              ),
              Text(
                '${selectedEvents.length} אירועים · '
                '${selectedTasks.length} משימות',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _CalendarItemsList(
            events: selectedEvents,
            tasks: selectedTasks,
            eventIcon: eventIcon,
            eventTimeLabel: timeLabel,
          ),
        ),
      ],
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.days,
    required this.selectedDay,
    required this.events,
    required this.tasks,
    required this.eventsForDay,
    required this.tasksForDay,
    required this.onSelectDay,
    required this.eventIcon,
    required this.timeLabel,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final List<CalendarEvent> events;
  final List<FamilyTask> tasks;
  final List<CalendarEvent> Function(
    List<CalendarEvent>,
    DateTime,
  ) eventsForDay;
  final List<FamilyTask> Function(
    List<FamilyTask>,
    DateTime,
  ) tasksForDay;
  final ValueChanged<DateTime> onSelectDay;
  final IconData Function(CalendarEventType) eventIcon;
  final String Function(CalendarEvent) timeLabel;

  bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final DateTime day = days[index];
              final bool selected = _sameDay(day, selectedDay);
              final int count = eventsForDay(events, day).length +
                  tasksForDay(tasks, day).length;

              return ChoiceChip(
                selected: selected,
                onSelected: (_) => onSelectDay(day),
                label: SizedBox(
                  width: 48,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('${day.day}/${day.month}'),
                      const SizedBox(height: 4),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _CalendarItemsList(
            events: eventsForDay(events, selectedDay),
            tasks: tasksForDay(tasks, selectedDay),
            eventIcon: eventIcon,
            eventTimeLabel: timeLabel,
          ),
        ),
      ],
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({
    required this.day,
    required this.events,
    required this.tasks,
    required this.eventIcon,
    required this.taskTimeLabel,
    required this.timeLabel,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final List<FamilyTask> tasks;
  final IconData Function(CalendarEventType) eventIcon;
  final String Function(FamilyTask) taskTimeLabel;
  final String Function(CalendarEvent) timeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: <Widget>[
              const CircleAvatar(
                backgroundColor: AppColors.softPurple,
                child: Icon(
                  Icons.today_rounded,
                  color: Color(0xFF6D3BE7),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${day.day}/${day.month}/${day.year}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        Expanded(
          child: _CalendarItemsList(
            events: events,
            tasks: tasks,
            eventIcon: eventIcon,
            eventTimeLabel: timeLabel,
            taskTimeLabel: taskTimeLabel,
          ),
        ),
      ],
    );
  }
}

class _AgendaView extends StatelessWidget {
  const _AgendaView({
    required this.events,
    required this.tasks,
    required this.eventIcon,
    required this.taskTimeLabel,
    required this.timeLabel,
  });

  final List<CalendarEvent> events;
  final List<FamilyTask> tasks;
  final IconData Function(CalendarEventType) eventIcon;
  final String Function(FamilyTask) taskTimeLabel;
  final String Function(CalendarEvent) timeLabel;

  @override
  Widget build(BuildContext context) {
    return _CalendarItemsList(
      events: events,
      tasks: tasks,
      eventIcon: eventIcon,
      eventTimeLabel: timeLabel,
      taskTimeLabel: taskTimeLabel,
      showDate: true,
    );
  }
}

class _CalendarItemsList extends ConsumerWidget {
  const _CalendarItemsList({
    required this.events,
    required this.tasks,
    required this.eventIcon,
    required this.eventTimeLabel,
    this.taskTimeLabel,
    this.showDate = false,
  });

  final List<CalendarEvent> events;
  final List<FamilyTask> tasks;
  final IconData Function(CalendarEventType) eventIcon;
  final String Function(CalendarEvent) eventTimeLabel;
  final String Function(FamilyTask)? taskTimeLabel;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty && tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.event_available_rounded,
              size: 46,
              color: Color(0xFF6D3BE7),
            ),
            SizedBox(height: 8),
            Text(
              'אין אירועים או משימות להצגה',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    final List<Object> items = <Object>[...events, ...tasks]
      ..sort((Object first, Object second) {
        final DateTime firstDate = first is CalendarEvent
            ? first.start
            : (first as FamilyTask).dueDate;
        final DateTime secondDate = second is CalendarEvent
            ? second.start
            : (second as FamilyTask).dueDate;
        return firstDate.compareTo(secondDate);
      });

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final Object item = items[index];

        if (item is FamilyTask) {
          final String time = taskTimeLabel?.call(item) ??
              (item.hasDueTime
                  ? '${item.dueDate.hour.toString().padLeft(2, '0')}:'
                      '${item.dueDate.minute.toString().padLeft(2, '0')}'
                  : 'ללא שעה');

          return Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: IconButton(
                tooltip: 'סמן כהושלם',
                onPressed: () => ref
                    .read(taskControllerProvider.notifier)
                    .toggleCompleted(item.id),
                icon: const Icon(
                  Icons.circle_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: Row(
                children: <Widget>[
                  const Icon(
                    Icons.task_alt_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${showDate ? '${item.dueDate.day}/${item.dueDate.month} · ' : ''}'
                '$time · משימה'
                '${item.assigneeName.isEmpty ? '' : ' · ${item.assigneeName}'}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: item.isOverdue ? AppColors.error : AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          );
        }

        final CalendarEvent event = item as CalendarEvent;
        final Color color = Color(event.colorValue);

        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/calendar/edit/${event.id}'),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(eventIcon(event.type), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          event.isPrivate
                              ? 'אירוע פרטי · ${event.title}'
                              : event.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${showDate ? '${event.start.day}/${event.start.month} · ' : ''}'
                          '${eventTimeLabel(event)} · ${event.type.label}'
                          '${event.location.isEmpty ? '' : ' · ${event.location}'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 4,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
