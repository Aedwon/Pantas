class DiagnosticSet {
  const DiagnosticSet({
    required this.id,
    required this.examId,
    required this.name,
    required this.questionIds,
  });

  final String id;
  final String examId;
  final String name;
  final List<String> questionIds;
}
