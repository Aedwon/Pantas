import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/beta_pro_row.dart';
import 'package:pantas/features/settings/settings.dart';

/// Settings destinations share the list pane. Providers and route state stay
/// owned by the destination, including when the browser opens a deep link.
class SettingsPanePage extends StatelessWidget {
  const SettingsPanePage({
    required this.title,
    required this.children,
    required this.section,
    this.backLabel,
    this.onBack,
    this.bottom,
    this.bottomInset = 24,
    super.key,
    this.description,
    this.icon,
  });
  final String title;
  final List<Widget> children;
  final String? backLabel;
  final VoidCallback? onBack;
  final Widget? bottom;
  final double bottomInset;
  final String section;
  final String? description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (!context.wideWeb) {
      return PantasPage(
        title: title,
        backLabel: backLabel,
        onBack: onBack,
        bottom: bottom,
        bottomInset: bottomInset,
        children: children,
      );
    }
    final t = context.webTokens;
    final headingIcon = icon == null
        ? title == 'Name'
            ? Icon(PantasIcons.edit, size: 22, color: t.colors.accent)
            : switch (section) {
                'Account' =>
                  Icon(PantasIcons.profile, size: 22, color: t.colors.accent),
                'Pantas Pro' => Icon(
                    PantasIcons.proSettings,
                    size: 22,
                    color: t.colors.accent,
                  ),
                'Your exam' =>
                  Icon(PantasIcons.exam, size: 22, color: t.colors.accent),
                'Practice' => Icon(
                    PantasIcons.practice,
                    size: 40,
                    color: const Color(0xFF2F6FEB),
                  ),
                'Appearance' => PantasIcons.appearance,
                'About' => PantasIcons.about,
                _ => null,
              }
        : Icon(icon, size: 32, color: t.colors.accent);
    final nested = backLabel != null && backLabel != 'Settings';
    return Material(
      color: t.colors.background,
      child: CallbackShortcuts(
        bindings: {
          if (nested && onBack != null)
            const SingleActivator(LogicalKeyboardKey.escape): onBack!,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Settings', style: t.h1),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth >= 1000
                          ? 360
                          : constraints.maxWidth * .33,
                      child: SingleChildScrollView(
                        child: SettingsNavigation(selected: section),
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: SingleChildScrollView(
                        key: const ValueKey('settings-detail'),
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (nested) ...[
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: onBack,
                                    child: Text('‹ $backLabel'),
                                  ),
                                  const WebKeyHint('Esc'),
                                ],
                              ),
                              const SizedBox(height: 14),
                            ],
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                              child: Row(
                                children: [
                                  if (headingIcon != null) ...[
                                    headingIcon,
                                    const SizedBox(width: 14),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: t.h2),
                                        if (description != null)
                                          Text(description!, style: t.sub),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ...children,
                            if (bottom != null) ...[
                              const SizedBox(height: 24),
                              bottom!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsNavigation extends ConsumerWidget {
  const SettingsNavigation({required this.selected, super.key});
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.webTokens;
    final settings =
        ref.watch(userSettingsProvider).valueOrNull ?? UserSettings.defaults();
    final user = ref.watch(currentUserProvider).valueOrNull;
    final theme = ref.watch(themePreferenceProvider).valueOrNull ??
        ThemePreference.system;
    final length = ref.watch(settingsSessionLengthProvider).valueOrNull ?? 10;
    void open(String path) {
      final router = GoRouter.maybeOf(context);
      if (router != null) unawaited(router.push<void>(path));
    }

    Widget row(String label, String path, Widget glyph, {String? value}) =>
        WebRow(
          title: label,
          titleStyle: t.style(
            16,
            weight: selected == label ? FontWeight.w600 : FontWeight.w400,
          ),
          horizontalPadding: 16,
          compact: true,
          selected: selected == label,
          value: value,
          leading: glyph,
          onPressed: () => open(path),
          divider: label != 'Appearance' && label != 'Pantas Pro',
        );
    return Column(
      key: const ValueKey('settings-navigation'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebCard(
          radius: 16,
          child: WebRow(
            title: settings.name?.trim().isNotEmpty ?? false
                ? settings.name!
                : 'Add your name',
            subtitle: user?.email ?? 'Not signed in',
            titleStyle: t.style(17, weight: FontWeight.w600),
            horizontalPadding: 16,
            selected: selected == 'Account',
            leading: SizedBox.square(
              dimension: 44,
              child: FittedBox(
                child: Avatar(
                  name: settings.name ?? '',
                  photo: user?.photoUrl == null
                      ? null
                      : NetworkImage(user!.photoUrl!),
                ),
              ),
            ),
            trailing: Icon(PantasIcons.next, size: 16, color: t.colors.chevron),
            divider: false,
            onPressed: () => open('/settings/account'),
          ),
        ),
        const SizedBox(height: 18),
        WebCard(
          radius: 16,
          child: Column(
            children: [
              row(
                'Pantas Pro',
                '/settings/pro',
                Icon(PantasIcons.proSettings, size: 22, color: t.colors.accent),
                value: ref.watch(proRowValueProvider),
              ),
              const BetaProRow(),
            ],
          ),
        ),
        const BetaProNote(),
        const SizedBox(height: 18),
        WebCard(
          radius: 16,
          child: Column(
            children: [
              row(
                'Your exam',
                '/settings/exam',
                Icon(PantasIcons.exam, size: 22, color: t.colors.accent),
                value: ref.watch(activeExamShortNameProvider),
              ),
              row(
                'Practice',
                '/settings/practice',
                Icon(PantasIcons.practice, size: 22, color: t.colors.accent),
                value: length < 0 ? 'All questions' : '$length questions',
              ),
              row(
                'Appearance',
                '/settings/appearance',
                PantasIcons.appearance,
                value: switch (theme) {
                  ThemePreference.light => 'Light',
                  ThemePreference.dark => 'Dark',
                  ThemePreference.system => 'Automatic',
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        WebCard(
          radius: 16,
          child: row('About', '/settings/about', PantasIcons.about),
        ),
      ],
    );
  }
}
