import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
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

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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

    switch (event.recurrence) {
      case CalendarRecurrence.none:
        return !target.isAfter(eventEnd);
      case CalendarRecurrence.daily:
        return true;
      case CalendarRecurrence.weekly:
        return target.weekday == eventStart.weekday;
      case CalendarRecurrence.monthly:
        return target.day == eventStart.day;
      case CalendarRecurrence.yearly:
        return target.month == eventStart.month && target.day == eventStart.day;
    }
  }

  List<CalendarEvent> _eventsForDay(
    List<CalendarEvent> events,
    DateTime day,
  ) {
    final List<CalendarEvent> result = events
        .where(
          (CalendarEvent event) => _eventOccursOn(event, day),
        )
        .toList();

    result.sort(
      (CalendarEvent first, CalendarEvent second) =>
          first.start.compareTo(second.start),
    );

    return result;
  }

  List<DateTime?> _buildMonthCells() {
    final DateTime firstDay = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
      1,
    );
    final int leadingEmptyCells = firstDay.weekday % 7;
    final int numberOfDays = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;

    final List<DateTime?> cells = <DateTime?>[];

    for (int index = 0; index < leadingEmptyCells; index++) {
      cells.add(null);
    }

    for (int day = 1; day <= numberOfDays; day++) {
      cells.add(
        DateTime(
          _visibleMonth.year,
          _visibleMonth.month,
          day,
        ),
      );
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
      _selectedDay = DateTime(
        _visibleMonth.year,
        _visibleMonth.month,
        1,
      );
    });
  }

  void _goToToday() {
    setState(_selectToday);
  }

  String _eventTime(CalendarEvent event) {
    if (event.isAllDay) {
      return 'כל היום';
    }

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(event.start.hour)}:'
        '${twoDigits(event.start.minute)}';
  }

  String _selectedDateTitle() {
    return '${_selectedDay.day} '
        '${_monthNames[_selectedDay.month - 1]}';
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
    final List<CalendarEvent> selectedEvents =
        _eventsForDay(familyEvents, _selectedDay);
    final List<DateTime?> monthCells = _buildMonthCells();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text(
            'יומן משפחתי',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _goToToday,
              child: const Text('היום'),
            ),
            IconButton(
              tooltip: 'אירוע חדש',
              onPressed: () {
                context.push(
                  '/calendar/new?date='
                  '${_selectedDay.toIso8601String()}',
                );
              },
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            context.push(
              '/calendar/new?date=${_selectedDay.toIso8601String()}',
            );
          },
          backgroundColor: const Color(0xFF6D3BE7),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
        body: calendarState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
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
                                    onPressed: () => _changeMonth(1),
                                    icon: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${_monthNames[_visibleMonth.month - 1]} '
                                      '${_visibleMonth.year}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _changeMonth(-1),
                                    icon: const Icon(
                                      Icons.chevron_left_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  for (final String weekday in _weekdayNames)
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
                              const SizedBox(height: 2),
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

                                  final bool selected =
                                      _isSameDay(day, _selectedDay);
                                  final bool today =
                                      _isSameDay(day, DateTime.now());
                                  final List<CalendarEvent> dayEvents =
                                      _eventsForDay(familyEvents, day);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      setState(() {
                                        _selectedDay = day;
                                      });
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 160,
                                          ),
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
                                                      ? const Color(
                                                          0xFF6D3BE7,
                                                        )
                                                      : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        SizedBox(
                                          height: 5,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: dayEvents.take(3).map(
                                              (CalendarEvent event) {
                                                return Container(
                                                  width: 4,
                                                  height: 4,
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 1,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Color(
                                                      event.colorValue,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                );
                                              },
                                            ).toList(),
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
                      padding: const EdgeInsets.fromLTRB(16, 9, 16, 5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _selectedDateTitle(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF6D3BE7),
                                  ),
                            ),
                          ),
                          Text(
                            '${selectedEvents.length} אירועים',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: selectedEvents.isEmpty
                          ? const _EmptyDayView()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                4,
                                12,
                                84,
                              ),
                              itemCount: selectedEvents.length,
                              separatorBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                return const SizedBox(height: 8);
                              },
                              itemBuilder: (
                                BuildContext context,
                                int index,
                              ) {
                                final CalendarEvent event =
                                    selectedEvents[index];

                                return _EventCard(
                                  event: event,
                                  icon: _eventIcon(event.type),
                                  timeLabel: _eventTime(event),
                                  onTap: () {
                                    context.push(
                                      '/calendar/edit/${event.id}',
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _EmptyDayView extends StatelessWidget {
  const _EmptyDayView();

  @override
  Widget build(BuildContext context) {
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
            'אין אירועים ביום הזה',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.icon,
    required this.timeLabel,
    required this.onTap,
  });

  final CalendarEvent event;
  final IconData icon;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(event.colorValue);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
                child: Icon(icon, color: color),
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
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$timeLabel · ${event.type.label}'
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
  }
}
