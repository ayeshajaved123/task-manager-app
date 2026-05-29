import 'package:flutter/material.dart';

class SyncBadge extends StatelessWidget {
  final bool isSynced;
  const SyncBadge({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSynced ? Icons.cloud_done : Icons.cloud_upload,
          size: 16,
          color: isSynced ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 6),
        Text(isSynced ? 'Synced' : 'Pending', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
