import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_skeletons.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

final mockSetupParsedBlueprintProvider =
    FutureProvider.family<ParsedMockBlueprint?, String>((ref, examId) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  if (focus.exam?.isCustom ?? false) {
    final customRepo =
        CustomBlueprintRepository(ref.watch(appDatabaseProvider));
    final customRow = await customRepo.read(examId);
    if (customRow == null) return null;
    final sections = BlueprintSection.parseList(customRow.sectionsJson);
    // The server times parts apart only for two or more. One part, or none,
    // runs on the one clock whatever the switch says.
    final byPart = customRow.sectionsTimedSeparately && sections.length >= 2;
    return ParsedMockBlueprint(
      blueprint: MockBlueprint(
        id: 'custom_$examId',
        examId: examId,
        name: focus.exam!.name,
        durationMinutes: customRow.totalMinutes,
        sectionsJson: customRow.sectionsJson,
        sectionalTiming:
            byPart ? SectionalTiming.sectional : SectionalTiming.roamable,
      ),
      // The student's minutes for a part are the part's own clock.
      sections: byPart ? sections.map(_withPartClock).toList() : sections,
    );
  }

  final result = await ref.watch(mockBlueprintsForExamProvider(examId).future);
  if (result.blueprints.isEmpty) return null;
  return result.blueprints.first;
});

BlueprintSection _withPartClock(BlueprintSection section) => BlueprintSection(
      id: section.id,
      name: section.name,
      questionCount: section.questionCount,
      suggestedMinutes: section.suggestedMinutes,
      topicIds: section.topicIds,
      topicWeights: section.topicWeights,
      sectionalMinutes: section.suggestedMinutes,
    );

final mockSetupQuestionCountProvider =
    FutureProvider.family<int?, String>((ref, examId) async {
  if (ref.watch(mockUsesServerProvider)) {
    return ref.watch(serverMockSetupCountProvider(examId).future);
  }
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

    final notOpen = countAsync.error;
    if (notOpen is ServerMockNotOpen) {
      firstScreenReady(context, ref);
      // The server has no paper it can build for a custom exam this device
      // holds a setup for. The setup page is where that is put right: it
      // shows the limit when the student has narrowed.
      if (notOpen.noBlueprint && isCustomExamId(examId)) {
        if (parsedAsync.isLoading) return const MockSetupSkeleton();
        if (parsedAsync.valueOrNull != null) return const _OpenCustomSetup();
      }
      return MockNotOpenView(notOpen);
    }

    final error = parsedAsync.error ?? settingsAsync.error ?? countAsync.error;
    if (error != null) {
      firstScreenReady(context, ref);
      return StateView.fullScreen(
        error: error,
        onRetry: () {
          if (ref.read(mockUsesServerProvider)) {
            ref.invalidate(serverMockSetupCountProvider(examId));
          }
          ref
            ..invalidate(mockBlueprintsForExamProvider(examId))
            ..invalidate(mockSetupParsedBlueprintProvider(examId))
            ..invalidate(mockSetupQuestionCountProvider(examId))
            ..invalidate(userSettingsProvider);
        },
      );
    }

    if (parsedAsync.isLoading ||
        settingsAsync.isLoading ||
        countAsync.isLoading) {
      return const MockSetupSkeleton();
    }

    firstScreenReady(context, ref);
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

/// Replaces the start page with the custom setup page.
class _OpenCustomSetup extends StatefulWidget {
  const _OpenCustomSetup();

  @override
  State<_OpenCustomSetup> createState() => _OpenCustomSetupState();
}

class _OpenCustomSetupState extends State<_OpenCustomSetup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pushReplacement('/quiz/mock/custom-setup');
    });
  }

  @override
  Widget build(BuildContext context) => const MockSetupSkeleton();
}

/// Shown instead of setup while the server will not start a mock. The wording
/// comes from the Quiz card (board QZ_Free) and the mock status card.
class MockNotOpenView extends StatelessWidget {
  const MockNotOpenView(this.notOpen, {this.onBack, super.key});

  final ServerMockNotOpen notOpen;

  /// Where Back goes. By default one step back, or the Quiz tab.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final opens = notOpen.nextOpensAt?.toLocal();
    return Scaffold(
      body: Center(
        child: StateView(
          // The server-backed mock is the web mock, which waits 30 days.
          message:
              opens == null ? 'Mock paper not ready' : freeMockIntervalLine(30),
          detail: opens == null ? null : mockNextOpensLine(opens),
          actionLabel: 'Back',
          onRetry: onBack ??
              () => context.canPop() ? context.pop() : context.go('/quiz'),
        ),
      ),
    );
  }
}
