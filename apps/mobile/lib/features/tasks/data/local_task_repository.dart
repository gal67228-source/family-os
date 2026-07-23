import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/family_task.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  static const String _key = 'family_os_tasks';

  @override
  Future<List<FamilyTask>> loadTasks() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <FamilyTask>[];
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List<Object?>) return <FamilyTask>[];
    return decoded
        .whereType<Map<String, Object?>>()
        .map(FamilyTask.fromJson)
        .toList();
  }

  @override
  Future<void> saveTasks(List<FamilyTask> tasks) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(tasks.map((FamilyTask task) => task.toJson()).toList()),
    );
  }
}
