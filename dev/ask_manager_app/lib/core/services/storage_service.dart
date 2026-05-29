import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/task_model.dart';

class StorageService {
  static const String _counterKey = 'counter_value';
  static const String _tasksKey = 'task_list_json';

  // Counter methods
  static Future<int> getCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_counterKey) ?? 0;
  }

  static Future<void> saveCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, value);
  }

  // Task methods
  static Future<List<TaskModel>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => TaskModel.fromJson(json)).toList();
  }

  static Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(jsonList));
  }
}