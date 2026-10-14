import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';

void main() {
  final topic = PracticeTopicEntry(
    id: 't',
    name: 'Algebra',
    questionCount: 60,
    lessons: [
      for (var i = 1; i <= 3; i++)
        PracticeLessonEntry(
          id: 'l$i',
          title: 'Lesson $i',
          isRead: false,
          questionCount: 20,
        ),
    ],
  );
  final index = PracticeIndex([
    PracticeSubjectEntry(id: 's', name: 'Mathematics', topics: [topic]),
  ]);

  test('selecting a topic contributes one unit for each lesson', () {
    final picked = const PracticeSelection.empty().toggleTopic(topic);
    expect(picked.units(index).map((u) => u.lessonId), ['l1', 'l2', 'l3']);
  });

  test('questions mode uses the approved initial pace of 50 seconds', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't', lessonId: 'l1')],
      index: index,
      wheelValue: 12,
      mode: PracticeUnitMode.questions,
    );
    expect(summary.totalQuestions, 12);
    expect(summary.estimatedMinutes, 10);
  });

  test('total time is divided across lessons instead of multiplied', () {
    final summary = BuildPracticeSummary.call(
      units: const [
        PracticeUnit(topicId: 't', lessonId: 'l1'),
        PracticeUnit(topicId: 't', lessonId: 'l2'),
        PracticeUnit(topicId: 't', lessonId: 'l3'),
      ],
      index: index,
      wheelValue: 10,
      mode: PracticeUnitMode.minutes,
      averageResponseMs: 50000,
    );
    expect(summary.totalQuestions, 12);
    expect(summary.perUnit, 4);
  });

  test('measured pace replaces the approved initial pace', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't', lessonId: 'l1')],
      index: index,
      wheelValue: 12,
      mode: PracticeUnitMode.questions,
      averageResponseMs: 25000,
    );
    expect(summary.estimatedMinutes, 5);
  });

  test('positive sub-minute pace remains measured without clamping', () {
    final summary = BuildPracticeSummary.call(
      units: const [PracticeUnit(topicId: 't', lessonId: 'l1')],
      index: index,
      wheelValue: 3,
      mode: PracticeUnitMode.questions,
      averageResponseMs: 5000,
    );
    expect(summary.totalQuestions, 3);
    expect(summary.estimatedMinutes, 0);
  });

  test('empty pool keeps a zero estimate regardless of positive pace', () {
    final summary = BuildPracticeSummary.call(
      units: const [],
      index: index,
      wheelValue: 3,
      mode: PracticeUnitMode.questions,
      averageResponseMs: 5000,
    );
    expect(summary.totalQuestions, 0);
    expect(summary.estimatedMinutes ?? 0, 0);
  });

  test('no questions in a lesson never become a selectable unit', () {
    final sparse = PracticeTopicEntry(
      id: 't',
      name: 'Algebra',
      questionCount: 20,
      lessons: [
        topic.lessons.first,
        const PracticeLessonEntry(
          id: 'empty',
          title: 'Empty',
          isRead: false,
          questionCount: 0,
        ),
      ],
    );
    final idx = PracticeIndex([
      PracticeSubjectEntry(id: 's', name: 'Mathematics', topics: [sparse]),
    ]);
    final picked = const PracticeSelection.empty().toggleTopic(sparse);
    expect(picked.units(idx).map((u) => u.lessonId), ['l1']);
    expect(picked.lessonSelected('empty'), isFalse);
  });

  for (final pace in [0, -50000]) {
    test('nonpositive pace $pace uses approved initial estimate for questions',
        () {
      final summary = BuildPracticeSummary.call(
        units: const [PracticeUnit(topicId: 't', lessonId: 'l1')],
        index: index,
        wheelValue: 12,
        mode: PracticeUnitMode.questions,
        averageResponseMs: pace,
      );
      expect(summary.totalQuestions, 12);
      expect(summary.estimatedMinutes, 10);
    });
    test('nonpositive pace $pace uses bounded total-time budget', () {
      final summary = BuildPracticeSummary.call(
        units: const [PracticeUnit(topicId: 't', lessonId: 'l1')],
        index: index,
        wheelValue: 10,
        mode: PracticeUnitMode.minutes,
        averageResponseMs: pace,
      );
      expect(summary.totalQuestions, 12);
      expect(summary.estimatedMinutes, 10);
    });
  }
}
