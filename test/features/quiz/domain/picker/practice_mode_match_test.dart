import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';

({PracticeIndex index, List<PracticeUnit> units}) pools(List<int> capacities) {
  final lessons = [
    for (final (i, capacity) in capacities.indexed)
      PracticeLessonEntry(
        id: 'l$i',
        title: 'Lesson $i',
        isRead: true,
        questionCount: capacity,
      ),
  ];
  return (
    index: PracticeIndex([
      PracticeSubjectEntry(
        id: 's',
        name: 'Subject',
        topics: [
          PracticeTopicEntry(
            id: 't',
            name: 'Topic',
            questionCount: capacities.fold<int>(0, (sum, n) => sum + n),
            lessons: lessons,
          ),
        ],
      ),
    ]),
    units: [
      for (final lesson in lessons)
        PracticeUnit(topicId: 't', lessonId: lesson.id),
    ],
  );
}

final questionValues = [for (var n = 3; n <= 50; n++) n];
final timeValues = [for (var n = 5; n <= 60; n += 5) n];

void main() {
  test('ten questions across six lessons match fifty total minutes', () {
    final data = pools(List.filled(6, 50));
    final value = BuildPracticeSummary.closestValue(
      units: data.units,
      index: data.index,
      totalQuestions: 60,
      values: timeValues,
      mode: PracticeUnitMode.minutes,
    );
    expect(value, 50);
  });

  test('matching evaluates actual capped totals in each destination', () {
    final data = pools([2, 4, 50]);
    expect(
      BuildPracticeSummary.closestValue(
        units: data.units,
        index: data.index,
        totalQuestions: 16,
        values: timeValues,
        mode: PracticeUnitMode.minutes,
      ),
      25,
    );
    expect(
      BuildPracticeSummary.closestValue(
        units: data.units,
        index: data.index,
        totalQuestions: 16,
        values: questionValues,
        mode: PracticeUnitMode.questions,
      ),
      10,
    );
  });

  test('short pools do not divide aggregate totals into a wrong base', () {
    final data = pools([2, 50]);
    expect(
      BuildPracticeSummary.closestValue(
        units: data.units,
        index: data.index,
        totalQuestions: 8,
        values: questionValues,
        mode: PracticeUnitMode.questions,
      ),
      6,
    );
  });

  test('quantized ties are deterministic and toggles settle', () {
    final data = pools([50, 50, 50]);
    var total = 21;
    for (var i = 0; i < 5; i++) {
      final minutes = BuildPracticeSummary.closestValue(
        units: data.units,
        index: data.index,
        totalQuestions: total,
        values: timeValues.reversed,
        mode: PracticeUnitMode.minutes,
      )!;
      expect(minutes, 15);
      final time = BuildPracticeSummary.call(
        units: data.units,
        index: data.index,
        wheelValue: minutes,
        mode: PracticeUnitMode.minutes,
      );
      final perLesson = BuildPracticeSummary.closestValue(
        units: data.units,
        index: data.index,
        totalQuestions: time.totalQuestions,
        values: questionValues.reversed,
        mode: PracticeUnitMode.questions,
      )!;
      expect(perLesson, 6);
      total = BuildPracticeSummary.call(
        units: data.units,
        index: data.index,
        wheelValue: perLesson,
        mode: PracticeUnitMode.questions,
      ).totalQuestions;
      expect(total, 18);
    }
  });

  test('invalid short times are excluded and no selection has no conversion',
      () {
    final data = pools(List.filled(8, 50));
    expect(
      BuildPracticeSummary.closestValue(
        units: data.units,
        index: data.index,
        totalQuestions: 8,
        values: const [5],
        mode: PracticeUnitMode.minutes,
      ),
      isNull,
    );
    expect(
      BuildPracticeSummary.closestValue(
        units: const [],
        index: data.index,
        totalQuestions: 0,
        values: timeValues,
        mode: PracticeUnitMode.minutes,
      ),
      isNull,
    );
  });
}
