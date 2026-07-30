import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson.dart';

class GetTopicLessons {
  GetTopicLessons(this._content);

  final ContentRepository _content;

  Future<List<Lesson>> call(TopicId topicId) async {
    return _content.lessonsByTopic(topicId);
  }
}
