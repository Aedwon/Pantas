import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/pantas_slider.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/presentation/widgets/text_size_sample.dart';
import 'package:pantas/features/settings/settings.dart';

// The board's wide theme tile: a 128 px preview with 6 px on each side.
const double _themeTileWidth = 140;

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
      return SettingsPanePage(
        section: 'Appearance',
        title: 'Appearance',
        description: 'How Pantas looks.',
        children: [
          SettingsSection(
            footer: "Automatic follows your computer's light or dark setting.",
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s16,
                  vertical: PantasSpace.s18,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: PantasSpace.s24,
                  runSpacing: PantasSpace.s18,
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
          const SizedBox(height: PantasSpace.s24),
          SettingsSection(
            header: 'Lesson Text Size',
            footer: 'Lessons and questions use this size. '
                '$commandKeyLabel + and $commandKeyLabel − still zoom the '
                'whole page.',
            children: _textSizeChildren(
              scale: scale,
              wide: true,
              onChanged: (value) => unawaited(
                ref.read(lessonTextScaleProvider.notifier).setScale(value),
              ),
            ),
          ),
          const SizedBox(height: PantasSpace.s24),
          SettingsSection(
            children: [
              SettingsRow(
                title: 'Remember table order',
                subtitle: 'Keeps how you sorted "See all topics and lessons" '
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
    // While Automatic is on, the tile of the theme in effect shows selected,
    // as the OS does; otherwise the chosen one does.
    final inEffect = preference == ThemePreference.system
        ? (MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? ThemePreference.dark
            : ThemePreference.light)
        : preference;
    return SettingsPanePage(
      section: 'Appearance',
      description: 'How Pantas looks.',
      title: 'Appearance',
      backLabel: 'Settings',
      hero: true,
      onBack: () => leavePage(context, fallback: '/settings'),
      children: [
        // ST_Appearance: one card holds the two phone previews and the
        // Automatic switch.
        SettingsSection(
          footer: "Automatic follows your phone's light or dark setting.",
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s18,
                PantasSpace.s16,
                PantasSpace.s16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: context.colors.separator,
                    width: PantasBorder.hairline,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PhoneTile(
                    value: ThemePreference.light,
                    label: 'Light',
                    selected: inEffect == ThemePreference.light,
                    onTap: () => setTheme(ThemePreference.light),
                  ),
                  const SizedBox(width: PantasSpace.s56),
                  _PhoneTile(
                    value: ThemePreference.dark,
                    label: 'Dark',
                    selected: inEffect == ThemePreference.dark,
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
        const SizedBox(height: PantasSpace.s20),
        SettingsSection(
          header: 'Lesson Text Size',
          footer: 'Lessons and questions use this size.',
          children: _textSizeChildren(
            scale: scale,
            wide: false,
            onChanged: (value) => unawaited(
              ref.read(lessonTextScaleProvider.notifier).setScale(value),
            ),
          ),
        ),
        const SizedBox(height: PantasSpace.s20),
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
              width: _themeTileWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 128,
                      height: 84,
                      decoration: BoxDecoration(
                        color: value == ThemePreference.dark
                            ? PantasColors.dark.bgPage
                            : PantasColors.light.bgPage,
                        gradient: value == ThemePreference.system
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  PantasColors.light.bgPage,
                                  PantasColors.light.bgPage,
                                  PantasColors.dark.bgPage,
                                  PantasColors.dark.bgPage,
                                ],
                                stops: const [0, .5, .5, 1],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(PantasRadius.lg),
                        border: selected
                            ? null
                            : Border.all(color: PantasColors.light.divider),
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
                    const SizedBox(height: PantasSpace.s10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: PantasSpace.s8,
                      runSpacing: PantasSpace.s2,
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
                                    color: t.colors.borderControl,
                                    width: PantasBorder.ringStrong,
                                  ),
                          ),
                          child: selected
                              ? Icon(
                                  Icons.check,
                                  size: 11,
                                  color: t.colors.onAccent,
                                )
                              : null,
                        ),
                        Text(
                          label,
                          style: PantasType.webSub
                              .copyWith(color: t.colors.textPrimary),
                        ),
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
    final palette = dark ? PantasColors.dark : PantasColors.light;
    final soft = palette.fill;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s8,
                  vertical: PantasSpace.s14,
                ),
                decoration: BoxDecoration(
                  color: dark
                      ? PantasColors.dark.bgPage
                      : PantasColors.light.surfaceCard,
                  borderRadius: BorderRadius.circular(PantasRadius.lg),
                  border: Border.all(color: PantasColors.light.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: bar(9, palette.dividerStrong, width: 40),
                    ),
                    const SizedBox(height: PantasSpace.s6),
                    bar(34, soft, radius: 6),
                    const SizedBox(height: PantasSpace.s6),
                    bar(6, soft),
                    const SizedBox(height: PantasSpace.s6),
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
              const SizedBox(height: PantasSpace.s8),
              Text(
                label,
                style: PantasType.phoneExplanation
                    .copyWith(color: context.colors.textPrimary),
              ),
              const SizedBox(height: PantasSpace.s8),
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? context.colors.accentFill : null,
                  border: selected
                      ? null
                      : Border.all(
                          color: context.colors.borderControl,
                          width: PantasBorder.ringStrong,
                        ),
                ),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 12,
                        color: context.colors.onAccent,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The lesson text size control: the system Slider, 1.0 to 2.0 times.
class _TextSizeSlider extends StatelessWidget {
  const _TextSizeSlider({required this.scale, required this.onChanged});
  final double scale;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = scale.clamp(1.0, 2.0);
    final shown = value.toStringAsFixed(1);
    return PantasSlider(
      value: value,
      onChanged: onChanged,
      valueText: '$shown\u00d7',
      semanticValue: '$shown times',
    );
  }
}

/// The inside of the Lesson Text Size card (board TS_A): the slider row, a
/// hairline, then the sample on the system inset surface. The wide card pads
/// both 18 by 16; the phone group pads both 16.
List<Widget> _textSizeChildren({
  required double scale,
  required bool wide,
  required ValueChanged<double> onChanged,
}) =>
    [
      Padding(
        padding: wide
            ? const EdgeInsets.symmetric(
                horizontal: PantasSpace.s16,
                vertical: PantasSpace.s18,
              )
            : const EdgeInsets.all(PantasSpace.s16),
        child: _TextSizeSlider(scale: scale, onChanged: onChanged),
      ),
      const _Hairline(),
      Builder(
        builder: (context) => ColoredBox(
          key: const ValueKey('text-size-band'),
          color: context.colors.surfaceInset,
          child: Padding(
            padding: wide
                ? const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s16,
                    vertical: PantasSpace.s18,
                  )
                : const EdgeInsets.all(PantasSpace.s16),
            child: const TextSizeSample(),
          ),
        ),
      ),
    ];

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Divider(
        height: PantasBorder.hairline,
        thickness: PantasBorder.hairline,
        color: context.colors.divider,
      );
}
