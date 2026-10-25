import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/legal/application/legal_providers.dart';
import 'package:pantas/features/settings/presentation/feedback_intent.dart';
import 'package:pantas/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({
    super.key,
    this.debugEnabled = DebugSettingsPage.enabled,
    this.version = '0.1.0',
    this.buildNumber = '1',
    this.opener,
    this.sharedLinksRow,
  });
  final bool debugEnabled;
  final String version;
  final String buildNumber;
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

    return PantasPage(
      title: '',
      backLabel: 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        Center(
          child: Column(
            children: [
              Text('Pantas', style: context.type.pageTitle),
              const SizedBox(height: 8),
              Text(
                'Version $version (build $buildNumber)',
                style: context.type.footnote,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'Legal',
          children: [
            ListRow(
              title: 'Privacy policy',
              divider: true,
              onTap: () => push('/legal/privacy'),
            ),
            ListRow(
              title: 'Terms of service',
              onTap: () => push('/legal/terms'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'Your data',
          footer: 'Help improve the app shares anonymous usage data. Crash '
              'reports are always sent. Contacting the officer opens your '
              'mail app.',
          children: [
            ListRow(
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
            if (sharedLinksRow != null) sharedLinksRow!,
            ListRow(
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
        GroupedSection(
          header: 'Get in touch',
          children: [
            ListRow(
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
        if (debugEnabled) ...[
          const SizedBox(height: 24),
          GroupedSection(
            header: 'Debug',
            children: [
              ListRow(title: 'Debug', onTap: () => push('/settings/_debug')),
              ListRow(
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
