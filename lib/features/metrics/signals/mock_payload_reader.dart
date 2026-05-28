import 'dart:convert';

class MockPayload {
  const MockPayload({
    required this.sections,
    required this.answers,
    required this.flaggedQuestionIds,
    required this.sectionResults,
  });

  final List<MockPayloadSection> sections;
  final Map<String, MockPayloadAnswer> answers;
  final Set<String> flaggedQuestionIds;
  final List<MockPayloadSectionResult> sectionResults;
}

class MockPayloadSection {
  const MockPayloadSection({
    required this.sectionId,
    required this.name,
    required this.questionIds,
  });

  final String sectionId;
  final String name;
  final List<String> questionIds;
}

class MockPayloadAnswer {
  const MockPayloadAnswer({
    required this.selectedIndex,
    required this.atSec,
  });

  final int selectedIndex;
  final int atSec;
}

class MockPayloadSectionResult {
  const MockPayloadSectionResult({
    required this.sectionId,
    required this.name,
    required this.correct,
    required this.total,
    required this.retiredCount,
    required this.timeSeconds,
  });

  final String sectionId;
  final String name;
  final int correct;
  final int total;
  final int retiredCount;
  final int timeSeconds;
}

class MockPayloadReader {
  const MockPayloadReader();

  MockPayload read({
    required String sampledQuestionsJson,
    required String answersJson,
    required String flagsJson,
    String? sectionResultsJson,
  }) {
    return MockPayload(
      sections: _sections(sampledQuestionsJson),
      answers: _answers(answersJson),
      flaggedQuestionIds: _flags(flagsJson),
      sectionResults: _sectionResults(sectionResultsJson),
    );
  }

  List<MockPayloadSection> _sections(String raw) {
    final decoded = _decode(raw);
    if (decoded is! List) return const [];
    return [
      for (final item in decoded)
        if (item is Map<String, Object?>)
          MockPayloadSection(
            sectionId: item['sectionId']! as String,
            name: item['name']! as String,
            questionIds: (item['questionIds']! as List).cast<String>(),
          ),
    ];
  }

  Map<String, MockPayloadAnswer> _answers(String raw) {
    final decoded = _decode(raw);
    if (decoded is! Map<String, Object?>) return const {};
    return {
      for (final entry in decoded.entries)
        if (entry.value is Map<String, Object?>)
          entry.key: MockPayloadAnswer(
            selectedIndex:
                (entry.value! as Map<String, Object?>)['selectedIndex']! as int,
            atSec: (entry.value! as Map<String, Object?>)['atSec']! as int,
          ),
    };
  }

  Set<String> _flags(String raw) {
    final decoded = _decode(raw);
    if (decoded is! List) return const {};
    return decoded.whereType<String>().toSet();
  }

  List<MockPayloadSectionResult> _sectionResults(String? raw) {
    if (raw == null) return const [];
    final decoded = _decode(raw);
    if (decoded is! Map<String, Object?>) return const [];
    final sections = decoded['sections'];
    if (sections is! List) return const [];
    return [
      for (final item in sections)
        if (item is Map<String, Object?>)
          MockPayloadSectionResult(
            sectionId: item['sectionId']! as String,
            name: item['name']! as String,
            correct: item['correct']! as int,
            total: item['total']! as int,
            retiredCount: item['retiredCount']! as int,
            timeSeconds: item['timeSeconds']! as int,
          ),
    ];
  }

  Object? _decode(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
