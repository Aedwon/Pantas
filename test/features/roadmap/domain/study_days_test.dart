import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/build_roadmap.dart';
import 'package:pantas/features/roadmap/domain/mock_day.dart';
import 'package:pantas/features/roadmap/domain/planning_window.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';
import 'package:pantas/features/roadmap/domain/week_preview.dart';

final weekdays = StudyDays(const [1, 2, 3, 4, 5]);
final start = DateTime(2026, 9, 30);
final exam = DateTime(2026, 12, 7);
final anchor = DateTime(2026, 11, 30);

RoadmapInputs inputs({
  DateTime? today,
  StudyDays studyDays = StudyDays.all,
  bool treatTodayAsStudyDay = false,
  DateTime? reviewOnlyFrom,
  int lessonCount = 120,
  int questionCount = 900,
  List<RoadmapReview> due = const [],
  List<int> history = const [],
}) =>
    RoadmapInputs(
      today: today ?? start,
      examId: 'e',
      examDate: ExamDate.onDay(exam),
      studyDays: studyDays,
      treatTodayAsStudyDay: treatTodayAsStudyDay,
      topics: const [RoadmapTopic(id: 't', authoredIndex: 0, name: 'T')],
      prerequisites: const {},
      lessons: [
        for (var i = 0; i < lessonCount; i++)
          RoadmapLesson(id: 'l$i', topicId: 't', ordering: i),
      ],
      questions: [
        for (var i = 0; i < questionCount; i++)
          RoadmapQuestion(id: 'q$i', topicId: 't'),
      ],
      seenQuestionIds: {for (final review in due) review.id},
      dueReviews: due,
      scores: const {},
      answeredPerActiveDay: history,
      mock: const RoadmapMockFacts(examHasMock: true, proIsActive: true),
      assessmentCompleted: true,
      contentRevision: 'r',
      anchoredReviewOnlyFrom: reviewOnlyFrom,
    );

void main() {
  test('mock placement chooses a study day later then earlier then none', () {
    for (final (today, target, days, expected) in [
      (
        start,
        DateTime(2026, 12, 2),
        StudyDays(const [4]),
        DateTime(2026, 12, 3)
      ),
      (start, DateTime(2026, 12, 6), weekdays, DateTime(2026, 12, 4)),
      (DateTime(2026, 12, 5), DateTime(2026, 12, 6), weekdays, null),
      (start, DateTime(2026, 12), StudyDays(const [1]), null),
    ]) {
      expect(
        MockDay.place(
          today: today,
          examDay: exam,
          reviewOnlyFrom: target,
          studyDays: days,
          mock: const RoadmapMockFacts(examHasMock: true, proIsActive: true),
          mockSubmittedInWindow: false,
        ),
        expected,
      );
    }
  });

  test('Free cooldown moves to the next study day inside the mock window', () {
    for (final (submitted, expected) in [
      (DateTime(2026, 11, 19), DateTime(2026, 12, 4)),
      (DateTime(2026, 11, 20), DateTime(2026, 12, 4)),
      (DateTime(2026, 11, 21), null),
    ]) {
      expect(
        MockDay.place(
          today: start,
          examDay: exam,
          reviewOnlyFrom: anchor,
          studyDays: StudyDays(const [3, 5]),
          mock: RoadmapMockFacts(
            examHasMock: true,
            proIsActive: false,
            lastSubmittedAt: submitted,
          ),
          mockSubmittedInWindow: false,
        ),
        expected,
      );
    }
  });

  test('week preview groups Monday lessons under the current Sunday', () {
    // A Monday-only lesson remaining on Sunday belongs to this Sunday week.
    final previews = WeekPreviews.build(
      today: DateTime(2026, 10, 3),
      reviewOnlyFrom: DateTime(2026, 10, 7),
      lessonTopicOrder: const ['t'],
      lessons: const [RoadmapLesson(id: 'l', topicId: 't', ordering: 0)],
      scheduledToday: const {},
      studyDays: StudyDays(const [1]),
    );
    expect(previews, [
      WeekPreview(weekStart: DateTime(2026, 10, 4), topicIds: const ['t']),
    ]);
    expect(
      WeekPreviews.build(
        today: DateTime(2026, 10, 3),
        reviewOnlyFrom: DateTime(2026, 10, 5),
        lessonTopicOrder: const ['t'],
        lessons: const [RoadmapLesson(id: 'l', topicId: 't', ordering: 0)],
        scheduledToday: const {},
        studyDays: StudyDays(const [1]),
      ),
      isEmpty,
    );
  });

  test('the weekday build assigns three lessons and twenty-one new questions',
      () {
    final plan = BuildRoadmap.call(inputs(studyDays: weekdays));
    final working = weekdays.countInRange(start, anchor);
    expect(plan.today.lessonIds.length, (120 / working).ceil());
    expect(plan.today.lessonIds, hasLength(3));
    expect(plan.today.newQuestionIds.length, (900 / working).ceil());
    expect(plan.today.newQuestionIds, hasLength(21));
    expect(plan.today.isRestDay, isFalse);
    expect(plan.reviewOnlyFrom, anchor);
  });

  test('weekly topics spread over study days left without losing later topics',
      () {
    final topics = ['a', 'b', 'c', 'd', 'e', 'f'];
    final previews = WeekPreviews.build(
      today: DateTime(2026, 10, 4),
      reviewOnlyFrom: DateTime(2026, 10, 20),
      lessonTopicOrder: topics,
      lessons: [
        for (final topic in topics)
          RoadmapLesson(id: 'l$topic', topicId: topic, ordering: 0),
      ],
      scheduledToday: const {},
      studyDays: StudyDays(const [1]),
    );
    expect(previews, [
      WeekPreview(weekStart: DateTime(2026, 10, 4), topicIds: const ['a', 'b']),
      WeekPreview(
        weekStart: DateTime(2026, 10, 11),
        topicIds: const ['c', 'd'],
      ),
      WeekPreview(
        weekStart: DateTime(2026, 10, 18),
        topicIds: const ['e', 'f'],
      ),
    ]);
  });

  test('Saturday holds no work and keeps the normal roadmap metadata', () {
    final saturday = DateTime(2026, 10, 3);
    final plan = BuildRoadmap.call(
      inputs(
        today: saturday,
        studyDays: weekdays,
        reviewOnlyFrom: anchor,
        due: [RoadmapReview(id: 'q0', due: saturday, retrievability: 0.8)],
      ),
    );
    expect(plan.today.lessonIds, isEmpty);
    expect(plan.today.newQuestionIds, isEmpty);
    expect(plan.today.reviewQuestionIds, isEmpty);
    expect(plan.today.isMockDay, isFalse);
    expect(plan.today.isRestDay, isTrue);
    expect(plan.state, RoadmapState.planning);
    expect(plan.examDay, exam);
    expect(plan.reviewOnlyFrom, anchor);
    expect(plan.mockDay, DateTime(2026, 12));
    expect(plan.weeksAhead, isNotEmpty);
    expect(plan.topicOrder, ['t']);
    final forced = BuildRoadmap.call(
      inputs(
        today: saturday,
        studyDays: weekdays,
        treatTodayAsStudyDay: true,
        reviewOnlyFrom: anchor,
      ),
    );
    expect(forced.today.isRestDay, isFalse);
    expect(forced.today.lessonIds, isNotEmpty);
  });

  test('review-only leftovers divide by study days before the exam', () {
    final plan = BuildRoadmap.call(
      inputs(
        today: DateTime(2026, 12, 3),
        studyDays: weekdays,
        reviewOnlyFrom: anchor,
        lessonCount: 8,
        questionCount: 40,
      ),
    );
    expect(plan.state, RoadmapState.reviewOnly);
    expect(plan.today.lessonIds, hasLength(4));
    expect(plan.today.newQuestionIds, hasLength(20));
    final cram = BuildRoadmap.call(
      inputs(
        today: DateTime(2026, 12, 5),
        studyDays: weekdays,
        treatTodayAsStudyDay: true,
        reviewOnlyFrom: anchor,
        lessonCount: 8,
        questionCount: 40,
      ),
    );
    expect(cram.today.lessonIds, hasLength(8));
    expect(cram.today.newQuestionIds, hasLength(40));
  });

  test('random study-day sets cover the corpus before the anchored stretch',
      () {
    for (var seed = 0; seed < 100; seed++) {
      final random = Random(seed);
      final days = StudyDays([
        1 + random.nextInt(7),
        for (var d = 1; d <= 7; d++)
          if (random.nextBool()) d,
      ]);
      final first = DateTime(2026, 10, 1 + random.nextInt(31));
      final examDay =
          DateTime(first.year, first.month, first.day + 1 + random.nextInt(90));
      final lessonCount = 1 + random.nextInt(100);
      final questionCount = 1 + random.nextInt(300);
      final lessons = [
        for (var i = 0; i < lessonCount; i++)
          RoadmapLesson(id: 'l$i', topicId: 't', ordering: i),
      ];
      final questions = [
        for (var i = 0; i < questionCount; i++)
          RoadmapQuestion(
            id: 'q$i',
            topicId: 't',
            lessonId: 'l${i % lessons.length}',
            passageId: i % 5 == 0 ? 'p${i ~/ 10}' : null,
          ),
      ];
      final read = <String, DateTime>{};
      final seen = <String>{questions.first.id};
      DateTime? fixed;
      for (var day = first;
          day.isBefore(examDay);
          day = DateTime(day.year, day.month, day.day + 1)) {
        final plan = BuildRoadmap.call(
          RoadmapInputs(
            today: day,
            examId: 'e',
            examDate: ExamDate.onDay(examDay),
            studyDays: days,
            topics: const [RoadmapTopic(id: 't', authoredIndex: 0, name: 'T')],
            prerequisites: const {},
            lessons: [
              for (final l in lessons)
                RoadmapLesson(
                  id: l.id,
                  topicId: l.topicId,
                  ordering: l.ordering,
                  readAt: read[l.id],
                ),
            ],
            questions: questions,
            seenQuestionIds: seen,
            dueReviews: [
              RoadmapReview(
                id: questions.first.id,
                due: first,
                retrievability: 0.7,
              ),
            ],
            scores: const {},
            answeredPerActiveDay: const [5],
            mock: const RoadmapMockFacts(examHasMock: true, proIsActive: true),
            assessmentCompleted: true,
            contentRevision: 'r',
            anchoredReviewOnlyFrom: fixed,
          ),
        );
        fixed ??= plan.reviewOnlyFrom;
        expect(
          plan.today.isRestDay,
          !days.isStudyDay(day),
          reason: 'seed $seed',
        );
        if (!days.isStudyDay(day)) {
          expect(plan.today.lessonIds, isEmpty, reason: 'seed $seed');
          expect(plan.today.questionCount, 0, reason: 'seed $seed');
          expect(plan.today.isMockDay, isFalse, reason: 'seed $seed');
        }
        if (plan.mockDay != null) {
          expect(days.isStudyDay(plan.mockDay!), isTrue);
        }
        for (final id in plan.today.lessonIds) {
          read[id] = day;
        }
        seen.addAll(plan.today.newQuestionIds);
        final next = DateTime(day.year, day.month, day.day + 1);
        if (!next.isBefore(fixed!) && days.countInRange(first, fixed) >= 1) {
          expect(
            read.keys.toSet(),
            lessons.map((l) => l.id).toSet(),
            reason: 'seed $seed',
          );
          expect(
            seen,
            questions.map((q) => q.id).toSet(),
            reason: 'seed $seed',
          );
          break;
        }
      }
    }
  });

  test('inputs default to all days and compare study-day choices by value', () {
    final all = inputs();
    final picked = inputs(studyDays: weekdays);
    final forced = inputs(treatTodayAsStudyDay: true);
    expect(all.studyDays, StudyDays.all);
    expect(all.treatTodayAsStudyDay, isFalse);
    expect(all, isNot(picked));
    expect(all, isNot(forced));
    expect(picked, inputs(studyDays: StudyDays(const [5, 4, 3, 2, 1])));
    expect(picked.hashCode, inputs(studyDays: weekdays).hashCode);
  });

  test('weekday pacing keeps the calendar window and counts 43 working days',
      () {
    final window = PlanningWindows.resolve(
      today: start,
      examDate: ExamDate.onDay(exam),
      studyDays: weekdays,
    );
    var counted = 0;
    for (var day = start;
        day.isBefore(anchor);
        day = DateTime(day.year, day.month, day.day + 1)) {
      if (day.weekday <= DateTime.friday) counted++;
    }
    expect(counted, 43);
    expect(weekdays.countInRange(start, anchor), counted);
    expect(window.workingDays, counted);
    expect(window.studyDaysBeforeExam, weekdays.countInRange(start, exam));
    expect(window.studyDaysBeforeExam, 48);
    expect(window.daysLeft, 68);
    expect(window.quiet, 7);
    expect(window.reviewOnlyFrom, anchor);
    expect(PlanningWindows.perDay(120, counted), 3);
    expect(PlanningWindows.perDay(900, counted), 21);
  });

  test('forcing a rest day counts today once only inside each range', () {
    final saturday = DateTime(2026, 12, 5);
    for (final reviewStart in [DateTime(2026, 12, 6), anchor]) {
      final window = PlanningWindows.resolve(
        today: saturday,
        examDate: ExamDate.onDay(exam),
        anchoredReviewOnlyFrom: reviewStart,
        studyDays: weekdays,
        treatTodayAsStudyDay: true,
      );
      expect(window.studyDaysBeforeExam, 1);
      expect(window.workingDays, reviewStart.isAfter(saturday) ? 1 : 0);
    }
    final monday = PlanningWindows.resolve(
      today: anchor,
      examDate: ExamDate.onDay(exam),
      studyDays: weekdays,
      treatTodayAsStudyDay: true,
    );
    expect(monday.studyDaysBeforeExam, 5);
    final examToday = PlanningWindows.resolve(
      today: exam,
      examDate: ExamDate.onDay(exam),
      studyDays: weekdays,
      treatTodayAsStudyDay: true,
    );
    expect(examToday.studyDaysBeforeExam, 0);
    expect(examToday.workingDays, 0);
  });

  test('all seven retains calendar counts including the anchored state', () {
    final window = PlanningWindows.resolve(
      today: start,
      examDate: ExamDate.onDay(exam),
    );
    expect(window.workingDays, 61);
    expect(window.studyDaysBeforeExam, 68);
    final restBeforeAnchor = PlanningWindows.resolve(
      today: DateTime(2026, 11, 28),
      examDate: ExamDate.onDay(exam),
      anchoredReviewOnlyFrom: anchor,
      studyDays: weekdays,
    );
    expect(restBeforeAnchor.workingDays, 0);
    expect(restBeforeAnchor.state, RoadmapState.planning);
  });
}
