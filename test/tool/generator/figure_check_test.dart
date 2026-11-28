// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';
import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';
import 'check_support.dart';
import 'support.dart';

ProblemType figureType() => parseProblemType(
      mathTypeData()
        ..['rule'] = 'testFigure'
        ..['choiceKind'] = 'figure'
        ..['stem'] = 'Which point comes next?'
        ..['explanation'] = 'Continue the equal steps.'
        ..['choiceCount'] = 2
        ..['mistakes'] = [
          {'id': 'short', 'note': 'This stops early. Check the step.'},
        ],
    );

Map<String, Object?> figureData() => {
      'index': 0,
      'slots': <String, Object?>{},
      'signature': 'figure-one',
      'ruleKey':
          '44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a',
      'cosmetics': <String, Object?>{},
      'figureSpec': {
        'kind': 'generic-test',
        'items': [
          {'x': 1, 'y': 0},
        ],
      },
      'choices': [
        {
          'correct': true,
          'text': 'Three right',
          'figure': {'x': 3, 'y': 0},
        },
        {
          'mistake': 'short',
          'text': 'Two right',
          'figure': {'x': 2, 'y': 0},
        },
      ],
    };

Variant asVariant(Map<String, Object?> data) => parseVariants({
      'variants': [data],
    }).single;

void main() {
  useTestSolverRegistry();
  test('good figure list passes', () {
    expect(checkVariants(figureType(), [asVariant(figureData())]), isEmpty);
  });
  test('all library solvers of matching kind reject alternate valid answers',
      () {
    figureSolvers['alternate'] = TestFigureSolver(2);
    final failures = checkVariants(figureType(), [asVariant(figureData())]);
    expect(
      failures.any(
        (f) => f.check == 'correctness' && f.reason.contains('library'),
      ),
      isTrue,
    );
  });
  test('shown data must fit the declared solver', () {
    figureSolvers['testFigure'] = TestFigureSolver(99);
    expect(
      checkVariants(figureType(), [asVariant(figureData())])
          .any((f) => f.check == 'correctness'),
      isTrue,
    );
  });
  test('unknown canonicalizer fails clearly', () {
    final data = figureData()..['figureSpec'] = {'kind': 'unknown'};
    expect(
      checkVariants(figureType(), [asVariant(data)])
          .any((f) => f.reason.contains('no canonicalizer for kind unknown')),
      isTrue,
    );
  });
  for (final point in [(0, 1), (-1, 0), (0, -1)]) {
    test('whole question rotation or reflection duplicates $point', () {
      final original = asVariant(figureData());
      final transformed = figureData()
        ..['index'] = 1
        ..['signature'] = 'forged'
        ..['figureSpec'] = {
          'kind': 'generic-test',
          'items': [
            {'x': point.$1, 'y': point.$2},
          ],
        }
        ..['choices'] = [
          {
            'correct': true,
            'text': 'Changed text',
            'figure': {'x': point.$1 * 3, 'y': point.$2 * 3},
          },
          {
            'mistake': 'short',
            'text': 'Other text',
            'figure': {'x': point.$1 * 2, 'y': point.$2 * 2},
          },
        ];
      expect(
        canonicalSignature(original),
        canonicalSignature(asVariant(transformed)),
      );
      expect(
        checkVariants(figureType(), [original, asVariant(transformed)])
            .any((f) => f.check == 'signature'),
        isTrue,
      );
    });
  }
  test('candidate-only rotation is a different whole question', () {
    final changed = figureData()
      ..['choices'] = [
        {
          'correct': true,
          'text': 'Up',
          'figure': {'x': 0, 'y': 3},
        },
        {
          'mistake': 'short',
          'text': 'Two',
          'figure': {'x': 0, 'y': 2},
        },
      ];
    expect(
      canonicalSignature(asVariant(figureData())),
      isNot(canonicalSignature(asVariant(changed))),
    );
  });
  test('merged source comparison accepts exact data and rejects changed data',
      () {
    final data = figureData()..['source'] = 'old';
    final type = parseProblemType(
      figureType().toMap()
        ..['mergedQuestions'] = [
          {'id': 'old', 'index': 0},
        ],
    );
    final question = {
      'stem': type.stem,
      'figureSpec': data['figureSpec'],
      'choices': [
        {'correct': true, 'text': 'Three right'},
        {'text': 'Two right'},
      ],
    };
    expect(
      checkVariants(type, [asVariant(data)], questions: {'old': question}),
      isEmpty,
    );
    question['figureSpec'] = {'kind': 'generic-test', 'items': <Object?>[]};
    expect(
      checkVariants(type, [asVariant(data)], questions: {'old': question})
          .any((f) => f.check == 'merged'),
      isTrue,
    );
  });
}
