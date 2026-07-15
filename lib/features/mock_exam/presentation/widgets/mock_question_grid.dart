import 'package:cse_cet_reviewer/core/ui/components/question_grid_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// One part of the paper, as the grid needs it.
class MockGridPart {
  const MockGridPart({
    required this.name,
    required this.startIndex,
    required this.count,
    required this.isOpen,
  });

  final String name;

  /// Where this part starts in the whole exam, counting from zero.
  final int startIndex;

  final int count;

  /// False until the part starts. A closed part still draws, because
  /// knowing what is coming and how much is left is what a printed booklet
  /// gives you.
  final bool isOpen;
}

/// The mock's navigator: six columns, grouped by part.
///
/// It shows progress and doubt, and never an outcome. A grid cell that
/// leaked correctness would destroy the simulation silently, and nothing
/// else in the app would catch it.
class MockQuestionGrid extends StatelessWidget {
  const MockQuestionGrid({
    required this.parts,
    required this.currentIndex,
    required this.answeredIndexes,
    required this.flaggedIndexes,
    required this.onTap,
    super.key,
  });

  final List<MockGridPart> parts;
  final int currentIndex;
  final Set<int> answeredIndexes;
  final Set<int> flaggedIndexes;

  /// Reports the question's index in the whole exam, counting from zero.
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final part in parts) ...[
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(part.name, style: styles.headlineSmall),
                ),
                Text(
                  '${part.count}',
                  style: styles.bodySmall.copyWith(
                    color: colors.inkMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (!part.isOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'Opens when this part starts.',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
            ),
          QuestionGridSheet(
            columns: 6,
            cells: [
              for (var i = 0; i < part.count; i += 1)
                GridCell(
                  number: part.startIndex + i + 1,
                  // Answered, never right or wrong: the mock reveals
                  // nothing until it is submitted.
                  mark: answeredIndexes.contains(part.startIndex + i)
                      ? GridCellMark.answered
                      : GridCellMark.none,
                  isFlagged: flaggedIndexes.contains(part.startIndex + i),
                  isCurrent: currentIndex == part.startIndex + i,
                  isEnabled: part.isOpen,
                ),
            ],
            onTap: (number) => onTap(number - 1),
          ),
        ],
      ],
    );
  }
}
