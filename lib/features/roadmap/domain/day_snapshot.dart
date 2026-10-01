import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

/// The inputs whose change rebuilds today's plan mid-day (spec 4.9). Stored
/// with each day so the next read can tell whether anything that shapes the
/// plan moved, and so a rebuild can name why.
@immutable
final class RoadmapDigest {
  RoadmapDigest({
    required this.examId,
    required this.examDate,
    required List<TopicId> scopeTopicIds,
    required this.contentRevision,
    required this.assessmentCompleted,
    required this.recordedMockCount,
    this.studyDays = StudyDays.all,
  }) : scopeTopicIds = List.unmodifiable([...scopeTopicIds]..sort());

  factory RoadmapDigest.parse(String encoded) {
    final json = jsonDecode(encoded) as Map<String, Object?>;
    return RoadmapDigest(
      examId: json['examId']! as String,
      examDate: json['examDate']! as String,
      scopeTopicIds: (json['scope']! as List).cast<String>(),
      contentRevision: json['content']! as String,
      assessmentCompleted: json['assessed']! as bool,
      recordedMockCount: json['mocks']! as int,
      studyDays: StudyDays.fromStorage(json['studyDays'] as String?),
    );
  }

  final ExamId examId;

  /// Storage value and precision, for example `2026-12-07:day`; empty when
  /// the student has no exam date.
  final String examDate;
  final List<TopicId> scopeTopicIds;
  final String contentRevision;
  final bool assessmentCompleted;
  final int recordedMockCount;
  final StudyDays studyDays;

  String encode() => jsonEncode({
        'examId': examId,
        'examDate': examDate,
        'scope': scopeTopicIds,
        'content': contentRevision,
        'assessed': assessmentCompleted,
        'mocks': recordedMockCount,
        'studyDays': studyDays.storageValue,
      });

  /// The causes that explain a move from this digest to [next], in a fixed
  /// order.
  List<RoadmapChangeCause> causesTo(RoadmapDigest next) => [
        if (examId != next.examId) RoadmapChangeCause.examChanged,
        if (examId == next.examId && examDate != next.examDate)
          RoadmapChangeCause.examDateChanged,
        if (examId == next.examId &&
            !const ListEquality<TopicId>()
                .equals(scopeTopicIds, next.scopeTopicIds))
          RoadmapChangeCause.scopeChanged,
        if (contentRevision != next.contentRevision)
          RoadmapChangeCause.contentChanged,
        if (!assessmentCompleted && next.assessmentCompleted)
          RoadmapChangeCause.assessmentCompleted,
        if (next.recordedMockCount > recordedMockCount)
          RoadmapChangeCause.mockAnswersRecorded,
        if (studyDays != next.studyDays) RoadmapChangeCause.studyDaysChanged,
      ];

  @override
  bool operator ==(Object other) =>
      other is RoadmapDigest && encode() == other.encode();

  @override
  int get hashCode => encode().hashCode;
}

/// What is persisted for one local day: the plan as built, and what it was
/// built from. Completed items are subtracted on read, never stored.
@immutable
final class DaySnapshot {
  DaySnapshot({
    required this.plan,
    required this.digest,
    required List<TopicId> topicOrderHead,
    this.reviewOnlyFrom,
    this.state = RoadmapState.planning,
  })  : topicOrder = List.unmodifiable(topicOrderHead),
        topicOrderHead = List.unmodifiable(topicOrderHead.take(3));

  factory DaySnapshot.fromJson(Map<String, Object?> json) {
    final plan = json['plan']! as Map<String, Object?>;
    return DaySnapshot(
      plan: DayPlan(
        day: _parseDay(plan['day']! as String),
        lessonIds: (plan['lessons']! as List).cast<String>(),
        reviewQuestionIds: (plan['reviews']! as List).cast<String>(),
        newQuestionIds: (plan['new']! as List).cast<String>(),
        isMockDay: plan['mockDay']! as bool,
        isRestDay: plan['restDay'] as bool? ?? false,
        advancedIds: (plan['advanced']! as List).cast<String>().toSet(),
      ),
      digest: RoadmapDigest.parse(json['digest']! as String),
      topicOrderHead: (json['head']! as List).cast<String>(),
      reviewOnlyFrom: json['reviewOnlyFrom'] == null
          ? null
          : _parseDay(json['reviewOnlyFrom']! as String),
      state: RoadmapState.values.byName(
        json['state'] as String? ?? RoadmapState.planning.name,
      ),
    );
  }

  final DayPlan plan;
  final RoadmapDigest digest;

  /// The whole topic order the day was built with; sittings are arranged by
  /// it.
  final List<TopicId> topicOrder;

  /// The first three topics of that order, which the change log compares.
  final List<TopicId> topicOrderHead;

  /// The review-only start this day was planned against, carried forward so
  /// the stretch stays fixed while the exam and its date do not change.
  final DateTime? reviewOnlyFrom;

  /// The plan's state when the day was built.
  final RoadmapState state;

  DateTime get day => plan.day;

  Map<String, Object?> toJson() => {
        'plan': {
          'day': dayKey(plan.day),
          'lessons': plan.lessonIds,
          'reviews': plan.reviewQuestionIds,
          'new': plan.newQuestionIds,
          'mockDay': plan.isMockDay,
          'restDay': plan.isRestDay,
          'advanced': plan.advancedIds.toList()..sort(),
        },
        'digest': digest.encode(),
        'head': topicOrder,
        if (reviewOnlyFrom != null) 'reviewOnlyFrom': dayKey(reviewOnlyFrom!),
        'state': state.name,
      };

  @override
  bool operator ==(Object other) =>
      other is DaySnapshot &&
      jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;
}

/// A local day as `YYYY-MM-DD`, the key a snapshot is stored under.
String dayKey(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

DateTime _parseDay(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

/// What the student has done, read fresh each time the day is shown.
@immutable
final class CompletionFacts {
  const CompletionFacts({
    required this.readLessonIds,
    required this.seenQuestionIds,
    required this.reviewedTodayIds,
  });

  final Set<LessonId> readLessonIds;

  /// Questions with a review state, so answered at least once.
  final Set<QuestionId> seenQuestionIds;

  /// Questions whose review state was last reviewed today.
  final Set<QuestionId> reviewedTodayIds;
}

abstract final class DaySnapshots {
  /// The day minus what is done: lessons read, new questions seen, reviews
  /// answered today. Order is kept.
  static DayPlan remaining(DaySnapshot snapshot, CompletionFacts facts) {
    final plan = snapshot.plan;
    return DayPlan(
      day: plan.day,
      lessonIds: [
        for (final id in plan.lessonIds)
          if (!facts.readLessonIds.contains(id)) id,
      ],
      reviewQuestionIds: [
        for (final id in plan.reviewQuestionIds)
          if (!facts.reviewedTodayIds.contains(id)) id,
      ],
      newQuestionIds: [
        for (final id in plan.newQuestionIds)
          if (!facts.seenQuestionIds.contains(id)) id,
      ],
      isMockDay: plan.isMockDay,
      isRestDay: plan.isRestDay,
      advancedIds: plan.advancedIds,
    );
  }

  /// Whether every item the day was built with is done. Advanced items never
  /// make a day incomplete (spec 4.9, partial advance).
  static bool originalDone(DaySnapshot snapshot, CompletionFacts facts) =>
      _originalLeft(snapshot, facts).isEmpty;

  /// The day's original items still undone, as counts.
  static RoadmapDayCounts originalLeftCounts(
    DaySnapshot snapshot,
    CompletionFacts facts,
  ) {
    final left = remaining(snapshot, facts);
    final advanced = snapshot.plan.advancedIds;
    return RoadmapDayCounts(
      lessons: left.lessonIds.where((id) => !advanced.contains(id)).length,
      newQuestions:
          left.newQuestionIds.where((id) => !advanced.contains(id)).length,
      reviews:
          left.reviewQuestionIds.where((id) => !advanced.contains(id)).length,
    );
  }

  /// How many advanced items were finished.
  static int advancedCompleted(DaySnapshot snapshot, CompletionFacts facts) {
    final left = remaining(snapshot, facts);
    final stillLeft = {
      ...left.lessonIds,
      ...left.newQuestionIds,
      ...left.reviewQuestionIds,
    };
    return snapshot.plan.advancedIds
        .where((id) => !stillLeft.contains(id))
        .length;
  }

  /// Appends the next study day's lessons and new questions. On a rest day,
  /// [reviews] holds only reviews already due today. All added items are
  /// advanced. The caller checks [originalDone] first.
  static DaySnapshot advance(
    DaySnapshot today,
    DayPlan tomorrow, {
    List<QuestionId> reviews = const [],
  }) {
    final plan = today.plan;
    final lessons = [...plan.lessonIds];
    final fresh = [...plan.newQuestionIds];
    final due = [...plan.reviewQuestionIds];
    final advanced = {...plan.advancedIds};
    for (final id in tomorrow.lessonIds) {
      if (lessons.contains(id)) continue;
      lessons.add(id);
      advanced.add(id);
    }
    for (final id in tomorrow.newQuestionIds) {
      if (fresh.contains(id)) continue;
      fresh.add(id);
      advanced.add(id);
    }
    for (final id in reviews) {
      if (due.contains(id)) continue;
      due.add(id);
      advanced.add(id);
    }
    return DaySnapshot(
      plan: DayPlan(
        day: plan.day,
        lessonIds: lessons,
        reviewQuestionIds: due,
        newQuestionIds: fresh,
        isMockDay: plan.isMockDay,
        isRestDay: plan.isRestDay,
        advancedIds: advanced,
      ),
      digest: today.digest,
      topicOrderHead: today.topicOrder,
      reviewOnlyFrom: today.reviewOnlyFrom,
      state: today.state,
    );
  }

  /// Counts of the items the day was built with, advanced items excluded.
  static RoadmapDayCounts originalCounts(DayPlan plan) => RoadmapDayCounts(
        lessons:
            plan.lessonIds.where((id) => !plan.advancedIds.contains(id)).length,
        newQuestions: plan.newQuestionIds
            .where((id) => !plan.advancedIds.contains(id))
            .length,
        reviews: plan.reviewQuestionIds
            .where((id) => !plan.advancedIds.contains(id))
            .length,
      );

  static List<String> _originalLeft(
    DaySnapshot snapshot,
    CompletionFacts facts,
  ) {
    final left = remaining(snapshot, facts);
    final advanced = snapshot.plan.advancedIds;
    return [
      ...left.lessonIds.where((id) => !advanced.contains(id)),
      ...left.newQuestionIds.where((id) => !advanced.contains(id)),
      ...left.reviewQuestionIds.where((id) => !advanced.contains(id)),
    ];
  }
}
