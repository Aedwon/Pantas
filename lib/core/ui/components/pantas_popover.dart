import 'dart:async';
import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// The three recipes of Popover (design system: Popover). The menu holds
/// actions, the picker chooses one value from a short list, the panel shows
/// a little read-only detail.
enum PantasPopoverRole { menu, picker, panel }

/// Which side of the trigger the popover opens on.
enum PantasPopoverSide { below, above }

/// Opens and closes a [PantasPopover] from outside, such as from the
/// trigger's own handler.
class PantasPopoverController extends ChangeNotifier {
  bool _open = false;

  bool get isOpen => _open;

  void open() {
    if (_open) return;
    _open = true;
    notifyListeners();
  }

  void close() {
    if (!_open) return;
    _open = false;
    notifyListeners();
  }

  void toggle() => _open ? close() : open();
}

/// A small floating surface anchored to the control that opened it.
///
/// It sits 8 below its trigger, aligned to the trigger's left edge, and flips
/// above when there is no room below. It opens in 240ms: it rises 8 and fades
/// in on `motion-move`. Under reduced motion it fades in place over 150ms.
/// Esc, an outside tap and a chosen item close it. Up and Down move between
/// the items and wrap. The popover sits above modals (`z-popover`).
///
/// Build the content from [PantasPopoverItem], [PantasPopoverSeparator] and
/// [PantasPopoverEmpty]. The trigger is the caller's: it should carry
/// `aria-haspopup`-style semantics through [PantasPopoverRole].
class PantasPopover extends StatefulWidget {
  const PantasPopover({
    required this.controller,
    required this.trigger,
    required this.children,
    this.role = PantasPopoverRole.menu,
    this.label,
    this.onClosed,
    super.key,
  });

  final PantasPopoverController controller;

  /// The control that opens it. The popover aligns to this widget.
  final Widget trigger;

  /// The items.
  final List<Widget> children;
  final PantasPopoverRole role;

  /// The accessible name of the surface.
  final String? label;

  /// Called after it closes, so the caller can return focus to the trigger.
  final VoidCallback? onClosed;

  /// The surface is at least this wide.
  static const double minWidth = PantasSize.tileMin + PantasSpace.s40;

  /// The surface is at most this wide, or the window less 32.
  static const double maxWidth = PantasSize.tileMin * 2 + PantasSpace.s32 * 2;

  /// The surface is at most this high, then it scrolls.
  static const double maxHeight = PantasSize.tileMin * 2 + PantasSpace.s40;

  /// The gap to the trigger.
  static const double gap = PantasSpace.s8;

  @override
  State<PantasPopover> createState() => _PantasPopoverState();
}

class _PantasPopoverState extends State<PantasPopover>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusScopeNode _scope = FocusScopeNode(debugLabel: 'popover');
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: PantasDurations.medium1,
  );
  PantasPopoverSide _side = PantasPopoverSide.below;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    if (widget.controller.isOpen) _show();
  }

  @override
  void didUpdateWidget(PantasPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_sync);
      widget.controller.addListener(_sync);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    _scope.dispose();
    _motion.dispose();
    super.dispose();
  }

  void _sync() {
    if (widget.controller.isOpen) {
      _show();
    } else {
      unawaited(_hide());
    }
  }

  void _show() {
    if (_portal.isShowing) return;
    // Open below, unless the trigger sits in the lower part of the window and
    // the surface would leave it.
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
      final room = MediaQuery.sizeOf(context).height - bottom;
      _side = room < PantasPopover.maxHeight + PantasPopover.gap
          ? PantasPopoverSide.above
          : PantasPopoverSide.below;
    }
    _portal.show();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = 1;
    } else {
      unawaited(_motion.forward(from: 0));
    }
  }

  Future<void> _hide() async {
    if (!_portal.isShowing) return;
    if (!MediaQuery.disableAnimationsOf(context)) {
      await _motion.reverse();
    }
    if (mounted) {
      _portal.hide();
      widget.onClosed?.call();
    }
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(
          controller: _portal,
          overlayLocation: OverlayChildLocation.rootOverlay,
          overlayChildBuilder: _overlay,
          child: widget.trigger,
        ),
      );

  Widget _overlay(BuildContext context) {
    final below = _side == PantasPopoverSide.below;
    final still = MediaQuery.disableAnimationsOf(context);
    final width = MediaQuery.sizeOf(context).width - PantasSpace.s32;
    final role = switch (widget.role) {
      PantasPopoverRole.menu => SemanticsRole.menu,
      PantasPopoverRole.picker => SemanticsRole.list,
      PantasPopoverRole.panel => SemanticsRole.dialog,
    };
    return Stack(
      children: [
        // An outside tap closes it.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.controller.close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: below ? Alignment.bottomLeft : Alignment.topLeft,
          followerAnchor: below ? Alignment.topLeft : Alignment.bottomLeft,
          offset: Offset(
            0,
            below ? PantasPopover.gap : -PantasPopover.gap,
          ),
          child: AnimatedBuilder(
            animation: _motion,
            builder: (context, child) {
              final t = PantasCurves.move.transform(_motion.value);
              return Opacity(
                opacity: still ? _motion.value : _motion.value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, still ? 0 : PantasSpace.s8 * (1 - t)),
                  child: child,
                ),
              );
            },
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape):
                    widget.controller.close,
                const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                    _scope.focusInDirection(TraversalDirection.down) ||
                    _scope.nextFocus(),
                const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                    _scope.focusInDirection(TraversalDirection.up) ||
                    _scope.previousFocus(),
              },
              child: FocusScope(
                node: _scope,
                autofocus: true,
                child: Semantics(
                  role: role,
                  label: widget.label,
                  explicitChildNodes: true,
                  child: _PopoverRoleScope(
                    role: widget.role,
                    child: _PopoverSurface(
                      maxWidth: width < PantasPopover.maxWidth
                          ? width
                          : PantasPopover.maxWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.children,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tells the items which recipe they sit in, so each takes the right role.
class _PopoverRoleScope extends InheritedWidget {
  const _PopoverRoleScope({required this.role, required super.child});

  final PantasPopoverRole role;

  static PantasPopoverRole of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PopoverRoleScope>()?.role ??
      PantasPopoverRole.menu;

  @override
  bool updateShouldNotify(_PopoverRoleScope oldWidget) =>
      oldWidget.role != role;
}

/// `surface-card`, radius `radius-lg`, padding 6, `elev-popover`, 200 to 380
/// wide, at most 360 high before it scrolls.
class _PopoverSurface extends StatelessWidget {
  const _PopoverSurface({required this.child, required this.maxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: PantasPopover.minWidth,
          maxWidth: maxWidth,
          maxHeight: PantasPopover.maxHeight,
        ),
        child: DecoratedBox(
          key: const ValueKey('pantas-popover-surface'),
          decoration: BoxDecoration(
            color: context.colors.surfaceCard,
            borderRadius: BorderRadius.circular(PantasRadius.lg),
            boxShadow: context.shadows.popover,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PantasSpace.s6),
              child: child,
            ),
          ),
        ),
      );
}

/// One row of a popover: 40 high at least, radius `radius-md`, padding 8 by
/// 12, 15/400, labels wrap. Hover or keyboard highlight is `surface-hover`.
/// A selected item is `accent-tint` with `accent-tint-text` in weight 600;
/// [check] adds the check at the end, so selection is not color alone.
class PantasPopoverItem extends StatefulWidget {
  const PantasPopoverItem({
    required this.label,
    this.onPressed,
    this.selected = false,
    this.check = false,
    this.leading,
    super.key,
  });

  final String label;

  /// Null makes the item disabled: `text-disabled`, skipped by Tab.
  final VoidCallback? onPressed;
  final bool selected;

  /// Shows the check at the end of a selected row (the picker).
  final bool check;
  final Widget? leading;

  /// The least height of a row.
  static const double minHeight = PantasSize.navItem;

  @override
  State<PantasPopoverItem> createState() => _PantasPopoverItemState();
}

class _PantasPopoverItemState extends State<PantasPopoverItem> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = widget.onPressed == null;
    final radius = BorderRadius.circular(PantasRadius.md);
    final fill = widget.selected
        ? colors.accentTint
        : (_hover || _focus) && !disabled
            ? colors.surfaceHover
            : Colors.transparent;
    final ink = disabled
        ? colors.textDisabled
        : widget.selected
            ? colors.accentTintText
            : colors.textPrimary;
    final style = PantasType.webRowValue.copyWith(
      color: ink,
      fontWeight: widget.selected ? FontWeight.w600 : null,
    );
    final recipe = _PopoverRoleScope.of(context);
    return Semantics(
      role: switch (recipe) {
        PantasPopoverRole.menu => SemanticsRole.menuItem,
        // A picker row is announced as a button that is selected (and
        // carries the check); a panel has no roles inside.
        PantasPopoverRole.picker ||
        PantasPopoverRole.panel =>
          SemanticsRole.none,
      },
      button: true,
      enabled: !disabled,
      selected: widget.selected,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: PantasSize.targetTouch,
        ),
        child: WebKeyboardRing(
          borderRadius: radius,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onPressed,
              child: Focus(
                canRequestFocus: !disabled,
                onFocusChange: (focused) => setState(() => _focus = focused),
                onKeyEvent: (node, event) {
                  if (disabled || event is! KeyDownEvent) {
                    return KeyEventResult.ignored;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space) {
                    widget.onPressed!();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: AnimatedContainer(
                  duration: PantasDurations.short2,
                  curve: PantasCurves.fade,
                  constraints: const BoxConstraints(
                    minHeight: PantasPopoverItem.minHeight,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s12,
                    vertical: PantasSpace.s8,
                  ),
                  decoration: BoxDecoration(color: fill, borderRadius: radius),
                  child: Row(
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: PantasSpace.s10),
                      ],
                      Expanded(child: Text(widget.label, style: style)),
                      if (widget.check && widget.selected) ...[
                        const SizedBox(width: PantasSpace.s10),
                        Icon(
                          PantasIcons.check,
                          size: PantasSize.icon,
                          color: colors.accentTintText,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 0.5 `divider` rule with 6 above and below and 8 on each side.
class PantasPopoverSeparator extends StatelessWidget {
  const PantasPopoverSeparator({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: PantasSpace.s6,
          horizontal: PantasSpace.s8,
        ),
        child: Divider(
          height: PantasBorder.hairline,
          thickness: PantasBorder.hairline,
          color: context.colors.divider,
        ),
      );
}

/// The one-line message shown while no option is visible.
class PantasPopoverEmpty extends StatelessWidget {
  const PantasPopoverEmpty(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(PantasSpace.s12),
        child: Text(
          message,
          style: PantasType.webSub.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      );
}
