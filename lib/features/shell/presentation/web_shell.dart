import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

/// Sidebar families from the board map. Sessions use focus mode.
bool webSidebarRoute(String path) =>
    const [
      '/home',
      '/study',
      '/quiz',
      '/record',
      '/tendencies',
      '/performance',
      '/plan',
      '/quiz/practice',
      '/quiz/mock/setup',
      '/quiz/mock/custom-setup',
    ].contains(path) ||
    path.startsWith('/settings') ||
    path.startsWith('/legal/') ||
    path.startsWith('/plan/') ||
    path.startsWith('/performance/') ||
    RegExp(r'^/quiz/practice/[^/]+$').hasMatch(path);

class WebShellFrame extends StatelessWidget {
  const WebShellFrame({
    required this.child,
    required this.activeIndex,
    required this.person,
    required this.exam,
    required this.plan,
    required this.onNavigate,
    required this.onSearch,
    this.web = kIsWeb,
    super.key,
  });
  final Widget child;
  final int activeIndex;
  final String person;
  final String exam;
  final String plan;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSearch;
  final bool web;
  @override
  Widget build(BuildContext context) {
    if (!isWideWebLayout(width: MediaQuery.sizeOf(context).width, web: web)) {
      return child;
    }
    final tier = webLayoutTier(
      width: MediaQuery.sizeOf(context).width,
      web: web,
    );
    if (tier == WebLayoutTier.tabletLandscape) {
      return WebTabletNavigation(
        activeIndex: activeIndex,
        onNavigate: onNavigate,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(44, 28, 44, 100),
          child: child,
        ),
      );
    }
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): onSearch,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): onSearch,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              WebSidebar(
                activeIndex: activeIndex,
                person: person,
                exam: exam,
                plan: plan,
                onNavigate: onNavigate,
                onSearch: onSearch,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(44, 28, 44, 44),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: child,
                    ),
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

class WebSidebar extends StatelessWidget {
  const WebSidebar({
    required this.activeIndex,
    required this.person,
    required this.exam,
    required this.plan,
    required this.onNavigate,
    required this.onSearch,
    super.key,
  });
  final int activeIndex;
  final String person;
  final String exam;
  final String plan;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSearch;
  static final _tabs = [
    (label: 'Home', glyph: PantasIcons.homeTab),
    (label: 'Study', glyph: PantasIcons.studyTab),
    (label: 'Quiz', glyph: PantasIcons.quizTab),
    (label: 'Settings', glyph: PantasIcons.settingsTab),
  ];
  static const _rowHeight = 40.0;
  static const _rowGap = 4.0;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    return Semantics(
      container: true,
      label: 'Main navigation',
      // Board `.side` at 1440: 230.4 px (its content's own width).
      child: SizedBox(
        width: 230.4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 22, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
                child: Text(
                  'Pantas',
                  style: t.style(
                    22,
                    weight: FontWeight.w700,
                    height: 1.27,
                    spacing: -.44,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: onSearch,
                style: ButtonStyle(
                  animationDuration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 150),
                  visualDensity: VisualDensity.standard,
                  minimumSize: const WidgetStatePropertyAll(Size(0, 38)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.fromLTRB(12, 0, 10, 0),
                  ),
                  backgroundColor: WidgetStatePropertyAll(c.surface),
                  side: WidgetStatePropertyAll(
                    BorderSide(color: c.separator),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      PantasIcons.search,
                      size: 18,
                      color: c.tertiaryLabel,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search lessons',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.style(
                          15,
                          height: 1.2,
                          color: c.tertiaryLabel,
                        ),
                      ),
                    ),
                    const WebKeyHint('Ctrl K'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // The selected row's fill is one marker that glides from row to
              // row. Each row is 40 px tall with 4 px between.
              Stack(
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: IgnorePointer(
                        child: SlidingMarker(
                          key: const ValueKey('sidebar-marker'),
                          axis: Axis.vertical,
                          offsets: [
                            for (var i = 0; i < _tabs.length; i++)
                              i * (_rowHeight + _rowGap),
                          ],
                          lengths: List.filled(_tabs.length, _rowHeight),
                          index: activeIndex,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: t.dark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: .06),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < _tabs.length; i++) ...[
                        if (i > 0) const SizedBox(height: _rowGap),
                        Semantics(
                          selected: activeIndex == i,
                          child: TextButton(
                            onPressed: () => onNavigate(i),
                            style: ButtonStyle(
                              animationDuration:
                                  MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : PantasDurations.quick,
                              visualDensity: VisualDensity.standard,
                              minimumSize: const WidgetStatePropertyAll(
                                Size(0, _rowHeight),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              // The selected fill is the marker behind.
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (s) => activeIndex != i &&
                                        (s.contains(WidgetState.hovered) ||
                                            s.contains(WidgetState.focused))
                                    ? t.dark
                                        ? c.fill
                                        : Colors.black.withValues(
                                            alpha: .045,
                                          )
                                    : Colors.transparent,
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              overlayColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                FadingColor(
                                  color: activeIndex == i
                                      ? c.accent
                                      : c.tertiaryLabel,
                                  builder: (context, color, _) => Icon(
                                    _tabs[i].glyph,
                                    size: 21,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _tabs[i].label,
                                    style: t.style(
                                      15,
                                      height: 1.2,
                                      weight: activeIndex == i
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _SidebarAvatar(person: person),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.style(14, weight: FontWeight.w600),
                          ),
                          Text(
                            '$exam · $plan',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.sm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phone navigation at its approved width on landscape tablets.
class WebTabletNavigation extends StatelessWidget {
  const WebTabletNavigation({
    required this.child,
    required this.activeIndex,
    required this.onNavigate,
    super.key,
  });
  final Widget child;
  final int activeIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: SizedBox(
                  width: 358,
                  child: AppNavBar(
                    currentIndex: activeIndex,
                    onTap: onNavigate,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

/// The sidebar picture (X_Side, ST_Avatars): the first letter capitalized,
/// accents included; an emoji as itself; otherwise a plain gray person.
class _SidebarAvatar extends StatelessWidget {
  const _SidebarAvatar({required this.person});
  final String person;
  static final _letter = RegExp(r'^\p{L}', unicode: true);

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    final initial = person.trim().isEmpty ? '' : person.trim().characters.first;
    final first = initial.isEmpty ? 0 : initial.runes.first;
    final emoji = initial.isNotEmpty &&
        (first >= 0x1F000 ||
            (first >= 0x2600 && first <= 0x27BF) ||
            initial.runes.contains(0xFE0F) ||
            initial.runes.contains(0x20E3));
    final plain = !emoji && !_letter.hasMatch(initial);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: plain ? c.fill : c.accentTint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: plain
          ? Icon(PantasIcons.profile, size: 16, color: c.chevron)
          : Text(
              emoji ? initial : initial.toUpperCase(),
              style: t.style(14, weight: FontWeight.w700, color: t.tintText),
            ),
    );
  }
}
