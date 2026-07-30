import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockSetupParsedBlueprintProvider =
    FutureProvider.family<ParsedMockBlueprint?, String>((ref, examId) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  if (focus.exam?.isCustom ?? false) {
    final customRepo =
        CustomBlueprintRepository(ref.watch(appDatabaseProvider));
    final customRow = await customRepo.read(examId);
    if (customRow == null) return null;
    return ParsedMockBlueprint(
      blueprint: MockBlueprint(
        id: 'custom_$examId',
        examId: examId,
        name: focus.exam!.name,
        durationMinutes: customRow.totalMinutes,
        sectionsJson: customRow.sectionsJson,
        sectionalTiming: customRow.sectionsTimedSeparately
            ? SectionalTiming.sectional
            : SectionalTiming.roamable,
      ),
      sections: BlueprintSection.parseList(customRow.sectionsJson),
    );
  } else {
    final result =
        await ref.watch(mockBlueprintsForExamProvider(examId).future);
    if (result.blueprints.isEmpty) return null;
    return result.blueprints.first;
  }
});

class MockSetupRoute extends ConsumerWidget {
  const MockSetupRoute({
    required this.examId,
    required this.onStart,
    super.key,
  });

  final String examId;
  final void Function(String blueprintId) onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsed =
        ref.watch(mockSetupParsedBlueprintProvider(examId)).valueOrNull;
    if (parsed == null) {
      return const Scaffold(body: Center(child: FaintBars()));
    }

    return MockSetupPage(
      parsedBlueprint: parsed,
      onStart: () {
        onStart(parsed.blueprint.id);
      },
    );
  }
}
