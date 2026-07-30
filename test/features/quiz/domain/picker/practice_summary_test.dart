import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';

PracticeTopicEntry topic(String id, int questionCount) => PracticeTopicEntry(
      id: id,
      name: 'Topic $id',
      questionCount: questionCount,
      lessons: const [],
    );

final index = PracticeIndex([
  PracticeSubjectEntry(
    id: 'subject_maths',
    name: 'Mathematics',
    topics: [topic('t_1', 40), topic('t_2', 40), topic('t_3', 8)],
  ),
]);

void main() {
  test('nothing selected says so', () {
    final summary = BuildPracticeSummary.call(
      units: const [],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.totalQuestions, 0);
    expect(summary.detail, 'Pick a topic or a lesson above.');
  });

  test('three full pools give the wheel value each', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
      ],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.totalQuestions, 30);
    expect(summary.headline, '30 questions');
    expect(summary.detail, '15 from each of 2 selections');
  });

  test('a short pool is named in the detail line', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
        PracticeUnit(topicId: 't_3'),
      ],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.totalQuestions, 38);
    expect(summary.shortfallCount, 1);
    expect(summary.detail, '15 from each of 3 selections, 1 had fewer');
  });

  test('one selection reads in the singular', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't_1')],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.detail, '15 from 1 selection');
  });

  test('no pace means no duration', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't_1')],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
    );

    expect(summary.estimatedMinutes, isNull);
    expect(summary.headline, '15 questions');
  });

  test('a measured pace adds the duration', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
      ],
      index: index,
      wheelValue: 15,
      mode: PracticeUnitMode.questions,
      // 40 seconds a question, 30 questions, 20 minutes.
      averageResponseMs: 40000,
    );

    expect(summary.estimatedMinutes, 20);
    expect(summary.headline, '30 questions · about 20 min');
  });

  test('minutes mode converts through the pace', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't_1'),
        PracticeUnit(topicId: 't_2'),
      ],
      index: index,
      // 20 minutes each, at 40 seconds a question, is 30 each.
      wheelValue: 20,
      mode: PracticeUnitMode.minutes,
      averageResponseMs: 40000,
    );

    expect(summary.perUnit, 30);
    expect(summary.totalQuestions, 60);
  });

  test('minutes mode without a pace asks for nothing', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't_1')],
      index: index,
      wheelValue: 20,
      mode: PracticeUnitMode.minutes,
    );

    expect(summary.totalQuestions, 0);
  });
}
