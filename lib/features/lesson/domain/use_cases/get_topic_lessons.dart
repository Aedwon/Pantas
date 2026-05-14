import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';

class GetTopicLessons {
  GetTopicLessons(this._content);

  final ContentRepository _content;

  Future<List<Lesson>> call(TopicId topicId) async {
    return _content.lessonsByTopic(topicId);
  }
}
