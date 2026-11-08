import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

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
            Text(
              title!,
              style: PantasType.phoneExplanation.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: PantasSpace.s8),
          ],
          MathText(
            text,
            style: PantasType.phoneReaderBody.copyWith(
              color: context.colors.readerBody,
            ),
          ),
          const SizedBox(height: PantasSpace.s16),
          Container(
            height: PantasBorder.hairline,
            color: context.colors.divider,
          ),
        ],
      );
}
