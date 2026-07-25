import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/home/application/topic_accuracy_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class UpNextLesson {
  const UpNextLesson({
    required this.lessonId,
    required this.title,
    required this.topicId,
    required this.subjectName,
    required this.estimatedMinutes,
  });

  final LessonId lessonId;
  final String title;
  final TopicId topicId;
  final String subjectName;
  final int estimatedMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpNextLesson &&
          runtimeType == other.runtimeType &&
          lessonId == other.lessonId &&
          title == other.title &&
          topicId == other.topicId &&
          subjectName == other.subjectName &&
          estimatedMinutes == other.estimatedMinutes;

  @override
  int get hashCode => Object.hash(
        lessonId,
        title,
        topicId,
        subjectName,
        estimatedMinutes,
      );
}

@immutable
class UpNextDay {
  const UpNextDay({
    required this.lessons,
    required this.allReadInWeakTopics,
  });

  final List<UpNextLesson> lessons;

  /// True when the weak topics hold no unread lesson at all. Distinct from
  /// an empty list caused by having no topics or no content.
  final bool allReadInWeakTopics;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpNextDay &&
          runtimeType == other.runtimeType &&
          allReadInWeakTopics == other.allReadInWeakTopics &&
          _listEquals(lessons, other.lessons);

  @override
  int get hashCode => Object.hash(Object.hashAll(lessons), allReadInWeakTopics);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final upNextProvider = FutureProvider<UpNextDay>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);
  final focus = await ref.watch(activeExamFocusProvider.future);
  if (focus.needsSelection || focus.exam == null) {
    return const UpNextDay(lessons: [], allReadInWeakTopics: false);
  }
  final examId = focus.exam!.id;

  final rankedTopics = await ref.watch(topicAccuracyProvider.future);
  if (rankedTopics.isEmpty) {
    return const UpNextDay(lessons: [], allReadInWeakTopics: false);
  }

  final subjectRows = await (contentDb.select(contentDb.contentSubjects)
        ..where((s) => s.examId.equals(examId)))
      .get();
  final subjectMap = {for (final s in subjectRows) s.id: s.name};

  final topicRows = await (contentDb.select(contentDb.contentTopics)
        ..where((t) => t.subjectId.isIn(subjectMap.keys)))
      .get();
  final topicSubjectMap = {for (final t in topicRows) t.id: t.subjectId};

  final progressRows = await db.select(db.lessonProgressLocal).get();
  final readLessonIds = {for (final p in progressRows) p.lessonId};

  final lessonRows = await (contentDb.select(contentDb.contentLessons)
        ..where((l) => l.topicId.isIn(topicSubjectMap.keys)))
      .get();

  final lessonsByTopic = <TopicId, List<ContentLessonRow>>{};
  for (final lesson in lessonRows) {
    lessonsByTopic.putIfAbsent(lesson.topicId, () => []).add(lesson);
  }

  for (final list in lessonsByTopic.values) {
    list.sort((a, b) {
      final cmp = a.ordering.compareTo(b.ordering);
      if (cmp != 0) return cmp;
      return a.id.compareTo(b.id);
    });
  }

  const targetCount = 3;
  final resultLessons = <UpNextLesson>[];

  for (final topicAcc in rankedTopics) {
    final topicLessons = lessonsByTopic[topicAcc.topicId] ?? const [];
    for (final lesson in topicLessons) {
      if (!readLessonIds.contains(lesson.id)) {
        final subjectId = topicSubjectMap[lesson.topicId];
        final subjectName =
            subjectId != null ? (subjectMap[subjectId] ?? '') : '';
        resultLessons.add(
          UpNextLesson(
            lessonId: lesson.id,
            title: lesson.title,
            topicId: lesson.topicId,
            subjectName: subjectName,
            estimatedMinutes: lesson.estimatedMinutes,
          ),
        );
        if (resultLessons.length == targetCount) break;
      }
    }
    if (resultLessons.length == targetCount) break;
  }

  final totalLessons = lessonRows.length;
  final allRead =
      totalLessons > 0 && lessonRows.every((l) => readLessonIds.contains(l.id));

  return UpNextDay(
    lessons: resultLessons,
    allReadInWeakTopics: allRead,
  );
});
