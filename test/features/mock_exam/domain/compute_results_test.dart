import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scores correct answers and treats missing answers as incorrect', () {
    final results = ComputeMockResults().call(
      sample: _sample(['q1', 'q2']),
      questionsById: {
        'q1': _question('q1', topicId: 'topic_a', correctIndex: 1),
        'q2': _question('q2', topicId: 'topic_a', correctIndex: 0),
      },
      answers: const {
        'q1': MockAnswer(selectedIndex: 1, atSec: 12),
      },
      totalTimeSeconds: 120,
      wasStrict: false,
      scoreBands: null,
    );

    expect(results.scoreRaw, 1);
    expect(results.scoreTotal, 2);
    expect(results.percent, 50);
    // This blueprint publishes no thresholds, so there is no band.
    expect(results.band, isNull);
  });

  test('excludes retired or missing questions from scoreTotal', () {
    final results = ComputeMockResults().call(
      sample: _sample(['q1', 'retired']),
      questionsById: {
        'q1': _question('q1', topicId: 'topic_a', correctIndex: 0),
      },
      answers: const {
        'q1': MockAnswer(selectedIndex: 0, atSec: 10),
        'retired': MockAnswer(selectedIndex: 0, atSec: 20),
      },
      totalTimeSeconds: 30,
      wasStrict: false,
      scoreBands: null,
    );

    expect(results.scoreRaw, 1);
    expect(results.scoreTotal, 1);
    expect(results.sections.single.retiredCount, 1);
  });

  test('computes section time from max answer atSec boundaries', () {
    final results = ComputeMockResults().call(
      sample: const MockSample(
        expectedQuestionCount: 4,
        sections: [
          SampledMockSection(
            sectionId: 's1',
            name: 'Part 1',
            questionIds: ['q1', 'q2'],
          ),
          SampledMockSection(
            sectionId: 's2',
            name: 'Part 2',
            questionIds: ['q3', 'q4'],
          ),
        ],
      ),
      questionsById: {
        for (final id in ['q1', 'q2', 'q3', 'q4'])
          id: _question(id, topicId: 'topic_a', correctIndex: 0),
      },
      answers: const {
        'q1': MockAnswer(selectedIndex: 0, atSec: 10),
        'q2': MockAnswer(selectedIndex: 0, atSec: 20),
        'q3': MockAnswer(selectedIndex: 0, atSec: 45),
      },
      totalTimeSeconds: 60,
      wasStrict: false,
      scoreBands: null,
    );

    expect(results.sections.map((section) => section.timeSeconds), [20, 25]);
  });

  test("the bands are the exam's own thresholds", () {
    final computer = ComputeMockResults();
    const bands = ScoreBands(passAtPercent: 70, closeAtPercent: 55);

    expect(
      computer.bandFor(scoreRaw: 7, scoreTotal: 10, scoreBands: bands),
      ScoreBand.pass,
    );
    expect(
      computer.bandFor(scoreRaw: 6, scoreTotal: 10, scoreBands: bands),
      ScoreBand.close,
    );
    expect(
      computer.bandFor(scoreRaw: 5, scoreTotal: 10, scoreBands: bands),
      ScoreBand.fail,
    );
  });

  test('an exam that publishes no thresholds gets no band', () {
    final computer = ComputeMockResults();

    // Not "Fail": nothing said what passing is.
    expect(
      computer.bandFor(scoreRaw: 3, scoreTotal: 4, scoreBands: null),
      isNull,
    );
  });

  test('top weak topics require at least two sampled questions', () {
    final results = ComputeMockResults().call(
      sample: _sample(['a1', 'a2', 'b1', 'b2', 'c1']),
      questionsById: {
        'a1': _question('a1', topicId: 'topic_a', correctIndex: 0),
        'a2': _question('a2', topicId: 'topic_a', correctIndex: 0),
        'b1': _question('b1', topicId: 'topic_b', correctIndex: 0),
        'b2': _question('b2', topicId: 'topic_b', correctIndex: 0),
        'c1': _question('c1', topicId: 'topic_c', correctIndex: 0),
      },
      answers: const {
        'a1': MockAnswer(selectedIndex: 1, atSec: 1),
        'a2': MockAnswer(selectedIndex: 1, atSec: 2),
        'b1': MockAnswer(selectedIndex: 0, atSec: 3),
        'b2': MockAnswer(selectedIndex: 1, atSec: 4),
        'c1': MockAnswer(selectedIndex: 1, atSec: 5),
      },
      totalTimeSeconds: 10,
      wasStrict: false,
      scoreBands: null,
    );

    expect(
      results.topWeak.map((topic) => topic.topicId),
      ['topic_a', 'topic_b'],
    );
    expect(results.topWeak.map((topic) => topic.drillRoute), [
      '/quiz/drill?topicId=topic_a',
      '/quiz/drill?topicId=topic_b',
    ]);
  });
}

MockSample _sample(List<String> questionIds) {
  return MockSample(
    expectedQuestionCount: questionIds.length,
    sections: [
      SampledMockSection(
        sectionId: 's1',
        name: 'Part 1',
        questionIds: questionIds,
      ),
    ],
  );
}

Question _question(
  String id, {
  required String topicId,
  required int correctIndex,
}) {
  return Question(
    id: id,
    version: 1,
    examIds: const ['exam_cse'],
    topicId: topicId,
    language: 'en',
    stem: 'Question $id',
    choices: [
      Choice(
        id: '${id}_a',
        label: 'A',
        text: 'A',
        isCorrect: correctIndex == 0,
      ),
      Choice(
        id: '${id}_b',
        label: 'B',
        text: 'B',
        isCorrect: correctIndex == 1,
      ),
    ],
    explanation: 'Because.',
  );
}
