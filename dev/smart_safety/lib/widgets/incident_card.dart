import 'package:flutter/material.dart';
import 'package:smart_community_safety/models/incident_model.dart';
import 'package:smart_community_safety/utils/helpers.dart';
import 'package:smart_community_safety/models/incident_model.dart';

class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const IncidentCard({
    Key? key,
    required this.incident,
    required this.onTap,
  }) : super(key: key);

  // Map category to built-in Flutter icon
  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Theft':
        return const Icon(Icons.security, color: Colors.orange);
      case 'Fire':
        return const Icon(Icons.local_fire_department, color: Colors.red);
      case 'Accident':
        return const Icon(Icons.car_crash, color: Colors.redAccent);
      case 'Suspicious Activity':
        return const Icon(Icons.remove_red_eye, color: Colors.purple);
      case 'Medical Emergency':
        return const Icon(Icons.medical_services, color: Colors.red);
      case 'Other':
      default:
        return const Icon(Icons.report, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = Helpers.getSeverityColor(incident.severity);
    final categoryIcon = _getCategoryIcon(incident.category);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      clipBehavior: Clip.hardEdge, // ✅ CORRECTED: valid Clip enum
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category icon (built-in)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: categoryIcon,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      incident.title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      incident.category,
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                incident.description.length > 80
                    ? '${incident.description.substring(0, 80)}...'
                    : incident.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                Helpers.formatTimestamp(incident.timestamp),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}