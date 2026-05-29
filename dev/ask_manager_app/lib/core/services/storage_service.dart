import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/task_model.dart';

class StorageService {
  static const String _counterKey = 'counter_value';
  static const String _tasksKey = 'task_list_json';

  static Future<int> getCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_counterKey) ?? 0;
    } catch (e) {
      return 0; // Explicit return for type safety
    }
  }

  static Future<void> saveCounter(int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_counterKey, value);
    } catch (e) {
      // Silently handle storage error
    }
  }

  static Future<List<TaskModel>> getTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_tasksKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      return []; // Explicit return for type safety
    }
  }

  static Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = tasks.map((task) => task.toJson()).toList();
      await prefs.setString(_tasksKey, jsonEncode(jsonList));
    } catch (e) {
      // Silently handle storage error
    }
  }
}