import 'dart:async';

import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_bar.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_group.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_switch.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/theme_control.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/settings_value_formats.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Settings, reached by the gear in Home's masthead. There is no Settings tab.
///
/// Twelve rows in five groups, all on one scroll. Sub-pages exist only where a
/// surface has states or a list too long for a row. The four-door version and
/// the identity-plate version were both drawn and rejected.
class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final theme = ref.watch(themePreferenceProvider).valueOrNull ??
        ThemePreference.system;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isAnonymous = ref.watch(isAnonymousProvider).valueOrNull ?? false;
    final syncStatus = ref.watch(syncStatusProvider).valueOrNull;
    final notificationsDenied =
        ref.watch(notificationPermissionStatusProvider).valueOrNull ==
            NotificationPermission.denied;
    final actions = ref.read(settingsActionsProvider);

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'Settings'),
          SettingsGroup(
            title: 'You',
            isFirst: true,
            children: [
              SettingsValueRow(
                title: 'Name',
                value: SettingsValueFormats.name(settings.name),
                onTap: () => _push(context, '/settings/name'),
              ),
              SettingsValueRow(
                title: 'Exam',
                value: ref.watch(activeExamShortNameProvider),
                showChevron: true,
                onTap: () => _push(context, '/settings/exam'),
              ),
              SettingsValueRow(
                title: 'Exam date',
                value: SettingsValueFormats.examDate(settings.examDate),
                onTap: () => _push(context, '/settings/exam-date'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'How you practice',
            children: [
              SettingsValueRow(
                title: 'How sessions are built',
                value: settings.sessionOrdering.label,
                showChevron: true,
                onTap: () => _push(context, '/settings/ordering'),
              ),
              SettingsValueRow(
                title: 'Strict mock mode',
                control: SettingsSwitch(value: settings.strictMockMode),
                onTap: () => unawaited(
                  actions.setStrictMockMode(enabled: !settings.strictMockMode),
                ),
              ),
              SettingsValueRow(
                title: 'Daily reminder',
                value: notificationsDenied
                    ? 'Notifications are off'
                    : settings.dailyReminderTime?.storageValue ?? 'Off',
                onTap: notificationsDenied
                    ? () => unawaited(
                          ref
                              .read(notificationServiceProvider)
                              .openAppNotificationSettings(),
                        )
                    : () => _push(context, '/settings/reminder'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'What you see',
            children: [
              SettingsValueRow(
                title: 'Remember table order',
                control: SettingsSwitch(value: settings.retainTableOrder),
                onTap: () => unawaited(
                  actions.setRetainTableOrder(
                    enabled: !settings.retainTableOrder,
                  ),
                ),
              ),
              SettingsValueRow(
                title: 'Theme',
                control: ThemeControl(
                  value: theme,
                  onChanged: (next) => unawaited(
                    ref
                        .read(themePreferenceControllerProvider.notifier)
                        .setThemePreference(next),
                  ),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Your account',
            children: [
              SettingsValueRow(
                title: 'Pro',
                value: ref.watch(proRowValueProvider),
                showChevron: true,
                onTap: () => _push(context, '/settings/pro'),
              ),
              SettingsValueRow(
                title: 'Account',
                value: SettingsValueFormats.account(
                  user: currentUser,
                  isAnonymous: isAnonymous,
                ),
                showChevron: true,
                onTap: () => _push(context, '/settings/account'),
              ),
              SettingsValueRow(
                title: 'Backup',
                value: SettingsValueFormats.backup(
                  isAnonymous: isAnonymous,
                  status: syncStatus,
                ),
                showChevron: true,
                onTap: () => _push(context, '/settings/backup'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'About',
            children: [
              SettingsValueRow(
                title: 'Version, privacy, feedback',
                showChevron: true,
                onTap: () => _push(context, '/settings/about'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Push, never go. Every destination sits outside the tab shell and relies
  /// on a back arrow, which only appears when the stack can pop.
  static void _push(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    if (router != null) unawaited(router.push<void>(location));
  }
}
