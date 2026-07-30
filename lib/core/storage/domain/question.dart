// ignore_for_file: sort_unnamed_constructors_first
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'question.freezed.dart';
part 'question.g.dart';

@freezed
abstract class Question with _$Question {
  const Question._();

  const factory Question({
    required QuestionId id,
    required int version,
    required List<ExamId> examIds,
    required TopicId topicId,
    required String language,
    required String stem,
    required List<Choice> choices,
    required String explanation,

    /// Null until the tagging pass lands. Questions carry `topicId` only today.
    LessonId? lessonId,

    /// Null for free-standing questions; set for reading comprehension sets.
    PassageId? passageId,

    /// A few words naming what the question is about, for the debrief's miss
    /// rows. Null falls back to the stem clamped to two lines.
    String? shortLabel,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Choice get correctChoice => choices.firstWhere(
        (c) => c.isCorrect,
        orElse: () => throw StateError('no correct choice'),
      );
}
