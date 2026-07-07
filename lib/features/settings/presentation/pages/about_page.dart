import 'dart:async';

import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_value_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    required this.version,
    required this.buildNumber,
    required this.dpoEmail,
    required this.physicalAddress,
    super.key,
  });

  final String version;
  final String buildNumber;
  final String dpoEmail;
  final String physicalAddress;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('CSE Reviewer', style: styles.headlineMedium),
          Text(
            'Version $version (build $buildNumber)',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Legal'),
          SettingsValueRow(
            title: 'Privacy Policy',
            onTap: () => _go(context, '/legal/privacy'),
          ),
          SettingsValueRow(
            title: 'Terms of Service',
            onTap: () => _go(context, '/legal/terms'),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Data & privacy'),
          SettingsValueRow(
            title: 'Contact our DPO',
            value: dpoEmail,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          Text(
            'For data export, correction, or other privacy requests, email '
            'our Data Protection Officer at $dpoEmail. '
            'Controller address: $physicalAddress.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 24),
          Text(
            '© ${DateTime.now().year} Pantas. All rights reserved.\n'
            'All lessons, illustrations, and questions in this app are '
            'proprietary content and may not be reproduced or '
            'redistributed without permission.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
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
}
