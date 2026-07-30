import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';

part 'exam.freezed.dart';
part 'exam.g.dart';

@freezed
class Exam with _$Exam {
  const factory Exam({
    required ExamId id,
    required String code,
    required String name,
    required String shortName,
    required String language,
    required bool isActive,
    required List<Subject> subjects,

    /// A track the student named themselves. The picker lists only the
    /// exams where this is false; everything else keys on the id and does
    /// not care where the row came from.
    @Default(false) bool isCustom,
  }) = _Exam;

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
}
