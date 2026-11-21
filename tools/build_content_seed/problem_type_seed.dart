import 'dart:convert';

({
  Map<String, Object?> question,
  List<String> examIds,
  String freeJson,
  String proJson,
}) nativeProblemType(Map<String, Object?> record) {
  final question = record['question']! as Map<String, Object?>;
  return (
    question: question,
    examIds: [
      for (final exam in (question['exams']! as List<Object?>).cast<String>())
        'exam_${exam.replaceAll('-', '_')}',
    ],
    freeJson: jsonEncode(record['free']),
    proJson: jsonEncode(record['pro']),
  );
}
