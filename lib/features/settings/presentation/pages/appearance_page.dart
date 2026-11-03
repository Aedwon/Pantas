import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
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
                    Text(
                      'A',
                      // ST_LargeText: 31 px row, 67 px card.
                      style: t.style(24).copyWith(
                            height: context.wideWeb ? 31 / 24 : null,
                          ),
                    ),
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
      hero: true,
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        // ST_Appearance: one card holds the two phone previews and the
        // Automatic switch.
        SettingsSection(
          footer: 'Automatic follows your phone: light by day, dark at night.',
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.colors.separator,
                    width: .5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PhoneTile(
                    value: ThemePreference.light,
                    label: 'Light',
                    selected: preference == ThemePreference.light,
                    onTap: () => setTheme(ThemePreference.light),
                  ),
                  const SizedBox(width: 56),
                  _PhoneTile(
                    value: ThemePreference.dark,
                    label: 'Dark',
                    selected: preference == ThemePreference.dark,
                    onTap: () => setTheme(ThemePreference.dark),
                  ),
                ],
              ),
            ),
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
        const SizedBox(height: 22),
        SettingsSection(
          header: 'Text size',
          footer: 'Lessons and questions use this size.',
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'A',
                    style: context.type.subhead.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: context.colors.accentFill,
                        inactiveTrackColor: context.colors.fill,
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
                  const SizedBox(width: 14),
                  Text(
                    'A',
                    style: context.type.body.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
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
        child: PressScale(
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
      ),
    );
  }
}

/// ST_Appearance on the phone: a 74 by 140 preview, the label and a 22 px
/// radio below it.
class _PhoneTile extends StatelessWidget {
  const _PhoneTile({
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final ThemePreference value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = value == ThemePreference.dark;
    Widget bar(
      double height,
      Color color, {
      double? width,
      double radius = 3,
    }) =>
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
    final soft = dark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: PressScale(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 140,
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 14),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF151515) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE3E3E8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: bar(
                        9,
                        dark
                            ? const Color(0xFF3D3D3D)
                            : const Color(0xFFD1D1D6),
                        width: 40,
                      ),
                    ),
                    const SizedBox(height: 7),
                    bar(34, soft, radius: 6),
                    const SizedBox(height: 7),
                    bar(6, soft),
                    const SizedBox(height: 7),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: .7,
                        child: bar(6, soft),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(label, style: context.type.body.copyWith(fontSize: 15)),
              const SizedBox(height: 8),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? context.colors.accentFill : null,
                  border: selected
                      ? null
                      : Border.all(color: const Color(0xFFC7C7CC), width: 1.5),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
