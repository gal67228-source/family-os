import 'package:family_os/features/tasks/application/task_controller.dart';
import 'package:family_os/features/tasks/data/task_repository.dart';
import 'package:family_os/features/tasks/domain/family_task.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryTaskRepository implements TaskRepository {
  List<FamilyTask> tasks = <FamilyTask>[];
  @override
  Future<List<FamilyTask>> loadTasks() async => tasks;
  @override
  Future<void> saveTasks(List<FamilyTask> value) async => tasks = value;
}

void main() {
  test('task lifecycle works', () async {
    final MemoryTaskRepository repo = MemoryTaskRepository();
    final TaskController controller = TaskController(repo);
    await controller.load();
    expect(
      await controller.addTask(
        familyId: 'f1',
        title: 'בדיקה',
        assigneeName: 'יוסי',
        priority: TaskPriority.high,
        dueDate: DateTime(2030),
      ),
      isTrue,
    );
    final String id = controller.state.tasks.single.id;
    await controller.toggleCompleted(id);
    expect(controller.state.tasks.single.isCompleted, isTrue);
    await controller.deleteTask(id);
    expect(controller.state.tasks, isEmpty);
  });
}
