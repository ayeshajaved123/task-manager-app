import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/incident.dart';
import '../../providers/incident_provider.dart';

class IncidentDetailScreen extends StatefulWidget {
  const IncidentDetailScreen({super.key, required this.incident});

  final Incident incident;

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  late TextEditingController _category;
  late TextEditingController _description;
  late TextEditingController _lat;
  late TextEditingController _lng;
  int _severity = 1;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _category = TextEditingController(text: widget.incident.category);
    _description = TextEditingController(text: widget.incident.description);
    _lat = TextEditingController(text: widget.incident.lat.toString());
    _lng = TextEditingController(text: widget.incident.lng.toString());
    _severity = widget.incident.severity;
  }

  @override
  void dispose() {
    _category.dispose();
    _description.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  String _sevLabel(int s) {
    if (s >= 3) return 'High';
    if (s == 2) return 'Medium';
    return 'Low';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updated = widget.incident.copyWith(
        category: _category.text.trim(),
        description: _description.text.trim(),
        severity: _severity,
        lat: double.tryParse(_lat.text.trim()) ?? widget.incident.lat,
        lng: double.tryParse(_lng.text.trim()) ?? widget.incident.lng,
      );

      await context.read<IncidentProvider>().updateIncident(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident updated (local-first).')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete incident?'),
        content: const Text('This will remove it from local storage (and cloud if online).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    await context.read<IncidentProvider>().deleteIncidentById(widget.incident.id);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final time = DateTime.fromMillisecondsSinceEpoch(widget.incident.createdAt).toLocal();

    return Scaffold(
      appBar: AppBar(
        title: Text('Incident #${widget.incident.id}'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            onPressed: _saving ? null : _delete,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(widget.incident.isSynced ? Icons.cloud_done : Icons.cloud_off),
                        const SizedBox(width: 8),
                        Text(widget.incident.isSynced ? 'Synced' : 'Pending Sync'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Created', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(time.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _severity,
              decoration: const InputDecoration(
                labelText: 'Severity',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Low')),
                DropdownMenuItem(value: 2, child: Text('Medium')),
                DropdownMenuItem(value: 3, child: Text('High')),
              ],
              onChanged: (v) => setState(() => _severity = v ?? 1),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lat,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lng,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Photos', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (widget.incident.photoPaths.isEmpty)
                      const Text('No photos attached.')
                    else
                      ...widget.incident.photoPaths.map((p) => Text('• $p')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save Changes'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current severity: ${_sevLabel(_severity)}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
