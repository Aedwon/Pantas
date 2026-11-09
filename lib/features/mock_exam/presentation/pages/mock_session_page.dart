import 'dart:async';
import 'dart:math' as math;

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
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_timer.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/own/mock_panel_glyph.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_question.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/part_clock.dart';
import 'package:pantas/features/mock_exam/presentation/mock_clock.dart';
import 'package:pantas/features/mock_exam/presentation/proctor_toast.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_proctor_sound.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_toast.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/question_navigator_chip.dart';
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

/// The question list's bottom reserve (MK_NavMotion): the system sets no
/// token for it.
const _panelBottomReserve = 120.0;

/// The tallest the question list grows before it scrolls (board height).
const _gridMaxHeight = 560.0;

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
    this.partNames = const [],
    this.partStarted = false,
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

  /// Every part of a paper timed part by part, in order. Empty for any other
  /// paper. When it is set the paper follows the by-part board: the part is
  /// under the clock on the phone, a closed part is not listed, and a later
  /// part is a faded grid.
  final List<String> partNames;

  /// A strict part the server started by itself, as the board says it:
  /// "Part N started" in place of the usual caption.
  final bool partStarted;
  final VoidCallback? onSubmitExam;

  Duration get effectivePartLength =>
      partLength ?? Duration(seconds: state.durationSeconds);

  bool get _byPart => partNames.isNotEmpty;

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

  bool get _byPart => widget._byPart;

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
        barrierColor: context.colors.scrim,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, update) => dialog(
            title: "Real exams don't pause.",
            message: 'Use this only when you really have to. The clock stops, '
                "but you won't get this during the real exam.",
            content: CheckboxRow(
              title: "Don't show this again",
              selected: skipWarning,
              padding: EdgeInsets.zero,
              onTap: () => update(() => skipWarning = !skipWarning),
            ),
            inlineActions: true,
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
      showMockToast(
        context,
        'Strict mode is on. Back is off until you submit.',
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
    final left = hours > 0
        ? '$hours hr ${minutes % 60} min'
        : '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    final blankWords = '$blank ${blank == 1 ? 'question' : 'questions'}';
    final part = widget.currentPartNumber;
    unawaited(
      showDialog<void>(
        context: context,
        barrierColor: context.colors.scrim,
        builder: (dialogContext) =>
            (context.wideWeb ? webMockConfirmation : CenteredDialog.new)(
          title: widget.oneBlock ? 'Submit the exam?' : 'End Part $part now?',
          message: widget.oneBlock
              ? 'You have $left left and $blankWords blank. Once you '
                  "submit, your answers can't be changed."
              : 'You have $left left and $blankWords blank. Ending now '
                  'closes Part $part for good, and the time left '
                  "doesn't carry over.",
          primaryLabel: widget.oneBlock ? 'Submit' : 'End Part $part',
          secondaryLabel: 'Keep Working',
          destructive: !context.wideWeb && !widget.oneBlock,
          inlineActions: true,
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

  /// The clock, in the system Timer. Under five minutes it takes the warning
  /// look (time and bar in `warning-text`, a visible tag); red stays for wrong
  /// answers. [inline] puts the time and a short bar on one line (the wide
  /// header, D151).
  Widget _timer({required bool inline}) {
    final warning = urgencyFor(widget.remainingInPart) != ClockUrgency.ample;
    // A node of its own, so the clock keeps its name beside the title.
    return Semantics(
      container: true,
      child: PantasTimer(
        inline: inline,
        // The proctor call (status role) already speaks the five-minute
        // warning, as before the redesign.
        announceWarning: false,
        timeText: formatMockRemaining(widget.remainingInPart),
        fractionLeft: remainingFraction(
          partLength: widget.effectivePartLength,
          remaining: widget.remainingInPart,
        ),
        state: warning ? PantasTimerState.warning : PantasTimerState.running,
      ),
    );
  }

  /// The question's Flag control. One header button at every width (D138):
  /// 36 high, tertiary, with the F key hint where a keyboard shows hints.
  Widget _flagControl({required Key key}) {
    final flagged = widget.state.flags.contains(widget.state.currentQuestionId);
    return Semantics(
      container: true,
      button: true,
      toggled: flagged,
      label: 'Flag question',
      excludeSemantics: true,
      onTap: widget.onToggleFlag,
      child: WebButton(
        key: key,
        label: flagged ? 'Flagged' : 'Flag',
        size: PantasButtonSize.xs,
        kind: PantasButtonKind.tertiary,
        tone: flagged ? PantasButtonTone.accent : null,
        icon: Icon(
          flagged ? PantasIcons.flagFill : PantasIcons.flag,
          size: PantasSize.icon,
        ),
        keyHint: 'F',
        onPressed: widget.onToggleFlag,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = widget.partPosition == widget.partTotal;
    final next = last
        ? widget.state.strictMode
            ? null
            : () => _confirmEndPartEarly(context)
        : widget.canGoNext
            ? widget.onNext
            : null;
    if (context.wideWeb) {
      return _wide(
        context,
        next,
        strictLine: widget.state.strictMode && last && !widget.oneBlock,
      );
    }
    return _phone(context, next, last: last);
  }

  /// Below 1024 wide (D170): the phone layout, built from the quiz's phone
  /// parts. A header with the clock and Pause, the question with its Flag in
  /// the question header, and the sticky floating bar with Previous, the
  /// question list, the counter and Next. The same controls and effects as
  /// the wide layout.
  Widget _phone(
    BuildContext context,
    VoidCallback? next, {
    required bool last,
  }) {
    final c = context.colors;
    final counter = '${widget.partPosition} of ${widget.partTotal}';
    final strictMessage = 'Part ${widget.currentPartNumber} runs to the end of '
        'its time. Strict mode is on.';
    // MK_LastQStrict draws the line for a timed part only. A one-block paper
    // has no part to name, and no board draws its line.
    final strictLine = widget.state.strictMode && last && !widget.oneBlock;
    final prev = PantasIconButton(
      key: const ValueKey('mock-prev'),
      tooltip: 'Previous question',
      glyph: PantasIcons.back,
      onPressed: widget.canGoPrevious ? widget.onPrevious : null,
    );
    final gridButton = PantasIconButton(
      key: const ValueKey('mock-grid'),
      tooltip: 'Questions',
      icon: PantasIcons.questionsSheet,
      onPressed: () => setState(() => _gridOpen = true),
    );
    final nextButton = PantasIconButton(
      key: const ValueKey('mock-next'),
      tooltip: last
          ? widget.oneBlock
              ? 'Submit the exam'
              : 'End part'
          : 'Next question',
      glyph: PantasIcons.next,
      onPressed: next,
    );
    final subject = widget.oneBlock
        ? widget.questionSubjects[widget.state.currentQuestionId] ??
            widget.partName
        : 'Part ${widget.currentPartNumber} · ${widget.partName}';
    final counterStyle = PantasType.webLink.copyWith(
      color: c.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final header = ConstrainedBox(
      key: const ValueKey('mock-header'),
      constraints: const BoxConstraints(minHeight: PantasLayout.focusHeadPhone),
      child: Padding(
        // Phone header sides are 4 and 8 (FocusHeader, R4R-O01).
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s4,
          PantasSpace.s4,
          PantasSpace.s8,
          PantasSpace.s4,
        ),
        child: Row(
          children: [
            const SizedBox(width: PantasSize.iconBtn),
            Expanded(
              child: Center(
                child: _byPart
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _timer(inline: false),
                          // Board PaperPh: the part is under the clock.
                          Text(
                            widget.partStarted
                                ? 'Part ${widget.currentPartNumber} started'
                                : 'Part ${widget.currentPartNumber} · '
                                    '${widget.partName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PantasType.webSmall.copyWith(
                              color: widget.partStarted
                                  ? c.accent
                                  : c.textSecondary,
                              fontWeight: widget.partStarted
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    : _timer(inline: false),
              ),
            ),
            if (!widget.state.strictMode)
              PantasIconButton(
                key: const Key('mock-pause'),
                tooltip: 'Pause',
                glyph: PantasIcons.pause,
                onPressed: _onPausePressed,
              )
            else
              const SizedBox(width: PantasSize.iconBtn),
          ],
        ),
      ),
    );
    final status = _proctorToastMinutes != null
        ? ProctorToast(minutes: _proctorToastMinutes!)
        : strictLine
            ? Text(
                strictMessage,
                textAlign: TextAlign.center,
                style: PantasType.webSmall.copyWith(color: c.textSecondary),
              )
            : null;
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
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                header,
                // The question header (subject and Flag, D138) is pinned, so
                // a long passage never scrolls the Flag off screen.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasLayout.gutterPhone,
                    PantasSpace.s8,
                    PantasLayout.gutterPhone,
                    PantasSpace.s0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        // Board PaperPh: the part is under the clock, so the
                        // question has no eyebrow, until the part starts by
                        // itself and the board draws both.
                        child: !_byPart || widget.partStarted
                            ? Text(
                                subject.toUpperCase(),
                                style: PantasType.phoneSectionHeader
                                    .copyWith(color: c.textSecondary),
                              )
                            : const SizedBox.shrink(),
                      ),
                      _flagControl(key: const ValueKey('mock-flag')),
                    ],
                  ),
                ),
                // The bar is sticky at the end of the screen, so a stacked bar
                // at large text takes its own height and never covers the
                // last option (FloatingBar, phone).
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      PantasLayout.gutterPhone,
                      PantasSpace.s20,
                      PantasLayout.gutterPhone,
                      PantasSpace.s24,
                    ),
                    children: [
                      _PaperSwap(
                        position: widget.state.currentIndex,
                        gridJump: _gridJump,
                        child: _QuestionBody(
                          key: ValueKey(widget.state.currentQuestionId),
                          questionId: widget.state.currentQuestionId,
                          subject: subject,
                          selectedIndex: widget
                              .state
                              .answers[widget.state.currentQuestionId]
                              ?.selectedIndex,
                          onAnswer: widget.onAnswer,
                          pinnedHeader: true,
                          showSubject: !_byPart || widget.partStarted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PantasLayout.gutterPhone,
                      PantasSpace.s0,
                      PantasLayout.gutterPhone,
                      PantasSpace.s8,
                    ),
                    child: status,
                  ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // The counter stacks above the buttons when it does not
                    // fit beside them (large text).
                    final counterMetrics = TextPainter(
                      text: TextSpan(text: counter, style: counterStyle),
                      textScaler: MediaQuery.textScalerOf(context),
                      textDirection: Directionality.of(context),
                    )..layout();
                    final needed = counterMetrics.width +
                        3 * PantasSize.iconBtn +
                        2 * PantasSpace.s12;
                    final available = constraints.maxWidth -
                        2 * PantasLayout.gutterPhone -
                        2 * PantasSpace.s8;
                    counterMetrics.dispose();
                    final bar = needed > available
                        ? FloatingBar.content(
                            radius: PantasRadius.xl,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  counter,
                                  textAlign: TextAlign.center,
                                  style: counterStyle,
                                ),
                                const SizedBox(height: PantasSpace.s8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [prev, gridButton],
                                    ),
                                    nextButton,
                                  ],
                                ),
                              ],
                            ),
                          )
                        // MK_Paper: previous and the question list at the left,
                        // the counter in the middle, next at the right.
                        : FloatingBar(
                            left: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [prev, gridButton],
                            ),
                            counter: counter,
                            right: nextButton,
                          );
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        PantasLayout.gutterPhone,
                        PantasSpace.s0,
                        PantasLayout.gutterPhone,
                        math.max(
                          PantasLayout.barBottomPhone,
                          MediaQuery.viewPaddingOf(context).bottom +
                              PantasSpace.s8,
                        ),
                      ),
                      child: bar,
                    );
                  },
                ),
              ],
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
    final ids = _idsInPart.toList();
    final count = ids.where(_isAnswered).length;
    // QuestionNavigator chip: blank is a `border-control` ring on the card;
    // answered is the `divider` fill with no ring; the current one has the
    // heavy `text-primary` ring; a flag is an `accent` dot on any state.
    Widget grid(List<String> questionIds, {bool enabled = true}) => Wrap(
          spacing: PantasSpace.s8,
          runSpacing: PantasSpace.s8,
          children: [
            for (final (i, id) in questionIds.indexed)
              Builder(
                builder: (context) {
                  final current = id == widget.state.currentQuestionId;
                  final answered = enabled && _isAnswered(id);
                  final flagged = widget.state.flags.contains(id);
                  final name = !enabled
                      ? 'Question ${i + 1}, locked'
                      : 'Question ${i + 1}'
                          '${current ? ', current' : ''}'
                          ', ${answered ? 'answered' : 'blank'}'
                          '${flagged ? ', flagged' : ''}';
                  return QuestionNavigatorChip(
                    number: i + 1,
                    name: name,
                    enabled: enabled,
                    answered: answered,
                    current: current,
                    flagged: flagged,
                    onTap: () => _goToPartQuestion(i + 1),
                  );
                },
              ),
          ],
        );
    Widget faded(MockUpcomingPart part) => Opacity(
          opacity: PantasOpacity.disabled,
          child: grid(
            [
              for (var i = 0; i < part.count; i++) 'upcoming-${part.number}-$i',
            ],
            enabled: false,
          ),
        );
    final panel = Container(
      key: const ValueKey('web-mock-panel'),
      width: PantasLayout.qpanel,
      decoration: BoxDecoration(color: c.bgPage),
      child: WebMockPanelContents(
        open: _widePanelOpen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s24,
            PantasSpace.s24,
            PantasSpace.s24,
            _panelBottomReserve,
          ),
          children: [
            Row(
              children: [
                Expanded(child: Text('Questions', style: t.h3)),
                PantasIconButton(
                  tooltip: 'Hide the question list',
                  size: PantasIconButtonSize.md,
                  icon: const MockPanelGlyph(),
                  onPressed: () => setState(() => _widePanelOpen = false),
                ),
              ],
            ),
            // Board Paper: a closed part is not listed on a paper by part.
            if (!widget.oneBlock && !_byPart && _gridSummary() != null) ...[
              const SizedBox(height: PantasSpace.s8),
              Text(_gridSummary()!, style: t.sm),
            ],
            const SizedBox(height: PantasSpace.s16),
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
                    style: t.eb,
                  ),
                ),
                const SizedBox(width: PantasSpace.s8),
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
            const SizedBox(height: PantasSpace.s8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _gridMaxHeight),
              // MK_SubmitCSE: cells fade out where more of the list is
              // hidden past the top or the bottom edge.
              child: _ScrollEdgeFade(
                builder: (controller) => SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.only(top: PantasSpace.s2),
                    child: grid(ids),
                  ),
                ),
              ),
            ),
            if (_byPart && widget.partStarted) ...[
              // Board Paper, break ran out: the other parts, done or still to
              // open, as a list.
              const SizedBox(height: PantasSpace.s24),
              for (final (i, name) in widget.partNames.indexed)
                if (i != part - 1)
                  _PartListRow(number: i + 1, name: name, done: i < part - 1),
            ] else
              for (final part in widget.upcomingParts) ...[
                const SizedBox(height: PantasSpace.s28),
                Text(
                  'PART ${part.number} · ${part.name.toUpperCase()}',
                  style: t.eb,
                ),
                const SizedBox(height: PantasSpace.s6),
                Text('Opens when this part starts.', style: t.sm),
                const SizedBox(height: PantasSpace.s14),
                // Board Paper: a later part is a faded grid cut at 120 px.
                if (_byPart)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ClipRect(child: faded(part)),
                  )
                else
                  faded(part),
              ],
            if (widget.oneBlock && !widget.state.strictMode) ...[
              const SizedBox(height: PantasSpace.s28),
              // MK_SubmitCSE: the button fills the panel's width.
              SizedBox(
                width: double.infinity,
                child: WebButton(
                  label: 'Submit the Exam',
                  expand: true,
                  onPressed: () => _confirmEndPartEarly(context),
                ),
              ),
            ],
            const SizedBox(height: PantasSpace.s20),
            Padding(
              padding: const EdgeInsets.only(top: PantasSpace.s4),
              child: Wrap(
                spacing: PantasSpace.s14,
                runSpacing: PantasSpace.s4,
                children: [
                  _LegendDot('Answered', fill: c.divider),
                  _LegendDot('Blank', ring: c.borderControl),
                  _LegendDot('Flagged', fill: c.accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final question = _PaperSwap(
      position: widget.state.currentIndex,
      gridJump: _gridJump,
      child: _QuestionBody(
        key: ValueKey(widget.state.currentQuestionId),
        questionId: widget.state.currentQuestionId,
        subject: widget.oneBlock
            ? widget.questionSubjects[widget.state.currentQuestionId] ??
                widget.partName
            // Board Paper, break ran out: the header and the list name the
            // part, so the question carries no eyebrow.
            : widget.partStarted
                ? ''
                : 'Part $part · ${widget.partName}',
        selectedIndex:
            widget.state.answers[widget.state.currentQuestionId]?.selectedIndex,
        onAnswer: widget.onAnswer,
      ),
    );
    // FocusHeader (wide): a 64 high bar. The exam name at the left, the
    // clock (Timer, inline) with what it counts, and Pause at the right.
    final proctor = _proctorToastMinutes != null;
    final header = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PantasLayout.focusHead),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s20,
          vertical: PantasSpace.s8,
        ),
        child: Row(
          children: [
            Expanded(
              child: widget.partStarted
                  // Board Paper, break ran out: the part line sits under the
                  // exam's name.
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.examTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PantasType.webRowSub
                              .copyWith(color: c.textSecondary),
                        ),
                        Text(
                          'Part $part of ${widget.partNames.length} · '
                          '${widget.partName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              PantasType.webLink.copyWith(color: c.textPrimary),
                        ),
                      ],
                    )
                  : Text(
                      widget.examTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          PantasType.webRowSub.copyWith(color: c.textSecondary),
                    ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _timer(inline: true),
                Text(
                  proctor
                      ? proctorCopyFor(_proctorToastMinutes!)
                      : widget.partStarted
                          ? 'Part $part started'
                          : widget.oneBlock
                              ? 'left'
                              : 'left in Part $part',
                  style: PantasType.webCaption.copyWith(
                    color: proctor
                        ? c.warningText
                        : widget.partStarted
                            ? c.accent
                            : c.textSecondary,
                    fontWeight: widget.partStarted && !proctor
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: widget.state.strictMode || widget.partStarted
                    ? const SizedBox.shrink()
                    : WebButton(
                        label: 'Pause',
                        icon: Icon(PantasIcons.pause, size: PantasSize.icon),
                        variant: WebButtonVariant.tertiary,
                        onPressed: _onPausePressed,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF): widget.onToggleFlag,
        // A to E pick a choice, as on the assessment. The count comes from
        // the question the page shows.
        ...answerKeyBindings(
          choiceCount: () =>
              ProviderScope.containerOf(context, listen: false)
                  .read(
                    hydratedMockQuestionProvider(
                      widget.state.currentQuestionId,
                    ),
                  )
                  .valueOrNull
                  ?.question
                  .choices
                  .length ??
              0,
          onPick: widget.onAnswer,
        ),
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
        child: KeyFocusKeeper(
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent) _proctorSound.prime();
            return KeyEventResult.ignored;
          },
          child: PopScope(
            canPop: false,
            // Browser Back reaches here through the route's `onExit`. It acts
            // as the phone's Back does: ask to pause, or explain strict mode.
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _onSystemBack();
            },
            child: Scaffold(
              body: Column(
                children: [
                  header,
                  Expanded(
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(end: _widePanelOpen ? 1 : 0),
                              duration: _panelMotion,
                              curve: PantasCurves.move,
                              builder: (context, value, _) => SizedBox(
                                width: PantasLayout.qpanel * value,
                                child: ClipRect(
                                  child: OverflowBox(
                                    alignment: Alignment.centerLeft,
                                    minWidth: PantasLayout.qpanel,
                                    maxWidth: PantasLayout.qpanel,
                                    child: Transform.translate(
                                      offset: Offset(
                                        -PantasLayout.qpanel * (1 - value),
                                        0,
                                      ),
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
                                      PantasSpace.s40,
                                      PantasSpace.s56,
                                      PantasSpace.s40,
                                      PantasLayout.reserveBar,
                                    ),
                                    children: [
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: PantasLayout.qcol,
                                          ),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              question,
                                              Positioned(
                                                top: -PantasSpace.s8,
                                                right: 0,
                                                child: _flagControl(
                                                  key: const ValueKey(
                                                    'web-mock-flag',
                                                  ),
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
                                    right: 0,
                                    bottom: PantasLayout.barBottom,
                                    // While the list is open the bar is
                                    // narrower (MK_NavMotion) by this much on
                                    // each side, so it stays centered under
                                    // the question column. The inset moves
                                    // with the list, not before it.
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        end: _widePanelOpen
                                            ? PantasSpace.s24
                                            : PantasSpace.s0,
                                      ),
                                      duration: _panelMotion,
                                      curve: PantasCurves.move,
                                      builder: (context, inset, child) =>
                                          Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: inset,
                                        ),
                                        child: child,
                                      ),
                                      child: Column(
                                        children: [
                                          if (strictLine)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: PantasSpace.s12,
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
                                            gap: PantasSpace.s6,
                                            counterPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: PantasSpace.s14,
                                            ),
                                            counter: '${widget.partPosition} '
                                                'of ${widget.partTotal}',
                                            leading: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                WebBarArrow(
                                                  tooltip: 'Previous question',
                                                  onPressed:
                                                      widget.canGoPrevious
                                                          ? widget.onPrevious
                                                          : null,
                                                  icon: Icons.chevron_left,
                                                ),
                                                const SizedBox(
                                                  width: PantasSpace.s6,
                                                ),
                                                const WebKeyHint('←'),
                                              ],
                                            ),
                                            action: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const WebKeyHint('→'),
                                                const SizedBox(
                                                  width: PantasSpace.s6,
                                                ),
                                                WebBarArrow(
                                                  tooltip: widget
                                                              .partPosition ==
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

  /// How long the question list takes to open or close, and the bar's inset
  /// with it.
  Duration get _panelMotion => MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : PantasDurations.navPanel;

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
    _controller.duration =
        _fade ? PantasDurations.nudge : PantasDurations.slide;
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
            : PantasCurves.enter.transform(_controller.value);
        final distance = _fade ? 0.0 : PantasSpace.s40 * _direction;
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
    this.pinnedHeader = false,
    this.showSubject = true,
    super.key,
  });

  final String questionId;
  final String subject;

  /// False draws the phone question with no eyebrow.
  final bool showSubject;
  final int? selectedIndex;
  final ValueChanged<int> onAnswer;

  /// The phone page pins the subject and Flag row (D138) above its scroll
  /// view, so the card leaves that row out.
  final bool pinnedHeader;

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
          showHeader: !pinnedHeader,
          showSubject: showSubject,
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

/// One other part in the list beside the question (board Paper, break ran
/// out): a closed part is a filled check, a part still to open an empty ring
/// with the line that says when it opens.
class _PartListRow extends StatelessWidget {
  const _PartListRow({
    required this.number,
    required this.name,
    required this.done,
  });
  final int number;
  final String name;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PantasSpace.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: PantasSpace.s2),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? c.accentFill : null,
                border: done
                    ? null
                    : Border.all(color: t.strongDivider, width: 1.5),
              ),
              child: done
                  ? Icon(PantasIcons.check, size: 11, color: c.onAccent)
                  : null,
            ),
          ),
          const SizedBox(width: PantasSpace.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Part $number · $name',
                  style: PantasType.webLink.copyWith(
                    fontWeight: FontWeight.w400,
                    color: done ? c.textSecondary : c.textPrimary,
                  ),
                ),
                if (!done) Text('Opens when this part starts.', style: t.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
          width: PantasSpace.s10,
          height: PantasSpace.s10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: ring == null
                ? null
                : Border.all(color: ring!, width: PantasBorder.ringStrong),
          ),
        ),
        const SizedBox(width: PantasSpace.s6),
        Text(
          label,
          style: PantasType.webCaption.copyWith(color: t.colors.textSecondary),
        ),
      ],
    );
  }
}

/// Fades the edge of a scrolling list that has more behind it, as the board
/// draws the question list. An edge with nothing behind it stays solid.
class _ScrollEdgeFade extends StatefulWidget {
  const _ScrollEdgeFade({required this.builder});

  final Widget Function(ScrollController controller) builder;

  @override
  State<_ScrollEdgeFade> createState() => _ScrollEdgeFadeState();
}

class _ScrollEdgeFadeState extends State<_ScrollEdgeFade> {
  static const _fade = PantasSpace.s18;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // The list's size is known after its first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final position = _controller.hasClients &&
                  _controller.position.hasContentDimensions
              ? _controller.position
              : null;
          final hiddenAbove = position != null && position.pixels > 1;
          final hiddenBelow = position != null &&
              position.maxScrollExtent - position.pixels > 1;
          // The mask stays in the tree whatever the scroll, so the list
          // keeps its place.
          return ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) {
              final edge = (_fade / rect.height).clamp(0.0, .5);
              // Only the alpha of the mask matters (dstIn).
              const solid = PantasColors.gray0;
              final clear = PantasColors.gray0.withValues(alpha: 0);
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  if (hiddenAbove) clear else solid,
                  solid,
                  solid,
                  if (hiddenBelow) clear else solid,
                ],
                stops: [0, edge, 1 - edge, 1],
              ).createShader(rect);
            },
            child: widget.builder(_controller),
          );
        },
      );
}
