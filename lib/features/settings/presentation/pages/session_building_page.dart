import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
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
    return SettingsPanePage(
      section: 'Practice',
      title: 'Practice',
      description: 'How your sessions are put together.',
      backLabel: 'Settings',
      hero: true,
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        SettingsSection(
          header: 'Session length',
          footer: 'How many questions in one quiz session. It doesn’t change '
              'how much is due for the whole day.',
          children: [
            Padding(
              padding: context.wideWeb
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                  : const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.wideWeb ? 420 : double.infinity,
                  ),
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          header: 'How sessions are built',
          footer: 'Studies show that mixing topics is harder now but gets '
              'much easier on exam day.',
          children: [
            for (final ordering in SessionOrdering.values)
              if (context.wideWeb)
                SettingsRow(
                  mutuallyExclusive: true,
                  title: _orderingTitle(ordering),
                  subtitle: _orderingSubtitle(ordering),
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
                )
              else
                _ChoiceRow(
                  title: _orderingTitle(ordering),
                  subtitle: _orderingSubtitle(ordering),
                  recommended: ordering.isRecommended,
                  selected: settings.sessionOrdering == ordering,
                  divider: ordering != SessionOrdering.values.last,
                  onTap: () => unawaited(actions.setSessionOrdering(ordering)),
                ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          footer: 'For mock exams: no pausing and no ending a section early. '
              'Leaving the ${context.wideWeb ? 'mock' : 'app'} instantly ends '
              'and submits your answers, '
              'finished or not finished.',
          children: [
            SettingsRow(
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

String _orderingTitle(SessionOrdering ordering) => switch (ordering) {
      SessionOrdering.blocked => 'One topic only',
      SessionOrdering.interleavedTail => 'Interleaved tail',
      SessionOrdering.fullyMixed => 'Fully mixed'
    };

String _orderingSubtitle(SessionOrdering ordering) => switch (ordering) {
      SessionOrdering.blocked => 'Grouped by topic, one topic at a time.',
      SessionOrdering.interleavedTail => 'Mostly one topic, some others.',
      SessionOrdering.fullyMixed => 'No two in a row from the same topic.'
    };

/// ST_Practice on the phone: a plain row with a green "Recommended" tag beside
/// the title and a check at the right of the chosen row.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.subtitle,
    required this.recommended,
    required this.selected,
    required this.divider,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool recommended;
  final bool selected;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      label: [title, if (recommended) 'Recommended', subtitle].join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            border: divider
                ? Border(bottom: BorderSide(color: c.separator, width: .5))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(title, style: context.type.body),
                        if (recommended) ...[
                          Text(
                            'Recommended',
                            style: context.type.footnote.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.accent,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(subtitle, style: context.type.footnote),
                  ],
                ),
              ),
              if (selected) Icon(PantasIcons.check, size: 18, color: c.accent),
            ],
          ),
        ),
      ),
    );
  }
}
