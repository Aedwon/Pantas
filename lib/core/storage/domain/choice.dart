import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'choice.freezed.dart';
part 'choice.g.dart';

@freezed
abstract class Choice with _$Choice {
  const factory Choice({
    required ChoiceId id,
    required String label,
    required String text,
    required bool isCorrect,

    /// Why this specific choice is right or wrong, addressed to the student
    /// who picked it. Null until the generation pass lands, in which case
    /// note B does not render.
    String? rationale,

    /// JSON of one figure item, for a figure choice (a series item, a matrix
    /// cell or a shape-row shape). Null for a text choice. `text` then
    /// describes the figure for a screen reader and is never shown.
    String? figureJson,
  }) = _Choice;

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);
}
