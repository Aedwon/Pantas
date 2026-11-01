import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';

class AppearancePage extends ConsumerWidget {
  const AppearancePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider).valueOrNull ??
        ThemePreference.system;
    final scale = ref.watch(lessonTextScaleProvider);
    final retain = ref.watch(retainTableOrderProvider).valueOrNull ?? true;
    void setTheme(ThemePreference value) => unawaited(
          ref
              .read(themePreferenceControllerProvider.notifier)
              .setThemePreference(value),
        );
    Widget preview(ThemePreference value, String label) => Expanded(
          child: RadioRow(
            title: label,
            selected: preference == value,
            onTap: () => setTheme(value),
            preview: Container(
              height: 128,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value == ThemePreference.dark
                    ? const Color(0xFF000000)
                    : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: preference == value
                      ? context.colors.accent
                      : context.colors.separator,
                  width: preference == value ? 2 : .5,
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      height: 22,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: value == ThemePreference.dark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        );
    if (context.wideWeb) {
      final t = context.webTokens;
      return SettingsPanePage(
        section: 'Appearance',
        title: 'Appearance',
        description: 'How Pantas looks.',
        children: [
          SettingsSection(
            footer: 'Automatic follows your computer: '
                'light by day, dark at night.',
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 18,
                  children: [
                    for (final value in ThemePreference.values)
                      _ThemeTile(
                        value: value,
                        selected: preference == value,
                        onTap: () => setTheme(value),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            header: 'Text size',
            footer: 'Lessons and questions use this size. '
                'Ctrl + and Ctrl − still zoom the whole page.',
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Text('A', style: t.style(14)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: t.colors.accentFill,
                          inactiveTrackColor: t.colors.separator,
                          thumbColor: Colors.white,
                          overlayColor: Colors.transparent,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 13,
                            elevation: 3,
                          ),
                          overlayShape: SliderComponentShape.noOverlay,
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          min: 1,
                          max: 2,
                          value: scale.clamp(1, 2),
                          onChanged: (value) => unawaited(
                            ref
                                .read(lessonTextScaleProvider.notifier)
                                .setScale(value),
                          ),
                        ),
                      ),
                    ),
                    Text('A', style: t.style(24)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSection(
            children: [
              SettingsRow(
                title: 'Remember table order',
                subtitle: 'Keeps how you sorted “See all topics and lessons” '
                    'for next time.',
                variant: ListRowVariant.switchControl,
                selected: retain,
                onTap: () async {
                  await ref
                      .read(settingsActionsProvider)
                      .setRetainTableOrder(enabled: !retain);
                  ref.invalidate(retainTableOrderProvider);
                },
              ),
            ],
          ),
        ],
      );
    }
    return SettingsPanePage(
      section: 'Appearance',
      description: 'How Pantas looks.',
      title: 'Appearance',
      backLabel: 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        Text(
          'How Pantas looks.',
          style:
              context.type.body.copyWith(color: context.colors.secondaryLabel),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            preview(ThemePreference.light, 'Light'),
            preview(ThemePreference.dark, 'Dark'),
          ],
        ),
        const SizedBox(height: 16),
        SettingsSection(
          footer: 'Automatic follows your phone: light by day, dark at night.',
          children: [
            SettingsRow(
              title: 'Automatic',
              variant: ListRowVariant.switchControl,
              selected: preference == ThemePreference.system,
              onTap: () => setTheme(
                preference == ThemePreference.system
                    ? ThemePreference.light
                    : ThemePreference.system,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          header: 'Text size',
          footer: 'Lessons and questions use this size.',
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('A'),
                ),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 2,
                    value: scale.clamp(1, 2),
                    onChanged: (value) => unawaited(
                      ref
                          .read(lessonTextScaleProvider.notifier)
                          .setScale(value),
                    ),
                  ),
                ),
                Text('A', style: context.type.pageTitle),
                const SizedBox(width: 16),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsSection(
          footer: 'Keeps how you sorted "See all topics and lessons" for next '
              'time.',
          children: [
            SettingsRow(
              title: 'Remember table order',
              variant: ListRowVariant.switchControl,
              selected: retain,
              onTap: () async {
                await ref
                    .read(settingsActionsProvider)
                    .setRetainTableOrder(enabled: !retain);
                ref.invalidate(retainTableOrderProvider);
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// One of the board's three appearance tiles: a 128 by 84 preview, then a 20 px
/// radio and the label. The chosen preview has a 3 px accent ring outside it.
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final ThemePreference value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final label = switch (value) {
      ThemePreference.light => 'Light',
      ThemePreference.dark => 'Dark',
      ThemePreference.system => 'Automatic',
    };
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 128,
                    height: 84,
                    decoration: BoxDecoration(
                      color: value == ThemePreference.dark
                          ? const Color(0xFF151515)
                          : const Color(0xFFF5F5F7),
                      gradient: value == ThemePreference.system
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF5F5F7),
                                Color(0xFFF5F5F7),
                                Color(0xFF151515),
                                Color(0xFF151515),
                              ],
                              stops: [0, .5, .5, 1],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(14),
                      border: selected
                          ? null
                          : Border.all(color: const Color(0xFFE3E3E8)),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: t.colors.accentFill,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? t.colors.accentFill : null,
                          border: selected
                              ? null
                              : Border.all(
                                  color: t.dark
                                      ? t.colors.controlOutline
                                      : const Color(0xFFC7C7CC),
                                  width: 1.5,
                                ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                size: 11,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Text(label, style: t.style(15)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
