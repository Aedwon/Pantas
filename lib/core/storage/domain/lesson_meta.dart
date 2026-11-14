import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';

/// Lesson metadata for planning without loading lesson bodies.
@immutable
class LessonMeta {
  const LessonMeta({
    required this.id,
    required this.topicId,
    required this.title,
    required this.ordering,
    required this.estimatedMinutes,
    this.part,
    this.partCount,
  });

  final LessonId id;
  final TopicId topicId;
  final String title;
  final int ordering;
  final int estimatedMinutes;

  /// Position in a split lesson; both null when the lesson is not split.
  final int? part;
  final int? partCount;
}
