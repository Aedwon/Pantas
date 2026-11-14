import 'package:pantas/core/ui/components/question_navigator_chip.dart';
import 'package:pantas/core/ui/components/question_navigator_grid.dart';

import '../golden_harness.dart';

QuestionNavigatorChip _chip({
  bool answered = false,
  bool current = false,
  bool flagged = false,
  bool enabled = true,
}) =>
    QuestionNavigatorChip(
      number: 12,
      name: 'Question 12',
      onTap: () {},
      answered: answered,
      current: current,
      flagged: flagged,
      enabled: enabled,
    );

void main() {
  goldenSheet(
    'question_navigator',
    [
      GoldenState('Blank', (_) => _chip(), width: 80),
      GoldenState('Answered', (_) => _chip(answered: true), width: 80),
      GoldenState('Current', (_) => _chip(current: true), width: 80),
      GoldenState('Locked', (_) => _chip(enabled: false), width: 80),
      GoldenState('Flagged', (_) => _chip(flagged: true), width: 80),
      GoldenState(
        'Hover',
        (_) => _chip(),
        action: GoldenAction.hover,
        width: 80,
      ),
      GoldenState(
        'Pressed',
        (_) => _chip(),
        action: GoldenAction.pressed,
        width: 80,
      ),
      GoldenState(
        'Focus',
        (_) => _chip(),
        action: GoldenAction.focus,
        width: 80,
      ),
      GoldenState(
        'Grid',
        (_) => QuestionNavigatorGrid(
          onSelected: (_) {},
          questions: const [
            NavigatorQuestion(number: 1, answered: true),
            NavigatorQuestion(number: 2, answered: true, flagged: true),
            NavigatorQuestion(number: 3, current: true),
            NavigatorQuestion(number: 4),
            NavigatorQuestion(number: 5, flagged: true),
            NavigatorQuestion(number: 6),
            NavigatorQuestion(number: 7, enabled: false),
            NavigatorQuestion(number: 8, enabled: false),
            NavigatorQuestion(number: 9, enabled: false),
          ],
        ),
        width: 330,
      ),
    ],
    cellWidth: 100,
    columns: 4,
  );
}
