import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'choice.freezed.dart';
part 'choice.g.dart';

@freezed
class Choice with _$Choice {
  const factory Choice({
    required ChoiceId id,
    required String label,
    required String text,
    required bool isCorrect,

    /// Why this specific choice is right or wrong, addressed to the student
    /// who picked it. Null until the generation pass lands, in which case
    /// note B does not render.
    String? rationale,
  }) = _Choice;

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);
}
