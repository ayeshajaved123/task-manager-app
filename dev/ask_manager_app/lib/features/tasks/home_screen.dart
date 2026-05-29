import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/task_model.dart';
import 'counter_widget.dart';
import 'task_list_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskModel> _tasks = [];
  bool _isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await StorageService.getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoadingTasks = false;
      });
    }
  }

  Future<void> _addTask(String title) async {
    final newTask = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    setState(() => _tasks.add(newTask));
    await StorageService.saveTasks(_tasks);
  }

  Future<void> _toggleTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      setState(() => _tasks[index] = TaskModel(
        id: task.id,
        title: task.title,
        isCompleted: !task.isCompleted,
      ));
      await StorageService.saveTasks(_tasks);
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    await StorageService.saveTasks(_tasks);
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  _addTask(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _showAddTaskDialog,
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingTasks
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CounterWidget(), // From Day 2
              const SizedBox(height: 20),
              Text(
                'My Tasks (${_tasks.length})',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TaskListWidget(
                tasks: _tasks,
                onToggle: _toggleTask,
                onDelete: _deleteTask,
              ),
            ],
          ),
        ),
      ),
    );
  }
}