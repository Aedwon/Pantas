import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';
import 'package:pantas/features/quiz/domain/picker/practice_summary.dart';

void main() {
  const index = PracticeIndex([
    PracticeSubjectEntry(
      id: 's',
      name: 'Subject',
      topics: [
        PracticeTopicEntry(
          id: 't',
          name: 'Topic',
          questionCount: 40,
          lessons: [
            PracticeLessonEntry(
              id: 'a',
              title: 'A',
              isRead: true,
              questionCount: 20,
            ),
            PracticeLessonEntry(
              id: 'b',
              title: 'B',
              isRead: true,
              questionCount: 20,
            ),
          ],
        ),
      ],
    ),
  ]);
  const units = [
    PracticeUnit(topicId: 't', lessonId: 'a'),
    PracticeUnit(topicId: 't', lessonId: 'b'),
  ];

  test('Questions adjustment changes count and time without changing base', () {
    final base = BuildPracticeSummary.call(
      units: units.take(1).toList(),
      index: index,
      wheelValue: 10,
      mode: PracticeUnitMode.questions,
    );
    final counts = BuildPracticeSummary.adjust(
      base,
      {'lesson:a'},
      1,
      preserveTotal: false,
    )!;
    final changed = BuildPracticeSummary.call(
      units: units.take(1).toList(),
      index: index,
      wheelValue: 10,
      mode: PracticeUnitMode.questions,
      adjustments: counts,
    );
    expect(changed.countsByUnit, {'lesson:a': 11});
    expect(changed.totalQuestions, 11);
    expect(changed.estimatedMinutes, 9);
    expect(changed.perUnit, 10);
  });

  test('Total time adjustment moves a question and preserves total budget', () {
    final base = BuildPracticeSummary.call(
      units: units,
      index: index,
      wheelValue: 30,
      mode: PracticeUnitMode.minutes,
    );
    final counts = BuildPracticeSummary.adjust(
      base,
      {'lesson:a'},
      1,
      preserveTotal: true,
    )!;
    expect(counts, {'lesson:a': 19, 'lesson:b': 17});
    final changed = BuildPracticeSummary.call(
      units: units,
      index: index,
      wheelValue: 30,
      mode: PracticeUnitMode.minutes,
      adjustments: counts,
    );
    expect(changed.totalQuestions, 36);
    expect(changed.estimatedMinutes, 30);
  });

  test('singleton Total time has no alternate allocation', () {
    final base = BuildPracticeSummary.call(
      units: units.take(1).toList(),
      index: index,
      wheelValue: 10,
      mode: PracticeUnitMode.minutes,
    );
    expect(
      BuildPracticeSummary.adjust(
        base,
        {'lesson:a'},
        1,
        preserveTotal: true,
      ),
      isNull,
    );
    expect(
      BuildPracticeSummary.adjust(
        base,
        {'lesson:a'},
        -1,
        preserveTotal: true,
      ),
      isNull,
    );
  });

  test('manual counts stay within real pool and keep a question per pick', () {
    final full = BuildPracticeSummary.call(
      units: units.take(1).toList(),
      index: index,
      wheelValue: 20,
      mode: PracticeUnitMode.questions,
    );
    expect(
      BuildPracticeSummary.adjust(
        full,
        {'lesson:a'},
        1,
        preserveTotal: false,
      ),
      isNull,
    );
    final one = BuildPracticeSummary.call(
      units: units.take(1).toList(),
      index: index,
      wheelValue: 3,
      mode: PracticeUnitMode.questions,
      adjustments: const {'lesson:a': 1},
    );
    expect(
      BuildPracticeSummary.adjust(
        one,
        {'lesson:a'},
        -1,
        preserveTotal: false,
      ),
      isNull,
    );
  });

  test('uneven time split and real pool shortfall use actual counts', () {
    final many = PracticeIndex([
      PracticeSubjectEntry(
        id: 's',
        name: 'Subject',
        topics: [
          PracticeTopicEntry(
            id: 't',
            name: 'Topic',
            questionCount: 200,
            lessons: [
              for (var i = 0; i < 8; i++)
                PracticeLessonEntry(
                  id: '$i',
                  title: '$i',
                  isRead: true,
                  questionCount: 20,
                ),
            ],
          ),
        ],
      ),
    ]);
    final all = [
      for (var i = 0; i < 8; i++) PracticeUnit(topicId: 't', lessonId: '$i'),
    ];
    final split = BuildPracticeSummary.call(
      units: all,
      index: many,
      wheelValue: 10,
      mode: PracticeUnitMode.minutes,
    );
    expect(split.countsByUnit.values, [2, 2, 2, 2, 1, 1, 1, 1]);
    final short = BuildPracticeSummary.call(
      units: units.take(1).toList(),
      index: index,
      wheelValue: 50,
      mode: PracticeUnitMode.questions,
    );
    expect(short.totalQuestions, 20);
    expect(short.estimatedMinutes, 17);
  });

  test('stale Total time overrides cannot change the current question budget',
      () {
    final recalculated = BuildPracticeSummary.call(
      units: units,
      index: index,
      wheelValue: 10,
      mode: PracticeUnitMode.minutes,
      adjustments: const {'lesson:a': 20, 'lesson:b': 20},
    );
    expect(recalculated.totalQuestions, 12);
    expect(recalculated.countsByUnit, {'lesson:a': 6, 'lesson:b': 6});
  });
}
