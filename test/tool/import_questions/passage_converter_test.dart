import 'package:flutter_test/flutter_test.dart';
import '../../../tools/import_questions/converter.dart';

void main() {
  const meta = QuestionMeta(
    subjectSlug: 'reading-comprehension',
    topicSlug: 'comprehension-skills',
    subtopicSlug: 'main-idea',
    examCodes: ['upcat'],
  );

  String makeBody(int wordCount) {
    return List.generate(wordCount, (i) => 'word$i').join(' ');
  }

  Map<String, Object?> makeQuestion(String id, {String? passageId}) {
    return {
      'id': id,
      if (passageId != null) 'passage': passageId,
      'type': 'main-idea',
      'difficulty': 'easy',
      'stem': 'What is the main idea?',
      'choices': [
        {'text': 'Option A', 'correct': true},
        {'text': 'Option B', 'correct': false},
      ],
      'explanation': 'Explanation here.',
    };
  }

  test('valid passage and questions convert successfully', () {
    final passage = {
      'id': 'p1',
      'title': 'The Harvest',
      'body': makeBody(200),
    };
    final questions = [
      makeQuestion('q1', passageId: 'p1'),
      makeQuestion('q2', passageId: 'p1'),
      makeQuestion('q3', passageId: 'p1'),
      makeQuestion('q4', passageId: 'p1'),
    ];

    final result = parsePassagesAndQuestions(
      rawPassages: [passage],
      rawQuestions: questions,
      meta: meta,
      updatedAt: DateTime.utc(2026, 8, 4),
    );

    expect(result.passages.length, equals(1));
    expect(result.passages.first['_id'], equals('p1'));
    expect(result.passages.first['wordCount'], equals(200));
    expect(result.questions.length, equals(4));
    expect(
      (result.questions.first['passage'] as Map?)?['_ref'],
      equals('p1'),
    );
  });

  test('rejects question naming a passage not in the same file', () {
    final questions = [
      makeQuestion('q1', passageId: 'p_missing'),
    ];

    expect(
      () => parsePassagesAndQuestions(
        rawPassages: [],
        rawQuestions: questions,
        meta: meta,
        updatedAt: DateTime.utc(2026, 8, 4),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('q1'), contains('p_missing')),
        ),
      ),
    );
  });

  test('rejects passage with fewer than 4 questions', () {
    final passage = {
      'id': 'p1',
      'title': 'The Harvest',
      'body': makeBody(200),
    };
    final questions = [
      makeQuestion('q1', passageId: 'p1'),
      makeQuestion('q2', passageId: 'p1'),
      makeQuestion('q3', passageId: 'p1'),
    ];

    expect(
      () => parsePassagesAndQuestions(
        rawPassages: [passage],
        rawQuestions: questions,
        meta: meta,
        updatedAt: DateTime.utc(2026, 8, 4),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('p1'),
        ),
      ),
    );
  });

  test('rejects passage with more than 8 questions', () {
    final passage = {
      'id': 'p1',
      'title': 'The Harvest',
      'body': makeBody(200),
    };
    final questions = List.generate(
      9,
      (i) => makeQuestion('q$i', passageId: 'p1'),
    );

    expect(
      () => parsePassagesAndQuestions(
        rawPassages: [passage],
        rawQuestions: questions,
        meta: meta,
        updatedAt: DateTime.utc(2026, 8, 4),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('p1'),
        ),
      ),
    );
  });

  test('rejects passage body with fewer than 150 words', () {
    final passage = {
      'id': 'p1',
      'title': 'The Harvest',
      'body': makeBody(149),
    };
    final questions = List.generate(
      4,
      (i) => makeQuestion('q$i', passageId: 'p1'),
    );

    expect(
      () => parsePassagesAndQuestions(
        rawPassages: [passage],
        rawQuestions: questions,
        meta: meta,
        updatedAt: DateTime.utc(2026, 8, 4),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('p1'),
        ),
      ),
    );
  });

  test('rejects passage body with more than 400 words', () {
    final passage = {
      'id': 'p1',
      'title': 'The Harvest',
      'body': makeBody(401),
    };
    final questions = List.generate(
      4,
      (i) => makeQuestion('q$i', passageId: 'p1'),
    );

    expect(
      () => parsePassagesAndQuestions(
        rawPassages: [passage],
        rawQuestions: questions,
        meta: meta,
        updatedAt: DateTime.utc(2026, 8, 4),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('p1'),
        ),
      ),
    );
  });

  test('rejects passage with no questions at all', () {
    final passage = {
      'id': 'p1',
      'title': 'The Harvest',
      'body': makeBody(200),
    };

    expect(
      () => parsePassagesAndQuestions(
        rawPassages: [passage],
        rawQuestions: [],
        meta: meta,
        updatedAt: DateTime.utc(2026, 8, 4),
      ),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('p1'),
        ),
      ),
    );
  });
}
