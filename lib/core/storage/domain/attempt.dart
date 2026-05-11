import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'attempt.freezed.dart';
part 'attempt.g.dart';

@freezed
class AttemptItem with _$AttemptItem {
  const AttemptItem._();

  const factory AttemptItem({
    required QuestionId questionId,
    required int questionVersion,
    required ChoiceId chosenChoiceId,
    required ChoiceId correctChoiceId,
    required int responseMs,
  }) = _AttemptItem;

  factory AttemptItem.fromJson(Map<String, dynamic> json) =>
      _$AttemptItemFromJson(json);

  bool get isCorrect => chosenChoiceId == correctChoiceId;
}

@freezed
class Attempt with _$Attempt {
  const Attempt._();

  const factory Attempt({
    required AttemptId id,
    required ExamId examId,
    required DateTime startedAt,
    required List<AttemptItem> items,
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
