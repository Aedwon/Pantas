import 'package:pantas/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';

class MarkLessonRead {
  MarkLessonRead(this._progress);

  final LessonProgressRepository _progress;

  Future<void> call(LessonId lessonId) => _progress.markRead(lessonId);
}
