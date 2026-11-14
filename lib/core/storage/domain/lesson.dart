import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@freezed
abstract class Lesson with _$Lesson {
  const factory Lesson({
    required LessonId id,
    required TopicId topicId,
    required String title,
    required String summary,
    required List<Map<String, dynamic>> bodyJson,
    required int estimatedMinutes,
    SubtopicId? subtopicId,
    @Default(0) int ordering,
    @Default(5) int quizSize,
    @Default('active') String status,
    List<String>? replacedBy,
    int? part,
    int? partCount,
    List<String>? keyPoints,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}
