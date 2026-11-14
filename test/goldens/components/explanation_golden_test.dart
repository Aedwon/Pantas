import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';

import '../golden_harness.dart';

const _text = 'Halves are larger than thirds, so 1/2 is larger than 1/3.';

void main() {
  goldenSheet(
    'explanation',
    [
      GoldenState(
        'Correct pick',
        (_) => const AnswerReveal(
          correctLetter: 'B',
          pickedLetter: 'B',
          explanation: _text,
        ),
        width: 358,
      ),
      GoldenState(
        'Wrong pick',
        (_) => const AnswerReveal(
          correctLetter: 'B',
          pickedLetter: 'C',
          wrongPick: 'Thirds are not larger than halves.',
          explanation: _text,
        ),
        width: 358,
      ),
      GoldenState(
        'No pick',
        (_) => const AnswerReveal(correctLetter: 'B', explanation: _text),
        width: 358,
      ),
      GoldenState(
        'Show passage',
        (_) => AnswerReveal(
          correctLetter: 'B',
          explanation: _text,
          onShowPassage: () {},
        ),
        width: 358,
      ),
      GoldenState(
        'Show passage focus',
        (_) => AnswerReveal(
          correctLetter: 'B',
          explanation: _text,
          onShowPassage: () {},
        ),
        action: GoldenAction.focus,
        width: 358,
      ),
    ],
    cellWidth: 358,
    columns: 2,
  );
}
