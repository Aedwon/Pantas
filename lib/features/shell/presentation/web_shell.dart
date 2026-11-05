import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
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

/// Pages that run in focus mode and place their own bar 28 px above the
/// window bottom: the lesson reader, a quiz being answered or looked back
/// over, and a mock being sat or reviewed. From 1024 to 1279 px they take the
/// whole window, with no phone navigation over them and no padding that moved
/// their bars up (7W-18, 3K-9a). Tab pages and result pages keep the
/// navigation (Oct 30 decision).
bool webFocusRoute(String path) =>
    const [
      '/lesson/',
      '/mock/review/',
      '/quiz/today/',
      '/quiz/resume/',
      '/quiz/quick/',
      '/quiz/retake/',
      '/quiz/inline/',
      '/quiz/viewer/',
      '/quiz/mock/start',
      '/quiz/mock/resume/',
    ].any(path.startsWith) ||
    path.startsWith('/quiz/practice/') && path.endsWith('/run') ||
    path.startsWith('/quiz/flagged/') && path.contains('/view/');

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
          // No bottom padding, as on desktop: the page scrolls under the
          // floating navigation and carries `webPageBottomInset` itself.
          padding: const EdgeInsets.fromLTRB(44, 28, 44, 0),
          child: child,
        ),
      );
    }
    return _DesktopShell(
      activeIndex: activeIndex,
      person: person,
      exam: exam,
      plan: plan,
      onNavigate: onNavigate,
      onSearch: onSearch,
      child: child,
    );
  }
}

/// The desktop shell: the sidebar beside the page.
///
/// Tab starts in the sidebar, as the screen reads left to right (5Q-12). A
/// page holds focus on its own key node until something is focused, and Tab
/// from that node went to the page's controls and reached the sidebar last.
/// The first Tab from such a node now goes to the sidebar's first control.
/// Tab on from the sidebar's last control goes straight to the page's first
/// control: Flutter first lands on the node the page holds focus on, which
/// shows nothing and does nothing, and from there the rule above sent Tab
/// back to the sidebar, so page content was never reached (6T-2).
class _DesktopShell extends StatefulWidget {
  const _DesktopShell({
    required this.child,
    required this.activeIndex,
    required this.person,
    required this.exam,
    required this.plan,
    required this.onNavigate,
    required this.onSearch,
  });
  final Widget child;
  final int activeIndex;
  final String person;
  final String exam;
  final String plan;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSearch;

  @override
  State<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<_DesktopShell> {
  final _sidebarEntry = FocusNode(debugLabel: 'sidebar entry');
  final _sidebar = FocusNode(debugLabel: 'sidebar');

  @override
  void dispose() {
    _sidebarEntry.dispose();
    _sidebar.dispose();
    super.dispose();
  }

  /// The sidebar is one column, so its last stop is its lowest.
  bool _isLastSidebarStop(FocusNode node) {
    final stops = _sidebar.traversalDescendants;
    return stops.contains(node) &&
        stops.every((stop) => stop.rect.top <= node.rect.top);
  }

  void _enterPage(FocusNode from) {
    from.nextFocus();
    // Runs after the focus change above, and before anything is drawn.
    scheduleMicrotask(() {
      final landed = FocusManager.instance.primaryFocus;
      if (landed == null || landed == from) return;
      if (landed.skipTraversal || landed is FocusScopeNode) landed.nextFocus();
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.tab) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isShiftPressed ||
        keyboard.isControlPressed ||
        keyboard.isAltPressed ||
        keyboard.isMetaPressed) {
      return KeyEventResult.ignored;
    }
    final primary = FocusManager.instance.primaryFocus;
    if (primary == null) return KeyEventResult.ignored;
    // A node that exists to hold keys: a page's own key node, or this one.
    if (primary.skipTraversal) {
      _sidebarEntry.requestFocus();
      return KeyEventResult.handled;
    }
    if (_isLastSidebarStop(primary)) {
      _enterPage(primary);
      return KeyEventResult.handled;
    }
    // Any other real control keeps Flutter's own order.
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final onSearch = widget.onSearch;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): onSearch,
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): onSearch,
      },
      child: Focus(
        autofocus: true,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: Scaffold(
          body: Row(
            children: [
              Focus(
                focusNode: _sidebar,
                canRequestFocus: false,
                skipTraversal: true,
                child: WebSidebar(
                  activeIndex: widget.activeIndex,
                  person: widget.person,
                  exam: widget.exam,
                  plan: widget.plan,
                  onNavigate: widget.onNavigate,
                  onSearch: onSearch,
                  entryFocus: _sidebarEntry,
                ),
              ),
              Expanded(
                child: Padding(
                  // No bottom padding: the page's scrolling content reaches
                  // the window bottom and carries `webPageBottomInset` itself.
                  padding: const EdgeInsets.fromLTRB(44, 28, 44, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      // The page's Navigator puts a modal barrier under its
                      // page, and a barrier hides every earlier sibling from
                      // the accessibility tree. The sidebar is such a
                      // sibling, so the page is its own semantics boundary.
                      child: Semantics(
                        container: true,
                        explicitChildNodes: true,
                        child: widget.child,
                      ),
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
    this.entryFocus,
    super.key,
  });
  final int activeIndex;
  final String person;
  final String exam;
  final String plan;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSearch;

  /// The search field's focus node, so the shell can send the first Tab here.
  final FocusNode? entryFocus;
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
                focusNode: entryFocus,
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
                  // The field's own rule, with the keyboard ring over it while
                  // the field has keyboard focus (4N-6).
                  side: WidgetStateProperty.resolveWith(
                    (s) =>
                        webFocusRing(s, c.accent) ??
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
                    // Board `.srch`: 8 px between the text and the key hint.
                    const SizedBox(width: 8),
                    WebKeyHint(
                      '$commandKeyLabel K',
                      // The board's "Ctrl K" is 42 px wide. "Cmd K" is wider,
                      // so the width is fixed and the label centered: the gap
                      // to the text stays the board's on every platform.
                      width: 42,
                    ),
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
                                            webKeyboardFocus(s))
                                    ? t.dark
                                        ? c.fill
                                        : Colors.black.withValues(
                                            alpha: .045,
                                          )
                                    : Colors.transparent,
                              ),
                              side: WidgetStateProperty.resolveWith(
                                (s) => webFocusRing(s, c.accent),
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
