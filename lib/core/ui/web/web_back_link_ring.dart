import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The hover fill and keyboard focus ring of a back link, drawn above the page.
///
/// The link reaches 14 px past the page edge so its arrow lines up with the
/// page (the board's `.back`, back link A of the design system canvas). The
/// page's navigator and scroll view both clip at that edge, so a fill or ring
/// drawn on the link was cut square on the left (5Q-11). This draws them in
/// the root overlay, which nothing clips, following the link: the rounded
/// rectangle of `radius-back` (11), the hover wash of the accent at
/// `opacity-hover`, and the 2 px ring, 2 px outside the link, only for
/// keyboard focus, by the rule every web ring uses.
///
/// The overlay sits above the label, so the 8 percent wash falls on the text
/// too. At that strength the label's color barely moves; drawing it under the
/// label would need the page's clip to move, which every page shares.
///
/// Where there is no overlay (a bare widget test), [supported] is false and
/// the link keeps the ring its button theme draws.
class WebBackLinkRing extends StatefulWidget {
  const WebBackLinkRing({required this.child, super.key});

  final Widget child;

  /// Whether the ring can be drawn here.
  static bool supported(BuildContext context) =>
      Overlay.maybeOf(context, rootOverlay: true) != null;

  @override
  State<WebBackLinkRing> createState() => _WebBackLinkRingState();
}

class _WebBackLinkRingState extends State<WebBackLinkRing> {
  final _link = LayerLink();
  final _overlay = OverlayPortalController();
  final _box = GlobalKey();
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    webKeyboardInput.addListener(_sync);
  }

  @override
  void dispose() {
    webKeyboardInput.removeListener(_sync);
    super.dispose();
  }

  bool get _ringShown =>
      webFocusRing(
        {if (_focused) WidgetState.focused},
        context.webTokens.colors.accent,
      ) !=
      null;

  void _sync() {
    if (!mounted) return;
    void apply() {
      if (!mounted) return;
      final show = _hovered || _ringShown;
      if (show && !_overlay.isShowing) _overlay.show();
      if (!show && _overlay.isShowing) _overlay.hide();
      // The overlay may already show for the other reason; redraw it.
      if (show) setState(() {});
    }

    // A focus change can arrive while the tree is building.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
  }

  Widget _ring(BuildContext context) {
    final size = (_box.currentContext?.findRenderObject() as RenderBox?)?.size;
    if (size == null) return const SizedBox.shrink();
    final accent = context.webTokens.colors.accent;
    const reach = PantasBorder.focus + PantasSpace.s2;
    final radius = BorderRadius.circular(PantasRadius.back);
    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      child: Align(
        alignment: Alignment.topLeft,
        child: IgnorePointer(
          child: SizedBox.fromSize(
            size: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The hover wash: the accent at `opacity-hover`, a rounded
                // rectangle of `radius-back`, never a pill.
                if (_hovered)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: accent.withValues(alpha: PantasOpacity.hover),
                        shape: RoundedRectangleBorder(borderRadius: radius),
                      ),
                    ),
                  ),
                // The keyboard ring: `border-focus` in `accent`, 2 outside.
                if (_ringShown)
                  Positioned(
                    left: -reach,
                    top: -reach,
                    right: -reach,
                    bottom: -reach,
                    child: DecoratedBox(
                      key: const ValueKey('back-link-ring'),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            PantasRadius.back + reach,
                          ),
                          side: BorderSide(
                            color: accent,
                            width: PantasBorder.focus,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (focused) {
          _focused = focused;
          _sync();
        },
        child: OverlayPortal(
          controller: _overlay,
          overlayLocation: OverlayChildLocation.rootOverlay,
          overlayChildBuilder: _ring,
          child: MouseRegion(
            onEnter: (_) {
              _hovered = true;
              _sync();
            },
            onExit: (_) {
              _hovered = false;
              _sync();
            },
            child: CompositedTransformTarget(
              link: _link,
              child: KeyedSubtree(key: _box, child: widget.child),
            ),
          ),
        ),
      );
}
