// ignore_for_file: sort_unnamed_constructors_first
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'question.freezed.dart';
part 'question.g.dart';

/// How a question's choices are shown: as text rows, or as figure tiles.
enum ChoiceKind { text, figure }

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

    /// How to draw this question's diagram, as JSON. Null when it has none.
    /// The painter decodes it; nothing else has to understand it.
    String? figureSpecJson,

    /// Index into the lesson's key points. Null when the lesson is not split
    /// or the question is not yet tagged.
    int? keyPoint,

    /// `figure` asks for figure tiles. The screen draws them only when every
    /// choice has a figure it can draw; otherwise it shows the text rows.
    @JsonKey(unknownEnumValue: ChoiceKind.text)
    @Default(ChoiceKind.text)
    ChoiceKind choiceKind,

    /// False hides the question figure when the choices are drawn as tiles,
    /// for odd-one-out questions whose shapes are the choices.
    @Default(true) bool showQuestionFigure,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Choice get correctChoice => choices.firstWhere(
        (c) => c.isCorrect,
        orElse: () => throw StateError('no correct choice'),
      );
}
