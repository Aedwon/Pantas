import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/home/application/plan_data.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

void main() {
  test('week labels distinguish current and next Sunday weeks', () {
    expect(
      planWeekLabel(DateTime(2026, 10, 5), DateTime(2026, 10, 4)),
      'This week',
    );
    expect(
      planWeekLabel(DateTime(2026, 10, 5), DateTime(2026, 10, 11)),
      'Next week',
    );
    expect(
      planWeekLabel(DateTime(2026, 10, 5), DateTime(2026, 10, 18)),
      isNull,
    );
  });

  test('past completion uses shared-question observations through the day', () {
    final facts = completedPlanFacts(DateTime(2026, 10, 25), const {}, [
      Attempt(
        id: 'a',
        examId: 'other-exam',
        startedAt: DateTime(2026, 10, 25),
        completedAt: DateTime(2026, 10, 25, 12),
        items: const [
          AttemptItem(
            questionId: 'shared',
            questionVersion: 1,
            chosenChoiceId: 'a',
            correctChoiceId: 'a',
            responseMs: 1000,
          ),
        ],
      ),
      Attempt(
        id: 'future',
        examId: 'same-exam',
        startedAt: DateTime(2026, 10, 26),
        completedAt: DateTime(2026, 10, 26, 12),
        items: const [
          AttemptItem(
            questionId: 'future',
            questionVersion: 1,
            chosenChoiceId: 'a',
            correctChoiceId: 'a',
            responseMs: 1000,
          ),
        ],
      ),
    ]);
    expect(facts.reviewedTodayIds, {'shared'});
    expect(facts.seenQuestionIds, {'shared'});
  });

  test('an early read preserves the opened day and its actual read state', () {
    final date = DateTime(2026, 10, 26);
    DayPlan plan(List<String> ids) => DayPlan(
          day: date,
          lessonIds: ids,
          reviewQuestionIds: const [],
          newQuestionIds: const [],
          isMockDay: false,
          advancedIds: const {},
        );
    final opened = PlanDayView(
      date: date,
      plan: plan(['l']),
      remaining: null,
      lessons: const [
        HomeTodayLesson(
          id: 'l',
          title: 'Cells',
          subject: 'Science',
          minutes: 8,
          read: false,
        ),
      ],
      kind: 'future',
    );
    final fresh = PlanDayView(
      date: date,
      plan: plan(['next']),
      remaining: null,
      lessons: const [],
      kind: 'future',
      readLessonIds: const {'l'},
    );
    final shown = retainOpenedPlanDay(opened, fresh);
    expect(shown.plan!.lessonIds, ['l']);
    expect(shown.lessons.single.read, isTrue);
    expect(shown.lessons.single.title, 'Cells');
  });

  test('plan Today counts checklist items instead of individual questions', () {
    DayPlan plan(
      List<String> lessons,
      List<String> reviews,
      List<String> fresh,
    ) =>
        DayPlan(
          day: DateTime(2026, 10, 25),
          lessonIds: lessons,
          reviewQuestionIds: reviews,
          newQuestionIds: fresh,
          isMockDay: false,
          advancedIds: const {},
        );
    final summary = planChecklistProgress(
      plan(['l1', 'l2'], ['r1', 'r2'], ['n1', 'n2', 'n3']),
      plan([], ['r2'], ['n1', 'n2', 'n3']),
    );
    expect(summary, (done: 2, total: 4));
  });

  RoadmapChange change(RoadmapChangeCause cause) => RoadmapChange(
        cause: cause,
        occurredAt: DateTime(2026, 10, 25),
        firstTopicsBefore: const [],
        firstTopicsAfter: const [],
      );
  test('history uses known causes without reconstructing absent details', () {
    expect(
      planHistoryText(
        change(RoadmapChangeCause.examChanged),
        examName: 'CSE-P',
      ),
      'Your plan changed on Oct 25.',
    );
    expect(
      planHistoryText(
        change(RoadmapChangeCause.examPassed),
        examName: 'CSE-P',
      ),
      'Your exam date passed. Your plan waits for a new date.',
    );
    expect(
      planHistoryText(
        change(RoadmapChangeCause.missingExamDate),
        examName: 'CSE-P',
      ),
      'Your exam date was removed. Your plan is rebuilt when you set one.',
    );
    expect(
      planHistoryText(
        change(RoadmapChangeCause.assessmentCompleted),
        examName: 'CSE-P',
      ),
      'Your plan was built from your assessment results.',
    );
    expect(
      planHistoryText(
        change(RoadmapChangeCause.prerequisiteCycle),
        examName: 'CSE-P',
      ),
      isNull,
    );
    expect(
      planHistoryText(change(RoadmapChangeCause.newDay), examName: 'CSE-P'),
      isNull,
    );
    expect(
      planHistoryText(
        change(RoadmapChangeCause.examDateChanged),
        examName: 'CSE-P',
      ),
      'Your plan changed on Oct 25.',
    );
  });
  test('week labels preserve Sunday boundaries and custom study days', () {
    expect(planWeekTitle(DateTime(2026, 9, 27)), 'Sep 27 – Oct 3');
    expect(planWeekTitle(DateTime(2026, 10, 4)), 'Oct 4 – 10');
    expect(
      planStudyDaysLabel({1, 2, 3, 4, 5, 6}),
      'You study Monday to Saturday.',
    );
    expect(
      planStudyDaysLabel({1, 3, 5, 6}),
      'You study Monday, Wednesday, Friday and Saturday.',
    );
  });
}
