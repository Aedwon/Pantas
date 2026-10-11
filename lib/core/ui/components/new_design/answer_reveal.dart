import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
            top: BorderSide(color: context.colors.separator, width: .5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  letter,
                  textAlign: TextAlign.center,
                  style: context.type.subheadStrong.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.secondaryLabel,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.type.footnote
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 3),
                    MathText(
                      body,
                      style: context.type.subhead.copyWith(height: 1.5),
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
            : const Duration(milliseconds: 140),
        builder: (context, value, child) => Opacity(
          key: const ValueKey('answer-reveal-opacity'),
          opacity: value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            note(context, correctLetter, 'correct answer', explanation),
            if (wrongPick != null && pickedLetter != null) ...[
              const SizedBox(height: 12),
              note(context, pickedLetter!, 'your pick', wrongPick!),
            ],
          ],
        ),
      );
}
