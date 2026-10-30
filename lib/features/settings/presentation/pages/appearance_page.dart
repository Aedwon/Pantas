import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          child: InkWell(
            onTap: () => setTheme(value),
            child: Column(
              children: [
                Container(
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
                const SizedBox(height: 12),
                Text(label, style: context.type.body),
                Semantics(
                  checked: preference == value,
                  inMutuallyExclusiveGroup: true,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: preference == value
                            ? context.colors.accent
                            : context.colors.controlOutline,
                        width: 1.5,
                      ),
                      color: preference == value
                          ? context.colors.accentFill
                          : null,
                    ),
                    child: preference == value
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: context.colors.onAccent,
                          )
                        : null,
                  ),
                ),
              ],
            ),
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
                      Semantics(
                        checked: preference == value,
                        inMutuallyExclusiveGroup: true,
                        child: TextButton(
                          onPressed: () => setTheme(value),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
                                  border: Border.all(
                                    color: preference == value
                                        ? t.colors.accent
                                        : t.colors.separator,
                                    width: preference == value ? 3 : 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: preference == value
                                          ? t.colors.accentFill
                                          : null,
                                      border: Border.all(
                                        color: preference == value
                                            ? t.colors.accentFill
                                            : t.strongDivider,
                                      ),
                                    ),
                                    child: preference == value
                                        ? const Icon(
                                            Icons.check,
                                            size: 13,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    switch (value) {
                                      ThemePreference.light => 'Light',
                                      ThemePreference.dark => 'Dark',
                                      ThemePreference.system => 'Automatic',
                                    },
                                    style: t.style(15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Text('A', style: t.style(14)),
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
