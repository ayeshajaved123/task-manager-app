import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/services/firestore_service.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/services/location_service.dart';
import 'package:smart_community_safety/utils/constants.dart';
import 'package:smart_community_safety/utils/helpers.dart';
import 'package:smart_community_safety/widgets/custom_button.dart';
import 'package:smart_community_safety/widgets/custom_textfield.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_community_safety/services/categorization_service.dart';

class ReportIncidentScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const ReportIncidentScreen({Key? key, this.initialLocation}) : super(key: key);

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  String _selectedCategory = AppConstants.incidentCategories[0];
  int _selectedSeverity = 1;
  List<XFile> _selectedImages = [];
  LatLng? _location;
  bool _isAnonymous = false;
  bool _isLoading = false;
  String? _locationStatus = 'Fetching location...';

  // ✅ AUTO-CATEGORIZATION
  String _autoDetectedCategory = AppConstants.incidentCategories[0];

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      setState(() {
        _location = widget.initialLocation;
        _locationStatus = null;
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await Helpers.requestLocationPermission();
    if (!hasPermission) {
      setState(() {
        _locationStatus = 'Location permission denied';
      });
      return;
    }

    final locationService = LocationService();
    final location = await locationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _location = location;
        _locationStatus = null;
      });
    } else {
      setState(() {
        _locationStatus = 'Unable to get location';
      });
    }
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      Helpers.showSnackbar(context, 'Maximum 3 photos allowed');
      return;
    }
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  // ✅ AUTO-CATEGORIZATION METHOD
  void _autoDetectCategory() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isNotEmpty || description.isNotEmpty) {
      final detected = CategorizationService.autoCategorize(title, description);
      if (AppConstants.incidentCategories.contains(detected)) {
        setState(() {
          _selectedCategory = detected;
          _autoDetectedCategory = detected;
        });
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      Helpers.showSnackbar(context, 'Location is required');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Helpers.showSnackbar(context, 'User not signed in');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final incidentId = const Uuid().v4();
      final timestamp = DateTime.now();

      final incident = IncidentModel(
        id: incidentId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        severity: _selectedSeverity,
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        photoPaths: _selectedImages.map((img) => img.path).toList(),
        reporterId: _isAnonymous ? 'anonymous' : user.uid,
        timestamp: timestamp,
        isAnonymous: _isAnonymous,
        isSynced: false,
      );

      await HiveService.incidentBox.put(incidentId, incident);
      await FirestoreService().syncIncidentToFirestore(incident);

      final syncedIncident = IncidentModel(
        id: incident.id,
        title: incident.title,
        description: incident.description,
        category: incident.category,
        severity: incident.severity,
        latitude: incident.latitude,
        longitude: incident.longitude,
        photoPaths: incident.photoPaths,
        reporterId: incident.reporterId,
        timestamp: incident.timestamp,
        isAnonymous: incident.isAnonymous,
        isSynced: true,
      );

      await HiveService.incidentBox.put(incidentId, syncedIncident);

      if (!mounted) return;
      Helpers.showSnackbar(context, 'Incident reported successfully!');
      Navigator.of(context).pop();
    }
    catch (e, stackTrace) {
      print("🔴 INCIDENT REPORT ERROR: $e");
      print("STACK TRACE: $stackTrace");

      if (e.toString().contains('PERMISSION_DENIED')) {
        Helpers.showSnackbar(context, 'Firestore rules block the request. Check Firebase Console.');
      } else if (e.toString().contains('network') || e.toString().contains('Network')) {
        Helpers.showSnackbar(context, 'No internet. Saved offline.');
        Navigator.of(context).pop();
      } else if (e.toString().contains('TOO_MANY_REQUESTS')) {
        Helpers.showSnackbar(context, 'Too many requests. Try again later.');
      } else {
        Helpers.showSnackbar(context, 'Error: ${e.toString().substring(0, 80)}...');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
                onChanged: (_) => _autoDetectCategory(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.incidentCategories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
                validator: (value) => value == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Severity', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSeverityOption(1, 'Low'),
                      _buildSeverityOption(2, 'Medium'),
                      _buildSeverityOption(3, 'High'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe the incident...',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Description is required' : null,
                    // ✅ ADD ONCHANGED HERE
                    onChanged: (_) => _autoDetectCategory(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Photos (Max 3)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedImages.map((image) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(image.path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImages.remove(image)),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      if (_selectedImages.length < 3)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_locationStatus != null)
                    Text(_locationStatus!, style: const TextStyle(color: Colors.grey)),
                  if (_location != null)
                    Text(
                      '${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      TextButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Refresh Location'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Switch(
                    value: _isAnonymous,
                    onChanged: (value) => setState(() => _isAnonymous = value),
                  ),
                  const Text('Report anonymously'),
                  const Icon(Icons.lock_outline, size: 16),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Submit Report',
                onPressed: _submitReport,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSeverityOption(int severity, String label) {
    final isSelected = _selectedSeverity == severity;
    final color = AppConstants.getSeverityColor(severity);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSeverity = severity),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? color : Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? color.withOpacity(0.2) : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}