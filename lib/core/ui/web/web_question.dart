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
class WebQuizQuestion extends StatefulWidget {
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
  State<WebQuizQuestion> createState() => _WebQuizQuestionState();
}

class _WebQuizQuestionState extends State<WebQuizQuestion>
    with SingleTickerProviderStateMixin {
  late final _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1840),
    value: widget.checked ? 1 : 0,
  );

  @override
  void didUpdateWidget(WebQuizQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id || !widget.checked) {
      _reveal.value = widget.checked ? 1 : 0;
    } else if (!oldWidget.checked) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _reveal.value = 1;
      } else {
        _reveal.forward(from: 0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) && widget.checked) {
      _reveal.value = 1;
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  double _phase(double start, double end) => const Cubic(.32, .72, 0, 1)
      .transform(((_reveal.value * 1840 - start) / (end - start)).clamp(0, 1));

  // RV_Reveal: badge opacity ends at 35% (37% for the fix), then
  // the scale settles at 38% (40%). Check is at 31% of the 8s comp.
  double _badgeScale({required bool delayed, required bool wrong}) {
    final start = delayed ? 160.0 : 0.0;
    final peak = delayed ? 480.0 : 320.0;
    final end = delayed ? 720.0 : 560.0;
    final top = wrong ? 1.1 : 1.15;
    final ms = _reveal.value * 1840;
    if (ms <= peak) return .4 + (top - .4) * _phase(start, peak);
    return top + (1 - top) * _phase(peak, end);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _reveal,
        builder: (context, _) => _build(context),
      );

  Widget _build(BuildContext context) {
    final t = context.webTokens;
    final correct = widget.question.correctChoice;
    final picked = widget.question.choices
        .where((c) => c.id == widget.chosenId)
        .firstOrNull;
    final wrong = widget.checked && widget.chosenId != correct.id;
    final column = SizedBox(
      key: const ValueKey('web-question-column'),
      width: widget.checked
          ? 720 - 120 * _phase(240, 1200)
          : widget.passage != null
              ? 520
              : 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.passage != null) const SizedBox(height: 22),
          Text(
            widget.passagePosition == null
                ? widget.subject.toUpperCase()
                : '${widget.subject.toUpperCase()} · '
                    '${widget.passagePosition!.ordinal} '
                    'OF ${widget.passagePosition!.total} ON THIS PASSAGE',
            style: t.eb,
          ),
          const SizedBox(height: 10),
          DefaultTextStyle(
            style: widget.passage != null
                ? t.qtext.copyWith(fontSize: 25, height: 1.38)
                : t.qtext,
            child: ContentRenderer(
              text: widget.question.stem,
              style: widget.passage != null
                  ? t.qtext.copyWith(fontSize: 25, height: 1.38)
                  : t.qtext,
            ),
          ),
          const SizedBox(height: 28),
          if (widget.question.figureSpecJson != null) ...[
            WebCard(
              padding: const EdgeInsets.all(20),
              child: Theme(
                data: buildLightTheme(web: true),
                child: ColoredBox(
                  color: Colors.white,
                  child:
                      QuestionFigure(specJson: widget.question.figureSpecJson),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
          for (final (index, choice) in widget.question.choices.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            WebAnswerOption(
              letter: choice.label,
              revealFromSelected: choice.id == widget.chosenId,
              revealProgress: widget.checked
                  ? _phase(
                      wrong && choice.id == correct.id ? 160 : 0,
                      wrong && choice.id == correct.id ? 560 : 400,
                    )
                  : 1,
              badgeProgress: widget.checked
                  ? _phase(
                      wrong && choice.id == correct.id ? 160 : 0,
                      wrong && choice.id == correct.id ? 480 : 320,
                    )
                  : 1,
              badgeScale: widget.checked
                  ? _badgeScale(
                      delayed: wrong && choice.id == correct.id,
                      wrong: choice.id != correct.id,
                    )
                  : 1,
              state: widget.checked
                  ? choice.id == correct.id
                      ? WebOptionState.right
                      : choice.id == widget.chosenId
                          ? WebOptionState.wrong
                          : WebOptionState.dimmed
                  : choice.id == widget.chosenId
                      ? WebOptionState.selected
                      : WebOptionState.normal,
              onPressed: widget.onPick == null
                  ? null
                  : () => widget.onPick!(choice.id),
              child: MathText(
                choice.text,
                style: t.style(
                  18,
                  height: 1.4,
                  weight: widget.checked && choice.id == correct.id
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
    final explanation = Opacity(
      key: const ValueKey('web-answer-reveal'),
      opacity: widget.checked ? _phase(880, 1840) : 0,
      child: Transform.translate(
        offset: Offset(24 * (1 - _phase(880, 1840)), 0),
        child: SizedBox(
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
                    if (wrong && widget.pro && picked?.rationale != null) ...[
                      _answer(
                        context,
                        picked!.label,
                        'your pick',
                        picked.rationale!,
                        true,
                      ),
                      const SizedBox(height: 18),
                      Divider(height: 1, color: t.colors.separator),
                      const SizedBox(height: 18),
                    ],
                    _answer(
                      context,
                      correct.label,
                      'correct answer',
                      widget.question.explanation,
                      false,
                    ),
                  ],
                ),
              ),
              if (wrong && widget.proPaused) ...[
                const SizedBox(height: 14),
                const ProPausedLine(),
              ],
              if (widget.notes != null) ...[
                const SizedBox(height: 14),
                widget.notes!,
              ],
            ],
          ),
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final splitPassage = widget.passage != null;
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
                              widget.passage!.body,
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
                    if (widget.checked) ...[
                      const SizedBox(height: 28),
                      explanation,
                    ],
                  ],
                ),
              )
            : explanation;
        if (!widget.checked && !splitPassage) return Center(child: column);
        const leftWidth = 600.0;
        final rightWidth = splitPassage ? 520.0 : 440.0;
        if (constraints.maxWidth < leftWidth + rightWidth + 40) {
          // The canvas wraps at smaller desktop widths.
          return Column(children: [left, const SizedBox(height: 40), right]);
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            left,
            SizedBox(width: splitPassage ? 40 : 40 * _phase(240, 1200)),
            ClipRect(
              child: Align(
                alignment: Alignment.topLeft,
                widthFactor: splitPassage ? 1 : _phase(240, 1200),
                child: right,
              ),
            ),
          ],
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
