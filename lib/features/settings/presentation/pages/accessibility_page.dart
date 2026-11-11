import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';

/// Settings > Accessibility. One setting for now: the Keyboard Shortcuts
/// switch that turns off every single-letter shortcut (WCAG 2.1.4). The list
/// shows this page on wide screens only; a phone has no letter shortcuts.
class AccessibilityPage extends ConsumerWidget {
  const AccessibilityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(letterShortcutsProvider);
    return SettingsPanePage(
      section: 'Accessibility',
      title: 'Accessibility',
      description: 'How Pantas works with your keyboard.',
      backLabel: 'Settings',
      onBack: () => leavePage(context, fallback: '/settings'),
      children: [
        SettingsSection(
          children: [
            SettingsRow(
              title: 'Keyboard Shortcuts',
              subtitle: 'Letter keys pick and flag answers in a quiz.',
              variant: ListRowVariant.switchControl,
              selected: enabled,
              onTap: () => unawaited(
                ref
                    .read(letterShortcutsProvider.notifier)
                    .setEnabled(enabled: !enabled),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
