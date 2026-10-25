import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';

class SessionBuildingPage extends ConsumerWidget {
  const SessionBuildingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final actions = ref.read(settingsActionsProvider);
    final length = ref.watch(settingsSessionLengthProvider).valueOrNull ?? 10;
    const lengths = [5, 10, 20, -1];
    return PantasPage(
      title: 'Practice',
      backLabel: 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        Text(
          'How your sessions are put together.',
          style:
              context.type.body.copyWith(color: context.colors.secondaryLabel),
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'Session length',
          footer: "How many questions in one quiz session. It doesn't change "
              'how much is due for the whole day.',
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: SegmentedSwitch(
                labels: const ['5', '10', '20', 'All'],
                selected: lengths.indexOf(length),
                onChanged: (index) async {
                  final repository =
                      ref.read(quizPreferencesRepositoryProvider);
                  final current = await repository.read();
                  await repository.save(
                    QuizPreferences(
                      sessionLength: lengths[index],
                      ordering: current.ordering,
                    ),
                  );
                  ref.invalidate(settingsSessionLengthProvider);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'How sessions are built',
          footer: 'Studies show that mixing topics is harder now but gets '
              'much easier on exam day.',
          children: [
            for (final ordering in SessionOrdering.values)
              ListRow(
                mutuallyExclusive: true,
                title: switch (ordering) {
                  SessionOrdering.blocked => 'One topic only',
                  SessionOrdering.interleavedTail => 'Interleaved tail',
                  SessionOrdering.fullyMixed => 'Fully mixed'
                },
                subtitle: switch (ordering) {
                  SessionOrdering.blocked =>
                    'Grouped by topic, one topic at a time.',
                  SessionOrdering.interleavedTail =>
                    'Mostly one topic, some others.',
                  SessionOrdering.fullyMixed =>
                    'No two in a row from the same topic.'
                },
                footer: ordering.isRecommended
                    ? Text(
                        'Recommended',
                        style: context.type.footnote
                            .copyWith(color: context.colors.accent),
                      )
                    : null,
                variant: ListRowVariant.check,
                selected: settings.sessionOrdering == ordering,
                divider: ordering != SessionOrdering.values.last,
                onTap: () => unawaited(actions.setSessionOrdering(ordering)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          footer: 'For mock exams: no pausing and no ending a section early. '
              'Leaving the app instantly ends and submits your answers, '
              'finished or not finished.',
          children: [
            ListRow(
              title: 'Strict mode',
              variant: ListRowVariant.switchControl,
              selected: settings.strictMockMode,
              onTap: () => unawaited(
                actions.setStrictMockMode(
                  enabled: !settings.strictMockMode,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
