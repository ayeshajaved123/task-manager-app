import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

class SeverityChip extends StatelessWidget {
  final int severity; // 1,2,3
  const SeverityChip({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      1 => ('Low', AppColors.low),
      2 => ('Medium', AppColors.medium),
      _ => ('High', AppColors.high),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color.withOpacity(0.45)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }
}
