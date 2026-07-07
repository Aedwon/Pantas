import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// What appears under the choices the moment a student commits.
class AnswerReveal extends StatelessWidget {
  const AnswerReveal({
    required this.question,
    required this.chosenChoiceId,
    required this.proIsActive,
    this.nextReviewIntervalDays,
    super.key,
  });

  final Question question;
  final ChoiceId chosenChoiceId;
  final bool proIsActive;
  final int? nextReviewIntervalDays;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final correct = question.correctChoice.id == chosenChoiceId;
    final chosen = _choiceById(chosenChoiceId);
    final answer = question.correctChoice;
    final rationale = chosen?.rationale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (nextReviewIntervalDays != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.rule,
                  width: AppDimensions.hairline,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    correct ? 'Correct' : 'Not this one',
                    style: styles.displaySmall.copyWith(
                      fontSize: 17,
                      color: correct ? colors.board : colors.rust,
                    ),
                  ),
                ),
                Text(
                  intervalLabel(nextReviewIntervalDays!),
                  style: styles.bodySmall
                      .copyWith(fontSize: 11.5, color: colors.inkMuted),
                ),
              ],
            ),
          ),
        ],
        _MarginalNote(
          letter: answer.label,
          kicker: 'the answer',
          body: question.explanation,
        ),
        // Only on a miss, only for Pro, and only where the content pass has
        // written a rationale. Free sees nothing in its place: a student has
        // just been wrong, and an offer at that moment reads as the app
        // charging for the thing that would have helped.
        if (!correct && proIsActive && rationale != null && chosen != null)
          _MarginalNote(
            letter: chosen.label,
            kicker: 'what you picked',
            body: rationale,
          ),
      ],
    );
  }

  Choice? _choiceById(ChoiceId id) =>
      question.choices.where((choice) => choice.id == id).firstOrNull;
}

/// "back in 9 days", "back tomorrow".
@visibleForTesting
String intervalLabel(int days) =>
    days <= 1 ? 'back tomorrow' : 'back in $days days';

/// A note in the 22px gutter the answer rows already use, so the note for B
/// lines up under B.
///
/// This replaces a tinted panel with a coloured left border and a coloured
/// label, which was rejected on sight as the visual signature of generated
/// output. A marginal note is a print device, it reuses a grid already on the
/// screen, and it needs no new colour.
class _MarginalNote extends StatelessWidget {
  const _MarginalNote({
    required this.letter,
    required this.kicker,
    required this.body,
  });

  final String letter;
  final String kicker;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.ruleFaint,
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              letter,
              style: styles.headlineSmall.copyWith(color: colors.inkMuted),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker,
                  style: styles.bodySmall
                      .copyWith(fontSize: 11.5, color: colors.inkMuted),
                ),
                const SizedBox(height: 4),
                // Explanations carry the same markup stems do.
                PortableTextRenderer(text: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
