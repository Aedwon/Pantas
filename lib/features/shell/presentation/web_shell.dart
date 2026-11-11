import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
// ds-raw: search entry and sidebar items own their states
import 'package:pantas/core/ui/raw_controls.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

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
    final tier = webLayoutTier(
      width: MediaQuery.sizeOf(context).width,
      web: web,
    );
    // Below 1024 the TabBar (AppShell) is the navigation, never the sidebar.
    if (tier.index < WebLayoutTier.compact.index) return child;
    return _DesktopShell(
      activeIndex: activeIndex,
      person: person,
      exam: exam,
      plan: plan,
      onNavigate: onNavigate,
      onSearch: onSearch,
      wide: tier == WebLayoutTier.wide,
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
    required this.wide,
  });
  final Widget child;
  final int activeIndex;
  final String person;
  final String exam;
  final String plan;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSearch;

  /// From 1440: main sides of 44. Compact (1024 to 1439) keeps 32.
  final bool wide;

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
                  padding: EdgeInsets.fromLTRB(
                    widget.wide ? PantasLayout.mainPadX : PantasSpace.s32,
                    PantasLayout.mainPadTop,
                    widget.wide ? PantasLayout.mainPadX : PantasSpace.s32,
                    PantasSpace.s0,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: PantasLayout.contentMax,
                      ),
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

/// SidebarNav (design system): the wordmark, search, four destinations and the
/// account block. It shows from 1024; the width is `layout-sidebar-min`.
class WebSidebar extends StatefulWidget {
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

  @override
  State<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<WebSidebar> {
  static final _tabs = [
    (label: 'Home', glyph: PantasIcons.homeTab),
    (label: 'Study', glyph: PantasIcons.studyTab),
    (label: 'Quiz', glyph: PantasIcons.quizTab),
    (label: 'Settings', glyph: PantasIcons.settingsTab),
  ];
  static const _iconSize = 21.0;
  static const _searchIconSize = 18.0;
  static const _searchLabel = 'Search lessons';
  // The system styles carry no letter spacing, and the Material default text
  // style would add its own 0.25 to each letter.
  static final _searchLabelStyle = PantasType.webSub.copyWith(letterSpacing: 0);

  final _navKey = GlobalKey(debugLabel: 'sidebar nav');
  final _itemKeys = List.generate(_tabs.length, (_) => GlobalKey());

  /// Where each item sits in the nav, measured after layout (R3-A14). Until
  /// the first measurement the marker uses the item height, so it is there
  /// on the first frame.
  List<double>? _offsets;
  List<double>? _lengths;
  bool _measureQueued = false;

  List<double> get _fallbackOffsets => [
        for (var i = 0; i < _tabs.length; i++)
          i * (PantasSize.navItem + PantasSpace.s4),
      ];

  void _queueMeasure() {
    if (_measureQueued) return;
    _measureQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureQueued = false;
      if (!mounted) return;
      final nav = _navKey.currentContext?.findRenderObject();
      if (nav is! RenderBox || !nav.attached) return;
      final offsets = <double>[];
      final lengths = <double>[];
      for (final key in _itemKeys) {
        final box = key.currentContext?.findRenderObject();
        if (box is! RenderBox || !box.attached) return;
        offsets.add(box.localToGlobal(Offset.zero, ancestor: nav).dy);
        lengths.add(box.size.height);
      }
      if (_sameSpans(offsets, lengths)) return;
      setState(() {
        _offsets = offsets;
        _lengths = lengths;
      });
    });
  }

  bool _sameSpans(List<double> offsets, List<double> lengths) {
    final currentOffsets = _offsets ?? _fallbackOffsets;
    final currentLengths =
        _lengths ?? List.filled(_tabs.length, PantasSize.navItem);
    for (var i = 0; i < offsets.length; i++) {
      if ((offsets[i] - currentOffsets[i]).abs() > .01 ||
          (lengths[i] - currentLengths[i]).abs() > .01) {
        return false;
      }
    }
    return true;
  }

  /// `layout-sidebar-min` (220), grown to the search row's own width and no
  /// further than `layout-sidebar-max` (244), as the flex basis and maximum of
  /// the system do. The search row is the widest: its label is the app's
  /// "Search lessons", which does not fit beside the key hint in 220.
  double _width(BuildContext context) {
    final label = TextPainter(
      text: TextSpan(text: _searchLabel, style: _searchLabelStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final row = _SearchButton.chromeWidth + label.width;
    label.dispose();
    // The sidebar's own side padding goes around the row.
    return (row + 2 * PantasSpace.s14).clamp(
      PantasLayout.sidebarMin,
      PantasLayout.sidebarMax,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // A measurement from another text size is stale: measure again after
    // every build, which costs nothing when nothing moved.
    _queueMeasure();
    final measured = _offsets != null;
    return Semantics(
      container: true,
      label: 'Main navigation',
      child: SizedBox(
        width: _width(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s14,
            PantasSpace.s20,
            PantasSpace.s14,
            PantasSpace.s20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s12,
                  PantasSpace.s4,
                  PantasSpace.s12,
                  PantasSpace.s18,
                ),
                child: Text(
                  'Pantas',
                  style: PantasType.webH3Lg.copyWith(color: c.textPrimary),
                ),
              ),
              const SizedBox(height: PantasSpace.s4),
              _SearchButton(
                focusNode: widget.entryFocus,
                onPressed: widget.onSearch,
                iconSize: _searchIconSize,
              ),
              // 4 of the sidebar gap and 10 under the search: the first
              // destination sits 14 below it.
              const SizedBox(height: PantasSpace.s14),
              // The selected row's fill is one marker that glides from row to
              // row, measured from the rows themselves.
              Stack(
                key: _navKey,
                children: [
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: IgnorePointer(
                        child: SlidingMarker(
                          key: const ValueKey('sidebar-marker'),
                          axis: Axis.vertical,
                          offsets: _offsets ?? _fallbackOffsets,
                          lengths: _lengths ??
                              List.filled(_tabs.length, PantasSize.navItem),
                          index: widget.activeIndex,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.surfaceCard,
                              borderRadius:
                                  BorderRadius.circular(PantasRadius.md),
                              boxShadow: context.shadows.navActive,
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
                        if (i > 0) const SizedBox(height: PantasSpace.s4),
                        _SidebarItem(
                          key: _itemKeys[i],
                          label: _tabs[i].label,
                          glyph: _tabs[i].glyph,
                          iconSize: _iconSize,
                          selected: widget.activeIndex == i,
                          // Without a measurement the item draws its own
                          // highlight, so large text never leaves the
                          // marker on the wrong item.
                          drawsOwnFill: !measured && widget.activeIndex == i,
                          onPressed: () => widget.onNavigate(i),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s12,
                  vertical: PantasSpace.s10,
                ),
                child: Row(
                  children: [
                    _SidebarAvatar(person: widget.person),
                    const SizedBox(width: PantasSpace.s10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.person,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PantasType.webLabel.copyWith(
                              color: c.textPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            widget.plan.isEmpty
                                ? widget.exam
                                : '${widget.exam} · ${widget.plan}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PantasType.webCaption.copyWith(
                              color: c.textSecondary,
                              letterSpacing: 0,
                            ),
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

/// The search entry: 38 high, `radius-sm`, with the Ctrl K hint. It opens the
/// lesson search; it is a button, not a field.
class _SearchButton extends StatelessWidget {
  const _SearchButton({
    required this.onPressed,
    required this.iconSize,
    this.focusNode,
  });
  final VoidCallback onPressed;
  final FocusNode? focusNode;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextButton(
      // ds-raw: search entry per SearchField, opens overlay
      focusNode: focusNode,
      onPressed: onPressed,
      style: ButtonStyle(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.short2,
        visualDensity: VisualDensity.standard,
        minimumSize: const WidgetStatePropertyAll(Size(0, PantasSize.search)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.fromLTRB(
            PantasSpace.s12,
            PantasSpace.s0,
            PantasSpace.s10,
            PantasSpace.s0,
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(c.surfaceCard),
        // The field's own rule, with the keyboard ring over it while the
        // field has keyboard focus (4N-6).
        side: WidgetStateProperty.resolveWith(
          (s) =>
              webFocusRing(s, c.accent) ?? BorderSide(color: c.borderControl),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PantasRadius.sm),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(PantasIcons.search, size: iconSize, color: c.iconMuted),
          const SizedBox(width: PantasSpace.s8),
          Expanded(
            child: Text(
              _WebSidebarState._searchLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _WebSidebarState._searchLabelStyle.copyWith(
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: PantasSpace.s8),
          WebKeyHint(
            '$commandKeyLabel K',
            // "Cmd K" is wider than "Ctrl K", so the width is fixed and the
            // label centered: the gap to the text stays the same on every
            // platform.
            width: _keyHintWidth,
          ),
        ],
      ),
    );
  }

  /// The board's "Ctrl K" hint.
  static const double _keyHintWidth = 42;

  /// Everything in the row but the label: side padding (12 and 10), the icon
  /// (18) and its gap (8), and the gap (8) and the hint.
  static const double chromeWidth = PantasSpace.s12 +
      PantasSpace.s10 +
      _WebSidebarState._searchIconSize +
      PantasSpace.s8 +
      PantasSpace.s8 +
      _keyHintWidth;
}

/// One destination: 40 high, `radius-md`, hover 8% of `text-primary`, pressed
/// scale 0.98, a keyboard ring offset 2 outside it.
class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.label,
    required this.glyph,
    required this.iconSize,
    required this.selected,
    required this.drawsOwnFill,
    required this.onPressed,
    super.key,
  });
  final String label;
  final IconData glyph;
  final double iconSize;
  final bool selected;
  final bool drawsOwnFill;
  final VoidCallback onPressed;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  static const double _pressedScale = .98;
  final _states = WidgetStatesController();

  @override
  void initState() {
    super.initState();
    _states.addListener(_onStates);
  }

  @override
  void dispose() {
    _states
      ..removeListener(_onStates)
      ..dispose();
    super.dispose();
  }

  void _onStates() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(PantasRadius.md);
    final pressed = _states.value.contains(WidgetState.pressed);
    return Semantics(
      selected: widget.selected,
      child: OffsetFocusRing(
        borderRadius: radius,
        child: AnimatedScale(
          scale: pressed && !still ? _pressedScale : 1,
          duration: PantasDurations.short1,
          curve: PantasCurves.fade,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.drawsOwnFill ? c.surfaceCard : null,
              borderRadius: radius,
              boxShadow: widget.drawsOwnFill ? context.shadows.navActive : null,
            ),
            child: TextButton(
              // ds-raw: sidebar nav item per SidebarNav
              statesController: _states,
              onPressed: widget.onPressed,
              style: ButtonStyle(
                animationDuration:
                    still ? Duration.zero : PantasDurations.short2,
                visualDensity: VisualDensity.standard,
                minimumSize:
                    const WidgetStatePropertyAll(Size(0, PantasSize.navItem)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: PantasSpace.s12,
                    vertical: PantasSpace.s8,
                  ),
                ),
                // The selected fill is the marker behind.
                backgroundColor: WidgetStateProperty.resolveWith(
                  (s) => !widget.selected && s.contains(WidgetState.hovered)
                      ? c.textPrimary.withValues(alpha: PantasOpacity.hover)
                      : Colors.transparent,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: radius),
                ),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              ),
              child: Row(
                children: [
                  FadingColor(
                    color: widget.selected ? c.accent : c.iconMuted,
                    builder: (context, color, _) => Icon(
                      widget.glyph,
                      size: widget.iconSize,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: PantasSpace.s12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: PantasType.webNav.copyWith(
                        letterSpacing: 0,
                        color: c.textPrimary,
                        fontWeight:
                            widget.selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
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

/// The sidebar picture (X_Side, ST_Avatars): the first letter capitalized,
/// accents included; an emoji as itself; otherwise a plain gray person.
class _SidebarAvatar extends StatelessWidget {
  const _SidebarAvatar({required this.person});
  final String person;
  static final _letter = RegExp(r'^\p{L}', unicode: true);
  static const double _plainIcon = 16;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial = person.trim().isEmpty ? '' : person.trim().characters.first;
    final first = initial.isEmpty ? 0 : initial.runes.first;
    final emoji = initial.isNotEmpty &&
        (first >= 0x1F000 ||
            (first >= 0x2600 && first <= 0x27BF) ||
            initial.runes.contains(0xFE0F) ||
            initial.runes.contains(0x20E3));
    final plain = !emoji && !_letter.hasMatch(initial);
    return Container(
      width: PantasSize.avatar,
      height: PantasSize.avatar,
      decoration: BoxDecoration(
        color: plain ? c.fill : c.accentTint,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: plain
          ? Icon(PantasIcons.profile, size: _plainIcon, color: c.iconChevron)
          : Text(
              emoji ? initial : initial.toUpperCase(),
              style: PantasType.webGlyph.copyWith(color: c.accentTintText),
            ),
    );
  }
}
