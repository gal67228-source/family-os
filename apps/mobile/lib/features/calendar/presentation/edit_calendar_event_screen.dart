import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../families/application/family_controller.dart';
import '../../families/domain/family_member.dart';
import '../application/calendar_controller.dart';
import '../domain/calendar_event.dart';

class EditCalendarEventScreen extends ConsumerStatefulWidget {
  const EditCalendarEventScreen({
    this.eventId,
    this.initialDate,
    super.key,
  });

  final String? eventId;
  final DateTime? initialDate;

  @override
  ConsumerState<EditCalendarEventScreen> createState() =>
      _EditCalendarEventScreenState();
}

class _EditCalendarEventScreenState
    extends ConsumerState<EditCalendarEventScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final TextEditingController _interval = TextEditingController(text: '1');

  CalendarEventType _type = CalendarEventType.family;
  CalendarRecurrence _recurrence = CalendarRecurrence.none;
  CalendarReminder _reminder = CalendarReminder.none;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 1));
  DateTime? _recurrenceEnd;
  bool _isAllDay = false;
  bool _isPrivate = false;
  int _colorValue = 0xFF1256E8;
  final Set<String> _participants = <String>{};
  bool _initialized = false;

  static const List<int> _colors = <int>[
    0xFF1256E8,
    0xFF20C55A,
    0xFFFF8A00,
    0xFF8B5CF6,
    0xFFEF4444,
    0xFF0EA5E9,
  ];

  @override
  void initState() {
    super.initState();
    final DateTime base = widget.initialDate ?? DateTime.now();
    _start = DateTime(base.year, base.month, base.day, 9);
    _end = _start.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    _interval.dispose();
    super.dispose();
  }

  IconData _typeIcon(CalendarEventType type) {
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

  Color _typeColor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.birthday:
        return const Color(0xFFEF4444);
      case CalendarEventType.appointment:
        return const Color(0xFF0EA5E9);
      case CalendarEventType.school:
        return const Color(0xFF8B5CF6);
      case CalendarEventType.work:
        return const Color(0xFF1256E8);
      case CalendarEventType.car:
        return const Color(0xFFFF8A00);
      case CalendarEventType.shopping:
        return const Color(0xFF20C55A);
      case CalendarEventType.vacation:
        return const Color(0xFF14B8A6);
      case CalendarEventType.family:
        return const Color(0xFFEC4899);
      case CalendarEventType.other:
        return const Color(0xFF6B7280);
    }
  }

  CalendarEvent? _existingEvent() {
    final String? eventId = widget.eventId;
    if (eventId == null) {
      return null;
    }

    for (final CalendarEvent event
        in ref.read(calendarControllerProvider).events) {
      if (event.id == eventId) {
        return event;
      }
    }

    return null;
  }

  void _initialize(CalendarEvent event) {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _title.text = event.title;
    _location.text = event.location;
    _notes.text = event.notes;
    _interval.text = event.recurrenceInterval.toString();
    _type = event.type;
    _recurrence = event.recurrence;
    _recurrenceEnd = event.recurrenceEnd;
    _reminder = event.reminder;
    _start = event.start;
    _end = event.end;
    _isAllDay = event.isAllDay;
    _isPrivate = event.isPrivate;
    _colorValue = event.colorValue;
    _participants.addAll(event.participantIds);
  }

  String _dateLabel(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _timeLabel(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  Future<DateTime?> _pickDateTime(
    DateTime current, {
    required bool includeTime,
  }) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) {
      return null;
    }

    if (!includeTime) {
      return DateTime(date.year, date.month, date.day);
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CalendarEvent? existing = _existingEvent();
    if (existing != null) {
      _initialize(existing);
    }

    final family = ref.watch(familyControllerProvider).activeFamily;
    final List<FamilyMember> members = family?.members ?? <FamilyMember>[];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: _typeColor(_type).withValues(alpha: 0.14),
                child: Icon(
                  _typeIcon(_type),
                  color: _typeColor(_type),
                  size: 19,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                existing == null ? 'אירוע חדש' : 'עריכת אירוע',
              ),
            ],
          ),
          actions: <Widget>[
            if (existing != null)
              IconButton(
                tooltip: 'מחיקת אירוע',
                onPressed: () async {
                  final bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('למחוק את האירוע?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('ביטול'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('מחק'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    await ref
                        .read(calendarControllerProvider.notifier)
                        .deleteEvent(existing.id);

                    if (context.mounted) {
                      context.go('/calendar');
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              40 + MediaQuery.paddingOf(context).bottom,
            ),
            children: <Widget>[
              AppCard(
                child: Column(
                  children: <Widget>[
                    AppTextField(
                      controller: _title,
                      label: 'כותרת',
                      icon: Icons.event_rounded,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<CalendarEventType>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        labelText: 'סוג אירוע',
                      ),
                      items: CalendarEventType.values.map(
                        (CalendarEventType type) {
                          return DropdownMenuItem<CalendarEventType>(
                            value: type,
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      _typeColor(type).withValues(alpha: 0.14),
                                  child: Icon(
                                    _typeIcon(type),
                                    size: 16,
                                    color: _typeColor(type),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(type.label),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: (CalendarEventType? value) {
                        if (value != null) {
                          setState(() => _type = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('אירוע לכל היום'),
                      value: _isAllDay,
                      onChanged: (bool value) {
                        setState(() => _isAllDay = value);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_rounded),
                      title: const Text('התחלה'),
                      subtitle: Text(
                        _isAllDay
                            ? _dateLabel(_start)
                            : '${_dateLabel(_start)} · '
                                '${_timeLabel(_start)}',
                      ),
                      onTap: () async {
                        final DateTime? value = await _pickDateTime(
                          _start,
                          includeTime: !_isAllDay,
                        );

                        if (value != null) {
                          setState(() {
                            _start = value;
                            if (_end.isBefore(_start)) {
                              _end = _isAllDay
                                  ? _start
                                  : _start.add(
                                      const Duration(hours: 1),
                                    );
                            }
                          });
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_send_rounded),
                      title: const Text('סיום'),
                      subtitle: Text(
                        _isAllDay
                            ? _dateLabel(_end)
                            : '${_dateLabel(_end)} · '
                                '${_timeLabel(_end)}',
                      ),
                      onTap: () async {
                        final DateTime? value = await _pickDateTime(
                          _end,
                          includeTime: !_isAllDay,
                        );

                        if (value != null) {
                          setState(() => _end = value);
                        }
                      },
                    ),
                    AppTextField(
                      controller: _location,
                      label: 'מיקום',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _notes,
                      label: 'הערות',
                      icon: Icons.notes_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  children: <Widget>[
                    DropdownButtonFormField<CalendarRecurrence>(
                      initialValue: _recurrence,
                      decoration: const InputDecoration(
                        labelText: 'חזרה',
                        prefixIcon: Icon(Icons.repeat_rounded),
                      ),
                      items: CalendarRecurrence.values.map(
                        (CalendarRecurrence value) {
                          return DropdownMenuItem<CalendarRecurrence>(
                            value: value,
                            child: Text(value.label),
                          );
                        },
                      ).toList(),
                      onChanged: (CalendarRecurrence? value) {
                        if (value != null) {
                          setState(() {
                            _recurrence = value;
                            if (value == CalendarRecurrence.none) {
                              _recurrenceEnd = null;
                            }
                          });
                        }
                      },
                    ),
                    if (_recurrence != CalendarRecurrence.none) ...<Widget>[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _interval,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'חזור כל',
                          prefixIcon: Icon(Icons.numbers_rounded),
                          suffixText: 'מחזורים',
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_busy_rounded),
                        title: const Text('סיום החזרה'),
                        subtitle: Text(
                          _recurrenceEnd == null
                              ? 'ללא תאריך סיום'
                              : _dateLabel(_recurrenceEnd!),
                        ),
                        trailing: _recurrenceEnd == null
                            ? null
                            : IconButton(
                                tooltip: 'נקה',
                                onPressed: () {
                                  setState(() => _recurrenceEnd = null);
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                        onTap: () async {
                          final DateTime? value = await _pickDateTime(
                            _recurrenceEnd ?? _start,
                            includeTime: false,
                          );

                          if (value != null) {
                            setState(() => _recurrenceEnd = value);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 14),
                    DropdownButtonFormField<CalendarReminder>(
                      initialValue: _reminder,
                      decoration: const InputDecoration(
                        labelText: 'תזכורת',
                        prefixIcon: Icon(Icons.notifications_active_rounded),
                      ),
                      items: CalendarReminder.values.map(
                        (CalendarReminder value) {
                          return DropdownMenuItem<CalendarReminder>(
                            value: value,
                            child: Text(value.label),
                          );
                        },
                      ).toList(),
                      onChanged: (CalendarReminder? value) {
                        if (value != null) {
                          setState(() => _reminder = value);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('אירוע פרטי'),
                      subtitle: const Text(
                        'רק הכותרת תופיע לבני משפחה אחרים',
                      ),
                      secondary: const Icon(Icons.lock_rounded),
                      value: _isPrivate,
                      onChanged: (bool value) {
                        setState(() => _isPrivate = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'צבע',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: _colors.map((int color) {
                        return InkWell(
                          onTap: () {
                            setState(() => _colorValue = color);
                          },
                          borderRadius: BorderRadius.circular(99),
                          child: CircleAvatar(
                            radius: _colorValue == color ? 18 : 15,
                            backgroundColor: Color(color),
                            child: _colorValue == color
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              if (members.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'משתתפים',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      for (final FamilyMember member in members)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(member.name),
                          value: _participants.contains(member.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _participants.add(member.id);
                              } else {
                                _participants.remove(member.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: existing == null ? 'צור אירוע' : 'שמור שינויים',
                icon: Icons.save_rounded,
                onPressed: family == null
                    ? null
                    : () async {
                        final int interval =
                            int.tryParse(_interval.text.trim()) ?? 1;

                        final bool success;
                        if (existing == null) {
                          success = await ref
                              .read(calendarControllerProvider.notifier)
                              .addEvent(
                                familyId: family.id,
                                title: _title.text,
                                type: _type,
                                start: _start,
                                end: _end,
                                isAllDay: _isAllDay,
                                location: _location.text,
                                notes: _notes.text,
                                participantIds: _participants.toList(),
                                colorValue: _colorValue,
                                recurrence: _recurrence,
                                recurrenceInterval: interval < 1 ? 1 : interval,
                                recurrenceEnd: _recurrenceEnd,
                                reminder: _reminder,
                                isPrivate: _isPrivate,
                              );
                        } else {
                          success = await ref
                              .read(calendarControllerProvider.notifier)
                              .updateEvent(
                                existing.copyWith(
                                  title: _title.text.trim(),
                                  type: _type,
                                  start: _start,
                                  end: _end,
                                  isAllDay: _isAllDay,
                                  location: _location.text.trim(),
                                  notes: _notes.text.trim(),
                                  participantIds: _participants.toList(),
                                  colorValue: _colorValue,
                                  recurrence: _recurrence,
                                  recurrenceInterval:
                                      interval < 1 ? 1 : interval,
                                  recurrenceEnd: _recurrenceEnd,
                                  clearRecurrenceEnd: _recurrenceEnd == null,
                                  reminder: _reminder,
                                  isPrivate: _isPrivate,
                                ),
                              );
                        }

                        if (success && context.mounted) {
                          context.go('/calendar');
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
