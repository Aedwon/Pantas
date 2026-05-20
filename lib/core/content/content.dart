import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/content_database_opener.dart';
import 'package:cse_cet_reviewer/core/content/repos/exam_repo.dart';
import 'package:cse_cet_reviewer/core/content/repos/lesson_repo.dart';
import 'package:cse_cet_reviewer/core/content/repos/question_repo.dart';
import 'package:cse_cet_reviewer/core/content/repos/subject_repo.dart';
import 'package:cse_cet_reviewer/core/content/repos/topic_repo.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'content_database.dart';
export 'repos/exam_repo.dart';
export 'repos/lesson_repo.dart';
export 'repos/question_repo.dart';
export 'repos/subject_repo.dart';
export 'repos/topic_repo.dart';

final contentDatabaseProvider = Provider<ContentDatabase>(
  (ref) => throw UnimplementedError(
    'Override contentDatabaseProvider in main bootstrap or tests',
  ),
);

Future<List<Override>> bootstrapContentOverrides({
  Future<ContentDatabase> Function() open = openContentDatabase,
}) async {
  final db = await open();
  return [contentDatabaseProvider.overrideWithValue(db)];
}

final examRepoProvider = Provider<ExamRepo>(
  (ref) => ExamRepo(ref.watch(contentDatabaseProvider)),
);

final subjectRepoProvider = Provider<SubjectRepo>(
  (ref) => SubjectRepo(ref.watch(contentDatabaseProvider)),
);

final topicRepoProvider = Provider<TopicRepo>(
  (ref) => TopicRepo(ref.watch(contentDatabaseProvider)),
);

final questionRepoProvider = Provider<QuestionRepo>(
  (ref) => QuestionRepo(ref.watch(contentDatabaseProvider)),
);

final lessonRepoProvider = Provider<LessonRepo>(
  (ref) => LessonRepo(ref.watch(contentDatabaseProvider)),
);

final activeExamsProvider = StreamProvider<List<Exam>>(
  (ref) => ref.watch(examRepoProvider).watchActive(),
);
