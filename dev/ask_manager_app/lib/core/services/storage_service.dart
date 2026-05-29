import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _counterKey = 'counter_value';
  static const String _tasksKey = 'task_list';

  // Counter methods
  static Future<int> getCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_counterKey) ?? 0;
  }

  static Future<void> saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, value);
  }

  // Task list methods (for Week 3)
  static Future<List<String>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_tasksKey) ?? [];
  }

  static Future<void> saveTasks(List<String> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_tasksKey, tasks);
  }
}