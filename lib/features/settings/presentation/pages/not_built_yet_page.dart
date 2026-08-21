import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
          SettingsBar(title: title, backLabel: 'Settings'),
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
