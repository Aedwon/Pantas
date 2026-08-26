import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/components/settings_group.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/components/settings_value_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/legal/application/legal_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';
import 'package:pantas/features/settings/presentation/feedback_intent.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

// The flag itself lives in one place, and the release guard enforces that.
// Reading `fromEnvironment` here would put a second definition in the tree,
// and this one lacked the `kDebugMode` half, so a release build with the flag
// set would have shown the debug row.
class AboutPage extends ConsumerWidget {
  const AboutPage({
    super.key,
    this.debugEnabled = DebugSettingsPage.enabled,
    this.version = '0.1.0',
    this.buildNumber = '1',
    this.opener,
  });

  final bool debugEnabled;
  final String version;
  final String buildNumber;

  /// Overridden in tests. Null uses the platform's own launcher.
  final LinkOpener? opener;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final actions = ref.read(settingsActionsProvider);
    // One definition of the addresses, read here rather than passed down,
    // so a page and a router cannot drift apart on what they say.
    final contact = ref.watch(legalContactProvider);

    return PageScaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SettingsBar(title: 'About', backLabel: 'Settings'),
          const SizedBox(height: 16),
          Text('Pantas', style: styles.displaySmall),
          const SizedBox(height: 4),
          Text(
            'Version $version (build $buildNumber)',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 24),
          SettingsGroup(
            title: 'Legal',
            isFirst: true,
            children: [
              SettingsValueRow(
                title: 'Privacy policy',
                showChevron: true,
                onTap: () => _push(context, '/legal/privacy'),
              ),
              SettingsValueRow(
                title: 'Terms of service',
                showChevron: true,
                onTap: () => _push(context, '/legal/terms'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Your data',
            children: [
              SettingsValueRow(
                title: 'Help improve the app',
                control: SettingsSwitch(value: settings.helpImproveApp),
                onTap: () => unawaited(
                  actions.setHelpImproveApp(
                    enabled: !settings.helpImproveApp,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'Shares anonymous usage data and crash reports.',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
              ),
              SettingsValueRow(
                title: 'Contact our DPO',
                value: contact.dpoEmail,
                onTap: () => unawaited(
                  openDpoMail(
                    contact.dpoEmail,
                    open: opener ?? launchUrl,
                  ),
                ),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Get in touch',
            children: [
              // The row names where it goes. Sending a student out of the
              // app without saying where is worse than not offering it.
              SettingsValueRow(
                title: 'Send feedback',
                value: 'Facebook group',
                onTap: () => unawaited(
                  openCommunityGroup(
                    contact.communityGroupUrl,
                    open: opener ?? launchUrl,
                  ),
                ),
              ),
            ],
          ),
          if (debugEnabled)
            SettingsGroup(
              title: 'Debug',
              children: [
                SettingsValueRow(
                  title: 'Debug menu',
                  showChevron: true,
                  onTap: () => _push(context, '/settings/_debug'),
                ),
              ],
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static void _push(BuildContext context, String location) {
    final router = GoRouter.maybeOf(context);
    if (router != null) unawaited(router.push<void>(location));
  }
}
