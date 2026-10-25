import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_diff.dart';

void main() {
  final sept30 = DateTime(2026, 9, 30);
  final oct1 = DateTime(2026, 10);
  final at = DateTime(2026, 10, 1, 7);

  RoadmapDigest digest({
    String examId = 'exam_upcat',
    String examDate = '2026-12-07:day',
    List<String> scope = const ['t_alg', 't_geo'],
    List<String> excludedLessons = const [],
    String content = 'rev2',
    bool assessed = true,
    int mocks = 0,
  }) =>
      RoadmapDigest(
        examId: examId,
        examDate: examDate,
        scopeTopicIds: scope,
        excludedLessonIds: excludedLessons,
        contentRevision: content,
        assessmentCompleted: assessed,
        recordedMockCount: mocks,
      );

  test('lesson exclusions survive digest round trip and change scope', () {
    final before = digest();
    final after = digest(excludedLessons: ['lesson-b', 'lesson-a']);
    expect(RoadmapDigest.parse(after.encode()), after);
    expect(after.excludedLessonIds, ['lesson-a', 'lesson-b']);
    expect(before.causesTo(after), [RoadmapChangeCause.scopeChanged]);
    expect(RoadmapDigest.parse(before.encode()).excludedLessonIds, isEmpty);
  });

  DaySnapshot snapshot({
    DateTime? day,
    List<String> lessons = const ['l1', 'l2'],
    List<String> reviews = const ['r1'],
    List<String> fresh = const ['n1', 'n2', 'n3'],
    Set<String> advanced = const {},
    RoadmapDigest? using,
    List<String> head = const ['t_alg', 't_geo'],
  }) =>
      DaySnapshot(
        plan: DayPlan(
          day: day ?? sept30,
          lessonIds: lessons,
          reviewQuestionIds: reviews,
          newQuestionIds: fresh,
          isMockDay: false,
          advancedIds: advanced,
        ),
        digest: using ?? digest(),
        topicOrderHead: head,
      );

  CompletionFacts done({
    Set<String> read = const {},
    Set<String> seen = const {},
    Set<String> reviewed = const {},
  }) =>
      CompletionFacts(
        readLessonIds: read,
        seenQuestionIds: seen,
        reviewedTodayIds: reviewed,
      );

  List<RoadmapChange> diff(
    DaySnapshot? prior,
    DaySnapshot next, {
    CompletionFacts? priorDone,
    bool capped = false,
    bool cycle = false,
  }) =>
      RoadmapDiff.between(
        prior: prior,
        priorCompletion: priorDone,
        next: next,
        backlogCapped: capped,
        cycleDetected: cycle,
        examPassed: false,
        examDateMissing: false,
        occurredAt: at,
      );

  group('snapshot', () {
    test('survives a JSON round trip', () {
      final original = snapshot(advanced: {'n3'});
      expect(DaySnapshot.fromJson(original.toJson()), original);
    });

    test('compares the first three topics and keeps the whole order', () {
      final s = snapshot(head: ['a', 'b', 'c', 'd']);
      expect(s.topicOrderHead, ['a', 'b', 'c']);
      expect(s.topicOrder, ['a', 'b', 'c', 'd']);
      expect(DaySnapshot.fromJson(s.toJson()).topicOrder, ['a', 'b', 'c', 'd']);
    });

    test('remaining drops read lessons, seen questions, reviews done today',
        () {
      final left = DaySnapshots.remaining(
        snapshot(),
        done(read: {'l1'}, seen: {'n2'}, reviewed: {'r1'}),
      );
      expect(left.lessonIds, ['l2']);
      expect(left.newQuestionIds, ['n1', 'n3']);
      expect(left.reviewQuestionIds, isEmpty);
    });

    test('advanced items never make the day incomplete', () {
      final s = snapshot(fresh: ['n1', 'n2', 'x1'], advanced: {'x1'});
      final facts = done(
        read: {'l1', 'l2'},
        seen: {'n1', 'n2'},
        reviewed: {'r1'},
      );
      expect(DaySnapshots.originalDone(s, facts), isTrue);
    });

    test('advance appends tomorrow without reviews and marks it advanced', () {
      final today = snapshot();
      final tomorrow = DayPlan(
        day: oct1,
        lessonIds: const ['l3'],
        reviewQuestionIds: const ['r9'],
        newQuestionIds: const ['n4', 'n5'],
        isMockDay: false,
        advancedIds: const {},
      );

      final advanced = DaySnapshots.advance(today, tomorrow);

      expect(advanced.plan.lessonIds, ['l1', 'l2', 'l3']);
      expect(advanced.plan.newQuestionIds, ['n1', 'n2', 'n3', 'n4', 'n5']);
      expect(advanced.plan.reviewQuestionIds, ['r1']);
      expect(advanced.plan.advancedIds, {'l3', 'n4', 'n5'});
      expect(DaySnapshots.originalCounts(advanced.plan).newQuestions, 3);
    });
  });

  group('changes', () {
    test('the first plan logs a new day with only after counts', () {
      final changes = diff(null, snapshot());
      expect(changes.map((c) => c.cause), [RoadmapChangeCause.newDay]);
      expect(changes.single.before, isNull);
      expect(
        changes.single.after,
        const RoadmapDayCounts(lessons: 2, newQuestions: 3, reviews: 1),
      );
    });

    test('a finished day then a new day logs only the new day', () {
      final changes = diff(
        snapshot(),
        snapshot(day: oct1),
        priorDone: done(
          read: {'l1', 'l2'},
          seen: {'n1', 'n2', 'n3'},
          reviewed: {'r1'},
        ),
      );
      expect(changes.map((c) => c.cause), [RoadmapChangeCause.newDay]);
    });

    test('unfinished original work logs missed work with what was left', () {
      final changes = diff(
        snapshot(),
        snapshot(day: oct1),
        priorDone: done(read: {'l1'}, seen: {'n1'}),
      );
      final missed =
          changes.singleWhere((c) => c.cause == RoadmapChangeCause.missedWork);
      expect(
        missed.before,
        const RoadmapDayCounts(lessons: 1, newQuestions: 2, reviews: 1),
      );
    });

    test('a partial advance logs advanced with the count done, not missed', () {
      final prior = snapshot(
        lessons: ['l1', 'x1'],
        fresh: ['n1', 'x2', 'x3'],
        advanced: {'x1', 'x2', 'x3'},
      );
      final changes = diff(
        prior,
        snapshot(day: oct1),
        priorDone: done(read: {'l1'}, seen: {'n1', 'x2'}, reviewed: {'r1'}),
      );

      expect(
        changes.map((c) => c.cause),
        isNot(contains(RoadmapChangeCause.missedWork)),
      );
      final advanced =
          changes.singleWhere((c) => c.cause == RoadmapChangeCause.advanced);
      expect(advanced.advancedCompleted, 1);
    });

    test('each changed input names its own cause mid-day', () {
      final prior = snapshot();
      final next = snapshot(
        using: digest(
          examDate: '2026-12-14:day',
          scope: ['t_alg'],
          content: 'rev3',
          mocks: 1,
        ),
      );
      expect(diff(prior, next).map((c) => c.cause), [
        RoadmapChangeCause.examDateChanged,
        RoadmapChangeCause.scopeChanged,
        RoadmapChangeCause.contentChanged,
        RoadmapChangeCause.mockAnswersRecorded,
      ]);
    });

    test('switching exams is one cause, not a date and scope change too', () {
      final next = snapshot(
        using: digest(
          examId: 'exam_cse',
          examDate: '2027-03-01:day',
          scope: ['t_x'],
        ),
      );
      expect(
        diff(snapshot(), next).map((c) => c.cause),
        [RoadmapChangeCause.examChanged],
      );
    });

    test('the assessment finishing is logged once', () {
      final prior = snapshot(using: digest(assessed: false));
      expect(
        diff(prior, snapshot()).map((c) => c.cause),
        [RoadmapChangeCause.assessmentCompleted],
      );
    });

    test('a new first topic with no other cause is an order change', () {
      final next = snapshot(day: oct1, head: ['t_geo', 't_alg']);
      final causes = diff(
        snapshot(),
        next,
        priorDone: done(
          read: {'l1', 'l2'},
          seen: {'n1', 'n2', 'n3'},
          reviewed: {'r1'},
        ),
      ).map((c) => c.cause);
      expect(causes, [
        RoadmapChangeCause.newDay,
        RoadmapChangeCause.orderChanged,
      ]);
    });

    test('a capped backlog and a prerequisite loop are logged', () {
      final causes =
          diff(null, snapshot(), capped: true, cycle: true).map((c) => c.cause);
      expect(causes, [
        RoadmapChangeCause.newDay,
        RoadmapChangeCause.backlogCapped,
        RoadmapChangeCause.prerequisiteCycle,
      ]);
    });

    test('choosing to advance logs before and after counts', () {
      final before = snapshot();
      final after = DaySnapshots.advance(
        before,
        DayPlan(
          day: oct1,
          lessonIds: const ['l3'],
          reviewQuestionIds: const [],
          newQuestionIds: const ['n4'],
          isMockDay: false,
          advancedIds: const {},
        ),
      );
      final entry =
          RoadmapDiff.advanced(before: before, after: after, occurredAt: at);
      expect(entry.cause, RoadmapChangeCause.advanced);
      expect(entry.before!.lessons, 2);
      expect(entry.after!.lessons, 3);
    });

    test('counts survive a JSON round trip', () {
      const counts =
          RoadmapDayCounts(lessons: 2, newQuestions: 15, reviews: 18);
      expect(RoadmapDayCounts.fromJson(counts.toJson()), counts);
    });
  });
}
