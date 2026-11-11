import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The reading text a question refers to (design system: Passage). A
/// `surface-card` with the "Passage" eyebrow, the optional title and the text.
/// Wide screens use radius `radius-xl` and padding 20 by 24 with the 18/1.7
/// reader body; the phone uses `radius-lg`, padding 16 by 18 and 17/1.55.
/// Dark adds the 1px `edge-card` edge.
class PassageCard extends StatelessWidget {
  const PassageCard({required this.text, this.title, super.key});
  final String text;
  final String? title;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = context.wideWeb;
    final radius =
        BorderRadius.circular(wide ? PantasRadius.xl : PantasRadius.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: radius,
        border: Theme.of(context).brightness == Brightness.dark
            ? Border.all(color: c.edgeCard)
            : null,
      ),
      child: Padding(
        padding: wide
            ? const EdgeInsets.symmetric(
                horizontal: PantasSpace.s24,
                vertical: PantasSpace.s20,
              )
            : const EdgeInsets.symmetric(
                horizontal: PantasSpace.s18,
                vertical: PantasSpace.s16,
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'PASSAGE',
              style: PantasType.webEyebrow.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: PantasSpace.s12),
            if (title != null) ...[
              Text(
                title!,
                style: PantasType.phoneExplanation.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: PantasSpace.s8),
            ],
            MathText(
              text,
              style:
                  (wide ? PantasType.webReaderBody : PantasType.phoneReaderBody)
                      .copyWith(color: c.readerBody),
            ),
          ],
        ),
      ),
    );
  }
}
