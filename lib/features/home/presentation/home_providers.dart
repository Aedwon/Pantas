import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// Everything the masthead prints, gathered once so the widget reads one
/// provider rather than three repositories.
@immutable
class HomeMastheadData {
  const HomeMastheadData({
    required this.name,
    required this.examShortName,
    required this.examDate,
  });

  /// Null and empty are the same state: no name.
  final String? name;
  final String examShortName;
  final ExamDate? examDate;

  @override
  bool operator ==(Object other) =>
      other is HomeMastheadData &&
      other.name == name &&
      other.examShortName == examShortName &&
      other.examDate == examDate;

  @override
  int get hashCode => Object.hash(name, examShortName, examDate);
}

final homeMastheadProvider = FutureProvider<HomeMastheadData>((ref) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final settings = await ref.watch(userSettingsProvider.future);
  final name = settings.name?.trim();
  return HomeMastheadData(
    name: name == null || name.isEmpty ? null : name,
    examShortName: focus.exam?.shortName ?? '',
    examDate: settings.examDate,
  );
});

@immutable
class LessonsRead {
  const LessonsRead({required this.read, required this.total});

  final int read;
  final int total;

  @override
  bool operator ==(Object other) =>
      other is LessonsRead && other.read == read && other.total == total;

  @override
  int get hashCode => Object.hash(read, total);
}

final lessonsReadProvider =
    FutureProvider.family<LessonsRead, ExamId>((ref, examId) async {
  final db = ref.watch(appDatabaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);
  final subjectRows = await (contentDb.select(contentDb.contentSubjects)
        ..where((s) => s.examId.equals(examId)))
      .get();
  final subjectIds = subjectRows.map((s) => s.id).toList();
  if (subjectIds.isEmpty) return const LessonsRead(read: 0, total: 0);

  final topicRows = await (contentDb.select(contentDb.contentTopics)
        ..where((t) => t.subjectId.isIn(subjectIds)))
      .get();
  final topicIds = topicRows.map((t) => t.id).toList();
  if (topicIds.isEmpty) return const LessonsRead(read: 0, total: 0);

  final lessonRows = await (contentDb.select(contentDb.contentLessons)
        ..where((l) => l.topicId.isIn(topicIds)))
      .get();
  final lessonIds = lessonRows.map((l) => l.id).toSet();
  if (lessonIds.isEmpty) return const LessonsRead(read: 0, total: 0);

  final progressRows = await (db.select(db.lessonProgressLocal)
        ..where((p) => p.lessonId.isIn(lessonIds)))
      .get();

  return LessonsRead(read: progressRows.length, total: lessonRows.length);
});
