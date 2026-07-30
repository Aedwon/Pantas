import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';

/// A single search result hit within a lesson.
class LessonSearchHit {
  const LessonSearchHit({
    required this.lessonId,
    required this.title,
    required this.topicName,
    required this.estimatedMinutes,
    this.titleMatch,
    this.bodySnippet,
  });

  final LessonId lessonId;
  final String title;
  final String topicName;
  final int estimatedMinutes;
  final SearchSnippet? titleMatch;
  final SearchSnippet? bodySnippet;
}
