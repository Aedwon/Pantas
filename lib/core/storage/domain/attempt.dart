// ignore_for_file: sort_unnamed_constructors_first
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'attempt.freezed.dart';
part 'attempt.g.dart';

/// What the student said went wrong, noted from the debrief. Null means they
/// were not asked or chose not to say, which is the common case: the debrief
/// states outright that leaving one blank costs nothing.
enum MistakeTag { misread, slipped, unknown }

@freezed
abstract class AttemptItem with _$AttemptItem {
  const AttemptItem._();

  const factory AttemptItem({
    required QuestionId questionId,
    required int questionVersion,
    required ChoiceId chosenChoiceId,
    required ChoiceId correctChoiceId,
    required int responseMs,
    MistakeTag? mistakeTag,
  }) = _AttemptItem;

  factory AttemptItem.fromJson(Map<String, dynamic> json) =>
      _$AttemptItemFromJson(json);

  bool get isCorrect => chosenChoiceId == correctChoiceId;
}

@freezed
abstract class Attempt with _$Attempt {
  const Attempt._();

  const factory Attempt({
    required AttemptId id,
    required ExamId examId,
    required DateTime startedAt,
    required List<AttemptItem> items,
    @Default('today_topic') String origin,
    DateTime? completedAt,
  }) = _Attempt;

  factory Attempt.fromJson(Map<String, dynamic> json) =>
      _$AttemptFromJson(json);

  bool get isCompleted => completedAt != null;

  /// Returns `(correct, total)`.
  (int correct, int total) get score {
    final correct = items.where((i) => i.isCorrect).length;
    return (correct, items.length);
  }
}
