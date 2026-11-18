import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/question_choices.dart';

import 'package:pantas/core/ui/web/web_keyboard_focus.dart'
    show resetWebKeyboardFocus;

import '../../core/ui/components/figure_choice_fixtures.dart';
import '../golden_harness.dart';

/// The O2_States board as sheets: figure choice tiles in every state, on the
/// phone (360 and 390) and on wide web (1440), light and dark. The samples are
/// a figure-series question and an odd-one-out question, with fixture data.
///
/// [chosen] is the index the student picked, or null; [checked] reveals the
/// answer (the right tile is index 1).
Widget _tiles(
  Question question, {
  int? chosen,
  bool checked = false,
}) {
  final right = question.choices.indexWhere((c) => c.isCorrect);
  return Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: QuestionChoices.build(
        question,
        chosenId: chosen == null ? null : question.choices[chosen].id,
        stateOf: (choice) {
          final i = question.choices.indexOf(choice);
          if (!checked) {
            return i == chosen ? ChoiceRowState.picked : ChoiceRowState.plain;
          }
          return i == right
              ? ChoiceRowState.right
              : i == chosen
                  ? ChoiceRowState.wrong
                  : ChoiceRowState.dimmed;
        },
        onPick: checked ? null : (_) {},
      ),
    ),
  );
}

List<GoldenState> _states({required bool wide}) {
  final series = arrowQuestion();
  final five = arrowQuestion(count: 5);
  final odd = oddOneOutQuestion();
  Finder tile(String letter) => find.byKey(ValueKey('figure-choice-$letter'));
  return [
    if (wide) ...[
      GoldenState(
        'Keyboard focus',
        (_) => _tiles(series),
        action: GoldenAction.focus,
      ),
      GoldenState(
        'Selected with focus',
        (_) => _tiles(series, chosen: 1),
        action: GoldenAction.focus,
      ),
    ],
    GoldenState('Rest', (_) => _tiles(series)),
    GoldenState('Selected', (_) => _tiles(series, chosen: 2)),
    GoldenState('Right pick', (_) => _tiles(series, chosen: 1, checked: true)),
    GoldenState('Wrong pick', (_) => _tiles(series, chosen: 0, checked: true)),
    GoldenState('Review', (_) => _tiles(series, chosen: 2, checked: true)),
    GoldenState('Five choices', (_) => _tiles(five)),
    GoldenState('Odd one out', (_) => _tiles(odd)),
    GoldenState('Odd one out, selected', (_) => _tiles(odd, chosen: 2)),
    GoldenState(
      'Odd one out, wrong pick',
      (_) => _tiles(odd, chosen: 2, checked: true),
    ),
    GoldenState(
      'Hover',
      (_) => _tiles(series),
      action: GoldenAction.hover,
      target: () => tile('B'),
    ),
    GoldenState(
      'Pressed',
      (_) => _tiles(series),
      action: GoldenAction.pressed,
      target: () => tile('B'),
    ),
  ];
}

void main() {
  // Each sheet is its own test binding, so the keyboard-focus listener starts
  // again for it.
  setUp(resetWebKeyboardFocus);
  goldenSheet(
    'figure_choice_tiles_phone_390',
    _states(wide: false),
    cellWidth: 358,
  );
  goldenSheet(
    'figure_choice_tiles_phone_360',
    _states(wide: false),
    cellWidth: 328,
  );
  goldenSheet(
    'figure_choice_tiles_wide_1440',
    _states(wide: true),
    cellWidth: 720,
    columns: 2,
    web: true,
  );
}
