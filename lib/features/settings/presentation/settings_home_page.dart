import 'dart:async';

import 'package:cse_cet_reviewer/core/auth/auth_user.dart';
import 'package:cse_cet_reviewer/core/auth/providers.dart';
import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/sync/providers.dart';
import 'package:cse_cet_reviewer/core/sync/sync_status.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/ios_switch.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/settings_row.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/settings_section.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/widgets/theme_segmented_control.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({
    this.subscriptionSubtitle = 'Free · Try Pro',
    super.key,
  });

  final String subscriptionSubtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSettings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final theme = ref.watch(themePreferenceProvider).valueOrNull ??
        ThemePreference.system;
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isAnonymous = ref.watch(isAnonymousProvider).valueOrNull ?? false;
    final syncStatus = ref.watch(syncStatusProvider).valueOrNull;
    final notificationPermission =
        ref.watch(notificationPermissionStatusProvider).valueOrNull;
    final notificationsDenied =
        notificationPermission == NotificationPermission.denied;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SettingsSection(
            title: 'Preferences',
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Expanded(child: Text('Theme')),
                    ThemeSegmentedControl(
                      value: theme,
                      onChanged: (value) => ref
                          .read(themePreferenceControllerProvider.notifier)
                          .setThemePreference(value),
                    ),
                  ],
                ),
              ),
              SettingsRow(
                title: 'Daily reminder',
                subtitle: notificationsDenied
                    ? 'Notifications are off - tap to enable'
                    : userSettings.dailyReminderTime?.storageValue ?? 'Not set',
                onTap: notificationsDenied
                    ? () => ref
                        .read(notificationServiceProvider)
                        .openAppNotificationSettings()
                    : () {},
              ),
              SettingsRow(
                title: 'Exam date',
                subtitle: _formatDate(userSettings.examDate) ??
                    'Not set - tap to add',
                onTap: () {},
              ),
              SettingsRow(
                title: 'Strict mock mode',
                subtitle: 'Removes pause during mock exams',
                trailing: IosSettingsSwitch(
                  value: userSettings.strictMockMode,
                  onChanged: (value) => ref
                      .read(settingsActionsProvider)
                      .setStrictMockMode(enabled: value),
                ),
                onTap: () => ref
                    .read(settingsActionsProvider)
                    .setStrictMockMode(enabled: !userSettings.strictMockMode),
              ),
              SettingsRow(
                title: 'Help improve the app',
                subtitle: 'Share anonymous usage data',
                trailing: IosSettingsSwitch(
                  value: userSettings.helpImproveApp,
                  onChanged: (value) => ref
                      .read(settingsActionsProvider)
                      .setHelpImproveApp(enabled: value),
                ),
                onTap: () => ref
                    .read(settingsActionsProvider)
                    .setHelpImproveApp(enabled: !userSettings.helpImproveApp),
              ),
            ],
          ),
          SettingsSection(
            title: 'Account',
            children: [
              SettingsRow(
                title: 'Account',
                subtitle: _accountSubtitle(
                  user: currentUser,
                  isAnonymous: isAnonymous,
                ),
                onTap: () => _go(context, '/settings/account'),
              ),
              SettingsRow(
                title: 'Subscription',
                subtitle: subscriptionSubtitle,
                onTap: () => _go(context, '/settings/subscription'),
              ),
              SettingsRow(
                title: 'Backup',
                subtitle: _backupSubtitle(
                  isAnonymous: isAnonymous,
                  status: syncStatus,
                ),
                onTap: () => _go(context, '/settings/backup'),
              ),
            ],
          ),
          SettingsSection(
            title: 'About',
            children: [
              SettingsRow(
                title: 'App info',
                subtitle: 'Version 0.1.0 - Legal - Contact DPO',
                onTap: () => _go(context, '/settings/about'),
              ),
              SettingsRow(
                title: 'Send feedback',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _go(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    // Push, never go: these destinations sit outside the tab shell and rely
    // on the AppBar's implicit back arrow, which only appears when the
    // stack can pop.
    if (router != null) unawaited(router.push<void>(location));
  }

  static String _accountSubtitle({
    required AuthUser? user,
    required bool isAnonymous,
  }) {
    if (user != null) return user.email;
    if (isAnonymous) return 'Signed in anonymously';
    return 'Not signed in';
  }

  static String _backupSubtitle({
    required bool isAnonymous,
    required SyncStatus? status,
  }) {
    if (isAnonymous) return 'Sign in to back up your progress';
    return 'Back up progress';
  }

  static String? _formatDate(ExamDate? date) {
    if (date == null) return null;
    if (date.precision == ExamDatePrecision.month) {
      const monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${monthNames[date.month - 1]} ${date.year}';
    }
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day!.day.toString().padLeft(2, '0')}';
  }
}
