import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A 1.6px ink rule drawn under a section header or plate.
class InkPlateRule extends StatelessWidget {
  const InkPlateRule({super.key});

  static const double height = 1.6;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const Key('inkPlateRule'),
      height: height,
      color: colors.ink,
    );
  }
}
