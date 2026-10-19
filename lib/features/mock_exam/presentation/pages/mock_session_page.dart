import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/confirmation_dialog.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/part_clock.dart';
import 'package:pantas/features/mock_exam/presentation/clock_rule.dart';
import 'package:pantas/features/mock_exam/presentation/proctor_toast.dart';

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
    this.onLeave,
    this.currentPartNumber = 1,
    this.partName = '',
    this.oneBlock = false,
    this.onSubmitExam,
    this.partLength,
    super.key,
  });

  final MockSessionInProgress state;

  /// What is left of the open part. The exam's own clock is not shown:
  /// what governs the student is the part they are in.
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
  final Future<bool> Function()? onLeave;
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
  late Duration _previousRemaining;
  int? _proctorToastMinutes;
  Timer? _toastTimer;
  var _leaving = false;
  var _gridOpen = false;

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
        _toastTimer?.cancel();
        setState(() {
          _proctorToastMinutes = threshold;
        });
        _toastTimer = Timer(proctorToastDisplayDuration, () {
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
    super.dispose();
  }

  void _onPausePressed() {
    if (!widget.pauseWarningSeen) {
      showAppConfirmationDialog(
        context: context,
        title: 'Real exams do not pause.',
        body: 'Use this only when you have to. The clock stops, but you '
            'will not get this in the real room.',
        cancelLabel: 'Keep going',
        confirmLabel: 'Pause',
        isDestructive: false,
        onCancel: () {},
        onConfirm: () {
          widget.onPauseWarningSeenChanged?.call(true);
          widget.onPause();
        },
      );
    } else {
      widget.onPause();
    }
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
        builder: (dialogContext) => CenteredDialog(
          title: widget.oneBlock ? 'Submit the exam?' : 'End Part $part now?',
          message: widget.oneBlock
              ? 'You have $left left and $blank questions blank. Once you '
                  "submit, your answers can't be changed."
              : 'You have $left left and $blank questions blank. Ending now '
                  'closes Part $part for good, and the time left '
                  "doesn't carry over.",
          primaryLabel: widget.oneBlock ? 'Submit' : 'End Part $part',
          secondaryLabel: 'Keep Working',
          destructive: !widget.oneBlock,
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
    final scale = MediaQuery.textScalerOf(context).scale(17);
    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_gridOpen) unawaited(_confirmLeave(context));
      },
      child: QuestionGridSheet(
        open: _gridOpen,
        onDismiss: () => setState(() => _gridOpen = false),
        mock: true,
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
                  icon: Icon(PantasIcons.pause, size: 20),
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
                final counter = '${widget.partPosition} of ${widget.partTotal}';
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
                    'time. Strict mock mode is on.';
                final strictLine = widget.state.strictMode && last;
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
                final left = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    control(
                      'mock-prev',
                      'Previous question',
                      Icon(PantasIcons.back, size: 20),
                      widget.canGoPrevious ? widget.onPrevious : null,
                    ),
                    control(
                      'mock-grid',
                      'Questions',
                      PantasIcons.questionsSheet,
                      () => setState(() => _gridOpen = true),
                    ),
                  ],
                );
                final right = Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    control(
                      'mock-flag',
                      'Flag question',
                      Icon(
                        PantasIcons.flag,
                        size: 21,
                        color: widget.state.flags
                                .contains(widget.state.currentQuestionId)
                            ? c.accent
                            : c.label,
                      ),
                      widget.onToggleFlag,
                    ),
                    control(
                      'mock-next',
                      last
                          ? widget.oneBlock
                              ? 'Submit the exam'
                              : 'End part'
                          : 'Next question',
                      Icon(PantasIcons.next, size: 20),
                      next,
                    ),
                  ],
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
                    : FloatingBar(left: left, counter: counter, right: right);
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
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
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
          questions: [
            for (var i = 1; i <= part.count; i++)
              GridQuestion(number: i, state: GridQuestionState.unreached),
          ],
        ),
    ];
  }

  void _goToPartQuestion(int number) =>
      widget.onGoTo?.call(_firstIndexInPart + number - 1);

  Future<void> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave mock?'),
        content: const Text('The clock keeps running.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Leave',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
        ],
      ),
    );
    if (leave != true) return;
    final mayLeave = await widget.onLeave?.call() ?? true;
    if (!mayLeave || !context.mounted) return;
    setState(() => _leaving = true);
    await WidgetsBinding.instance.endOfFrame;
    if (context.mounted) Navigator.of(context).pop();
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

/// MK_Paper: Next sends the old question out to the left over 260ms while the
/// new one comes in from the right over 280ms, starting 80ms later. Both use
/// the house curve. Going back or jumping from the grid is not drawn, so it
/// changes at once, and so does everything under reduced motion.
class _PaperSwap extends StatefulWidget {
  const _PaperSwap({required this.position, required this.child});

  final int position;
  final Widget child;

  @override
  State<_PaperSwap> createState() => _PaperSwapState();
}

class _PaperSwapState extends State<_PaperSwap>
    with SingleTickerProviderStateMixin {
  static const _total = Duration(milliseconds: 360);
  static const _outMs = 260.0;
  static const _inStartMs = 80.0;
  static const _inMs = 280.0;
  static const _distance = 24.0;

  late final AnimationController _controller;
  Widget? _outgoing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _total)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _outgoing = null);
        }
      });
  }

  @override
  void didUpdateWidget(_PaperSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final forward = widget.position == oldWidget.position + 1;
    if (forward && !MediaQuery.disableAnimationsOf(context)) {
      _outgoing = oldWidget.child;
      _controller.forward(from: 0);
    } else {
      _outgoing = null;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static double _progress(double milliseconds, double start, double length) =>
      PantasCurves.houseOut
          .transform(((milliseconds - start) / length).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final outgoing = _outgoing;
    if (outgoing == null) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final ms = _controller.value * _total.inMilliseconds;
        final out = _progress(ms, 0, _outMs);
        final entering = _progress(ms, _inStartMs, _inMs);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              key: const ValueKey('paper-swap-in'),
              opacity: entering,
              child: Transform.translate(
                offset: Offset(_distance * (1 - entering), 0),
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
                    opacity: 1 - out,
                    child: Transform.translate(
                      offset: Offset(-_distance * out, 0),
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

    return hydratedAsync.when(
      data: (hydrated) {
        if (hydrated == null) {
          return errorFor(
            'question',
            () => ref.invalidate(hydratedMockQuestionProvider(questionId)),
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
      loading: () => loadingFor(hydratedAsync),
      error: (e, st) => errorFor(
        'question',
        () => ref.invalidate(hydratedMockQuestionProvider(questionId)),
        error: e,
      ),
    );
  }
}
