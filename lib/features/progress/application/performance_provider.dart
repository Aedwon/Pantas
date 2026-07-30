import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/progress/application/table_order_prefs.dart';

@immutable
class PerformanceRow {
  const PerformanceRow({
    required this.id,
    required this.title,
    required this.subtext,
    required this.correct,
    required this.answered,
    required this.secondsPerQuestion,
  });

  final String id;
  final String title;

  /// The row's parent at topic and lesson level. At subject level, the
  /// section's published size: "60 of 180 questions". T2.
  final String? subtext;

  final int correct;
  final int answered;

  /// Null when no timed mock has touched this row. Never estimated from
  /// practice.
  final double? secondsPerQuestion;

  double? get accuracy => answered == 0 ? null : correct / answered;
}

@immutable
class PerformanceTable {
  const PerformanceTable({
    required this.rows,
    required this.timeIsMeasurable,
    required this.lessonLevelAvailable,
    required this.subjects,
  });

  final List<PerformanceRow> rows;

  /// False until a full length mock has been sat. The Time column and its
  /// head are then absent, not filled with placeholders.
  final bool timeIsMeasurable;

  /// False until questions carry a lessonId. The Lesson label is then
  /// absent, not dimmed and not empty.
  final bool lessonLevelAvailable;

  /// Feeds the scope sheet, so it can print a count beside each subject
  /// without a second query. Empty below two subjects with data, which is
  /// exactly when the control does not render.
  final List<({String id, String name, int rowCount})> subjects;
}

/// The level, plus the subject the table is scoped to. Null subject means
/// all subjects.
@immutable
class PerformanceQuery {
  const PerformanceQuery({required this.level, this.subjectId});

  final TableLevel level;
  final String? subjectId;

  @override
  bool operator ==(Object other) =>
      other is PerformanceQuery &&
      other.level == level &&
      other.subjectId == subjectId;

  @override
  int get hashCode => Object.hash(level, subjectId);
}

/// One row's identity while it is being counted.
class _Bucket {
  _Bucket({required this.id, required this.title, required this.parent});

  final String id;
  final String title;
  final String? parent;
  int correct = 0;
  int answered = 0;
}

/// A section of the published paper, as far as this table needs it.
@immutable
class _PublishedSection {
  const _PublishedSection({
    required this.id,
    required this.questionCount,
    required this.topicIds,
  });

  final String id;
  final int questionCount;
  final List<String> topicIds;
}

final performanceProvider =
    FutureProvider.family<PerformanceTable, PerformanceQuery>(
        (ref, query) async {
  final db = ref.watch(appDatabaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (exam == null) {
    return const PerformanceTable(
      rows: [],
      timeIsMeasurable: false,
      lessonLevelAvailable: false,
      subjects: [],
    );
  }
  final examId = exam.id;

  final subjectRows = await (contentDb.select(contentDb.contentSubjects)
        ..where((s) => s.examId.equals(examId))
        ..orderBy([(s) => OrderingTerm.asc(s.ordering)]))
      .get();
  if (subjectRows.isEmpty) {
    return const PerformanceTable(
      rows: [],
      timeIsMeasurable: false,
      lessonLevelAvailable: false,
      subjects: [],
    );
  }
  final subjectIds = [for (final s in subjectRows) s.id];

  final topicRows = await (contentDb.select(contentDb.contentTopics)
        ..where((t) => t.subjectId.isIn(subjectIds))
        ..orderBy([(t) => OrderingTerm.asc(t.ordering)]))
      .get();
  final questionRows = await (contentDb.select(contentDb.contentQuestions)
        ..where((q) => q.topicId.isIn([for (final t in topicRows) t.id])))
      .get();
  final lessonRows = await (contentDb.select(contentDb.contentLessons)
        ..where((l) => l.topicId.isIn([for (final t in topicRows) t.id]))
        ..orderBy([(l) => OrderingTerm.asc(l.ordering)]))
      .get();

  final subjectNameById = {for (final s in subjectRows) s.id: s.name};
  final topicById = {for (final t in topicRows) t.id: t};
  final subjectIdForQuestion = <String, String>{};
  final topicIdForQuestion = <String, String>{};
  final lessonIdForQuestion = <String, String>{};
  for (final q in questionRows) {
    final topic = topicById[q.topicId];
    if (topic == null) continue;
    topicIdForQuestion[q.id] = topic.id;
    subjectIdForQuestion[q.id] = topic.subjectId;
    final lessonId = q.lessonId;
    if (lessonId != null) lessonIdForQuestion[q.id] = lessonId;
  }

  // The Lesson level exists once any question carries a lesson. Absent is
  // not the same as dimmed: absent says this does not exist yet.
  final lessonLevelAvailable = lessonIdForQuestion.isNotEmpty;
  final level = query.level == TableLevel.lesson && !lessonLevelAvailable
      ? TableLevel.subject
      : query.level;

  bool inScope(String questionId) {
    final subjectId = query.subjectId;
    if (subjectId == null) return true;
    return subjectIdForQuestion[questionId] == subjectId;
  }

  // Every row the level can hold, whether or not it has been answered: a
  // topic nobody has touched is a row with a null accuracy, not a missing
  // row.
  final buckets = <String, _Bucket>{};
  switch (level) {
    case TableLevel.subject:
      for (final s in subjectRows) {
        if (query.subjectId != null && s.id != query.subjectId) continue;
        buckets[s.id] = _Bucket(id: s.id, title: s.name, parent: null);
      }
    case TableLevel.topic:
      for (final t in topicRows) {
        if (query.subjectId != null && t.subjectId != query.subjectId) {
          continue;
        }
        buckets[t.id] = _Bucket(
          id: t.id,
          title: t.name,
          parent: subjectNameById[t.subjectId],
        );
      }
    case TableLevel.lesson:
      for (final l in lessonRows) {
        final topic = topicById[l.topicId];
        if (topic == null) continue;
        if (query.subjectId != null && topic.subjectId != query.subjectId) {
          continue;
        }
        buckets[l.id] = _Bucket(id: l.id, title: l.title, parent: topic.name);
      }
  }

  String? bucketIdFor(String questionId) {
    switch (level) {
      case TableLevel.subject:
        return subjectIdForQuestion[questionId];
      case TableLevel.topic:
        return topicIdForQuestion[questionId];
      case TableLevel.lesson:
        return lessonIdForQuestion[questionId];
    }
  }

  const reader = AttemptItemReader();
  final attemptRows = await (db.select(db.attemptsLocal)
        ..where((a) => a.examId.equals(examId) & a.completedAt.isNotNull()))
      .get();

  final answeredPerSubject = <String, int>{};
  for (final attempt in attemptRows) {
    for (final item in reader.read(attempt.itemsJson)) {
      final subjectId = subjectIdForQuestion[item.questionId];
      if (subjectId != null) {
        answeredPerSubject[subjectId] =
            (answeredPerSubject[subjectId] ?? 0) + 1;
      }
      if (!inScope(item.questionId)) continue;
      final bucket = buckets[bucketIdFor(item.questionId)];
      if (bucket == null) continue;
      bucket.answered += 1;
      if (item.isCorrect) bucket.correct += 1;
    }
  }

  final published = await _publishedSections(ref, examId);
  final secondsPerBucket = await _measuredSeconds(
    db,
    examId: examId,
    level: level,
    subjectIdForQuestion: subjectIdForQuestion,
    topicIdForQuestion: topicIdForQuestion,
    lessonIdForQuestion: lessonIdForQuestion,
  );

  String? subtextFor(_Bucket bucket) {
    if (level != TableLevel.subject) {
      // While the table is filtered every row would repeat the filter, so
      // the parent line drops.
      return query.subjectId == null ? bucket.parent : null;
    }
    final size = _publishedSizeForSubject(
      bucket.id,
      published: published,
      topicById: topicById,
    );
    if (size == null) return null;
    return '${bucket.answered} of $size questions';
  }

  final rows = [
    for (final bucket in buckets.values)
      PerformanceRow(
        id: bucket.id,
        title: bucket.title,
        subtext: subtextFor(bucket),
        correct: bucket.correct,
        answered: bucket.answered,
        secondsPerQuestion: secondsPerBucket[bucket.id],
      ),
  ];

  final subjectsWithData = [
    for (final s in subjectRows)
      if ((answeredPerSubject[s.id] ?? 0) > 0)
        (
          id: s.id,
          name: s.name,
          rowCount: topicRows.where((t) => t.subjectId == s.id).length,
        ),
  ];

  return PerformanceTable(
    rows: rows,
    // The head renders only when a row in this table can carry a figure,
    // so the column is absent rather than empty.
    timeIsMeasurable: rows.any((r) => r.secondsPerQuestion != null),
    lessonLevelAvailable: lessonLevelAvailable,
    subjects: subjectsWithData.length < 2 ? const [] : subjectsWithData,
  );
});

/// The published paper's sections, or empty when no blueprint ships.
Future<List<_PublishedSection>> _publishedSections(
  Ref ref,
  String examId,
) async {
  final List<MockBlueprint> blueprints;
  try {
    blueprints = await ref.watch(mockBlueprintRepoProvider).byExam(examId);
  } on Object {
    return const [];
  }
  final sections = <_PublishedSection>[];
  for (final blueprint in blueprints) {
    final Object? decoded;
    try {
      decoded = jsonDecode(blueprint.sectionsJson);
    } on FormatException {
      continue;
    }
    if (decoded is! List) continue;
    for (final entry in decoded) {
      if (entry is! Map<String, Object?>) continue;
      final id = entry['id'];
      final count = entry['questionCount'];
      final topicIds = entry['topicIds'];
      if (id is! String || count is! int || topicIds is! List) continue;
      sections.add(
        _PublishedSection(
          id: id,
          questionCount: count,
          topicIds: [
            for (final t in topicIds)
              if (t is String) t,
          ],
        ),
      );
    }
  }
  return sections;
}

/// A subject's published size, summed over the sections that sit wholly
/// inside it. A section spanning two subjects is not divided between them:
/// that is the T4 figure this tab was rewritten to remove.
int? _publishedSizeForSubject(
  String subjectId, {
  required List<_PublishedSection> published,
  required Map<String, ContentTopicRow> topicById,
}) {
  var total = 0;
  var found = false;
  for (final section in published) {
    final subjects = {
      for (final topicId in section.topicIds)
        if (topicById[topicId] != null) topicById[topicId]!.subjectId,
    };
    if (subjects.length != 1 || subjects.single != subjectId) continue;
    total += section.questionCount;
    found = true;
  }
  return found ? total : null;
}

/// Seconds per question, measured and never estimated.
///
/// A mock records the clock per section, not per question, so a row can
/// carry a figure only when a whole section sits inside it. Splitting a
/// section's time across the topics it covers would be a measurement
/// multiplied by an assumption about how the student spent it.
Future<Map<String, double>> _measuredSeconds(
  AppDatabase db, {
  required String examId,
  required TableLevel level,
  required Map<String, String> subjectIdForQuestion,
  required Map<String, String> topicIdForQuestion,
  required Map<String, String> lessonIdForQuestion,
}) async {
  final mockRows = await (db.select(db.mockAttempts)
        ..where(
          (m) => m.examId.equals(examId) & m.submittedAt.isNotNull(),
        ))
      .get();

  final seconds = <String, int>{};
  final counted = <String, int>{};

  for (final mock in mockRows) {
    final sampled = _decodeList(mock.sampledQuestionsJson);
    final results = _decodeList(mock.sectionResultsJson ?? '[]');
    final questionIdsBySection = <String, List<String>>{};
    for (final section in sampled) {
      final id = section['sectionId'];
      final questionIds = section['questionIds'];
      if (id is! String || questionIds is! List) continue;
      questionIdsBySection[id] = [
        for (final q in questionIds)
          if (q is String) q,
      ];
    }

    for (final result in results) {
      final sectionId = result['sectionId'];
      final timeSeconds = result['timeSeconds'];
      final total = result['total'];
      if (sectionId is! String || timeSeconds is! int || total is! int) {
        continue;
      }
      if (total <= 0) continue;
      final questionIds = questionIdsBySection[sectionId] ?? const [];
      if (questionIds.isEmpty) continue;

      final owners = <String>{};
      for (final questionId in questionIds) {
        final owner = switch (level) {
          TableLevel.subject => subjectIdForQuestion[questionId],
          TableLevel.topic => topicIdForQuestion[questionId],
          TableLevel.lesson => lessonIdForQuestion[questionId],
        };
        if (owner == null) {
          owners.clear();
          break;
        }
        owners.add(owner);
      }
      // The section has to land wholly in one row, or its clock says
      // nothing about any single row.
      if (owners.length != 1) continue;

      final owner = owners.single;
      seconds[owner] = (seconds[owner] ?? 0) + timeSeconds;
      counted[owner] = (counted[owner] ?? 0) + total;
    }
  }

  return {
    for (final entry in seconds.entries)
      if ((counted[entry.key] ?? 0) > 0)
        entry.key: entry.value / counted[entry.key]!,
  };
}

List<Map<String, Object?>> _decodeList(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    return const [];
  }
  if (decoded is! List) return const [];
  return [
    for (final entry in decoded)
      if (entry is Map<String, Object?>) entry,
  ];
}
