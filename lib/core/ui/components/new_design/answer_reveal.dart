import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

class AnswerReveal extends StatelessWidget {
  const AnswerReveal({
    required this.correctLetter,
    required this.explanation,
    this.pickedLetter,
    this.wrongPick,
    super.key,
  });
  final String correctLetter;
  final String explanation;
  final String? pickedLetter;
  final String? wrongPick;
  Widget note(BuildContext context, String letter, String label, String body) =>
      DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.colors.divider,
              width: PantasBorder.hairline,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: PantasSpace.s12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key column 30 (`size-opt-badge-phone`): the letter on an
              // `accent-fill` circle, 15/700 in `on-accent` (Explanation
              // README, `.xpl-phone__key`).
              DecoratedBox(
                key: const ValueKey('answer-reveal-key'),
                decoration: BoxDecoration(
                  color: context.colors.accentFill,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: PantasSize.optBadgePhone,
                  child: Center(
                    child: Text(
                      letter,
                      style: PantasType.phoneExplanation.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1,
                        color: context.colors.onAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: PantasSpace.s12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: PantasType.phoneFootnote.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PantasSpace.s4),
                    MathText(
                      body,
                      style: PantasType.phoneExplanation.copyWith(
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(
          begin: MediaQuery.disableAnimationsOf(context) ? 1 : 0,
          end: 1,
        ),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.short2,
        builder: (context, value, child) => Opacity(
          key: const ValueKey('answer-reveal-opacity'),
          opacity: value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            note(context, correctLetter, 'Correct answer', explanation),
            if (wrongPick != null && pickedLetter != null) ...[
              const SizedBox(height: PantasSpace.s12),
              note(context, pickedLetter!, 'Your pick', wrongPick!),
            ],
          ],
        ),
      );
}
