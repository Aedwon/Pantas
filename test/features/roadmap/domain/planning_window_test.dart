import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

void main() {
  group('PlanningWindows.resolve', () {
    test('sizes the September to December window from calendar dates', () {
      // October has 31 days, November 30, and December contributes 7.
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 9, 30),
        examDate: ExamDate.onDay(DateTime(2026, 12, 7)),
      );

      expect(window.state, RoadmapState.planning);
      expect(window.examDay, DateTime(2026, 12, 7));
      expect(window.daysLeft, 68);
      expect(window.quiet, 7);
      expect(window.workingDays, 61);
      expect(window.reviewOnlyFrom, DateTime(2026, 11, 30));
      // 61 * 1 < 120 <= 61 * 2; 61 * 14 < 900 <= 61 * 15.
      expect(PlanningWindows.perDay(120, window.workingDays), 2);
      expect(PlanningWindows.perDay(900, window.workingDays), 15);
    });

    for (final (distance, quiet, workingDays, reviewDay) in [
      (10, 2, 8, DateTime(2026, 10, 8)),
      (4, 1, 3, DateTime(2026, 10, 3)),
      (1, 0, 1, DateTime(2026, 10)),
    ]) {
      test('reserves the quiet stretch with $distance days left', () {
        final window = PlanningWindows.resolve(
          today: DateTime(2026, 9, 30),
          examDate: ExamDate.onDay(DateTime(2026, 9, 30 + distance)),
        );

        expect(window.state, RoadmapState.planning);
        expect(window.daysLeft, distance);
        expect(window.quiet, quiet);
        expect(window.workingDays, workingDays);
        expect(window.reviewOnlyFrom, reviewDay);
      });
    }

    test('exam today has no new-material pacing', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 9, 30, 23, 59),
        examDate: ExamDate.onDay(DateTime(2026, 9, 30)),
      );

      expect(window.state, RoadmapState.reviewOnly);
      expect(window.daysLeft, 0);
      expect(window.quiet, 0);
      expect(window.workingDays, 0);
      expect(window.reviewOnlyFrom, DateTime(2026, 9, 30));
      expect(PlanningWindows.perDay(120, window.workingDays), 0);
    });

    test('exam yesterday waits for an answer with no pacing', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 9, 30),
        examDate: ExamDate.onDay(DateTime(2026, 9, 29)),
      );

      expect(window.state, RoadmapState.examPassedAwaitingAnswer);
      expect(window.examDay, DateTime(2026, 9, 29));
      expect(window.daysLeft, -1);
      expect(PlanningWindows.perDay(120, window.workingDays), 0);
    });

    test('a future exam month plans to its first day', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 9, 30),
        examDate: ExamDate.inMonth(year: 2026, month: 12),
      );

      expect(window.state, RoadmapState.planning);
      expect(window.examDay, DateTime(2026, 12));
      expect(window.daysLeft, 62);
      expect(window.quiet, 7);
      expect(window.workingDays, 55);
      expect(window.reviewOnlyFrom, DateTime(2026, 11, 24));
    });

    test('inside the exam month plans to its last day while awaiting the day',
        () {
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 12, 10),
        examDate: ExamDate.inMonth(year: 2026, month: 12),
      );

      expect(window.state, RoadmapState.monthStartedAwaitingDay);
      expect(window.examDay, DateTime(2026, 12, 31));
      expect(window.daysLeft, 21);
      expect(window.quiet, 5);
      expect(window.workingDays, 16);
      expect(window.reviewOnlyFrom, DateTime(2026, 12, 26));
    });

    test('the first day of the exam month starts awaiting the exact day', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 12),
        examDate: ExamDate.inMonth(year: 2026, month: 12),
      );

      expect(window.state, RoadmapState.monthStartedAwaitingDay);
      expect(window.examDay, DateTime(2026, 12, 31));
      expect(window.daysLeft, 30);
    });

    test('a completed exam month waits for an answer', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2027, 1, 2),
        examDate: ExamDate.inMonth(year: 2026, month: 12),
      );

      expect(window.state, RoadmapState.examPassedAwaitingAnswer);
      expect(window.examDay, DateTime(2026, 12, 31));
      expect(window.daysLeft, -2);
      expect(PlanningWindows.perDay(120, window.workingDays), 0);
    });

    test('the last day of a leap-year exam month has reviews only', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2028, 2, 29),
        examDate: ExamDate.inMonth(year: 2028, month: 2),
      );

      expect(window.state, RoadmapState.reviewOnly);
      expect(window.examDay, DateTime(2028, 2, 29));
      expect(window.daysLeft, 0);
      expect(window.workingDays, 0);
    });

    test('no exam date does not invent a planning window', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 9, 30),
        examDate: null,
      );

      expect(window.state, RoadmapState.planning);
      expect(window.examDay, isNull);
      expect(window.daysLeft, 0);
      expect(window.quiet, 0);
      expect(window.workingDays, 0);
      expect(window.reviewOnlyFrom, isNull);
    });

    test('counts calendar days and subtracts quiet days across fall DST', () {
      final window = PlanningWindows.resolve(
        today: DateTime(2026, 10, 23, 23, 59),
        examDate: ExamDate.onDay(DateTime(2026, 11, 2)),
      );

      expect(window.daysLeft, 10);
      expect(window.workingDays, 8);
      expect(window.reviewOnlyFrom, DateTime(2026, 10, 31));
      expect(window.reviewOnlyFrom!.hour, 0);
      expect(window.reviewOnlyFrom!.isUtc, isFalse);
    });
  });

  group('PlanningWindows.perDay', () {
    test('rounds up only when a remainder exists', () {
      expect(PlanningWindows.perDay(16, 8), 2);
      expect(PlanningWindows.perDay(17, 8), 3);
      expect(PlanningWindows.perDay(1, 61), 1);
      expect(PlanningWindows.perDay(0, 61), 0);
    });

    test('no working days assigns no new material', () {
      expect(PlanningWindows.perDay(900, 0), 0);
      expect(PlanningWindows.perDay(900, -2), 0);
    });
  });

  group('immutable value types', () {
    test('scores require at least three answers to be measured', () {
      expect(
        const RoadmapTopicScore(id: 'topic', correct: 2, answered: 2)
            .isMeasured,
        isFalse,
      );
      expect(
        const RoadmapTopicScore(id: 'topic', correct: 2, answered: 3)
            .isMeasured,
        isTrue,
      );
    });

    test('day plans own their lists and sets and count both question types',
        () {
      final lessons = <String>['lesson'];
      final reviews = <String>['review'];
      final fresh = <String>['new1', 'new2'];
      final advanced = <String>{'new2'};
      final plan = DayPlan(
        day: DateTime(2026, 9, 30),
        lessonIds: lessons,
        reviewQuestionIds: reviews,
        newQuestionIds: fresh,
        isMockDay: false,
        advancedIds: advanced,
      );
      final equal = DayPlan(
        day: DateTime(2026, 9, 30),
        lessonIds: const ['lesson'],
        reviewQuestionIds: const ['review'],
        newQuestionIds: const ['new1', 'new2'],
        isMockDay: false,
        advancedIds: const {'new2'},
      );
      final hash = plan.hashCode;

      lessons.clear();
      reviews.clear();
      fresh.clear();
      advanced.clear();

      expect(plan.questionCount, 3);
      expect(plan, equal);
      expect(plan.hashCode, hash);
      expect(plan.hashCode, equal.hashCode);
      expect(plan.lessonIds.clear, throwsUnsupportedError);
      expect(plan.reviewQuestionIds.clear, throwsUnsupportedError);
      expect(plan.newQuestionIds.clear, throwsUnsupportedError);
      expect(plan.advancedIds.clear, throwsUnsupportedError);
    });

    test('inputs copy nested prerequisites and compare maps and sets by value',
        () {
      final prerequisites = <String, List<String>>{
        'topic2': ['topic1'],
        'topic3': ['topic1'],
      };
      final seen = <String>{'q1', 'q2'};
      final first = _inputs(prerequisites: prerequisites, seen: seen);
      final equal = _inputs(
        prerequisites: {
          'topic3': ['topic1'],
          'topic2': ['topic1'],
        },
        seen: {'q2', 'q1'},
      );
      final hash = first.hashCode;

      prerequisites['topic2']!.clear();
      prerequisites.clear();
      seen.clear();

      expect(first, equal);
      expect(first.hashCode, equal.hashCode);
      expect(first.hashCode, hash);
      expect(
        first == _inputs(prerequisites: const {}, seen: const {}),
        isFalse,
      );
      expect(first.prerequisites.clear, throwsUnsupportedError);
      expect(
        first.prerequisites['topic2']!.clear,
        throwsUnsupportedError,
      );
      expect(first.topics.clear, throwsUnsupportedError);
      expect(first.lessons.clear, throwsUnsupportedError);
      expect(first.questions.clear, throwsUnsupportedError);
      expect(first.seenQuestionIds.clear, throwsUnsupportedError);
      expect(first.dueReviews.clear, throwsUnsupportedError);
      expect(first.scores.clear, throwsUnsupportedError);
      expect(first.answeredPerActiveDay.clear, throwsUnsupportedError);
    });

    test('ordered lists affect equality while set insertion order does not',
        () {
      DayPlan plan(List<String> questions, Set<String> advanced) => DayPlan(
            day: DateTime(2026, 9, 30),
            lessonIds: const [],
            reviewQuestionIds: const [],
            newQuestionIds: questions,
            isMockDay: false,
            advancedIds: advanced,
          );

      final first = plan(['q1', 'q2'], {'q1', 'q2'});
      final equal = plan(['q1', 'q2'], {'q2', 'q1'});
      expect(first, equal);
      expect(first.hashCode, equal.hashCode);
      expect(first == plan(['q2', 'q1'], {'q1', 'q2'}), isFalse);
    });

    test('roadmaps compare nested values and protect preview and change lists',
        () {
      Roadmap roadmap() => Roadmap(
            state: RoadmapState.planning,
            today: DayPlan(
              day: DateTime(2026, 9, 30),
              lessonIds: const ['lesson'],
              reviewQuestionIds: const [],
              newQuestionIds: const ['question'],
              isMockDay: false,
              advancedIds: const {},
            ),
            examDay: DateTime(2026, 12, 7),
            reviewOnlyFrom: DateTime(2026, 11, 30),
            mockDay: DateTime(2026, 12),
            weeksAhead: [
              WeekPreview(
                weekStart: DateTime(2026, 10, 5),
                topicIds: const ['topic'],
              ),
            ],
            topicOrder: const ['topic'],
            changes: [
              RoadmapChange(
                cause: RoadmapChangeCause.newDay,
                occurredAt: DateTime(2026, 9, 30),
                before: const RoadmapDayCounts(
                  lessons: 0,
                  newQuestions: 0,
                  reviews: 0,
                ),
                after: const RoadmapDayCounts(
                  lessons: 1,
                  newQuestions: 1,
                  reviews: 0,
                ),
                firstTopicsBefore: const [],
                firstTopicsAfter: const ['topic'],
              ),
            ],
          );

      final first = roadmap();
      final equal = roadmap();
      expect(first, equal);
      expect(first.hashCode, equal.hashCode);
      expect(first.weeksAhead.clear, throwsUnsupportedError);
      expect(
        first.weeksAhead.single.topicIds.clear,
        throwsUnsupportedError,
      );
      expect(first.topicOrder.clear, throwsUnsupportedError);
      expect(first.changes.clear, throwsUnsupportedError);
      expect(
        first.changes.single.firstTopicsBefore.clear,
        throwsUnsupportedError,
      );
      expect(
        first.changes.single.firstTopicsAfter.clear,
        throwsUnsupportedError,
      );
    });

    test('planning windows compare by value', () {
      final first = PlanningWindows.resolve(
        today: DateTime(2026, 9, 30),
        examDate: ExamDate.onDay(DateTime(2026, 12, 7)),
      );
      final equal = PlanningWindows.resolve(
        today: DateTime(2026, 9, 30),
        examDate: ExamDate.onDay(DateTime(2026, 12, 7)),
      );
      final different = PlanningWindows.resolve(
        today: DateTime(2026, 10),
        examDate: ExamDate.onDay(DateTime(2026, 12, 7)),
      );

      expect(first, equal);
      expect(first.hashCode, equal.hashCode);
      expect(first == different, isFalse);
    });
  });
}

RoadmapInputs _inputs({
  required Map<String, List<String>> prerequisites,
  required Set<String> seen,
}) =>
    RoadmapInputs(
      today: DateTime(2026, 9, 30),
      examId: 'exam',
      examDate: ExamDate.onDay(DateTime(2026, 12, 7)),
      topics: const [
        RoadmapTopic(id: 'topic1', authoredIndex: 0, name: 'Topic 1'),
      ],
      prerequisites: prerequisites,
      lessons: [
        RoadmapLesson(
          id: 'lesson',
          topicId: 'topic1',
          ordering: 0,
          readAt: DateTime(2026, 9, 29),
        ),
      ],
      questions: const [
        RoadmapQuestion(
          id: 'q1',
          topicId: 'topic1',
          lessonId: 'lesson',
          passageId: 'passage',
        ),
      ],
      seenQuestionIds: seen,
      dueReviews: [
        RoadmapReview(
          id: 'q1',
          due: DateTime(2026, 9, 30),
          retrievability: 0.8,
        ),
      ],
      scores: const {
        'topic1': RoadmapTopicScore(id: 'topic1', correct: 2, answered: 3),
      },
      answeredPerActiveDay: const [3, 5],
      mock: RoadmapMockFacts(
        examHasMock: true,
        proIsActive: false,
        lastSubmittedAt: DateTime(2026, 9),
      ),
      assessmentCompleted: true,
      contentRevision: 'revision',
    );
