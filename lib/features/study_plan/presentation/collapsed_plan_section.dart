import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:flutter/material.dart';

class CollapsedPlanSection extends StatelessWidget {
  const CollapsedPlanSection({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return InkTableRow(title: label);
  }
}
