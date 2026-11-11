import 'dart:async';

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
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_side_drawer.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

// The scrolling passage pane's height on the approved board. The system
// sets the passage column's width but not this pane's height.
// ds-board: approved Quiz board; Passage README sets width only
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
    this.drawer,
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

  /// Opts in to the modal explanation Drawer below 1134 wide (Explanation
  /// README, `bp-focus-split`). Without it the explanation stays a column
  /// beside the question, or under it when the window is too narrow.
  final ExplanationDrawer? drawer;

  @override
  State<WebQuizQuestion> createState() => _WebQuizQuestionState();
}

/// What the explanation Drawer needs from the page that owns the bar: the
/// counter and the bar's action for its foot, and a signal when it opens or
/// closes so the page can hide the bar's main action and return focus to it.
@immutable
class ExplanationDrawer {
  const ExplanationDrawer({
    required this.counter,
    required this.actionLabel,
    required this.onAction,
    this.busy = false,
    this.onOpenChanged,
  });

  /// The foot's counter, such as "4 of 10".
  final String counter;

  /// The label of the foot's button: the bar's Next, Finish or Back.
  final String actionLabel;
  final VoidCallback? onAction;
  final bool busy;

  /// Called after a frame when the Drawer opens (true) or closes (false).
  final ValueChanged<bool>? onOpenChanged;
}

class _WebQuizQuestionState extends State<WebQuizQuestion>
    with TickerProviderStateMixin {
  late final _reveal = AnimationController(
    vsync: this,
    // ds-board: AnswerOption README: reveal timings 560/700 ms
    duration: const Duration(milliseconds: 1840),
    value: widget.checked ? 1 : 0,
  );

  /// With reduced motion the explanation fades in place over 150 ms and does
  /// not slide (Explanation README, Motion).
  late final _fade = AnimationController(
    vsync: this,
    duration: PantasDurations.short2,
    value: widget.checked ? 1 : 0,
    animationBehavior: AnimationBehavior.preserve,
  );

  /// The explanation Drawer is open (below 1134, when [WebQuizQuestion.drawer]
  /// is set).
  bool _drawerOpen = false;

  /// The passage Drawer is open.
  bool _passageOpen = false;

  bool get _split =>
      MediaQuery.sizeOf(context).width >= PantasLayout.bpFocusSplit;

  /// The explanation is a modal Drawer here, not a column.
  bool get _useDrawer => widget.drawer != null && !_split;

  void _setDrawer(bool open) {
    if (_drawerOpen == open) return;
    _drawerOpen = open;
    final changed = widget.drawer?.onOpenChanged;
    if (changed == null) return;
    // The page hides its bar action, so it is told after this frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => changed(open));
  }

  @override
  void didUpdateWidget(WebQuizQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id || !widget.checked) {
      _reveal.value = widget.checked ? 1 : 0;
      _fade.value = widget.checked ? 1 : 0;
      _setDrawer(false);
      _passageOpen = false;
    } else if (!oldWidget.checked) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _reveal.value = 1;
        unawaited(_fade.forward(from: 0));
      } else {
        _fade.value = 1;
        _reveal.forward(from: 0);
      }
      // Opens on reveal (Explanation README).
      if (_useDrawer) _setDrawer(true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) && widget.checked) {
      _reveal.value = 1;
    }
    // At 1134 and up the explanation is a region, not a dialog.
    if (_drawerOpen && !_useDrawer) _setDrawer(false);
  }

  @override
  void dispose() {
    final changed = widget.drawer?.onOpenChanged;
    if (_drawerOpen && changed != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => changed(false));
    }
    _reveal.dispose();
    _fade.dispose();
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
        animation: Listenable.merge([_reveal, _fade]),
        builder: (context, _) => _build(context),
      );

  Widget _build(BuildContext context) {
    final t = context.webTokens;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final passageStyle = PantasType.webReaderBody.copyWith(
      color: t.colors.readerBody,
    );
    final correct = widget.question.correctChoice;
    final wrong = widget.checked && widget.chosenId != correct.id;
    final move = _phase(240, 1200);
    // RV_Reveal moves the column and nothing else: its width stays put, so the
    // stem and the choices do not re-wrap while it slides. The checked width
    // is taken at once and the column starts where the open one stood.
    final useDrawer = _useDrawer;
    final slide = widget.checked && widget.passage == null && !useDrawer;
    final passaged = widget.passage != null;
    final Widget column = SizedBox(
      key: const ValueKey('web-question-column'),
      // The column is 720 wide, 600 while the explanation shows beside it
      // (`layout-qcol`, `layout-qcol-narrow`). Next to a passage it takes the
      // passage column's measure (`layout-passage`).
      width: passaged && !useDrawer
          ? PantasLayout.passage.basis
          : widget.checked && !useDrawer && !passaged
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
          if (widget.checked && useDrawer && !_drawerOpen) ...[
            const SizedBox(height: PantasSpace.s18),
            Align(
              alignment: Alignment.centerLeft,
              child: WebTextLink(
                label: 'Show Explanation',
                arrow: false,
                onPressed: () => setState(() => _setDrawer(true)),
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
    final progress = reduced
        ? _fade.value
        : widget.checked
            ? _enter(880, 880.0 + PantasDurations.reveal.inMilliseconds)
            : 0.0;
    // The column slides in 28 px from the right with a fade over the reveal
    // duration; reduced motion fades it in place over 150 ms.
    final explanation = Opacity(
      key: const ValueKey('web-answer-reveal'),
      opacity: widget.checked ? progress : 0,
      child: Transform.translate(
        offset: Offset(reduced ? 0 : PantasSpace.s28 * (1 - progress), 0),
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: 'Explanation',
          child: SizedBox(
            key: const ValueKey('web-answer-column'),
            width: PantasLayout.xpl,
            child: _explanationBody(context, passageLink: passaged),
          ),
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget layout;
        if (useDrawer) {
          layout = Center(
            child: passaged
                ? SizedBox(
                    width: PantasLayout.qcol,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _collapsedPassage(context, passageStyle),
                        column,
                      ],
                    ),
                  )
                : column,
          );
        } else {
          layout = _inline(
            context,
            constraints,
            passageStyle: passageStyle,
            column: column,
            stage: stage,
            explanation: explanation,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            layout,
            if (widget.drawer != null)
              WebSideDrawer(
                open: _drawerOpen,
                // Focus goes back to the bar's Check or Next, which the page
                // shows again once the Drawer is gone.
                restoreFocus: false,
                headingKey: const ValueKey('explanation-heading'),
                title: 'Explanation',
                closeLabel: 'Close explanation',
                onDismiss: () => setState(() => _setDrawer(false)),
                body: _explanationBody(context, passageLink: false),
                foot: _drawerFoot(context),
              ),
            if (passaged)
              WebSideDrawer(
                open: _passageOpen,
                headingKey: const ValueKey('passage-heading'),
                title: 'Passage',
                closeLabel: 'Close passage',
                onDismiss: () => setState(() => _passageOpen = false),
                body: DefaultTextStyle(
                  style: passageStyle,
                  child: MathText(widget.passage!.body, style: passageStyle),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Eases [start] to [end] (ms of the reveal clock) on `motion-enter`.
  double _enter(double start, double end) => PantasCurves.enter.transform(
        ((_reveal.value * 1840 - start) / (end - start)).clamp(0, 1),
      );

  /// The columns beside the question, at 1134 and up or when no Drawer is
  /// asked for.
  Widget _inline(
    BuildContext context,
    BoxConstraints constraints, {
    required TextStyle passageStyle,
    required Widget column,
    required Widget stage,
    required Widget explanation,
  }) {
    final t = context.webTokens;
    final passaged = widget.passage != null;
    final reading = passaged && !widget.checked;
    // Before the reveal the passage takes the left column. On reveal the
    // explanation replaces it (Passage README), keeping the column's width so
    // the question does not move.
    final left = reading
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
        : passaged
            ? SizedBox(
                width: PantasLayout.qcolNarrow,
                child: Align(alignment: Alignment.topRight, child: explanation),
              )
            : stage;
    final right = passaged
        ? SizedBox(width: PantasLayout.passage.basis, child: column)
        : explanation;
    if (!widget.checked && !passaged) return Center(child: column);
    const leftWidth = PantasLayout.qcolNarrow;
    final rightWidth = passaged ? PantasLayout.passage.basis : PantasLayout.xpl;
    final gap = passaged ? PantasSpace.s40 : PantasSpace.s14;
    if (constraints.maxWidth < leftWidth + rightWidth + gap) {
      // The canvas wraps at smaller desktop widths.
      return Column(
        children: [
          if (passaged && !reading) explanation else left,
          const SizedBox(height: PantasSpace.s40),
          if (passaged) column else right,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        left,
        SizedBox(width: passaged ? gap : gap * _phase(240, 1200)),
        ClipRect(
          child: Align(
            alignment: Alignment.topLeft,
            widthFactor: passaged ? 1 : _phase(240, 1200),
            child: right,
          ),
        ),
      ],
    );
  }

  /// The passage collapsed above the stem below 1134: four lines and a Show
  /// Passage link that opens the whole text in a Drawer.
  Widget _collapsedPassage(BuildContext context, TextStyle style) {
    final t = context.webTokens;
    final lineHeight = MediaQuery.textScalerOf(context)
        .scale(style.fontSize! * (style.height ?? 1));
    return Padding(
      padding: const EdgeInsets.only(bottom: PantasSpace.s8),
      child: WebCard(
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s24,
          vertical: PantasSpace.s20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('PASSAGE', style: t.eb),
            const SizedBox(height: PantasSpace.s12),
            ClipRect(
              child: SizedBox(
                key: const ValueKey('web-passage-collapsed'),
                height: lineHeight * 4,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: DefaultTextStyle(
                    style: style,
                    child: MathText(
                      widget.passage!.body,
                      style: style,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: PantasSpace.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: WebTextLink(
                label: 'Show Passage',
                arrow: false,
                onPressed: () => setState(() => _passageOpen = true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The card of the correct answer, then the Pro "your pick" note as a
  /// separate block after it (the note is a product feature, AGENTS.md).
  Widget _explanationBody(BuildContext context, {required bool passageLink}) {
    final correct = widget.question.correctChoice;
    final picked = widget.question.choices
        .where((c) => c.id == widget.chosenId)
        .firstOrNull;
    final wrong = widget.checked && widget.chosenId != correct.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebCard(
          padding: const EdgeInsets.all(PantasSpace.s24),
          child: _answer(
            context,
            correct.label,
            'correct answer',
            widget.question.explanation,
            false,
            trailing: passageLink
                ? WebTextLink(
                    label: 'Show Passage',
                    arrow: false,
                    onPressed: () => setState(() => _passageOpen = true),
                  )
                : null,
          ),
        ),
        if (wrong && widget.pro && picked?.rationale != null) ...[
          const SizedBox(height: PantasSpace.s14),
          WebCard(
            key: const ValueKey('web-your-pick'),
            padding: const EdgeInsets.all(PantasSpace.s24),
            child: _answer(
              context,
              picked!.label,
              'your pick',
              picked.rationale!,
              true,
            ),
          ),
        ],
        if (wrong && widget.proPaused) ...[
          const SizedBox(height: PantasSpace.s14),
          const ProPausedLine(),
        ],
        if (widget.notes != null) ...[
          const SizedBox(height: PantasSpace.s14),
          widget.notes!,
        ],
      ],
    );
  }

  /// The Drawer's foot (`xpl__foot`): the counter at the left and the bar's
  /// action, Next, at the right.
  Widget _drawerFoot(BuildContext context) {
    final drawer = widget.drawer!;
    return Row(
      children: [
        Text(drawer.counter, style: context.webTokens.sm),
        const Spacer(),
        WebButton(
          key: const ValueKey('explanation-drawer-action'),
          label: drawer.actionLabel,
          busy: drawer.busy,
          onPressed: drawer.onAction,
        ),
      ],
    );
  }

  Widget _answer(
    BuildContext context,
    String letter,
    String label,
    String text,
    bool wrong, {
    Widget? trailing,
  }) {
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
              // ds-board: README type: web-glyph leading 1
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: PantasType.webFieldLabel.copyWith(
                        letterSpacing: PantasType.webFieldLabel.fontSize! * .02,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
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
