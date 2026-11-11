import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/roadmap_diff.dart';

final saturday = DateTime(2026, 10, 3);
final monday = DateTime(2026, 10, 5);
final weekdays = StudyDays(const [1, 2, 3, 4, 5]);

RoadmapDigest digest({StudyDays days = StudyDays.all}) => RoadmapDigest(
      examId: 'e',
      examDate: '2026-12-07:day',
      scopeTopicIds: const ['t'],
      contentRevision: 'r',
      assessmentCompleted: true,
      recordedMockCount: 0,
      studyDays: days,
    );

DaySnapshot snapshot({
  bool rest = false,
  RoadmapDigest? using,
  DateTime? day,
}) =>
    DaySnapshot(
      plan: DayPlan(
        day: day ?? saturday,
        lessonIds: const [],
        newQuestionIds: const [],
        reviewQuestionIds: const [],
        isMockDay: false,
        advancedIds: const {},
        isRestDay: rest,
      ),
      digest: using ?? digest(),
      topicOrderHead: const ['t'],
    );

const nothingDone = CompletionFacts(
  readLessonIds: {},
  seenQuestionIds: {},
  reviewedTodayIds: {},
);

List<RoadmapChange> diff(DaySnapshot prior, DaySnapshot next) =>
    RoadmapDiff.between(
      prior: prior,
      next: next,
      priorCompletion: nothingDone,
      backlogCapped: false,
      cycleDetected: false,
      examPassed: false,
      examDateMissing: false,
      occurredAt: next.day,
    );

void main() {
  test('an old digest and snapshot remain equivalent to the all-seven default',
      () {
    final old = <String, Object?>{
      'examId': 'e',
      'examDate': '2026-12-07:day',
      'scope': ['t'],
      'content': 'r',
      'assessed': true,
      'mocks': 0,
    };
    expect(RoadmapDigest.parse(jsonEncode(old)), digest());
    final restored = DaySnapshot.fromJson({
      'plan': const <String, Object?>{
        'day': '2026-10-03',
        'lessons': <String>[],
        'reviews': <String>[],
        'new': <String>[],
        'mockDay': false,
        'advanced': <String>[],
      },
      'digest': jsonEncode(old),
      'head': const ['t'],
    });
    expect(restored, snapshot());
    expect(restored.plan.isRestDay, isFalse);
  });

  test('study-day digests round trip and name the change', () {
    final picked = digest(days: weekdays);
    expect(RoadmapDigest.parse(picked.encode()), picked);
    final encoded = jsonDecode(picked.encode()) as Map<String, Object?>;
    expect(encoded['studyDays'], '1,2,3,4,5');
    expect(digest(), isNot(picked));
    expect(digest().causesTo(picked).map((c) => c.name), ['studyDaysChanged']);
    expect(
      diff(snapshot(), snapshot(rest: true, using: picked))
          .map((c) => c.cause.name),
      ['studyDaysChanged'],
    );
  });

  test('rest-day identity survives storage and remaining work', () {
    final rest = snapshot(rest: true);
    expect(rest.plan, isNot(snapshot().plan));
    expect(rest.plan.hashCode, isNot(snapshot().plan.hashCode));
    expect(rest.toJson()['plan'], containsPair('restDay', true));
    expect(DaySnapshot.fromJson(rest.toJson()).plan.isRestDay, isTrue);
    expect(DaySnapshots.remaining(rest, nothingDone).isRestDay, isTrue);
    expect(DaySnapshots.originalDone(rest, nothingDone), isTrue);
  });

  test('rest-day advance appends due reviews once and marks them advanced', () {
    final next = DayPlan(
      day: monday,
      lessonIds: const ['l'],
      newQuestionIds: const ['n'],
      reviewQuestionIds: const ['future'],
      isMockDay: false,
      advancedIds: const {},
    );
    final advanced = DaySnapshots.advance(
      snapshot(rest: true),
      next,
      reviews: const ['due', 'due'],
    );
    expect(advanced.plan.lessonIds, ['l']);
    expect(advanced.plan.newQuestionIds, ['n']);
    expect(advanced.plan.reviewQuestionIds, ['due']);
    expect(advanced.plan.advancedIds, {'l', 'n', 'due'});
    expect(advanced.plan.isRestDay, isTrue);
    expect(DaySnapshots.originalDone(advanced, nothingDone), isTrue);
    expect(DaySnapshots.originalCounts(advanced.plan).reviews, 0);
    expect(DaySnapshots.originalLeftCounts(advanced, nothingDone).reviews, 0);
    expect(DaySnapshots.advancedCompleted(advanced, nothingDone), 0);
    expect(
      DaySnapshots.advancedCompleted(
        advanced,
        const CompletionFacts(
          readLessonIds: {},
          seenQuestionIds: {},
          reviewedTodayIds: {'due'},
        ),
      ),
      1,
    );
    final repeated =
        DaySnapshots.advance(advanced, next, reviews: const ['due']);
    expect(repeated, advanced);
  });

  test('unfinished advanced reviews on a rest day never log missed work', () {
    final prior = DaySnapshots.advance(
      snapshot(rest: true),
      DayPlan(
        day: monday,
        lessonIds: const [],
        newQuestionIds: const [],
        reviewQuestionIds: const [],
        isMockDay: false,
        advancedIds: const {},
      ),
      reviews: const ['due'],
    );
    final changes = diff(prior, snapshot(day: monday));
    expect(
      changes.map((c) => c.cause),
      isNot(contains(RoadmapChangeCause.missedWork)),
    );
    expect(
      changes
          .singleWhere((c) => c.cause == RoadmapChangeCause.advanced)
          .advancedCompleted,
      0,
    );
  });

  test('a stored rest day is excluded from missed work', () {
    final prior = DaySnapshot(
      plan: DayPlan(
        day: saturday,
        lessonIds: const ['old'],
        newQuestionIds: const [],
        reviewQuestionIds: const ['due'],
        isMockDay: false,
        advancedIds: const {},
        isRestDay: true,
      ),
      digest: digest(),
      topicOrderHead: const ['t'],
    );
    expect(
      diff(prior, snapshot(day: monday)).map((c) => c.cause),
      [RoadmapChangeCause.newDay],
    );
  });
}
