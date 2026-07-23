import '../domain/family_task.dart';

abstract interface class TaskRepository {
  Future<List<FamilyTask>> loadTasks();
  Future<void> saveTasks(List<FamilyTask> tasks);
}
