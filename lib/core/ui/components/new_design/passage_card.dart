import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class PassageCard extends StatelessWidget {
  const PassageCard({required this.text, this.title, super.key});
  final String text;
  final String? title;
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: context.type.subheadStrong),
            const SizedBox(height: 8),
          ],
          MathText(text, style: context.type.body.copyWith(height: 1.55)),
          const SizedBox(height: 16),
          Container(height: .5, color: context.colors.separator),
        ],
      );
}
