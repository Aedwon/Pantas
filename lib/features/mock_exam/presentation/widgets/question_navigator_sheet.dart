import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';

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
    final styles = context.textStyles;
    final colors = context.colors;
    final questionIds = [
      for (final section in sections) ...section.questionIds,
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in sections) ...[
              SectionHeader(title: section.name),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final questionId in section.questionIds)
                    _QuestionCell(
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
                GestureDetector(
                  onTap: () {
                    final index = questionIds.indexWhere(
                      (id) => !answers.containsKey(id),
                    );
                    if (index != -1) onJumpTo(index);
                  },
                  child: Text(
                    'Next blank',
                    style: styles.labelLarge.copyWith(color: colors.board),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    final index = questionIds.indexWhere(flags.contains);
                    if (index != -1) onJumpTo(index);
                  },
                  child: Text(
                    'Next flagged',
                    style: styles.labelLarge.copyWith(color: colors.board),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCell extends StatelessWidget {
  const _QuestionCell({
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
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: answered ? colors.boardTint : null,
          border: Border.all(
            color: current ? colors.board : colors.rule,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          flagged ? '$label*' : label,
          style: styles.bodySmall.copyWith(
            color: answered ? colors.board : colors.ink,
            fontWeight: current ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
