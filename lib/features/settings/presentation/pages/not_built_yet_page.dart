import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/components/settings_bar.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Temporary destination for a row whose page lands in a later plan.
///
/// Delete this file when its last caller goes, at the end of Plan 06.
class NotBuiltYetPage extends StatelessWidget {
  const NotBuiltYetPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsBar(title: title),
          const SizedBox(height: 24),
          Text(
            'This screen is not built yet.',
            style: context.textStyles.bodyMedium.copyWith(
              color: context.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
