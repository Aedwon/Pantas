import 'package:cse_cet_reviewer/core/ui/components/answer_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_session_state.dart';
import 'package:flutter/material.dart';

class MockSessionPage extends StatelessWidget {
  const MockSessionPage({
    required this.state,
    required this.onAnswer,
    required this.onToggleFlag,
    required this.onPause,
    required this.onShowNavigator,
    super.key,
  });

  final MockSessionInProgress state;
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
        appBar: AppBar(
          title:
              Text('${state.currentIndex + 1} of ${state.questionIds.length}'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _formatRemaining(state.remainingSeconds),
                  style: textStyles.bodyMedium.copyWith(
                    color: colors.inkMuted,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Flag',
              icon: const Icon(Icons.flag_outlined),
              onPressed: onToggleFlag,
            ),
            if (!state.strictMode)
              IconButton(
                tooltip: 'Pause',
                icon: const Icon(Icons.pause),
                onPressed: onPause,
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text(state.currentQuestionId, style: textStyles.headlineMedium),
            const SizedBox(height: 20),
            AnswerRow(letter: 'A', text: 'Choice A', onTap: () => onAnswer(0)),
            AnswerRow(letter: 'B', text: 'Choice B', onTap: () => onAnswer(1)),
            const SizedBox(height: 16),
            BoardButton(
              label: 'Questions',
              secondary: true,
              onPressed: onShowNavigator,
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

  String _formatRemaining(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }
}
