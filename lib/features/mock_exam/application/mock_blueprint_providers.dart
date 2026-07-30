import 'package:pantas/core/content/content.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockBlueprintsForExamProvider =
    FutureProvider.family<MockBlueprintLoadResult, String>((ref, examId) async {
  final repo = ref.watch(mockBlueprintRepoProvider);
  final blueprints = await repo.byExam(examId);
  final parsed = <ParsedMockBlueprint>[];
  final failures = <MockBlueprintParseFailure>[];

  for (final blueprint in blueprints) {
    try {
      parsed.add(
        ParsedMockBlueprint(
          blueprint: blueprint,
          sections: BlueprintSection.parseList(blueprint.sectionsJson),
        ),
      );
    } on BlueprintParseException catch (error) {
      failures.add(
        MockBlueprintParseFailure(
          blueprintId: blueprint.id,
          error: error,
        ),
      );
    }
  }

  return MockBlueprintLoadResult(
    blueprints: List.unmodifiable(parsed),
    failures: List.unmodifiable(failures),
  );
});

class MockBlueprintLoadResult {
  const MockBlueprintLoadResult({
    required this.blueprints,
    required this.failures,
  });

  final List<ParsedMockBlueprint> blueprints;
  final List<MockBlueprintParseFailure> failures;

  List<String> get invalidBlueprintIds => [
        for (final failure in failures) failure.blueprintId,
      ];
}

class ParsedMockBlueprint {
  const ParsedMockBlueprint({
    required this.blueprint,
    required this.sections,
  });

  final MockBlueprint blueprint;
  final List<BlueprintSection> sections;
}

class MockBlueprintParseFailure {
  const MockBlueprintParseFailure({
    required this.blueprintId,
    required this.error,
  });

  final String blueprintId;
  final BlueprintParseException error;
}
