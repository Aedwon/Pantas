import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

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
  }

  final result = await ref.watch(mockBlueprintsForExamProvider(examId).future);
  if (result.blueprints.isEmpty) return null;
  return result.blueprints.first;
});

final mockSetupQuestionCountProvider =
    FutureProvider.family<int?, String>((ref, examId) async {
  final parsed =
      await ref.watch(mockSetupParsedBlueprintProvider(examId).future);
  if (parsed == null) return null;
  final pools = await ref.watch(mockQuestionPoolsProvider(examId).future);
  final sample = ref.watch(mockSamplerProvider).sample(
        sections: parsed.sections,
        poolsByTopic: pools.poolsByTopic,
        passageSetsByTopic: pools.passageSetsByTopic,
        recentlySampledQuestionIds: const <String>{},
        seed: 0,
      );
  return sample.sections.fold<int>(
    0,
    (sum, section) => sum + section.questionIds.length,
  );
});

class MockSetupRoute extends ConsumerWidget {
  const MockSetupRoute({
    required this.examId,
    required this.onStart,
    super.key,
  });

  final String examId;
  final void Function(String blueprintId, {required bool strictMode}) onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsedAsync = ref.watch(mockSetupParsedBlueprintProvider(examId));
    final settingsAsync = ref.watch(userSettingsProvider);
    final countAsync = ref.watch(mockSetupQuestionCountProvider(examId));

    final error = parsedAsync.error ?? settingsAsync.error ?? countAsync.error;
    if (error != null) {
      return StateView.fullScreen(
        error: error,
        onRetry: () {
          ref
            ..invalidate(mockSetupParsedBlueprintProvider(examId))
            ..invalidate(mockSetupQuestionCountProvider(examId))
            ..invalidate(userSettingsProvider);
        },
      );
    }

    if (parsedAsync.isLoading ||
        settingsAsync.isLoading ||
        countAsync.isLoading) {
      return const Scaffold(body: Center(child: FaintBars()));
    }

    final parsed = parsedAsync.valueOrNull;
    final settings = settingsAsync.valueOrNull;
    if (parsed == null || settings == null) {
      return const Scaffold(
        body: Center(
          child: StateView(
            message: 'This mock is not available yet.',
            detail: 'Try another exam or come back after a content update.',
          ),
        ),
      );
    }

    return MockSetupPage(
      parsedBlueprint: parsed,
      initialStrictMode: settings.strictMockMode,
      actualQuestionCount: countAsync.valueOrNull,
      onStart: (strictMode) =>
          onStart(parsed.blueprint.id, strictMode: strictMode),
    );
  }
}
