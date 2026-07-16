import 'dart:async';

import 'package:cse_cet_reviewer/core/ui/components/answer_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/confirmation_dialog.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_session_state.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/part_clock.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/clock_rule.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/proctor_toast.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/mock_floating_bar.dart';
import 'package:flutter/material.dart';

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
        _toastTimer = Timer(const Duration(milliseconds: 2500), () {
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
        body:
            'Use this only when you have to. The clock stops, but you will not get this in the real room.',
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
    final partNum = widget.currentPartNumber;
    showAppConfirmationDialog(
      context: context,
      title: 'End Part $partNum now?',
      body:
          'Ending now closes Part $partNum for good. The time you have left does not carry over.',
      cancelLabel: 'Keep going',
      confirmLabel: 'End part',
      isDestructive: true,
      onCancel: () {},
      onConfirm: () => widget.onEndPartEarly?.call(),
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
      canPop: false,
      onPopInvokedWithResult: (_, __) => _confirmLeave(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _formatRemaining(widget.remainingInPart),
            style: textStyles.headlineSmall.copyWith(
              fontFamily: 'SourceSerif4',
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
                Text(widget.state.currentQuestionId,
                    style: textStyles.headlineMedium),
                const SizedBox(height: 20),
                AnswerRow(
                  letter: 'A',
                  text: 'Choice A',
                  onTap: () => widget.onAnswer(0),
                ),
                AnswerRow(
                  letter: 'B',
                  text: 'Choice B',
                  onTap: () => widget.onAnswer(1),
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
                  'Part ${widget.currentPartNumber} runs to the end of its time. Strict mock mode is on.',
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

  Future<void> _confirmLeave(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave mock?'),
        content: const Text('The clock keeps running.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay'),
          ),
        ],
      ),
    );
  }

  String _formatRemaining(Duration remaining) {
    final minutes = remaining.inMinutes;
    final secs = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }
}
