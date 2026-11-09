import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

// The scrolling passage pane's height on the approved board. The system
// sets the passage column's width but not this pane's height.
// ds-board: passage pane 560 (approved board)
const double _passageHeight = 560;

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
    // ds-board: answer reveal timeline, no token
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

  double _phase(double start, double end) => PantasCurves.move
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
    final passageStyle = PantasType.webReaderBody.copyWith(
      color: t.colors.readerBody,
    );
    final correct = widget.question.correctChoice;
    final picked = widget.question.choices
        .where((c) => c.id == widget.chosenId)
        .firstOrNull;
    final wrong = widget.checked && widget.chosenId != correct.id;
    final move = _phase(240, 1200);
    // RV_Reveal moves the column and nothing else: its width stays put, so the
    // stem and the choices do not re-wrap while it slides. The checked width
    // is taken at once and the column starts where the open one stood.
    final slide = widget.checked && widget.passage == null;
    final passaged = widget.passage != null;
    final Widget column = SizedBox(
      key: const ValueKey('web-question-column'),
      // The column is 720 wide, 600 while the explanation shows beside it
      // (`layout-qcol`, `layout-qcol-narrow`). Next to a passage it takes the
      // passage column's measure (`layout-passage`).
      width: passaged
          ? PantasLayout.passage.basis
          : widget.checked
              ? PantasLayout.qcolNarrow
              : PantasLayout.qcol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (passaged) const SizedBox(height: PantasSpace.s24),
          Text(
            widget.passagePosition == null
                ? widget.subject.toUpperCase()
                : '${widget.subject.toUpperCase()} · '
                    '${widget.passagePosition!.ordinal} '
                    'OF ${widget.passagePosition!.total} ON THIS PASSAGE',
            style: t.eb,
          ),
          const SizedBox(height: PantasSpace.s10),
          DefaultTextStyle(
            style: t.qtext,
            child: ContentRenderer(text: widget.question.stem, style: t.qtext),
          ),
          const SizedBox(height: PantasSpace.s28),
          if (widget.question.figureSpecJson != null) ...[
            WebCard(
              padding: const EdgeInsets.all(PantasSpace.s20),
              child: Theme(
                data: buildLightTheme(web: true),
                child: ColoredBox(
                  color: PantasColors.light.figureBg,
                  child:
                      QuestionFigure(specJson: widget.question.figureSpecJson),
                ),
              ),
            ),
            const SizedBox(height: PantasSpace.s28),
          ],
          for (final (index, choice) in widget.question.choices.indexed) ...[
            if (index > 0) const SizedBox(height: PantasSpace.s12),
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
              child: Builder(
                builder: (context) {
                  final optionState = widget.checked
                      ? choice.id == correct.id
                          ? WebOptionState.right
                          : choice.id == widget.chosenId
                              ? WebOptionState.wrong
                              : WebOptionState.dimmed
                      : choice.id == widget.chosenId
                          ? WebOptionState.selected
                          : WebOptionState.normal;
                  return MathText(
                    choice.text,
                    style: WebAnswerOption.textStyle(context, optionState),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
    final stage = slide
        ? Transform.translate(
            offset: Offset(-60 * (1 - move), 0),
            child: column,
          )
        : column;
    final explanation = Opacity(
      key: const ValueKey('web-answer-reveal'),
      opacity: widget.checked ? _phase(880, 1840) : 0,
      child: Transform.translate(
        offset: Offset(24 * (1 - _phase(880, 1840)), 0),
        child: SizedBox(
          key: const ValueKey('web-answer-column'),
          width: PantasLayout.xpl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WebCard(
                padding: const EdgeInsets.all(PantasSpace.s24),
                child: Column(
                  children: [
                    _answer(
                      context,
                      correct.label,
                      'correct answer',
                      widget.question.explanation,
                      false,
                    ),
                    if (wrong && widget.pro && picked?.rationale != null) ...[
                      const SizedBox(height: PantasSpace.s18),
                      Divider(height: 1, color: t.colors.divider),
                      const SizedBox(height: PantasSpace.s18),
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
              if (wrong && widget.proPaused) ...[
                const SizedBox(height: PantasSpace.s14),
                const ProPausedLine(),
              ],
              if (widget.notes != null) ...[
                const SizedBox(height: PantasSpace.s14),
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
                width: PantasLayout.qcolNarrow,
                child: WebCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          PantasSpace.s28,
                          PantasSpace.s24,
                          PantasSpace.s28,
                          PantasSpace.s14,
                        ),
                        child: Text('PASSAGE', style: t.eb),
                      ),
                      Divider(height: 1, color: t.colors.divider),
                      SizedBox(
                        height: _passageHeight,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(PantasSpace.s28),
                          child: DefaultTextStyle(
                            style: passageStyle,
                            child: MathText(
                              widget.passage!.body,
                              style: passageStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : stage;
        final right = splitPassage
            ? SizedBox(
                width: PantasLayout.passage.basis,
                child: Column(
                  children: [
                    column,
                    if (widget.checked) ...[
                      const SizedBox(height: PantasSpace.s28),
                      explanation,
                    ],
                  ],
                ),
              )
            : explanation;
        if (!widget.checked && !splitPassage) return Center(child: column);
        const leftWidth = PantasLayout.qcolNarrow;
        final rightWidth =
            splitPassage ? PantasLayout.passage.basis : PantasLayout.xpl;
        final gap = splitPassage ? PantasSpace.s40 : PantasSpace.s14;
        if (constraints.maxWidth < leftWidth + rightWidth + gap) {
          // The canvas wraps at smaller desktop widths.
          return Column(
            children: [
              left,
              const SizedBox(height: PantasSpace.s40),
              right,
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            left,
            SizedBox(width: splitPassage ? gap : gap * _phase(240, 1200)),
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
    final c = t.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The key: a filled circle holding the letter (Explanation).
        Container(
          width: PantasSize.optBadge,
          height: PantasSize.optBadge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: wrong ? c.dangerFill : c.accentFill,
          ),
          child: Text(
            letter,
            style: PantasType.webLink.copyWith(
              // ds-board: letter line height 1, centered glyph
              height: 1,
              fontWeight: FontWeight.w700,
              color: wrong ? c.onDanger : c.onAccent,
            ),
          ),
        ),
        const SizedBox(width: PantasSpace.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: PantasType.webFieldLabel.copyWith(
                  letterSpacing: PantasType.webFieldLabel.fontSize! * .02,
                  color: c.textSecondary,
                ),
              ),
              const SizedBox(height: PantasSpace.s4),
              DefaultTextStyle(
                style: _bodyStyle(c),
                child: MathText(text, style: _bodyStyle(c)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  TextStyle _bodyStyle(PantasColors c) =>
      PantasType.webExplanation.copyWith(color: c.readerBody);
}
