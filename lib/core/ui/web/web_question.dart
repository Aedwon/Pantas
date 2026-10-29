import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The question, passage and checked answer share one desktop stage.
class WebQuizQuestion extends StatelessWidget {
  const WebQuizQuestion({
    required this.question,
    required this.subject,
    this.chosenId,
    this.checked = false,
    this.pro = false,
    this.proPaused = false,
    this.passage,
    this.passagePosition,
    this.onPick,
    this.notes,
    super.key,
  });
  final Question question;
  final String subject;
  final String? chosenId;
  final bool checked;
  final bool pro;
  final bool proPaused;
  final Passage? passage;
  final ({int ordinal, int total})? passagePosition;
  final ValueChanged<String>? onPick;
  final Widget? notes;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final correct = question.correctChoice;
    final picked = question.choices.where((c) => c.id == chosenId).firstOrNull;
    final wrong = checked && chosenId != correct.id;
    final column = SizedBox(
      key: const ValueKey('web-question-column'),
      width: checked
          ? 600
          : passage != null
              ? 520
              : 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (passage != null) const SizedBox(height: 22),
          Text(
            passagePosition == null
                ? subject.toUpperCase()
                : '${subject.toUpperCase()} · ${passagePosition!.ordinal} '
                    'OF ${passagePosition!.total} ON THIS PASSAGE',
            style: t.eb,
          ),
          const SizedBox(height: 10),
          DefaultTextStyle(
            style: passage != null
                ? t.qtext.copyWith(fontSize: 25, height: 1.38)
                : t.qtext,
            child: ContentRenderer(
              text: question.stem,
              style: passage != null
                  ? t.qtext.copyWith(fontSize: 25, height: 1.38)
                  : t.qtext,
            ),
          ),
          const SizedBox(height: 28),
          if (question.figureSpecJson != null) ...[
            WebCard(
              padding: const EdgeInsets.all(20),
              child: Theme(
                data: buildLightTheme(web: true),
                child: ColoredBox(
                  color: Colors.white,
                  child: QuestionFigure(specJson: question.figureSpecJson),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
          for (final (index, choice) in question.choices.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            WebAnswerOption(
              letter: choice.label,
              state: checked
                  ? choice.id == correct.id
                      ? WebOptionState.right
                      : choice.id == chosenId
                          ? WebOptionState.wrong
                          : WebOptionState.dimmed
                  : choice.id == chosenId
                      ? WebOptionState.selected
                      : WebOptionState.normal,
              onPressed: onPick == null ? null : () => onPick!(choice.id),
              child: MathText(
                choice.text,
                style: t.style(
                  18,
                  height: 1.4,
                  weight: checked && choice.id == correct.id
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
    final explanation = SizedBox(
      key: const ValueKey('web-answer-column'),
      width: 440,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WebCard(
            radius: 20,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _answer(
                  context,
                  correct.label,
                  'correct answer',
                  question.explanation,
                  false,
                ),
                if (wrong && pro && picked?.rationale != null) ...[
                  const SizedBox(height: 18),
                  Divider(height: 1, color: t.colors.separator),
                  const SizedBox(height: 18),
                  _answer(
                    context,
                    picked!.label,
                    'your pick',
                    picked.rationale!,
                    true,
                  ),
                ],
              ],
            ),
          ),
          if (wrong && proPaused) ...[
            const SizedBox(height: 14),
            const ProPausedLine(),
          ],
          if (notes != null) ...[const SizedBox(height: 14), notes!],
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final splitPassage = passage != null;
        final left = splitPassage
            ? SizedBox(
                width: 600,
                child: WebCard(
                  radius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 22, 28, 14),
                        child: Text('PASSAGE', style: t.eb),
                      ),
                      Divider(height: 1, color: t.colors.separator),
                      SizedBox(
                        height: 560,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
                          child: DefaultTextStyle(
                            style: t.style(17, height: 1.7),
                            child: MathText(
                              passage!.body,
                              style: t.style(17, height: 1.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : column;
        final right = splitPassage
            ? SizedBox(
                width: 520,
                child: Column(
                  children: [
                    column,
                    if (checked) ...[const SizedBox(height: 28), explanation],
                  ],
                ),
              )
            : explanation;
        if (!checked && !splitPassage) return Center(child: column);
        final leftWidth = splitPassage ? 600.0 : 600.0;
        final rightWidth = splitPassage ? 520.0 : 440.0;
        if (constraints.maxWidth < leftWidth + rightWidth + 40) {
          // The canvas wraps at smaller desktop widths.
          return Column(children: [left, const SizedBox(height: 40), right]);
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [left, const SizedBox(width: 40), right],
        );
      },
    );
  }

  Widget _answer(
    BuildContext context,
    String letter,
    String label,
    String text,
    bool wrong,
  ) {
    final t = context.webTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            letter,
            textAlign: TextAlign.center,
            style: t.style(
              15,
              weight: FontWeight.w700,
              color: wrong ? t.colors.wrongText : t.colors.accent,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: t.style(
                  13,
                  weight: FontWeight.w600,
                  color: t.colors.secondaryLabel,
                ),
              ),
              const SizedBox(height: 4),
              DefaultTextStyle(
                style: t.style(16, height: 1.55),
                child: MathText(text, style: t.style(16, height: 1.55)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
