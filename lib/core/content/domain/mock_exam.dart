class MockExam {
  const MockExam({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.publishedAt,
  });

  final String id;
  final String blueprintId;
  final String name;
  final DateTime publishedAt;
}
