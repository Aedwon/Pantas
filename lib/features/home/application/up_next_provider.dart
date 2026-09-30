import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

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

  /// True when every lesson in the roadmap scope is read. Distinct from
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

  final today = await ref.watch(roadmapTodayProvider(examId).future);
  final scopeTopicIds = today.snapshot.digest.scopeTopicIds;
  if (scopeTopicIds.isEmpty) {
    return const UpNextDay(lessons: [], allReadInWeakTopics: false);
  }

  final topicRows = await (contentDb.select(contentDb.contentTopics)
        ..where((t) => t.id.isIn(scopeTopicIds)))
      .get();
  final topicSubjectMap = {for (final t in topicRows) t.id: t.subjectId};
  final subjectRows = await (contentDb.select(contentDb.contentSubjects)
        ..where((s) => s.id.isIn(topicSubjectMap.values)))
      .get();
  final subjectMap = {for (final s in subjectRows) s.id: s.name};

  final lessonGroups = await ref
      .watch(contentRepositoryProvider)
      .lessonMetaByTopics(scopeTopicIds);
  final lessonsById = {
    for (final lessons in lessonGroups.values)
      for (final lesson in lessons) lesson.id: lesson,
  };

  final progressRows = await db.select(db.lessonProgressLocal).get();
  final readLessonIds = {for (final p in progressRows) p.lessonId};
  final resultLessons = <UpNextLesson>[];
  for (final id in today.remaining.lessonIds) {
    final lesson = lessonsById[id];
    if (lesson == null) continue;
    final subjectId = topicSubjectMap[lesson.topicId];
    resultLessons.add(
      UpNextLesson(
        lessonId: lesson.id,
        title: lesson.title,
        topicId: lesson.topicId,
        subjectName: subjectMap[subjectId] ?? '',
        estimatedMinutes: lesson.estimatedMinutes,
      ),
    );
  }

  return UpNextDay(
    lessons: resultLessons,
    allReadInWeakTopics: lessonsById.isNotEmpty &&
        lessonsById.keys.every(readLessonIds.contains),
  );
});
