// Pure JSON boundary shared by the VM reference and compiled server core.
import 'package:pantas/features/roadmap/domain/session_diagnosis.dart';

import 'roadmap_codec.dart';

Map<String, Object?> sessionDiagnosisFromJson(Map<String, Object?> json) {
  final session = json['session']! as Map<String, Object?>;
  final result = SessionDiagnosis.compute(
    inputs: inputsFromJson(json['inputs']! as Map<String, Object?>),
    sessionAnswers: [
      for (final value in (session['answers']! as List<Object?>)
          .cast<Map<String, Object?>>())
        DiagnosisAnswer(
          questionId: value['questionId']! as String,
          chosenChoiceId: value['chosen'] as String?,
          correct: value['correct']! as bool,
        ),
    ],
    mistakeNotes: (json['notes'] as Map<String, Object?>? ?? const {})
        .cast<String, String>(),
    includeDetail: json['includeDetail'] as bool? ?? false,
  ).toJson();
  if (json['includeDetail'] != true) return result;
  for (final key in ['traced', 'withinLesson']) {
    final rows = (result[key]! as List<Map<String, Object?>>).map((row) {
      final questions = (row['questions']! as List<Map<String, Object?>>)
          .toList()
        // Answer order, so the debrief lists question numbers ascending.
        ..sort(
          (a, b) => (a['position']! as int).compareTo(b['position']! as int),
        );
      return {...row, 'questions': questions};
    }).toList()
      ..sort((a, b) {
        for (final field in key == 'traced'
            ? ['prerequisite', 'forLesson', 'via']
            : ['lesson']) {
          final order = (a[field]! as String).compareTo(b[field]! as String);
          if (order != 0) return order;
        }
        return 0;
      });
    result[key] = rows;
  }
  return result;
}
