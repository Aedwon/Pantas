import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/question_variant.dart';
import 'package:pantas/core/storage/domain/variant_selector.dart';

void main() {
  const type = Question(
    id: 'qt-test',
    version: 1,
    examIds: ['exam_test'],
    topicId: 'topic_test',
    language: 'en',
    stem: '',
    choices: [],
    explanation: '',
    choiceKind: ChoiceKind.figure,
    showQuestionFigure: false,
  );

  test('resolves pinned figures and shuffles the key across all positions', () {
    final document = VariantDocument.fromJson({
      'id': type.id,
      'variants': [
        for (var index = 0; index < 100; index++)
          {
            'variantIndex': index,
            'ruleKey': 'rule',
            'stem': 'Stem $index',
            'explanation': 'Explanation $index',
            'figureSpec': {'kind': 'figure-series'},
            'choices': [
              {
                'text': 'Key',
                'correct': true,
                'figure': {'form': 'circle'}
              },
              {'text': 'Wrong', 'rationale': 'Wrong choice note'},
              {'text': 'Wrong again'},
              {'text': 'Another wrong answer'},
            ],
          },
      ],
    });
    final keyPositions = <String>{};
    for (var index = 0; index < 100; index++) {
      final question = resolveVariant(type, document, index)!;
      expect(question.id, type.id);
      expect(question.stem, 'Stem $index');
      expect(question.explanation, 'Explanation $index');
      expect(question.figureSpecJson, '{"kind":"figure-series"}');
      expect(question.choiceKind, ChoiceKind.figure);
      expect(question.showQuestionFigure, isFalse);
      expect(question.correctChoice.figureJson, '{"form":"circle"}');
      expect(question.correctChoice.id, 'qt-test_a');
      expect(
        question.choices
            .singleWhere((choice) => choice.id == 'qt-test_b')
            .rationale,
        'Wrong choice note',
      );
      keyPositions.add(question.correctChoice.label);
    }
    expect(keyPositions, {'A', 'B', 'C', 'D'});
    expect(resolveVariant(type, document, 100), isNull);
    expect(resolveVariant(type, null, 0), isNull);
    expect(resolveVariant(type.copyWith(id: 'other'), document, 0), isNull);
  });

  test('serves distinct rules, then unseen indexes, then the oldest', () {
    final served = <int, DateTime>{};
    int? choose() => chooseVariant(
          uid: 'user',
          typeId: type.id,
          ruleKeysByIndex: ['a', 'a', 'b', 'c'],
          served: served,
        );
    final order = <int>[];
    for (var turn = 0; turn < 4; turn++) {
      final index = choose()!;
      expect(choose(), index);
      order.add(index);
      served[index] = DateTime.utc(2026, 1, 1 + turn);
    }
    expect(order.take(3).map((i) => ['a', 'a', 'b', 'c'][i]).toSet(),
        {'a', 'b', 'c'});
    expect(order, [0, 3, 2, 1]);
    expect(choose(), order.first);
  });
}
