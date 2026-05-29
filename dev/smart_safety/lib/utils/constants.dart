import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Smart Community Safety';

  // Hive Box Names
  static const String hiveBoxUsers = 'users';
  static const String hiveBoxIncidents = 'incidents';
  static const String hiveBoxMessages = 'messages';
  static const String hiveBoxSettings = 'settings';

  // Incident Categories
  static const List<String> incidentCategories = [
    'Theft',
    'Fire',
    'Accident',
    'Suspicious Activity',
    'Medical Emergency',
    'Other'
  ];

  // Severity Levels
  static const Map<int, String> severityLabels = {
    1: 'Low',
    2: 'Medium',
    3: 'High',
  };

  // Colors (as Strings for easy use in maps)
  static const Map<int, String> severityColorHex = {
    1: '#26A69A', // Accent Green
    2: '#FF7043', // Safety Orange
    3: '#EF5350', // Danger Red
  };

  // Convert hex to Color
  static Color getSeverityColor(int severity) {
    final hex = severityColorHex[severity] ?? '#EF5350';
    return Color(int.parse('0xFF${hex.substring(1)}'));
  }

  // SOS Button Size
  static const double sosButtonSize = 70.0;

  // Notification Channel
  static const String notificationChannelId = 'safety_alerts';
  static const String notificationChannelName = 'Community Safety Alerts';
}