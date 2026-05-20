class MockBlueprint {
  const MockBlueprint({
    required this.id,
    required this.examId,
    required this.name,
    required this.durationMinutes,
    required this.sectionsJson,
  });

  final String id;
  final String examId;
  final String name;
  final int durationMinutes;
  final String sectionsJson;
}
