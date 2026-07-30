import 'package:pantas/core/ui/components/progress_rule.dart';
import 'package:flutter/material.dart';

class ReaderRail extends StatelessWidget {
  const ReaderRail({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ProgressRule(value: progress);
  }
}
