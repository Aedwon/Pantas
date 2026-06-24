import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/database_opener.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/assessment_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_bookmarks_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/quiz_nudge_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/streak_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/domain/topic.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(
    'Override appDatabaseProvider in main bootstrap or tests',
  ),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(appDatabaseProvider)),
);

final attemptsRepositoryProvider = Provider<AttemptsRepository>(
  (ref) => AttemptsRepository(ref.watch(appDatabaseProvider)),
);

final reviewStateRepositoryProvider = Provider<ReviewStateRepository>(
  (ref) => ReviewStateRepository(ref.watch(appDatabaseProvider)),
);

final streakRepositoryProvider = Provider<StreakRepository>(
  (ref) => StreakRepository(ref.watch(appDatabaseProvider)),
);

final appPreferencesRepositoryProvider = Provider<AppPreferencesRepository>(
  (ref) => AppPreferencesRepository(ref.watch(appDatabaseProvider)),
);

final seederProvider = Provider<Seeder>(
  (ref) => Seeder(ref.watch(appDatabaseProvider), bundle: rootBundle),
);

/// Opens the encrypted DB and returns a ProviderContainer override list.
/// Call from main bootstrap.
Future<List<Override>> bootstrapStorageOverrides() async {
  final db = await openEncryptedDatabase();
  return [appDatabaseProvider.overrideWithValue(db)];
}

final examListProvider = FutureProvider<List<Exam>>((ref) async {
  return ref.watch(contentRepositoryProvider).listExams();
});

final topicsBySubjectProvider =
    FutureProvider.family<List<Topic>, SubjectId>((ref, subjectId) async {
  return ref.watch(contentRepositoryProvider).topicsBySubject(subjectId);
});

final topicByIdProvider =
    FutureProvider.family<Topic?, TopicId>((ref, topicId) async {
  return ref.watch(contentRepositoryProvider).topicById(topicId);
});

final topicsByExamProvider =
    FutureProvider.family<List<Topic>, ExamId>((ref, examId) async {
  return ref.watch(contentRepositoryProvider).topicsByExam(examId);
});

final lessonByIdProvider =
    FutureProvider.family<Lesson?, LessonId>((ref, id) async {
  return ref.watch(contentRepositoryProvider).lessonById(id);
});

final topicLessonsProvider =
    FutureProvider.family<List<Lesson>, TopicId>((ref, topicId) async {
  return ref.watch(contentRepositoryProvider).lessonsByTopic(topicId);
});

final lessonProgressRepositoryProvider = Provider<LessonProgressRepository>(
  (ref) => LessonProgressRepository(ref.watch(appDatabaseProvider)),
);

final lessonBookmarksRepositoryProvider = Provider<LessonBookmarksRepository>(
  (ref) => LessonBookmarksRepository(ref.watch(appDatabaseProvider)),
);

final quizNudgeRepositoryProvider = Provider<QuizNudgeRepository>(
  (ref) => QuizNudgeRepository(ref.watch(appDatabaseProvider)),
);

final isLessonReadProvider =
    FutureProvider.family<bool, LessonId>((ref, lessonId) async {
  return ref.watch(lessonProgressRepositoryProvider).isRead(lessonId);
});

final readCountForTopicProvider =
    FutureProvider.family<int, TopicId>((ref, topicId) async {
  return ref.watch(lessonProgressRepositoryProvider).readCountForTopic(topicId);
});

final anyLessonReadProvider = FutureProvider<bool>((ref) async {
  return ref.watch(lessonProgressRepositoryProvider).hasAnyRead();
});

final quizNudgeDismissedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(quizNudgeRepositoryProvider).hasDismissed();
});

final assessmentRepositoryProvider = Provider<AssessmentRepository>(
  (ref) => AssessmentRepository(ref.watch(appDatabaseProvider)),
);

final assessmentCompletedProvider =
    FutureProvider.family<bool, ExamId>((ref, examId) async {
  return ref.watch(assessmentRepositoryProvider).hasCompletedForExam(examId);
});

final countForExamProvider =
    FutureProvider.family<int, ExamId>((ref, examId) async {
  return ref.watch(attemptsRepositoryProvider).countForExam(examId);
});
