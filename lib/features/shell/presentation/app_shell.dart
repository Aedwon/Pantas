import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/tab_bar_visibility.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/theme/app_text_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;
  static const _labels = ['home', 'study', 'quiz', 'settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        extendBody: true,
        body: context.wideWeb
            ? navigationShell
            : FloatingTabBarScope(child: navigationShell),
        bottomNavigationBar: context.wideWeb
            ? null
            : ValueListenableBuilder<bool>(
                valueListenable: phoneTabBarHidden,
                builder: (context, hidden, bar) =>
                    hidden ? const SizedBox.shrink() : bar!,
                child: _TabBarDock(
                  child: AppNavBar(
                    currentIndex: navigationShell.currentIndex,
                    onTap: (i) {
                      ref.read(telemetryProvider).log(
                        TelemetryEvent.tabOpened,
                        properties: {'tab': _labels[i]},
                      );
                      navigationShell.goBranch(
                        i,
                        initialLocation: i == navigationShell.currentIndex,
                      );
                    },
                  ),
                ),
              ),
      );
}

/// Where the TabBar floats: inset 16 at each side, at most 358 wide and
/// centered, 24 above the bottom edge or 8 above the safe area if that is
/// higher (PhoneFrame, TabBar).
class _TabBarDock extends StatelessWidget {
  const _TabBarDock({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        PantasLayout.tabbarInset,
        PantasSpace.s0,
        PantasLayout.tabbarInset,
        math.max(PantasLayout.tabbarBottom, safeBottom + PantasSpace.s8),
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: PantasLayout.tabbarMax),
          child: child,
        ),
      ),
    );
  }
}

/// TabBar: four destinations in a floating pill (D187 keeps it a pill). The
/// current item sits on an `accent-tint` marker that glides to it.
class AppNavBar extends StatelessWidget {
  const AppNavBar({required this.currentIndex, required this.onTap, super.key});
  final int currentIndex;
  final ValueChanged<int> onTap;
  static final _tabs = <({String label, IconData glyph})>[
    (label: 'Home', glyph: PantasIcons.homeTab),
    (label: 'Study', glyph: PantasIcons.studyTab),
    (label: 'Quiz', glyph: PantasIcons.quizTab),
    (label: 'Settings', glyph: PantasIcons.settingsTab),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    const shape = BorderRadius.all(Radius.circular(PantasRadius.full));
    // The 1px ring is `edge-bar`, drawn over the bar without taking room.
    final bar = Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: shape,
        boxShadow: context.shadows.bar,
      ),
      padding: const EdgeInsets.all(PantasSpace.s6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = PantasSpace.s2;
          final width =
              (constraints.maxWidth - gap * (_tabs.length - 1)) / _tabs.length;
          // Where each tab starts, so the pill can glide to it.
          final offsets = [
            for (var i = 0; i < _tabs.length; i++) i * (width + gap),
          ];
          return Stack(
            children: [
              // The pill is the one thing that moves: a translation, drawn
              // behind the tabs, so a tap never rebuilds the screen.
              Positioned.fill(
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: SlidingMarker(
                      key: const ValueKey('nav-pill'),
                      offsets: offsets,
                      lengths: List.filled(_tabs.length, width),
                      index: currentIndex,
                      child: const _TabMarker(),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    SizedBox(
                      width: width,
                      child: _NavItem(
                        label: _tabs[i].label,
                        glyph: _tabs[i].glyph,
                        isActive: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
    return Stack(
      children: [
        bar,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: shape,
                border: Border.all(color: c.edgeBar),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabMarker extends StatelessWidget {
  const _TabMarker();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.accentTint,
          borderRadius: BorderRadius.circular(PantasRadius.full),
        ),
      );
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.label,
    required this.glyph,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final IconData glyph;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  static const double _iconSize = 23;
  static const double _pressedScale = .96;
  bool _pressed = false;
  OverlayEntry? _large;

  @override
  void dispose() {
    _hideLarge();
    super.dispose();
  }

  /// Large Content Viewer, as on iOS: a long press shows the label at the full
  /// OS text size over the bar, because the label itself stops at 12.
  void _showLarge() {
    _hideLarge();
    final box = context.findRenderObject();
    final overlay = Overlay.maybeOf(context);
    if (box is! RenderBox || !box.attached || overlay == null) return;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final screen = MediaQuery.sizeOf(context);
    final colors = context.colors;
    final shadows = context.shadows;
    final os = OsTextScaler.of(context);
    final label = widget.label;
    final glyph = widget.glyph;
    _large = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        right: 0,
        bottom: screen.height - rect.top + PantasSpace.s8,
        child: IgnorePointer(
          child: Center(
            child: Semantics(
              excludeSemantics: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(PantasRadius.lg),
                  boxShadow: shadows.popover,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s20,
                    vertical: PantasSpace.s12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        glyph,
                        size: _iconSize,
                        color: colors.accentTintText,
                      ),
                      const SizedBox(width: PantasSpace.s8),
                      Text(
                        label,
                        textScaler: os,
                        style: PantasType.phoneHeadline.copyWith(
                          color: colors.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_large!);
  }

  void _hideLarge() {
    _large?.remove();
    _large?.dispose();
    _large = null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final active = widget.isActive;
    final still = MediaQuery.disableAnimationsOf(context);
    // Unselected tabs are enabled controls, not disabled text.
    final iconColor = active ? c.accentTintText : c.iconMuted;
    final labelColor = active ? c.accentTintText : c.textSecondary;
    // The one UI text that stops below the 2.0 clamp: the label grows to 12
    // at most (D181). Browser zoom still scales it.
    final labelScaler = MediaQuery.textScalerOf(context).clamp(
      maxScaleFactor:
          PantasSize.tabLabelMax / PantasType.phoneTabLabel.fontSize!,
    );
    return Semantics(
      label: widget.label,
      button: true,
      selected: active,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: OffsetFocusRing(
        borderRadius: BorderRadius.circular(PantasRadius.full),
        child: FocusableActionDetector(
          shortcuts: const {
            SingleActivator(
              LogicalKeyboardKey.enter,
              includeRepeats: false,
            ): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onTap();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onLongPress: _showLarge,
            onLongPressUp: _hideLarge,
            onLongPressCancel: _hideLarge,
            child: AnimatedScale(
              scale: _pressed && !still ? _pressedScale : 1,
              duration: PantasDurations.short1,
              curve: PantasCurves.fade,
              child: ConstrainedBox(
                // Fills the item: the focus ring's stack hands down loose
                // constraints, and the whole item is the target.
                constraints: const BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: PantasSize.tabbarItem,
                ),
                // The icon and label fade between their two colors.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadingColor(
                      color: iconColor,
                      builder: (context, color, _) =>
                          Icon(widget.glyph, color: color, size: _iconSize),
                    ),
                    const SizedBox(height: PantasSpace.s2),
                    FadingColor(
                      color: labelColor,
                      builder: (context, color, _) => Text(
                        widget.label,
                        textScaler: labelScaler,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                        // Rest is 500; the current tab is the 600 state.
                        style: PantasType.phoneTabLabel.copyWith(
                          letterSpacing: 0,
                          color: color,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
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
