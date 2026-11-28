import 'dart:convert';

import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';

/// Fixture data for the figure choice tests and sheets. No content is edited.

const _arrows = [
  ('A', 'arrow pointing lower-right', 135),
  ('B', 'arrow pointing down', 180),
  ('C', 'arrow pointing lower-left', 225),
  ('D', 'arrow pointing up', 0),
  ('E', 'arrow pointing right', 90),
];

String _arrowItem(int degrees) => jsonEncode({
      'form': 'square',
      'rotation': degrees,
      'arrow': 'up',
    });

const _seriesSpec = {
  'kind': 'figure-series',
  'items': [
    {'form': 'square', 'rotation': 0, 'arrow': 'up'},
    {'form': 'square', 'rotation': 45, 'arrow': 'up'},
    {'form': 'square', 'rotation': 90, 'arrow': 'up'},
  ],
  'blank': true,
};

/// A figure-series question whose answers are arrows. The right answer is B.
/// [figures] replaces the per-choice figure JSON, for bad and mixed data.
Question arrowQuestion({
  ChoiceKind kind = ChoiceKind.figure,
  bool showQuestionFigure = true,
  String? figureSpecJson,
  List<String?>? figures,
  int count = 4,
}) =>
    Question(
      id: 'q-arrows',
      version: 1,
      examIds: const ['exam'],
      topicId: 'topic',
      language: 'en',
      stem: 'Which figure comes next?',
      explanation: 'Each arrow turns 45 degrees.',
      figureSpecJson: figureSpecJson ?? jsonEncode(_seriesSpec),
      choiceKind: kind,
      showQuestionFigure: showQuestionFigure,
      choices: [
        for (var i = 0; i < count; i++)
          Choice(
            id: 'choice-$i',
            label: _arrows[i].$1,
            text: _arrows[i].$2,
            isCorrect: i == 1,
            figureJson:
                figures != null ? figures[i] : _arrowItem(_arrows[i].$3),
          ),
      ],
    );

const _lineCounts = [3, 1, 3, 3];

String _circleItem(int lines) =>
    jsonEncode({'form': 'circle', 'lines': lines, 'through': 'centre'});

/// An odd-one-out question: the shapes are the choices and no question figure
/// shows. The right answer is B, the circle with one line.
Question oddOneOutQuestion() => Question(
      id: 'q-odd',
      version: 1,
      examIds: const ['exam'],
      topicId: 'topic',
      language: 'en',
      stem: 'Group these figures by the number of internal lines. '
          'Which does not belong?',
      explanation: 'One circle has a single line.',
      figureSpecJson: jsonEncode({
        'kind': 'shape-row',
        'shapes': [
          for (final lines in _lineCounts) {'form': 'circle', 'lines': lines},
        ],
      }),
      choiceKind: ChoiceKind.figure,
      showQuestionFigure: false,
      choices: [
        for (var i = 0; i < 4; i++)
          Choice(
            id: 'odd-$i',
            label: String.fromCharCode(65 + i),
            text: _lineCounts[i] == 1
                ? 'circle with one line through the center'
                : 'circle with three lines through the center',
            isCorrect: i == 1,
            figureJson: _circleItem(_lineCounts[i]),
          ),
      ],
    );
