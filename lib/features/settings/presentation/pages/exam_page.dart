import 'dart:async';

import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_bar.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/application/settings_providers.dart';
import 'package:cse_cet_reviewer/features/settings/domain/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExamPage extends ConsumerWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final activeExamName = ref.watch(activeExamShortNameProvider);
    final examsAsync = ref.watch(examListProvider);
    final actions = ref.read(settingsActionsProvider);

    final activeCount = examsAsync.valueOrNull?.where((e) => e.isActive).length;
    final availableValue =
        activeCount != null ? '$activeCount available' : 'Available';

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'Exam'),
          SettingsGroup(
            title: activeExamName,
            isFirst: true,
            children: [
              SettingsValueRow(
                title: 'Change exam',
                value: availableValue,
                showChevron: true,
                onTap: () => _push(context, '/settings/exam/change'),
              ),
              SettingsValueRow(
                title: 'Carry over progress',
                control: SettingsSwitch(value: settings.carryOverProgress),
                onTap: () => unawaited(
                  actions.setCarryOverProgress(
                    enabled: !settings.carryOverProgress,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Answers from your other exams count toward this one. '
                  'Nothing is ever deleted.',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ),
              SettingsValueRow(
                title: "What's included",
                value: 'All subjects',
                showChevron: true,
                onTap: () => _push(context, '/settings/exam/included'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _push(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    if (router != null) unawaited(router.push<void>(location));
  }
}
