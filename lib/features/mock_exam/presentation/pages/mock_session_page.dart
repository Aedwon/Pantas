import 'package:cse_cet_reviewer/core/ui/components/answer_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_session_state.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/mock_floating_bar.dart';
import 'package:flutter/material.dart';

class MockSessionPage extends StatelessWidget {
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
    super.key,
  });

  final MockSessionInProgress state;

  /// What is left of the open part. The exam's own clock is not shown:
  /// what governs the student is the part they are in.
  final Duration remainingInPart;

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

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _confirmLeave(context),
      child: Scaffold(
        // The clock alone, centred. No title and no trailing element: it
        // must never be hunted for, and the pager holds everything else.
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            _formatRemaining(remainingInPart),
            style: textStyles.headlineSmall.copyWith(
              fontFamily: 'SourceSerif4',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.ink,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
              children: [
                Text(state.currentQuestionId, style: textStyles.headlineMedium),
                const SizedBox(height: 20),
                AnswerRow(
                  letter: 'A',
                  text: 'Choice A',
                  onTap: () => onAnswer(0),
                ),
                AnswerRow(
                  letter: 'B',
                  text: 'Choice B',
                  onTap: () => onAnswer(1),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: MockFloatingBar(
                  position: partPosition,
                  total: partTotal,
                  isFlagged: state.flags.contains(state.currentQuestionId),
                  onPrevious: canGoPrevious ? onPrevious : null,
                  onNext: canGoNext ? onNext : null,
                  onGrid: onShowNavigator,
                  onFlag: onToggleFlag,
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
