import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/profile_provider.dart';
import '../../providers/incident_provider.dart';
import '../map/location_picker_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _desc = TextEditingController();

  String _category = 'Theft';
  int _severity = 1;

  LatLng _picked = const LatLng(33.6844, 73.0479);
  final List<String> _photoPaths = [];

  final _categories = const [
    'Theft',
    'Harassment',
    'Accident',
    'Violence',
    'Suspicious Activity',
    'Other',
  ];

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (x == null) return;

    setState(() => _photoPaths.add(x.path));
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initial: _picked),
      ),
    );

    if (result is LatLng) {
      setState(() => _picked = result);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<ProfileProvider>();

    // ✅ Permission rule
    if (_severity >= 3 && profile.isVerified == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("High severity reports require verified profile."),
        ),
      );
      return;
    }

    final provider = context.read<IncidentProvider>();

    await provider.createIncident(
      category: _category,
      severity: _severity,
      description: _desc.text.trim(),
      lat: _picked.latitude,
      lng: _picked.longitude,
      photoPaths: List<String>.from(_photoPaths),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.pendingCount > 0
              ? "Saved offline. Will sync when online."
              : "Incident submitted successfully.",
        ),
      ),
    );

    _desc.clear();
    setState(() {
      _severity = 1;
      _category = 'Theft';
      _photoPaths.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final profile = context.watch<ProfileProvider>();

    final bool verified = profile.isVerified;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Incident"),
        actions: [
          TextButton(
            onPressed: () => incidents.sync(),
            child: Text("Sync (${incidents.pendingCount})"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Incident Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _category,
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? 'Other'),
                    decoration: const InputDecoration(labelText: "Category"),
                  ),

                  const SizedBox(height: 14),

                  // ✅ Better UX: if not verified, don't allow selecting High
                  DropdownButtonFormField<int>(
                    value: _severity,
                    items: [
                      const DropdownMenuItem(value: 1, child: Text("Low")),
                      const DropdownMenuItem(value: 2, child: Text("Medium")),
                      DropdownMenuItem(
                        value: 3,
                        enabled: verified,
                        child: Text(
                          verified ? "High" : "High (Verified only)",
                          style: TextStyle(
                            color: verified ? null : Colors.grey,
                            fontWeight: verified ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      final newValue = v ?? 1;

                      if (newValue == 3 && !verified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Verify your profile to report High severity."),
                          ),
                        );
                        return;
                      }

                      setState(() => _severity = newValue);
                    },
                    decoration: const InputDecoration(labelText: "Severity"),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: "Description"),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Description required"
                        : null,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickLocation,
                          icon: const Icon(Icons.map_outlined),
                          label: const Text("Pick Location"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text("Add Photo"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Location: ${_picked.latitude.toStringAsFixed(5)}, ${_picked.longitude.toStringAsFixed(5)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 12),

                  if (_photoPaths.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _photoPaths.map((path) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 18),

                  FilledButton(
                    onPressed: _submit,
                    child: const Text("Submit Report"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
