import 'package:flutter/material.dart';

class ProUpgradeChip extends StatelessWidget {
  const ProUpgradeChip({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.lock_open, size: 18),
      onPressed: onTap,
    );
  }
}
