import 'package:flutter/material.dart';

class CollapsedPlanSection extends StatelessWidget {
  const CollapsedPlanSection({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
