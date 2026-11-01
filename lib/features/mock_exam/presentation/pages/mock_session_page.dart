import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_question.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/part_clock.dart';
import 'package:pantas/features/mock_exam/presentation/clock_rule.dart';
import 'package:pantas/features/mock_exam/presentation/proctor_toast.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_proctor_sound.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_dialog.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_panel_tab.dart';

/// A part that has not opened yet, as the question grid lists it.
@immutable
class MockUpcomingPart {
  const MockUpcomingPart({
    required this.number,
    required this.name,
    required this.count,
  });

  /// Counting from one.
  final int number;
  final String name;
  final int count;
}

class MockSessionPage extends StatefulWidget {
  const MockSessionPage({
    required this.state,
    required this.remainingInPart,
    required this.partPosition,
    required this.partTotal,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onAnswer,
    required this.onToggleFlag,
    required this.onPause,
    this.closedPartCount = 0,
    this.upcomingParts = const [],
    this.onGoTo,
    this.questionSubjects = const {},
    this.pauseWarningSeen = false,
    this.onPauseWarningSeenChanged,
    this.onEndPartEarly,
    this.currentPartNumber = 1,
    this.partName = '',
    this.oneBlock = false,
    this.onSubmitExam,
    this.partLength,
    this.examTitle = 'Mock exam',
    super.key,
  });

  final MockSessionInProgress state;

  /// What is left of the open part. The exam's own clock is not shown:
  /// what governs the student is the part they are in.
  final String examTitle;
  final Duration remainingInPart;
  final Duration? partLength;

  /// Where they are within the part, counting from one.
  final int partPosition;
  final int partTotal;

  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onAnswer;
  final VoidCallback onToggleFlag;
  final VoidCallback onPause;

  /// Parts the student can no longer reach. The grid says how many.
  final int closedPartCount;

  /// Parts after this one. The grid lists them dimmed.
  final List<MockUpcomingPart> upcomingParts;

  /// Reports a question's index in the whole exam, counting from zero.
  final ValueChanged<int>? onGoTo;

  /// The subject line above each question of a one-block paper, by question
  /// id. A sectional paper names its part instead.
  final Map<String, String> questionSubjects;
  final bool pauseWarningSeen;
  final ValueChanged<bool>? onPauseWarningSeenChanged;
  final VoidCallback? onEndPartEarly;
  final int currentPartNumber;
  final String partName;
  final bool oneBlock;
  final VoidCallback? onSubmitExam;

  Duration get effectivePartLength =>
      partLength ?? Duration(seconds: state.durationSeconds);

  @override
  State<MockSessionPage> createState() => _MockSessionPageState();
}

class _MockSessionPageState extends State<MockSessionPage> {
  final _proctorSound = MockProctorSound();
  late Duration _previousRemaining;
  int? _proctorToastMinutes;
  Timer? _toastTimer;
  var _gridOpen = false;
  var _widePanelOpen = true;
  var _gridJump = 0;

  @override
  void initState() {
    super.initState();
    _previousRemaining = widget.remainingInPart;
  }

  @override
  void didUpdateWidget(MockSessionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingInPart != oldWidget.remainingInPart) {
      final threshold = callThresholdCrossed(
        before: _previousRemaining,
        after: widget.remainingInPart,
      );
      if (threshold != null) {
        if (context.wideWeb) _proctorSound.play();
        _toastTimer?.cancel();
        setState(() {
          _proctorToastMinutes = threshold;
        });
        _toastTimer = Timer(
            context.wideWeb
                ? const Duration(milliseconds: 2500)
                : proctorToastDisplayDuration, () {
          if (mounted) {
            setState(() {
              _proctorToastMinutes = null;
            });
          }
        });
      }
      _previousRemaining = widget.remainingInPart;
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _proctorSound.dispose();
    super.dispose();
  }

  void _onPausePressed() {
    if (widget.pauseWarningSeen) {
      widget.onPause();
      return;
    }
    var skipWarning = false;
    final dialog = context.wideWeb ? webMockConfirmation : CenteredDialog.new;
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: context.colors.shadow.withValues(alpha: .34),
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, update) => dialog(
            title: "Real exams don't pause.",
            message: 'Use this only when you really have to. The clock stops, '
                "but you won't get this during the real exam.",
            content: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: CheckboxRow(
                title: "Don't show this again",
                selected: skipWarning,
                padding: EdgeInsets.zero,
                onTap: () => update(() => skipWarning = !skipWarning),
              ),
            ),
            inlineActions: true,
            // MK_PauseWarn: 24 px from the screen edge, 10 px between buttons.
            horizontalInset: 24,
            actionGap: 10,
            primaryLabel: 'Pause',
            secondaryLabel: 'Keep Going',
            onCancel: () => Navigator.pop(dialogContext),
            onConfirm: () {
              Navigator.pop(dialogContext);
              if (skipWarning) widget.onPauseWarningSeenChanged?.call(true);
              widget.onPause();
            },
          ),
        ),
      ),
    );
  }

  /// System back acts like pause. Strict mode explains why Back is blocked.
  void _onSystemBack() {
    if (_gridOpen) return;
    if (widget.state.strictMode) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? context.colors.surface
                : context.colors.label,
            content: Text(
              'Strict mode is on. Back is off until you submit.',
              style: context.type.footnote
                  .copyWith(fontSize: 12, color: Colors.white),
            ),
          ),
        );
      return;
    }
    _onPausePressed();
  }

  void _confirmEndPartEarly(BuildContext context) {
    final first = widget.state.currentIndex - widget.partPosition + 1;
    final ids = widget.state.questionIds.skip(first).take(widget.partTotal);
    final blank = ids
        .where((id) => (widget.state.answers[id]?.selectedIndex ?? -1) < 0)
        .length;
    final minutes = widget.remainingInPart.inMinutes;
    final hours = minutes ~/ 60;
    final left =
        hours > 0 ? '$hours hr ${minutes % 60} min' : '$minutes minutes';
    final part = widget.currentPartNumber;
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: context.colors.shadow.withValues(alpha: .34),
        builder: (dialogContext) =>
            (context.wideWeb ? webMockConfirmation : CenteredDialog.new)(
          title: widget.oneBlock ? 'Submit the exam?' : 'End Part $part now?',
          message: widget.oneBlock
              ? 'You have $left left and $blank questions blank. Once you '
                  "submit, your answers can't be changed."
              : 'You have $left left and $blank questions blank. Ending now '
                  'closes Part $part for good, and the time left '
                  "doesn't carry over.",
          primaryLabel: widget.oneBlock ? 'Submit' : 'End Part $part',
          secondaryLabel: 'Keep Working',
          destructive: !context.wideWeb && !widget.oneBlock,
          inlineActions: true,
          // MK_SubmitCSE: 342 px wide (24 px edge), buttons 146 px apart by 10.
          horizontalInset: 24,
          actionGap: 10,
          onCancel: () => Navigator.pop(dialogContext),
          onConfirm: () {
            Navigator.pop(dialogContext);
            (widget.oneBlock ? widget.onSubmitExam : widget.onEndPartEarly)
                ?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final urgency = urgencyFor(widget.remainingInPart);
    final last = widget.partPosition == widget.partTotal;
    final next = last
        ? widget.state.strictMode
            ? null
            : () => _confirmEndPartEarly(context)
        : widget.canGoNext
            ? widget.onNext
            : null;
    final clockColor = switch (urgency) {
      ClockUrgency.ample => c.label,
      ClockUrgency.closing => c.warningText,
      ClockUrgency.last => c.wrongText,
    };
    Widget control(String key, String label, Widget icon, VoidCallback? tap) =>
        Semantics(
          button: true,
          label: label,
          enabled: tap != null,
          child: Opacity(
            opacity: tap == null ? .25 : 1,
            child: InkWell(
              key: ValueKey(key),
              onTap: tap,
              borderRadius: BorderRadius.circular(22),
              child:
                  SizedBox(width: 44, height: 44, child: Center(child: icon)),
            ),
          ),
        );
    if (context.wideWeb) {
      return _wide(
        context,
        next,
        strictLine: widget.state.strictMode && last && !widget.oneBlock,
      );
    }
    final scale = MediaQuery.textScalerOf(context).scale(17);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onSystemBack();
      },
      child: QuestionGridSheet(
        open: _gridOpen,
        onDismiss: () => setState(() => _gridOpen = false),
        mock: true,
        helpText: 'Tap any question in this part to go to it.',
        summary: _gridSummary(),
        parts: _gridParts(),
        onSelected: _goToPartQuestion,
        footer: widget.oneBlock && !widget.state.strictMode
            ? PantasButton(
                label: 'Submit the Exam',
                onPressed: () {
                  setState(() => _gridOpen = false);
                  _confirmEndPartEarly(context);
                },
              )
            : null,
        page: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: (scale * 1.35 + 21).clamp(50.0, double.infinity),
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatRemaining(widget.remainingInPart),
                  style: context.type.subheadStrong.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: clockColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 120,
                  height: 5,
                  child: ClockRule(
                    remaining: widget.remainingInPart,
                    partLength: widget.effectivePartLength,
                  ),
                ),
              ],
            ),
            actions: [
              if (!widget.state.strictMode)
                IconButton(
                  key: const Key('mock-pause'),
                  tooltip: 'Pause',
                  // MK_Paper: a thin two-bar glyph, not the outlined boxes.
                  icon: CustomPaint(
                    size: const Size.square(20),
                    painter: _PhonePauseGlyphPainter(c.label),
                  ),
                  onPressed: _onPausePressed,
                )
              else
                const SizedBox(width: 44),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final counter = '${widget.partPosition} '
                    'of ${widget.partTotal}';
                final counterMetrics = TextPainter(
                  text: TextSpan(
                    text: counter,
                    style: context.type.subheadStrong,
                  ),
                  textScaler: MediaQuery.textScalerOf(context),
                  textDirection: Directionality.of(context),
                )..layout();
                final compact =
                    counterMetrics.width + 176 > constraints.maxWidth - 48;
                final barHeight =
                    compact ? 16 + counterMetrics.height + 8 + 44 : 60.0;
                counterMetrics.dispose();
                final strictMessage =
                    'Part ${widget.currentPartNumber} runs to the end of its '
                    'time. Strict mode is on.';
                // MK_LastQStrict draws the line for a timed part only. A
                // one-block paper has no part to name, and no board draws
                // its line.
                final strictLine =
                    widget.state.strictMode && last && !widget.oneBlock;
                final status = _proctorToastMinutes != null
                    ? proctorCopyFor(_proctorToastMinutes!)
                    : strictLine
                        ? strictMessage
                        : null;
                final statusMetrics = TextPainter(
                  text: TextSpan(
                    text: status ?? '',
                    style: _proctorToastMinutes != null
                        ? context.type.subheadStrong.copyWith(fontSize: 14)
                        : context.type.footnote,
                  ),
                  textScaler: MediaQuery.textScalerOf(context),
                  textDirection: Directionality.of(context),
                )..layout(
                    maxWidth: constraints.maxWidth -
                        (_proctorToastMinutes != null ? 64 : 32),
                  );
                final statusHeight = status == null
                    ? 0
                    : statusMetrics.height +
                        (_proctorToastMinutes != null ? 20 : 0) +
                        12;
                statusMetrics.dispose();
                final prev = control(
                  'mock-prev',
                  'Previous question',
                  Icon(PantasIcons.back, size: 20),
                  widget.canGoPrevious ? widget.onPrevious : null,
                );
                final gridButton = control(
                  'mock-grid',
                  'Questions',
                  // MK_Paper: a 3 x 3 grid of rounded squares.
                  CustomPaint(
                    size: const Size.square(19),
                    painter: _MockGridGlyphPainter(c.label),
                  ),
                  () => setState(() => _gridOpen = true),
                );
                final flagButton = control(
                  'mock-flag',
                  'Flag question',
                  // MK_Paper: a flag on a pole.
                  CustomPaint(
                    size: const Size.square(21),
                    painter: _FlagGlyphPainter(
                      widget.state.flags
                              .contains(widget.state.currentQuestionId)
                          ? c.accent
                          : c.label,
                    ),
                  ),
                  widget.onToggleFlag,
                );
                final nextButton = control(
                  'mock-next',
                  last
                      ? widget.oneBlock
                          ? 'Submit the exam'
                          : 'End part'
                      : 'Next question',
                  Icon(PantasIcons.next, size: 20),
                  next,
                );
                final left = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [prev, gridButton],
                );
                final right = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [flagButton, nextButton],
                );
                final bar = compact
                    ? FloatingBar.content(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              counter,
                              textAlign: TextAlign.center,
                              style: context.type.subheadStrong,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [left, right],
                            ),
                          ],
                        ),
                      )
                    // MK_Paper: previous and next at the edges, the grid and
                    // flag grouped with the counter.
                    : FloatingBar(
                        left: prev,
                        beforeCounter: gridButton,
                        counter: counter,
                        afterCounter: flagButton,
                        right: nextButton,
                      );
                return Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        20,
                        16,
                        barHeight + 50 + statusHeight,
                      ),
                      children: [
                        _PaperSwap(
                          position: widget.state.currentIndex,
                          gridJump: _gridJump,
                          child: _QuestionBody(
                            key: ValueKey(widget.state.currentQuestionId),
                            questionId: widget.state.currentQuestionId,
                            subject: widget.oneBlock
                                ? widget.questionSubjects[
                                        widget.state.currentQuestionId] ??
                                    widget.partName
                                : 'Part ${widget.currentPartNumber} · '
                                    '${widget.partName}',
                            selectedIndex: widget
                                .state
                                .answers[widget.state.currentQuestionId]
                                ?.selectedIndex,
                            onAnswer: widget.onAnswer,
                          ),
                        ),
                      ],
                    ),
                    if (_proctorToastMinutes != null)
                      Positioned(
                        bottom: barHeight + 42,
                        left: 16,
                        right: 16,
                        child: ProctorToast(minutes: _proctorToastMinutes!),
                      )
                    else if (strictLine)
                      Positioned(
                        bottom: barHeight + 42,
                        left: 16,
                        right: 16,
                        child: Text(
                          strictMessage,
                          textAlign: TextAlign.center,
                          style: context.type.footnote
                              .copyWith(color: c.secondaryLabel),
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
                        child: bar,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _wide(
    BuildContext context,
    VoidCallback? next, {
    required bool strictLine,
  }) {
    final t = context.webTokens;
    final part = widget.currentPartNumber;
    final c = t.colors;
    final urgency = urgencyFor(widget.remainingInPart);
    final clockColor = switch (urgency) {
      ClockUrgency.ample => c.label,
      ClockUrgency.closing => c.warningText,
      ClockUrgency.last => c.wrongText
    };
    final ids = _idsInPart.toList();
    final count = ids.where(_isAnswered).length;
    Widget grid(List<String> questionIds, {bool enabled = true}) => Wrap(
          spacing: 7,
          runSpacing: 8,
          children: [
            for (final (i, id) in questionIds.indexed)
              Semantics(
                selected: id == widget.state.currentQuestionId,
                child: SizedBox.square(
                  dimension: 36,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: TextButton(
                          onPressed:
                              enabled ? () => _goToPartQuestion(i + 1) : null,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor:
                                enabled ? c.label : c.tertiaryLabel,
                            backgroundColor: enabled && _isAnswered(id)
                                ? c.separator
                                : c.surface,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: id == widget.state.currentQuestionId
                                    ? c.label
                                    : enabled
                                        ? t.strongDivider
                                        : c.separator,
                                width: id == widget.state.currentQuestionId
                                    ? 2.5
                                    : 1.5,
                              ),
                            ),
                            textStyle: t.style(13, weight: FontWeight.w600),
                          ),
                          child: Text('${i + 1}'),
                        ),
                      ),
                      if (widget.state.flags.contains(id))
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: c.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
    final panel = Container(
      key: const ValueKey('web-mock-panel'),
      width: 300,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(right: BorderSide(color: c.separator)),
      ),
      child: WebMockPanelContents(
        open: _widePanelOpen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          children: [
            Transform.translate(
              offset: const Offset(-10, -8),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 36,
                    child: IconButton(
                      tooltip: 'Hide the question list',
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _widePanelOpen = false),
                      icon: const MockPanelGlyph(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Questions',
                    style: t.style(17, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (!widget.oneBlock && _gridSummary() != null) ...[
              const SizedBox(height: 8),
              Text(_gridSummary()!, style: t.sm),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.oneBlock
                        ? 'WHOLE PAPER'
                        : 'PART $part · '
                            '${widget.partName.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: .26,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.oneBlock
                      ? '$count of ${widget.partTotal} answered'
                      : '$count of ${widget.partTotal}',
                  style: t.sm.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 560),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: grid(ids),
                ),
              ),
            ),
            for (final part in widget.upcomingParts) ...[
              const SizedBox(height: 28),
              Text(
                'PART ${part.number} · ${part.name.toUpperCase()}',
                style: t.eb,
              ),
              const SizedBox(height: 6),
              Text('Opens when this part starts.', style: t.sm),
              const SizedBox(height: 14),
              Opacity(
                opacity: .4,
                child: grid(
                  [
                    for (var i = 0; i < part.count; i++)
                      'upcoming-${part.number}-$i',
                  ],
                  enabled: false,
                ),
              ),
            ],
            if (widget.oneBlock && !widget.state.strictMode) ...[
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: WebButton(
                    label: 'Submit the Exam',
                    onPressed: () => _confirmEndPartEarly(context),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  _LegendDot('Answered', fill: c.separator),
                  _LegendDot(
                    'Blank',
                    ring: t.strongDivider,
                  ),
                  _LegendDot('Flagged', fill: c.accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final question = _QuestionBody(
      questionId: widget.state.currentQuestionId,
      subject: widget.oneBlock
          ? widget.questionSubjects[widget.state.currentQuestionId] ??
              widget.partName
          : 'Part $part · ${widget.partName}',
      selectedIndex:
          widget.state.answers[widget.state.currentQuestionId]?.selectedIndex,
      onAnswer: widget.onAnswer,
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF): widget.onToggleFlag,
        if (!widget.state.strictMode)
          const SingleActivator(LogicalKeyboardKey.keyP): _onPausePressed,
        if (widget.canGoPrevious)
          const SingleActivator(LogicalKeyboardKey.arrowLeft):
              widget.onPrevious,
        if (next != null)
          const SingleActivator(LogicalKeyboardKey.arrowRight): next,
      },
      child: Listener(
        onPointerDown: (_) => _proctorSound.prime(),
        child: Focus(
          autofocus: true,
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent) _proctorSound.prime();
            return KeyEventResult.ignored;
          },
          child: PopScope(
            canPop: false,
            child: Scaffold(
              body: Column(
                children: [
                  SizedBox(
                    height: 72,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(widget.examTitle, style: t.sm),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatRemaining(widget.remainingInPart),
                                style: t.style(
                                  30,
                                  weight: FontWeight.w700,
                                  height: 1.1,
                                  color: clockColor,
                                ),
                              ),
                              Text(
                                _proctorToastMinutes != null
                                    ? proctorCopyFor(
                                        _proctorToastMinutes!,
                                      )
                                    : widget.oneBlock
                                        ? 'left'
                                        : 'left in Part '
                                            '$part',
                                style: t.style(
                                  12,
                                  color: _proctorToastMinutes != null
                                      ? clockColor
                                      : c.tertiaryLabel,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: widget.state.strictMode
                                  ? const SizedBox.shrink()
                                  : WebButton(
                                      label: 'Pause',
                                      icon: CustomPaint(
                                        size: const Size.square(18),
                                        painter: _PauseGlyphPainter(
                                          c.secondaryLabel,
                                        ),
                                      ),
                                      variant: WebButtonVariant.tertiary,
                                      onPressed: _onPausePressed,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: widget.effectivePartLength.inMilliseconds <= 0
                          ? 0
                          : (widget.remainingInPart.inMilliseconds /
                                  widget.effectivePartLength.inMilliseconds)
                              .clamp(0, 1),
                      backgroundColor: c.separator,
                      color: clockColor,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(end: _widePanelOpen ? 1 : 0),
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 460),
                              curve: const Cubic(.32, .72, 0, 1),
                              builder: (context, value, _) => SizedBox(
                                width: 300 * value,
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: 300,
                                    maxWidth: 300,
                                    child: Transform.translate(
                                      offset: Offset(-300 * (1 - value), 0),
                                      child: Offstage(
                                        offstage: value == 0,
                                        child: panel,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                      40,
                                      56,
                                      40,
                                      150,
                                    ),
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 680,
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              question,
                                              Positioned(
                                                top: -8,
                                                right: 0,
                                                child: _FlagButton(
                                                  key: const ValueKey(
                                                    'web-mock-flag',
                                                  ),
                                                  flagged: widget.state.flags
                                                      .contains(
                                                    widget.state
                                                        .currentQuestionId,
                                                  ),
                                                  onPressed:
                                                      widget.onToggleFlag,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: _widePanelOpen ? 48 : 0,
                                    bottom: 28,
                                    child: Column(
                                      children: [
                                        if (strictLine)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Text(
                                              'Part $part runs '
                                              'to the end of its time. '
                                              'Strict mode is on.',
                                              style: t.sm,
                                            ),
                                          ),
                                        WebBottomBar(
                                          compact: true,
                                          gap: 6,
                                          counterPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                          counter: '${widget.partPosition} '
                                              'of ${widget.partTotal}',
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              WebBarArrow(
                                                tooltip: 'Previous question',
                                                onPressed: widget.canGoPrevious
                                                    ? widget.onPrevious
                                                    : null,
                                                icon: Icons.chevron_left,
                                              ),
                                              const SizedBox(width: 6),
                                              const WebKeyHint('←'),
                                            ],
                                          ),
                                          action: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const WebKeyHint('→'),
                                              const SizedBox(width: 6),
                                              WebBarArrow(
                                                tooltip: widget.partPosition ==
                                                        widget.partTotal
                                                    ? widget.oneBlock
                                                        ? 'Submit the exam'
                                                        : 'End part'
                                                    : 'Next question',
                                                onPressed: next,
                                                icon: Icons.chevron_right,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        WebMockPanelTab(
                          hidden: !_widePanelOpen,
                          onPressed: () =>
                              setState(() => _widePanelOpen = true),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int get _firstIndexInPart =>
      widget.state.currentIndex - widget.partPosition + 1;

  Iterable<String> get _idsInPart =>
      widget.state.questionIds.skip(_firstIndexInPart).take(widget.partTotal);

  bool _isAnswered(String id) =>
      (widget.state.answers[id]?.selectedIndex ?? -1) >= 0;

  String? _gridSummary() {
    if (widget.oneBlock) {
      final answered = _idsInPart.where(_isAnswered).length;
      return '$answered of ${widget.partTotal} answered';
    }
    final closed = widget.closedPartCount;
    if (closed == 0) return null;
    if (closed == 1) return 'Part 1 is closed';
    final numbers = [for (var i = 1; i <= closed; i++) '$i'];
    return 'Parts ${numbers.take(closed - 1).join(', ')} and '
        '${numbers.last} are closed';
  }

  List<QuestionGridPart> _gridParts() {
    final first = _firstIndexInPart;
    final ids = _idsInPart.toList();
    final open = QuestionGridPart(
      title: widget.oneBlock
          ? ''
          : 'PART ${widget.currentPartNumber} · '
              '${widget.partName.toUpperCase()}',
      count: widget.oneBlock
          ? null
          : '${ids.where(_isAnswered).length} of ${widget.partTotal}',
      questions: [
        for (var i = 0; i < ids.length; i++)
          GridQuestion(
            number: i + 1,
            state: _isAnswered(ids[i])
                ? GridQuestionState.answered
                : GridQuestionState.unreached,
            current: first + i == widget.state.currentIndex,
            flagged: widget.state.flags.contains(ids[i]),
          ),
      ],
    );
    return [
      open,
      for (final part in widget.upcomingParts)
        QuestionGridPart(
          title: 'PART ${part.number} · ${part.name.toUpperCase()}',
          enabled: false,
          lockedNote: 'Opens when this part starts.',
          questions: [
            for (var i = 1; i <= part.count; i++)
              GridQuestion(number: i, state: GridQuestionState.unreached),
          ],
        ),
    ];
  }

  void _goToPartQuestion(int number) {
    final target = _firstIndexInPart + number - 1;
    if (target != widget.state.currentIndex) setState(() => _gridJump++);
    widget.onGoTo?.call(target);
  }

  String _formatRemaining(Duration remaining) {
    final seconds = remaining.inSeconds.clamp(0, 1 << 31);
    final hours = seconds ~/ 3600;
    final minutes = (seconds ~/ 60) % 60;
    final secs = seconds % 60;
    return '${hours > 0 ? '$hours:' : ''}'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }
}

/// The approved paper slide is mirrored for Previous. Grid selection always
/// crossfades, including when its target happens to be the adjacent question.
class _PaperSwap extends StatefulWidget {
  const _PaperSwap({
    required this.position,
    required this.gridJump,
    required this.child,
  });
  final int position;
  final int gridJump;
  final Widget child;
  @override
  State<_PaperSwap> createState() => _PaperSwapState();
}

class _PaperSwapState extends State<_PaperSwap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _lastGridJump = widget.gridJump;
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _outgoing = null);
        }
      });
  }

  Widget? _outgoing;
  var _lastGridJump = 0;
  var _fade = false;
  var _direction = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) && _outgoing != null) {
      _controller.stop();
      _outgoing = null;
    }
  }

  @override
  void didUpdateWidget(_PaperSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.position == oldWidget.position) return;
    _fade = widget.gridJump != _lastGridJump ||
        (widget.position - oldWidget.position).abs() != 1;
    _lastGridJump = widget.gridJump;
    _direction = widget.position > oldWidget.position ? 1 : -1;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _outgoing = null;
      return;
    }
    _outgoing = oldWidget.child;
    _controller.duration = Duration(milliseconds: _fade ? 200 : 380);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outgoing = _outgoing;
    if (outgoing == null) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _fade
            ? _controller.value
            : const Cubic(.2, .9, .3, 1).transform(_controller.value);
        final distance = _fade ? 0.0 : 40.0 * _direction;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              key: const ValueKey('paper-swap-in'),
              opacity: progress,
              child: Transform.translate(
                offset: Offset(distance * (1 - progress), 0),
                child: widget.child,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Opacity(
                    key: const ValueKey('paper-swap-out'),
                    opacity: 1 - progress,
                    child: Transform.translate(
                      offset: Offset(-distance * progress, 0),
                      child: outgoing,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuestionBody extends ConsumerWidget {
  const _QuestionBody({
    required this.questionId,
    required this.subject,
    required this.selectedIndex,
    required this.onAnswer,
    super.key,
  });

  final String questionId;
  final String subject;
  final int? selectedIndex;
  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydratedAsync = ref.watch(hydratedMockQuestionProvider(questionId));

    firstScreenReady(context, ref, ready: !hydratedAsync.isLoading);
    return hydratedAsync.when(
      data: (hydrated) {
        if (hydrated == null) {
          return errorFor(
            'question',
            () => ref.invalidate(hydratedMockQuestionProvider(questionId)),
          );
        }

        if (context.wideWeb) {
          final choices = hydrated.question.choices;
          return WebQuizQuestion(
            question: hydrated.question,
            subject: subject,
            passage: hydrated.passage,
            chosenId: selectedIndex != null &&
                    selectedIndex! >= 0 &&
                    selectedIndex! < choices.length
                ? choices[selectedIndex!].id
                : null,
            onPick: (id) =>
                onAnswer(choices.indexWhere((choice) => choice.id == id)),
          );
        }
        return QuestionCard(
          key: ValueKey(hydrated.question.id),
          subject: subject,
          stem: hydrated.question.stem,
          passage: hydrated.passage == null
              ? null
              : PassageCard(
                  text: hydrated.passage!.body,
                  title: hydrated.passage!.title.isEmpty
                      ? null
                      : hydrated.passage!.title,
                ),
          figure: hydrated.question.figureSpecJson == null
              ? null
              : QuestionFigure(specJson: hydrated.question.figureSpecJson),
          choices: [
            for (var i = 0; i < hydrated.question.choices.length; i++)
              ChoiceRow(
                letter: hydrated.question.choices[i].label,
                text: hydrated.question.choices[i].text,
                state: selectedIndex == i
                    ? ChoiceRowState.picked
                    : ChoiceRowState.plain,
                onTap: () => onAnswer(i),
              ),
          ],
        );
      },
      loading: () => const SkeletonQuestionPage(),
      error: (e, st) => errorFor(
        'question',
        () => ref.invalidate(hydratedMockQuestionProvider(questionId)),
        error: e,
      ),
    );
  }
}

/// The question's Flag control (board `.btn3`, 36 px, 14 px text).
class _FlagButton extends StatelessWidget {
  const _FlagButton({
    required this.flagged,
    required this.onPressed,
    super.key,
  });
  final bool flagged;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.fromLTRB(10, 0, 8, 0),
        foregroundColor: flagged ? t.colors.accent : t.colors.secondaryLabel,
        overlayColor: Colors.transparent,
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: t.style(14, weight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size.square(17),
            painter: _FlagGlyphPainter(
              flagged ? t.colors.accent : t.colors.secondaryLabel,
            ),
          ),
          const SizedBox(width: 8),
          Text(flagged ? 'Flagged' : 'Flag'),
          const SizedBox(width: 8),
          const WebKeyHint('F'),
        ],
      ),
    );
  }
}

class _FlagGlyphPainter extends CustomPainter {
  const _FlagGlyphPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawLine(Offset(6 * k, 3.2 * k), Offset(6 * k, 20.8 * k), paint)
      ..drawPath(
        Path()
          ..moveTo(6 * k, 4.4 * k)
          ..lineTo(18.2 * k, 4.4 * k)
          ..lineTo(14 * k, 9 * k)
          ..lineTo(18.2 * k, 13.6 * k)
          ..lineTo(6 * k, 13.6 * k),
        paint,
      );
  }

  @override
  bool shouldRepaint(_FlagGlyphPainter old) => old.color != color;
}

/// Phone pause glyph (MK_Paper): two 2.2 px round strokes, `M9 6v12M15 6v12`.
class _PhonePauseGlyphPainter extends CustomPainter {
  const _PhonePauseGlyphPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * k
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(9 * k, 6 * k), Offset(9 * k, 18 * k), paint)
      ..drawLine(Offset(15 * k, 6 * k), Offset(15 * k, 18 * k), paint);
  }

  @override
  bool shouldRepaint(_PhonePauseGlyphPainter old) => old.color != color;
}

/// Phone question-grid glyph (MK_Paper): nine 5.4 px squares, radius 1.2.
class _MockGridGlyphPainter extends CustomPainter {
  const _MockGridGlyphPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()..color = color;
    for (final y in [1.2, 8.6, 16.0]) {
      for (final x in [1.2, 8.6, 16.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x * k, y * k, 5.4 * k, 5.4 * k),
            Radius.circular(1.2 * k),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_MockGridGlyphPainter old) => old.color != color;
}

class _PauseGlyphPainter extends CustomPainter {
  const _PauseGlyphPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()..color = color;
    for (final x in [6.5, 13.9]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * k, 5 * k, 3.6 * k, 14 * k),
          Radius.circular(1.2 * k),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PauseGlyphPainter old) => old.color != color;
}

/// A legend entry: a 10 px dot and its word (board `.hrow`, 12 px).
class _LegendDot extends StatelessWidget {
  const _LegendDot(this.label, {this.fill, this.ring});
  final String label;
  final Color? fill;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: ring == null ? null : Border.all(color: ring!, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: t.style(12, color: t.colors.secondaryLabel)),
      ],
    );
  }
}
