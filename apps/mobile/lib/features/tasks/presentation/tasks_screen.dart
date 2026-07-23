import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../families/application/family_controller.dart';
import '../application/task_controller.dart';
import '../domain/family_task.dart';

enum _TaskFilter { open, mine, overdue, completed }

extension on _TaskFilter {
  String get label {
    switch (this) {
      case _TaskFilter.open:
        return 'פתוחות';
      case _TaskFilter.mine:
        return 'שלי';
      case _TaskFilter.overdue:
        return 'באיחור';
      case _TaskFilter.completed:
        return 'הושלמו';
    }
  }
}

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  _TaskFilter _filter = _TaskFilter.open;
  TaskPriority? _priorityFilter;

  String _dateLabel(FamilyTask task) {
    final DateTime date = task.dueDate;
    final String value = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';

    if (!task.hasDueTime) {
      return value;
    }

    return '$value · '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.secondary;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.high:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaskState state = ref.watch(taskControllerProvider);
    final List<FamilyTask> all = ref.watch(activeFamilyTasksProvider);
    final family = ref.watch(familyControllerProvider).activeFamily;
    final String currentMemberId =
        family?.members.isNotEmpty == true ? family!.members.first.id : '';

    final List<FamilyTask> tasks = all.where(
      (FamilyTask task) {
        final bool statusMatches = switch (_filter) {
          _TaskFilter.open => !task.isCompleted,
          _TaskFilter.mine =>
            !task.isCompleted && task.assigneeId == currentMemberId,
          _TaskFilter.overdue => task.isOverdue,
          _TaskFilter.completed => task.isCompleted,
        };

        final bool priorityMatches =
            _priorityFilter == null || task.priority == _priorityFilter;

        return statusMatches && priorityMatches;
      },
    ).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.softBlue,
                child: Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'משימות',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          actions: <Widget>[
            PopupMenuButton<TaskPriority?>(
              tooltip: 'סינון עדיפות',
              icon: Badge(
                isLabelVisible: _priorityFilter != null,
                child: const Icon(Icons.filter_alt_rounded),
              ),
              onSelected: (TaskPriority? value) {
                setState(() => _priorityFilter = value);
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<TaskPriority?>>[
                  const PopupMenuItem<TaskPriority?>(
                    value: null,
                    child: Text('כל העדיפויות'),
                  ),
                  for (final TaskPriority priority in TaskPriority.values)
                    PopupMenuItem<TaskPriority?>(
                      value: priority,
                      child: Text(priority.label),
                    ),
                ];
              },
            ),
            IconButton(
              tooltip: 'משימה חדשה',
              onPressed: () => context.push('/tasks/new'),
              icon: const Icon(
                Icons.add_circle_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ],
        ),
        body: state.isLoading
            ? const LoadingView(message: 'טוען משימות...')
            : Column(
                children: <Widget>[
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: _TaskFilter.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (
                        BuildContext context,
                        int index,
                      ) {
                        final _TaskFilter filter = _TaskFilter.values[index];

                        return ChoiceChip(
                          label: Text(filter.label),
                          selected: _filter == filter,
                          onSelected: (_) {
                            setState(() => _filter = filter);
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? EmptyState(
                            icon: Icons.task_alt_rounded,
                            title: 'אין משימות',
                            message: 'אין משימות שתואמות לסינון שבחרת.',
                            action: FilledButton.icon(
                              onPressed: () => context.push('/tasks/new'),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('הוסף משימה'),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              4,
                              16,
                              110,
                            ),
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (
                              BuildContext context,
                              int index,
                            ) {
                              final FamilyTask task = tasks[index];
                              final Color priorityColor =
                                  _priorityColor(task.priority);

                              return AppCard(
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: IconButton(
                                    tooltip: task.isCompleted
                                        ? 'פתח מחדש'
                                        : 'סמן כהושלם',
                                    onPressed: () => ref
                                        .read(
                                          taskControllerProvider.notifier,
                                        )
                                        .toggleCompleted(task.id),
                                    icon: Icon(
                                      task.isCompleted
                                          ? Icons.check_circle_rounded
                                          : Icons.circle_outlined,
                                      color: task.isCompleted
                                          ? AppColors.secondary
                                          : priorityColor,
                                    ),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 5,
                                        children: <Widget>[
                                          _TaskMeta(
                                            icon: Icons.person_rounded,
                                            label: task.assigneeName.isEmpty
                                                ? 'ללא אחראי'
                                                : task.assigneeName,
                                          ),
                                          _TaskMeta(
                                            icon: Icons.calendar_today_rounded,
                                            label: _dateLabel(task),
                                            color: task.isOverdue
                                                ? AppColors.error
                                                : null,
                                          ),
                                          _TaskMeta(
                                            icon: Icons.flag_rounded,
                                            label: task.priority.label,
                                            color: priorityColor,
                                          ),
                                          if (task.recurrence !=
                                              TaskRecurrence.none)
                                            _TaskMeta(
                                              icon: Icons.repeat_rounded,
                                              label: task.recurrence.label,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'מחיקה',
                                    onPressed: () => ref
                                        .read(
                                          taskControllerProvider.notifier,
                                        )
                                        .deleteTask(task.id),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TaskMeta extends StatelessWidget {
  const _TaskMeta({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: effectiveColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: effectiveColor,
            fontWeight: color == null ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
