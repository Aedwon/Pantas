import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _confirmLeave(context),
      child: Scaffold(
        appBar: AppBar(
          title:
              Text('${state.currentIndex + 1} of ${state.questionIds.length}'),
          actions: [
            Text(_formatRemaining(state.remainingSeconds)),
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
          padding: const EdgeInsets.all(16),
          children: [
            Text(state.currentQuestionId),
            const SizedBox(height: 24),
            AppButton(label: 'A', onPressed: () => onAnswer(0)),
            const SizedBox(height: 8),
            AppButton(label: 'B', onPressed: () => onAnswer(1)),
            const SizedBox(height: 16),
            AppButton(
              label: 'Questions',
              variant: AppButtonVariant.secondary,
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
