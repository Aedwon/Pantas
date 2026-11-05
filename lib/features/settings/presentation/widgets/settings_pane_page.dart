import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/own/own_icons.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pane_transition.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
    this.hero = false,
    this.noHeading = false,
    this.compactTitle = false,
    this.titleLineHeight = 1.12,
    this.titleGap = 22,
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

  /// Phone only: draws the board's icon card (Practice, Appearance, Your exam)
  /// in place of the large title.
  final bool hero;

  /// Phone only: no large title at all. The page draws its own header.
  final bool noHeading;

  /// Phone only: the 28 px page title of the Settings sub-pages (Name,
  /// What's included, Privacy Policy).
  final bool compactTitle;
  final double titleLineHeight;
  final double titleGap;

  @override
  Widget build(BuildContext context) {
    if (!context.wideWeb) {
      return PantasPage(
        title: title,
        backLabel: backLabel,
        onBack: onBack,
        bottom: bottom,
        bottomInset: bottomInset,
        // Settings boards put the back row 4 px from the edge.
        backPadding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
        titleStyle: compactTitle
            ? context.type.pageTitleCompact.copyWith(height: titleLineHeight)
            : null,
        titlePadding: compactTitle
            ? EdgeInsets.fromLTRB(4, 6, 4, titleGap)
            : const EdgeInsets.fromLTRB(4, 0, 4, 20),
        hero: noHeading
            ? const SizedBox.shrink()
            : hero
                ? _SettingsHero(
                    section: section,
                    title: title,
                    subtitle: description ?? '',
                  )
                : null,
        children: children,
      );
    }
    final t = context.webTokens;
    final headingIcon = icon == null
        ? title == 'Name'
            ? Icon(PantasIcons.profile, size: 22, color: t.colors.accent)
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
                // The list row's size and blue, like the other headers.
                'Practice' => Icon(
                    PantasIcons.practice,
                    size: 22,
                    color: const Color(0xFF2F6FEB),
                  ),
                'Appearance' => _grayGlyph(t, PantasIcons.appearance),
                'About' => _grayGlyph(t, PantasIcons.about),
                _ => null,
              }
        : Icon(icon, size: 32, color: t.colors.accent);
    final nested = backLabel != null && backLabel != 'Settings';
    // The page paints its own background in pieces rather than on the Material,
    // because the detail pane must be able to show the pane behind it while it
    // opens (see [PaneDetailMotion]).
    final background = t.colors.background;
    return Material(
      type: MaterialType.transparency,
      child: CallbackShortcuts(
        bindings: {
          if (nested && onBack != null)
            const SingleActivator(LogicalKeyboardKey.escape): onBack!,
        },
        // A page opened from a row starts with nothing focused, and a key only
        // reaches the shortcut from a node inside it. Without this, Esc did
        // nothing on a page the pane's Esc hint is printed on.
        child: Focus(
          autofocus: nested && onBack != null,
          skipTraversal: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('Settings', style: t.h1),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ColoredBox(
                        color: background,
                        child: SizedBox(
                          width: _listWidth(constraints.maxWidth),
                          height: constraints.maxHeight,
                          child: _SettingsListScroll(selected: section),
                        ),
                      ),
                      ColoredBox(
                        color: background,
                        child:
                            SizedBox(width: 28, height: constraints.maxHeight),
                      ),
                      Expanded(
                        child: PaneDetailMotion(
                          background: background,
                          child: SingleChildScrollView(
                            key: const ValueKey('settings-detail'),
                            padding: EdgeInsets.only(
                              bottom: 24 + context.webPageBottomInset,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (nested) ...[
                                  Row(
                                    children: [
                                      WebBackLink(
                                        label: backLabel!,
                                        fontSize: 15,
                                        tightIcon: true,
                                        onPressed: onBack ?? () {},
                                      ),
                                      const SizedBox(width: 8),
                                      const WebKeyHint('Esc'),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 4, 4, 0),
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The board's list pane is `flex: 1 1 300px; max-width: 360px` beside a
/// detail pane of `flex: 999 1 460px`, 28 px apart: 300 px plus a thousandth
/// of what is left over. Below that it keeps a third of the width.
double _listWidth(double available) {
  final spare = available - 28 - 300 - 460;
  return spare >= 0 ? math.min(360, 300 + spare / 1000) : available * .33;
}

/// A 22 px outline glyph in the board's gray (`#6E6E73`).
Widget _grayGlyph(WebTokens t, Widget glyph) => IconTheme(
      data: IconThemeData(color: t.colors.secondaryLabel, size: 22),
      child: SizedBox.square(dimension: 22, child: glyph),
    );

/// Where the list was last scrolled to. Every Settings row is its own page,
/// and a new page would start the list back at the top. Opening the next row
/// would then make the list jump, so the offset is carried across pages.
final settingsListOffsetProvider = StateProvider<double>((ref) => 0);

/// The row that was selected when another was tapped. The page that opens
/// rebuilds the list, so it starts from this row and fades to its own (item 17,
/// demo 4). Read once as the new list is built, then cleared.
final settingsListFromProvider = StateProvider<String?>((ref) => null);

class _SettingsListScroll extends ConsumerStatefulWidget {
  const _SettingsListScroll({required this.selected});
  final String selected;

  @override
  ConsumerState<_SettingsListScroll> createState() =>
      _SettingsListScrollState();
}

class _SettingsListScrollState extends ConsumerState<_SettingsListScroll> {
  late final ScrollController _controller;
  late final String? _from = ref.read(settingsListFromProvider);

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(
      initialScrollOffset: ref.read(settingsListOffsetProvider),
    )..addListener(_remember);
    if (_from != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(settingsListFromProvider.notifier).state = null;
      });
    }
  }

  void _remember() {
    if (_controller.hasClients) {
      ref.read(settingsListOffsetProvider.notifier).state = _controller.offset;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: _controller,
        padding: EdgeInsets.only(bottom: context.webPageBottomInset),
        child: SettingsNavigation(selected: widget.selected, from: _from),
      );
}

class SettingsNavigation extends ConsumerWidget {
  const SettingsNavigation({required this.selected, this.from, super.key});
  final String selected;

  /// The row that was selected before this list was built, if any. Its tint
  /// starts full and fades out while the new row's fades in.
  final String? from;

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
      if (router == null) return;
      ref.read(settingsListFromProvider.notifier).state = selected;
      unawaited(router.push<void>(path));
    }

    Widget row(String label, String path, Widget glyph, {String? value}) =>
        WebRow(
          title: label,
          // The label keeps one weight, so the text does not jump while the
          // tint fades (item 17, demo 4).
          titleStyle: t.style(16),
          horizontalPadding: 16,
          compact: true,
          leadingGap: 12,
          selected: selected == label,
          enterFromSelected: from == null ? null : from == label,
          value: value,
          valueStyle: t.sub,
          selectedValueColor: t.colors.accent,
          leading: glyph,
          onPressed: () => open(path),
          divider: label != 'Appearance' &&
              label != 'Pantas Pro' &&
              label != 'About',
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
            verticalPadding: 14,
            leadingGap: 12,
            selected: selected == 'Account',
            enterFromSelected: from == null ? null : from == 'Account',
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
                Icon(
                  PantasIcons.practice,
                  size: 22,
                  color: const Color(0xFF2F6FEB),
                ),
                value: length < 0 ? 'All questions' : '$length questions',
              ),
              row(
                'Appearance',
                '/settings/appearance',
                _grayGlyph(t, PantasIcons.appearance),
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
          child:
              row('About', '/settings/about', _grayGlyph(t, PantasIcons.about)),
        ),
      ],
    );
  }
}

/// ST_Practice, ST_Appearance and ST_Exam: a white 18 px card with a 42 px
/// colored icon, a 24 px bold title and a 15 px gray subtitle.
class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.section,
    required this.title,
    required this.subtitle,
  });
  final String section;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = switch (section) {
      'Practice' =>
        Icon(PantasIcons.practice, size: 42, color: const Color(0xFF2F6FEB)),
      'Appearance' => IconTheme(
          data: const IconThemeData(color: Color(0xFF5F3DC4), size: 42),
          child: context.wideWeb
              ? PantasIcons.appearance
              : const OwnIcon(OwnIconKind.appearance, fill: Color(0xFF1D1D1F)),
        ),
      _ => Icon(PantasIcons.exam, size: 42, color: c.accent),
    };
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(dimension: 52, child: Center(child: icon)),
            const SizedBox(height: 10),
            Semantics(
              header: true,
              child: Text(
                title,
                style: context.type.sectionHero.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  letterSpacing: -0.288,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.type.body.copyWith(
                fontSize: 15,
                height: 1.4,
                letterSpacing: 0,
                color: c.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
