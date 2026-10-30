import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/build_info.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/legal/application/legal_providers.dart';
import 'package:pantas/features/settings/presentation/feedback_intent.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({
    super.key,
    this.debugEnabled = DebugSettingsPage.enabled,
    this.version = '0.1.0',
    this.buildNumber,
    this.opener,
    this.sharedLinksRow,
  });
  final bool debugEnabled;
  final String version;
  final String? buildNumber;
  final LinkOpener? opener;

  /// W4g supplies its account-bound SharedLinksRow here.
  final Widget? sharedLinksRow;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final contact = ref.watch(legalContactProvider);
    void push(String path) {
      final router = GoRouter.maybeOf(context);
      if (router != null) unawaited(router.push<void>(path));
    }

    return SettingsPanePage(
      section: 'About',
      title: context.wideWeb ? 'About' : '',
      backLabel: 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        if (context.wideWeb)
          WebCard(
            radius: 16,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.webTokens.colors.accentFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'P',
                      style: context.webTokens.style(
                        26,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pantas',
                        style: context.webTokens.style(
                          18,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Version $version (${buildNumber ?? kBuildNumber})',
                        style: context.webTokens.sm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Center(
            child: Column(
              children: [
                Text('Pantas', style: context.type.pageTitle),
                const SizedBox(height: 8),
                Text(
                  'Version $version (build ${buildNumber ?? kBuildNumber})',
                  style: context.type.footnote,
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        SettingsSection(
          header: 'Legal',
          children: [
            SettingsRow(
              title: 'Privacy policy',
              divider: true,
              onTap: () => push('/legal/privacy'),
            ),
            SettingsRow(
              title: 'Terms of service',
              onTap: () => push('/legal/terms'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          header: 'Your data',
          footer: 'Help improve the app shares anonymous usage data. Crash '
              'reports are always sent. Contacting the officer opens your '
              'mail app.',
          children: [
            SettingsRow(
              title: 'Help improve the app',
              variant: ListRowVariant.switchControl,
              selected: settings.helpImproveApp,
              divider: true,
              onTap: () => unawaited(
                ref
                    .read(settingsActionsProvider)
                    .setHelpImproveApp(enabled: !settings.helpImproveApp),
              ),
            ),
            if (!context.wideWeb && sharedLinksRow != null) sharedLinksRow!,
            SettingsRow(
              title: 'Contact our data protection officer',
              onTap: () => unawaited(
                openDpoMail(
                  contact.dpoEmail,
                  open: opener ?? launchUrl,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SelectableText(
                contact.dpoEmail,
                style: context.type.footnote,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          header: 'Get in touch',
          children: [
            SettingsRow(
              title: 'Send feedback',
              value: context.wideWeb ? 'Facebook group ↗' : 'Facebook group',
              variant: context.wideWeb
                  ? ListRowVariant.value
                  : ListRowVariant.navigation,
              onTap: () => unawaited(
                openCommunityGroup(
                  contact.communityGroupUrl,
                  open: opener ?? launchUrl,
                ),
              ),
            ),
          ],
        ),
        if (debugEnabled) ...[
          const SizedBox(height: 24),
          SettingsSection(
            header: 'Debug',
            children: [
              SettingsRow(
                title: 'Debug',
                onTap: () => push('/settings/_debug'),
              ),
              SettingsRow(
                title: 'Component gallery',
                onTap: () => push('/settings/_gallery'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
