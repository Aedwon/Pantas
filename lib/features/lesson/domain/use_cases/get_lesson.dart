import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';

class GetLesson {
  GetLesson(this._content);

  final ContentRepository _content;

  Future<Lesson> call(LessonId id) async {
    final lesson = await _content.lessonById(id);
    if (lesson == null) throw StateError('Lesson not found: $id');
    return lesson;
  }
}
