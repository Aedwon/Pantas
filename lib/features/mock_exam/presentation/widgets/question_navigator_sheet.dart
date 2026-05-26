import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_results.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_sample.dart';
import 'package:flutter/material.dart';

class QuestionNavigatorSheet extends StatelessWidget {
  const QuestionNavigatorSheet({
    required this.sections,
    required this.currentIndex,
    required this.answers,
    required this.flags,
    required this.onJumpTo,
    super.key,
  });

  final List<SampledMockSection> sections;
  final int currentIndex;
  final Map<String, MockAnswer> answers;
  final Set<String> flags;
  final ValueChanged<int> onJumpTo;

  @override
  Widget build(BuildContext context) {
    final questionIds = [
      for (final section in sections) ...section.questionIds,
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in sections) ...[
              Text(section.name),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final questionId in section.questionIds)
                    _QuestionChip(
                      label: '${questionIds.indexOf(questionId) + 1}',
                      answered: answers.containsKey(questionId),
                      flagged: flags.contains(questionId),
                      current: questionIds.indexOf(questionId) == currentIndex,
                      onTap: () => onJumpTo(questionIds.indexOf(questionId)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    final index = questionIds.indexWhere(
                      (id) => !answers.containsKey(id),
                    );
                    if (index != -1) onJumpTo(index);
                  },
                  child: const Text('Next blank'),
                ),
                TextButton(
                  onPressed: () {
                    final index = questionIds.indexWhere(flags.contains);
                    if (index != -1) onJumpTo(index);
                  },
                  child: const Text('Next flagged'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionChip extends StatelessWidget {
  const _QuestionChip({
    required this.label,
    required this.answered,
    required this.flagged,
    required this.current,
    required this.onTap,
  });

  final String label;
  final bool answered;
  final bool flagged;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(flagged ? '$label*' : label),
      avatar: current ? const Icon(Icons.radio_button_checked, size: 16) : null,
      backgroundColor:
          answered ? Theme.of(context).colorScheme.primaryContainer : null,
      onPressed: onTap,
    );
  }
}
