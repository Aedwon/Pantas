import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ProPausedLine extends StatelessWidget {
  const ProPausedLine({super.key});

  @override
  Widget build(BuildContext context) => Text(
        'Connect once to keep using Pro.',
        style: context.type.body,
      );
}
