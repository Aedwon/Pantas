import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The keyboard focus ring of a back link, drawn above the page.
///
/// The link sits 6 px left of the page edge so its arrow lines up with the
/// page (the board's `.back`). The page's navigator and scroll view both clip
/// at that edge, so a ring drawn on the link was cut square on the left
/// (5Q-11). This draws the same 2 px pill in the root overlay, which nothing
/// clips, following the link. Only keyboard focus shows it, by the rule every
/// web ring uses.
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

  void _sync() {
    if (!mounted) return;
    final accent = context.webTokens.colors.accent;
    final want = webFocusRing({if (_focused) WidgetState.focused}, accent);
    if ((want != null) == _overlay.isShowing) return;
    void apply() {
      if (!mounted) return;
      final show = webFocusRing(
            {if (_focused) WidgetState.focused},
            accent,
          ) !=
          null;
      if (show && !_overlay.isShowing) _overlay.show();
      if (!show && _overlay.isShowing) _overlay.hide();
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
    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      child: Align(
        alignment: Alignment.topLeft,
        child: IgnorePointer(
          child: SizedBox.fromSize(
            size: size,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: StadiumBorder(
                  side: BorderSide(
                    color: context.webTokens.colors.accent,
                    width: 2,
                  ),
                ),
              ),
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
          child: CompositedTransformTarget(
            link: _link,
            child: KeyedSubtree(key: _box, child: widget.child),
          ),
        ),
      );
}
