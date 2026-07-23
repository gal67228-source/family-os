import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/task_controller.dart';
import '../domain/family_task.dart';

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final TaskState state = ref.watch(taskControllerProvider);
    final List<FamilyTask> all = ref.watch(activeFamilyTasksProvider);
    final List<FamilyTask> tasks = switch (_filter) {
      1 => all.where((FamilyTask task) => task.isCompleted).toList(),
      2 => all.where((FamilyTask task) => task.isOverdue).toList(),
      _ => all.where((FamilyTask task) => !task.isCompleted).toList(),
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('משימות'),
          actions: <Widget>[
            IconButton(
              onPressed: () => context.push('/tasks/new'),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        body: state.isLoading
            ? const LoadingView(message: 'טוען משימות...')
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: List<Widget>.generate(3, (int index) {
                        const List<String> labels = <String>[
                          'פתוחות',
                          'הושלמו',
                          'באיחור'
                        ];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Center(child: Text(labels[index])),
                              selected: _filter == index,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: _filter == index
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              side: BorderSide.none,
                              onSelected: (_) =>
                                  setState(() => _filter = index),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? EmptyState(
                            icon: Icons.task_alt_rounded,
                            title: 'אין משימות',
                            message: 'הוסף משימה חדשה כדי להתחיל.',
                            action: FilledButton(
                              onPressed: () => context.push('/tasks/new'),
                              child: const Text('הוסף משימה'),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (BuildContext context, int index) {
                              final FamilyTask task = tasks[index];
                              return AppCard(
                                padding: EdgeInsets.zero,
                                child: ListTile(
                                  leading: IconButton(
                                    onPressed: () => ref
                                        .read(taskControllerProvider.notifier)
                                        .toggleCompleted(task.id),
                                    icon: Icon(
                                      task.isCompleted
                                          ? Icons.check_circle_rounded
                                          : Icons.circle_outlined,
                                      color: task.isCompleted
                                          ? AppColors.secondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${task.assigneeName.isEmpty ? 'ללא אחראי' : task.assigneeName} · '
                                    '${_formatDate(task.dueDate)} · '
                                    '${task.priority.label}',
                                    style: TextStyle(
                                      color: task.isOverdue
                                          ? AppColors.error
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => ref
                                        .read(taskControllerProvider.notifier)
                                        .deleteTask(task.id),
                                    icon: const Icon(Icons.delete_outline),
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
