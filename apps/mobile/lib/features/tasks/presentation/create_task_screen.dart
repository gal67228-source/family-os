import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../families/application/family_controller.dart';
import '../../families/domain/family_member.dart';
import '../application/task_controller.dart';
import '../domain/family_task.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final TextEditingController _title = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  TaskRecurrence _recurrence = TaskRecurrence.none;
  DateTime _dueDate = DateTime.now();
  String _assigneeId = '';
  bool _hasDueTime = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _timeLabel(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(familyControllerProvider).activeFamily;

    if (family == null) {
      return const Scaffold(
        body: Center(child: Text('אין משפחה פעילה')),
      );
    }

    final List<FamilyMember> members = family.members;

    if (_assigneeId.isEmpty && members.isNotEmpty) {
      _assigneeId = members.first.id;
    }

    FamilyMember? assignee;
    for (final FamilyMember member in members) {
      if (member.id == _assigneeId) {
        assignee = member;
        break;
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFEAF2FF),
                child: Icon(
                  Icons.add_task_rounded,
                  size: 19,
                ),
              ),
              SizedBox(width: 9),
              Text('משימה חדשה'),
            ],
          ),
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
                      label: 'כותרת המשימה',
                      icon: Icons.task_alt_rounded,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _assigneeId.isEmpty ? null : _assigneeId,
                      decoration: const InputDecoration(
                        labelText: 'אחראי/ת',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                      items: members.map((FamilyMember member) {
                        return DropdownMenuItem<String>(
                          value: member.id,
                          child: Text(member.name),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() => _assigneeId = value ?? '');
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: 'עדיפות',
                        prefixIcon: Icon(Icons.flag_circle_rounded),
                      ),
                      items: TaskPriority.values.map(
                        (TaskPriority priority) {
                          return DropdownMenuItem<TaskPriority>(
                            value: priority,
                            child: Text(priority.label),
                          );
                        },
                      ).toList(),
                      onChanged: (TaskPriority? value) {
                        if (value != null) {
                          setState(() => _priority = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month_rounded),
                      title: const Text('תאריך יעד'),
                      subtitle: Text(_dateLabel(_dueDate)),
                      onTap: () async {
                        final DateTime? value = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );

                        if (value != null) {
                          setState(() {
                            _dueDate = DateTime(
                              value.year,
                              value.month,
                              value.day,
                              _dueDate.hour,
                              _dueDate.minute,
                            );
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('הגדר שעה'),
                      secondary: const Icon(Icons.schedule_rounded),
                      value: _hasDueTime,
                      onChanged: (bool value) {
                        setState(() => _hasDueTime = value);
                      },
                    ),
                    if (_hasDueTime)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.access_time_rounded),
                        title: const Text('שעת יעד'),
                        subtitle: Text(_timeLabel(_dueDate)),
                        onTap: () async {
                          final TimeOfDay? value = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_dueDate),
                          );

                          if (value != null) {
                            setState(() {
                              _dueDate = DateTime(
                                _dueDate.year,
                                _dueDate.month,
                                _dueDate.day,
                                value.hour,
                                value.minute,
                              );
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskRecurrence>(
                      initialValue: _recurrence,
                      decoration: const InputDecoration(
                        labelText: 'חזרה',
                        prefixIcon: Icon(Icons.repeat_rounded),
                      ),
                      items: TaskRecurrence.values.map(
                        (TaskRecurrence recurrence) {
                          return DropdownMenuItem<TaskRecurrence>(
                            value: recurrence,
                            child: Text(recurrence.label),
                          );
                        },
                      ).toList(),
                      onChanged: (TaskRecurrence? value) {
                        if (value != null) {
                          setState(() => _recurrence = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: 'שמור משימה',
                icon: Icons.save_rounded,
                onPressed: () async {
                  final bool ok =
                      await ref.read(taskControllerProvider.notifier).addTask(
                            familyId: family.id,
                            title: _title.text,
                            assigneeId: assignee?.id ?? '',
                            assigneeName: assignee?.name ?? '',
                            priority: _priority,
                            dueDate: _dueDate,
                            hasDueTime: _hasDueTime,
                            recurrence: _recurrence,
                          );

                  if (ok && context.mounted) {
                    context.pop();
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
