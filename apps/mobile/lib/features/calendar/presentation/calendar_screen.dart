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
      ..sort((CalendarEvent first, CalendarEvent second) =>
          first.start.compareTo(second.start));
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

  String _timeLabel(CalendarEvent event) {
    if (event.isAllDay) {
      return 'כל היום';
    }
    final String hour = event.start.hour.toString().padLeft(2, '0');
    final String minute = event.start.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
        appBar: AppBar(
          title: const Text('יומן משפחתי'),
          actions: <Widget>[
            IconButton(
              tooltip: 'אירוע חדש',
              onPressed: () => context.push(
                '/calendar/new?date=${_selectedDay.toIso8601String()}',
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: <Widget>[
                  AppCard(
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
                                style: Theme.of(context).textTheme.titleLarge,
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
                            for (final String day in <String>[
                              'א',
                              'ב',
                              'ג',
                              'ד',
                              'ה',
                              'ו',
                              'ש'
                            ])
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
                            childAspectRatio: 0.9,
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
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => setState(() => _selectedDay = day),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.softBlue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: today
                                      ? Border.all(
                                          color: AppColors.primary,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        fontWeight: selected || today
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                        color: selected || today
                                            ? AppColors.primary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 2,
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
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'אירועים ב־${_selectedDay.day}/'
                          '${_selectedDay.month}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push(
                          '/calendar/new?date=${_selectedDay.toIso8601String()}',
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('הוסף'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (selectedEvents.isEmpty)
                    const AppCard(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.event_available_rounded,
                            size: 44,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 10),
                          Text('אין אירועים ביום הזה'),
                        ],
                      ),
                    )
                  else
                    for (final CalendarEvent event in selectedEvents)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          onTap: () =>
                              context.push('/calendar/edit/${event.id}'),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 5,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Color(event.colorValue),
                                  borderRadius: BorderRadius.circular(99),
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
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_timeLabel(event)} · '
                                      '${event.type.label}'
                                      '${event.location.isEmpty ? '' : ' · ${event.location}'}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_left_rounded),
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
