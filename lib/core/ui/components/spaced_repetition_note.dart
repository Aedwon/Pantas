import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// What the app is doing with the questions it brings back.
///
/// **Moved out of How you work on 11 August.** That page is about the
/// student's own habits: their archetype, their hours, their tendencies. A
/// general explanation of the scheduler is not about them at all, which is
/// why it read as out of place there.
///
/// It sits in the quiz debrief instead, where the thing being explained has
/// just happened to them.
class SpacedRepetitionNote extends StatelessWidget {
  const SpacedRepetitionNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text.rich(
        TextSpan(
          style: styles.bodyMedium.copyWith(
            color: colors.inkMuted,
            height: 1.4,
          ),
          children: [
            const TextSpan(
              text: 'Pantas shows a question again just before you '
                  'would forget it. The ones you forget fast come '
                  'back often. The ones that stick come back '
                  'rarely, so your time goes where it is needed. '
                  'This is called ',
            ),
            TextSpan(
              text: 'spaced repetition',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
