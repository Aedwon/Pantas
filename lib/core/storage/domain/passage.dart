// ignore_for_file: sort_unnamed_constructors_first
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/ids.dart';

part 'passage.freezed.dart';
part 'passage.g.dart';

@freezed
abstract class Passage with _$Passage {
  const Passage._();

  const factory Passage({
    required PassageId id,
    required TopicId topicId,
    required String title,
    required String body,
    required String language,
    required int wordCount,
  }) = _Passage;

  factory Passage.fromJson(Map<String, dynamic> json) =>
      _$PassageFromJson(json);
}
