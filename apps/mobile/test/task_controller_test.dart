import 'package:family_os/features/tasks/application/task_controller.dart';
import 'package:family_os/features/tasks/data/task_repository.dart';
import 'package:family_os/features/tasks/domain/family_task.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryTaskRepository implements TaskRepository {
  List<FamilyTask> tasks = <FamilyTask>[];

  @override
  Future<List<FamilyTask>> loadTasks() async => tasks;

  @override
  Future<void> saveTasks(List<FamilyTask> value) async {
    tasks = value;
  }
}

void main() {
  test('task lifecycle works', () async {
    final MemoryTaskRepository repository = MemoryTaskRepository();
    final TaskController controller = TaskController(repository);
    await controller.load();

    expect(
      await controller.addTask(
        familyId: 'f1',
        title: 'בדיקה',
        assigneeId: 'm1',
        assigneeName: 'יוסי',
        priority: TaskPriority.high,
        dueDate: DateTime(2030, 1, 1, 10),
        hasDueTime: true,
        recurrence: TaskRecurrence.none,
      ),
      isTrue,
    );

    final String id = controller.state.tasks.single.id;
    await controller.toggleCompleted(id);
    expect(controller.state.tasks.single.isCompleted, isTrue);

    await controller.deleteTask(id);
    expect(controller.state.tasks, isEmpty);
  });

  test('completing recurring task creates next task', () async {
    final MemoryTaskRepository repository = MemoryTaskRepository();
    final TaskController controller = TaskController(repository);
    await controller.load();

    await controller.addTask(
      familyId: 'f1',
      title: 'להוציא זבל',
      assigneeId: 'm1',
      assigneeName: 'יוסי',
      priority: TaskPriority.medium,
      dueDate: DateTime(2030, 1, 1),
      hasDueTime: false,
      recurrence: TaskRecurrence.weekly,
    );

    final String id = controller.state.tasks.single.id;
    await controller.toggleCompleted(id);

    expect(controller.state.tasks, hasLength(2));
    expect(
      controller.state.tasks
          .where((FamilyTask task) => !task.isCompleted)
          .single
          .dueDate,
      DateTime(2030, 1, 8),
    );
  });
}
