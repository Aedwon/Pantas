// ignore_for_file: lines_longer_than_80_chars

import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';

class MockStartPreparationPage extends StatelessWidget {
  const MockStartPreparationPage({
    required this.parsedBlueprint,
    required this.onStart,
    this.sample,
    super.key,
  });

  final ParsedMockBlueprint parsedBlueprint;
  final MockSample? sample;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final ready = sample != null;
    final parts = ready
        ? sample!.sections
        : parsedBlueprint.sections
            .map(
              (section) => SampledMockSection(
                sectionId: section.id,
                name: section.name,
                questionIds: const [],
              ),
            )
            .toList(growable: false);
    final count = ready
        ? sample!.actualQuestionCount
        : parsedBlueprint.blueprint.totalPublishedItems ??
            parsedBlueprint.sections.fold<int>(
              0,
              (sum, section) => sum + section.questionCount,
            );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s16,
            PantasSpace.s44,
            PantasSpace.s16,
            PantasSpace.s28,
          ),
          children: [
            Align(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.label,
                  borderRadius: BorderRadius.circular(PantasRadius.xl),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: colors.surface,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: PantasSpace.s10),
            Text(
              'Setting out your paper',
              textAlign: TextAlign.center,
              style: type.pageTitleCompact,
            ),
            const SizedBox(height: PantasSpace.s6),
            Text(
              '${parsedBlueprint.blueprint.name} · $count questions',
              textAlign: TextAlign.center,
              style: type.subhead.copyWith(color: colors.secondaryLabel),
            ),
            const SizedBox(height: PantasSpace.s24),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(PantasRadius.lg),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var index = 0; index < parts.length; index++) ...[
                    _PreparationRow(
                      name: parts[index].name,
                      questionCount: ready
                          ? parts[index].questionIds.length
                          : parsedBlueprint.sections[index].questionCount,
                      ready: ready,
                    ),
                    if (index != parts.length - 1)
                      Divider(
                        height: 1,
                        indent: 54,
                        color: colors.separator,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: PantasSpace.s24),
            if (ready) ...[
              Text(
                'Your paper is set. The clock starts when you tap.',
                textAlign: TextAlign.center,
                style: type.subheadStrong,
              ),
              const SizedBox(height: PantasSpace.s20),
              PantasButton(
                label: 'Start the Paper',
                onPressed: onStart,
              ),
            ] else
              Semantics(
                label: 'Setting out your paper',
                liveRegion: true,
                child: const SkeletonPulse(
                  child: Column(
                    children: [
                      SkeletonBlock(width: 280, height: 18),
                      SizedBox(height: PantasSpace.s24),
                      SkeletonBlock(height: 52, radius: 14),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreparationRow extends StatelessWidget {
  const _PreparationRow({
    required this.name,
    required this.questionCount,
    required this.ready,
  });

  final String name;
  final int questionCount;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s16,
        vertical: PantasSpace.s14,
      ),
      child: Row(
        children: [
          SizedBox(
            width: PantasSpace.s24,
            height: 24,
            child: ready
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colors.onAccent,
                      size: 15,
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.skeleton,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
          const SizedBox(width: PantasSpace.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: type.body),
                const SizedBox(height: PantasSpace.s2),
                Text(
                  '$questionCount ${questionCount == 1 ? 'question' : 'questions'}',
                  style: type.footnote.copyWith(color: colors.secondaryLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
