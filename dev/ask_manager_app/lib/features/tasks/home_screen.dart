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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await StorageService.getTasks();
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
      _fadeController.forward();
    }
  }

  Future<void> _addTask(String title) async {
    final newTask = TaskModel(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title);
    setState(() => _tasks.insert(0, newTask));
    await StorageService.saveTasks(_tasks);
    _showSnackbar('Task added');
  }

  Future<void> _toggleTask(TaskModel task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      setState(() => _tasks[idx] = TaskModel(id: task.id, title: task.title, isCompleted: !task.isCompleted));
      await StorageService.saveTasks(_tasks);
      _showSnackbar(task.isCompleted ? 'Marked incomplete' : 'Task completed ✅');
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    setState(() => _tasks.removeWhere((t) => t.id == task.id));
    await StorageService.saveTasks(_tasks);
    _showSnackbar('Task deleted', action: 'Undo');
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Task title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () { if (controller.text.trim().isNotEmpty) { _addTask(controller.text.trim()); Navigator.pop(context); } }, child: const Text('Add'))
        ],
      ),
    );
  }

  void _showSnackbar(String msg, {String? action}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), action: action != null ? SnackBarAction(label: action, onPressed: () {}) : null, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
          IconButton(icon: const Icon(Icons.add_circle), onPressed: _showAddTaskDialog, tooltip: 'Add Task'),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
          opacity: _fadeController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CounterWidget(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Tasks (${_tasks.length})', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    if (_tasks.isNotEmpty)
                      TextButton(
                        onPressed: () { setState(() => _tasks = []); StorageService.saveTasks([]); _showSnackbar('All cleared'); },
                        child: Text('Clear All', style: TextStyle(color: theme.colorScheme.error)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TaskListWidget(tasks: _tasks, onToggle: _toggleTask, onDelete: _deleteTask),
              ],
            ),
          ),
        ),
      ),
    );
  }
}