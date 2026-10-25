import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
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
    return PantasPage(
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
        GroupedSection(
          footer: 'Automatic follows your phone: light by day, dark at night.',
          children: [
            ListRow(
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
        GroupedSection(
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
        GroupedSection(
          footer: 'Keeps how you sorted "See all topics and lessons" for next '
              'time.',
          children: [
            ListRow(
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
