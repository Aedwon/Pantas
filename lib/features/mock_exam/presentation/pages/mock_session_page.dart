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
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/part_clock.dart';
import 'package:pantas/features/mock_exam/presentation/clock_rule.dart';
import 'package:pantas/features/mock_exam/presentation/proctor_toast.dart';

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
    required this.onShowNavigator,
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
  final VoidCallback onShowNavigator;
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
        if (!didPop) unawaited(_confirmLeave(context));
      },
      child: Scaffold(
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
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 150),
                children: [
                  _QuestionBody(
                    questionId: widget.state.currentQuestionId,
                    subject: widget.oneBlock
                        ? widget.partName
                        : 'Part ${widget.currentPartNumber} · '
                            '${widget.partName}',
                    selectedIndex: widget.state
                        .answers[widget.state.currentQuestionId]?.selectedIndex,
                    onAnswer: widget.onAnswer,
                  ),
                ],
              ),
              if (_proctorToastMinutes != null)
                Positioned(
                  bottom: 102,
                  left: 16,
                  right: 16,
                  child: ProctorToast(minutes: _proctorToastMinutes!),
                )
              else if (widget.state.strictMode && last)
                Positioned(
                  bottom: 102,
                  left: 16,
                  right: 16,
                  child: Text(
                    'Part ${widget.currentPartNumber} runs to the end of its '
                    'time. Strict mock mode is on.',
                    textAlign: TextAlign.center,
                    style:
                        context.type.footnote.copyWith(color: c.secondaryLabel),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  child: FloatingBar(
                    left: Row(
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
                          widget.onShowNavigator,
                        ),
                      ],
                    ),
                    counter: '${widget.partPosition} of ${widget.partTotal}',
                    right: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        control(
                          'mock-flag',
                          'Flag question',
                          Icon(
                            PantasIcons.flag,
                            size: 21,
                            color: widget.state.flags.contains(
                              widget.state.currentQuestionId,
                            )
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

class _QuestionBody extends ConsumerWidget {
  const _QuestionBody({
    required this.questionId,
    required this.subject,
    required this.selectedIndex,
    required this.onAnswer,
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
          return const Center(child: Text('Question not found'));
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
