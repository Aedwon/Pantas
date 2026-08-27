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
    final questionIds = [
      for (final section in sections) ...section.questionIds,
    ];
    final nextBlank = questionIds.indexWhere(
      (id) => !answers.containsKey(id),
    );
    final nextFlagged = questionIds.indexWhere(flags.contains);

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
                _NavigationAction(
                  label: 'Next blank',
                  semanticsLabel: 'Next blank question',
                  onTap: nextBlank == -1 ? null : () => onJumpTo(nextBlank),
                ),
                const SizedBox(width: 20),
                _NavigationAction(
                  label: 'Next flagged',
                  semanticsLabel: 'Next flagged question',
                  onTap: nextFlagged == -1 ? null : () => onJumpTo(nextFlagged),
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
    final semanticsLabel = 'Question $label, '
        '${answered ? 'answered' : 'not answered'}, '
        '${flagged ? 'flagged' : 'not flagged'}';

    return Semantics(
      container: true,
      button: true,
      enabled: true,
      selected: current,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
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
      ),
    );
  }
}

class _NavigationAction extends StatelessWidget {
  const _NavigationAction({
    required this.label,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String label;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Semantics(
      container: true,
      button: true,
      enabled: onTap != null,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Center(
            child: Text(
              label,
              style: styles.labelLarge.copyWith(
                color: onTap == null ? colors.inkMuted : colors.board,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
