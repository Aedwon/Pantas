import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'review_state.freezed.dart';
part 'review_state.g.dart';

enum ReviewStage {
  @JsonValue('new')
  newCard,
  @JsonValue('learning')
  learning,
  @JsonValue('review')
  review,
  @JsonValue('relearning')
  relearning,
}

@freezed
abstract class ReviewState with _$ReviewState {
  const ReviewState._();

  const factory ReviewState({
    required QuestionId questionId,
    required int questionVersion,
    required ReviewStage stage,
    required double stability,
    required double difficulty,
    required DateTime due,
    required DateTime lastReview,
    required int reps,
    required int lapses,
    required double elapsedDays,
    required double scheduledDays,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(<int, DateTime>{})
    Map<int, DateTime> servedVariants,
  }) = _ReviewState;

  factory ReviewState.fromJson(Map<String, dynamic> json) =>
      _$ReviewStateFromJson(json);

  ReviewState withServedVariant(int? variantIndex, DateTime answeredAt) {
    if (variantIndex == null) return this;
    final previous = servedVariants[variantIndex];
    if (previous != null && !answeredAt.isAfter(previous)) return this;
    return copyWith(
      servedVariants: {...servedVariants, variantIndex: answeredAt.toUtc()},
    );
  }

  factory ReviewState.seed({
    required QuestionId questionId,
    required int questionVersion,
    required DateTime now,
  }) =>
      ReviewState(
        questionId: questionId,
        questionVersion: questionVersion,
        stage: ReviewStage.newCard,
        stability: 0,
        difficulty: 0,
        due: now,
        lastReview: now,
        reps: 0,
        lapses: 0,
        elapsedDays: 0,
        scheduledDays: 0,
      );
}
