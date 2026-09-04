import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/confirmation_dialog.dart';
import 'package:pantas/core/ui/components/question_card.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/domain/part_clock.dart';
import 'package:pantas/features/mock_exam/presentation/clock_rule.dart';
import 'package:pantas/features/mock_exam/presentation/proctor_toast.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_floating_bar.dart';

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
    showAppConfirmationDialog(
      context: context,
      title: 'End Part ${widget.currentPartNumber} now?',
      body: 'You have ${widget.remainingInPart.inMinutes} minutes left in '
          'this part. If you end it early, this time does not carry over.',
      cancelLabel: 'Keep going',
      confirmLabel: 'End part',
      onCancel: () {},
      onConfirm: widget.onEndPartEarly ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final urgency = urgencyFor(widget.remainingInPart);
    final isLastItemOfPart = widget.partPosition == widget.partTotal;

    final VoidCallback? effectiveOnNext;
    if (isLastItemOfPart) {
      if (widget.state.strictMode) {
        effectiveOnNext = null;
      } else {
        effectiveOnNext = () => _confirmEndPartEarly(context);
      }
    } else {
      effectiveOnNext = widget.canGoNext ? widget.onNext : null;
    }

    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave(context));
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _formatRemaining(widget.remainingInPart),
            style: textStyles.headlineSmall.copyWith(
              fontFamily: 'SourceSans3',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: urgency == ClockUrgency.last ? colors.amber : colors.ink,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          actions: [
            if (!widget.state.strictMode)
              IconButton(
                key: const Key('mock-pause'),
                icon: const Icon(Icons.pause_outlined),
                onPressed: _onPausePressed,
              ),
          ],
          bottom: ClockRule(
            remaining: widget.remainingInPart,
            partLength: widget.effectivePartLength,
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
              children: [
                _QuestionBody(
                  questionId: widget.state.currentQuestionId,
                  selectedIndex: widget.state
                      .answers[widget.state.currentQuestionId]?.selectedIndex,
                  onAnswer: widget.onAnswer,
                ),
              ],
            ),
            if (_proctorToastMinutes != null)
              Positioned(
                bottom: 74,
                left: 20,
                right: 20,
                child: Center(
                  child: ProctorToast(minutes: _proctorToastMinutes!),
                ),
              )
            else if (widget.state.strictMode && isLastItemOfPart)
              Positioned(
                bottom: 74,
                left: 20,
                right: 20,
                child: Text(
                  'Part ${widget.currentPartNumber} runs to the end of its '
                  'time. Strict mock mode is on.',
                  textAlign: TextAlign.center,
                  style: textStyles.captionSmall.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: MockFloatingBar(
                  position: widget.partPosition,
                  total: widget.partTotal,
                  isFlagged: widget.state.flags
                      .contains(widget.state.currentQuestionId),
                  onPrevious: widget.canGoPrevious ? widget.onPrevious : null,
                  onNext: effectiveOnNext,
                  onGrid: widget.onShowNavigator,
                  onFlag: widget.onToggleFlag,
                ),
              ),
            ),
          ],
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
    final minutes = remaining.inMinutes;
    final secs = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }
}

class _QuestionBody extends ConsumerWidget {
  const _QuestionBody({
    required this.questionId,
    required this.selectedIndex,
    required this.onAnswer,
  });

  final String questionId;
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

        final choiceId = selectedIndex != null &&
                selectedIndex! < hydrated.question.choices.length
            ? hydrated.question.choices[selectedIndex!].id
            : null;

        return QuestionCard(
          key: ValueKey(hydrated.question.id),
          question: hydrated.question,
          passage: hydrated.passage,
          chosenChoiceId: choiceId,
          onAnswer: (cid) {
            final index =
                hydrated.question.choices.indexWhere((c) => c.id == cid);
            if (index >= 0) onAnswer(index);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
