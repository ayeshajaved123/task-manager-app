import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    final value = await StorageService.getCounter();
    if (mounted) {
      setState(() {
        _counter = value;
        _isLoading = false;
      });
    }
  }

  Future<void> _increment() async {
    setState(() => _counter++);
    await StorageService.saveCounter(_counter);
  }

  Future<void> _decrement() async {
    setState(() => _counter--);
    await StorageService.saveCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Counter (Persistent)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _decrement, color: theme.colorScheme.primary),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$_counter', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _increment, color: theme.colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text('Value persists after app restart', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}