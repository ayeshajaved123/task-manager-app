import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:smart_community_safety/utils/constants.dart';

class Helpers {
  // Request location permission
  static Future<bool> requestLocationPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      status = await Geolocator.requestPermission();
    }
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  // Format timestamp for display
  static String formatTimestamp(DateTime timestamp) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp);
  }

  // Get severity color from int
  static Color getSeverityColor(int severity) {
    return AppConstants.getSeverityColor(severity);
  }

  // Slide right route (consistent navigation)
  static MaterialPageRoute<T> slideRightRoute<T>({required WidgetBuilder builder}) {
    return MaterialPageRoute<T>(
      builder: builder,
      settings: const RouteSettings(),
    );
  }

  // Show snackbar
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}