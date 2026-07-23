import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../families/application/family_controller.dart';
import '../data/local_task_repository.dart';
import '../data/task_repository.dart';
import '../domain/family_task.dart';

class TaskState {
  const TaskState({
    this.tasks = const <FamilyTask>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FamilyTask> tasks;
  final bool isLoading;
  final String? errorMessage;
}

class TaskController extends StateNotifier<TaskState> {
  TaskController(this._repository) : super(const TaskState()) {
    load();
  }

  final TaskRepository _repository;

  Future<void> load() async {
    state = const TaskState(isLoading: true);
    try {
      state = TaskState(tasks: await _repository.loadTasks());
    } catch (_) {
      state = const TaskState(errorMessage: 'לא הצלחנו לטעון משימות.');
    }
  }

  Future<bool> addTask({
    required String familyId,
    required String title,
    required String assigneeName,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    if (title.trim().length < 2) return false;
    final DateTime now = DateTime.now();
    final FamilyTask task = FamilyTask(
      id: now.microsecondsSinceEpoch.toString(),
      familyId: familyId,
      title: title.trim(),
      assigneeName: assigneeName.trim(),
      priority: priority,
      dueDate: dueDate,
      isCompleted: false,
      createdAt: now,
    );
    await _persist(<FamilyTask>[...state.tasks, task]);
    return true;
  }

  Future<void> toggleCompleted(String id) async {
    await _persist(state.tasks.map((FamilyTask task) {
      return task.id == id
          ? task.copyWith(isCompleted: !task.isCompleted)
          : task;
    }).toList());
  }

  Future<void> deleteTask(String id) async {
    await _persist(
      state.tasks.where((FamilyTask task) => task.id != id).toList(),
    );
  }

  Future<void> _persist(List<FamilyTask> tasks) async {
    await _repository.saveTasks(tasks);
    state = TaskState(tasks: tasks);
  }
}

final Provider<TaskRepository> taskRepositoryProvider =
    Provider<TaskRepository>((Ref ref) => LocalTaskRepository());

final StateNotifierProvider<TaskController, TaskState> taskControllerProvider =
    StateNotifierProvider<TaskController, TaskState>(
  (Ref ref) => TaskController(ref.watch(taskRepositoryProvider)),
);

final Provider<List<FamilyTask>> activeFamilyTasksProvider =
    Provider<List<FamilyTask>>((Ref ref) {
  final String? familyId = ref.watch(familyControllerProvider).activeFamilyId;
  final List<FamilyTask> tasks = ref.watch(taskControllerProvider).tasks;
  if (familyId == null) return <FamilyTask>[];
  final List<FamilyTask> result = tasks
      .where((FamilyTask task) => task.familyId == familyId)
      .toList()
    ..sort((FamilyTask a, FamilyTask b) => a.dueDate.compareTo(b.dueDate));
  return result;
});
