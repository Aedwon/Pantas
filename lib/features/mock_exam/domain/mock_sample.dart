class MockSample {
  const MockSample({
    required this.sections,
    required this.expectedQuestionCount,
  });

  final List<SampledMockSection> sections;
  final int expectedQuestionCount;

  int get actualQuestionCount => sections.fold<int>(
        0,
        (total, section) => total + section.questionIds.length,
      );

  bool get partiallyFulfilled => actualQuestionCount < expectedQuestionCount;
}

class SampledMockSection {
  const SampledMockSection({
    required this.sectionId,
    required this.name,
    required this.questionIds,
  });

  final String sectionId;
  final String name;
  final List<String> questionIds;
}
