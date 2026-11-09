import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The 440 px Drawer of design system 4.0 on a wide screen: a panel at the
/// right edge over a real scrim, with a title and a Close button at the top,
/// a scrolling body, and an optional foot over a hairline.
///
/// It is modal. The scrim closes it, Esc closes it, Tab stays inside, and
/// focus moves to the title when it opens. With [restoreFocus] focus goes back
/// to the control that opened it when it closes; a caller that sends focus
/// somewhere else (the quiz bar's Check or Next) turns that off.
///
/// The drawer lives on the root overlay, so [body] and [foot] are built there.
/// Both keep their last open value while the drawer slides out.
class WebSideDrawer extends StatefulWidget {
  const WebSideDrawer({
    required this.open,
    required this.onDismiss,
    required this.title,
    required this.closeLabel,
    required this.body,
    this.foot,
    this.restoreFocus = true,
    this.headingKey,
    super.key,
  });

  final bool open;
  final VoidCallback onDismiss;

  /// The title, which names the dialog and takes focus when it opens.
  final String title;

  /// The Close button's name, such as "Close explanation".
  final String closeLabel;
  final Widget body;
  final Widget? foot;
  final bool restoreFocus;

  /// Marks the title, so a test can find the node that holds focus.
  final Key? headingKey;

  @override
  State<WebSideDrawer> createState() => _WebSideDrawerState();
}

class _WebSideDrawerState extends State<WebSideDrawer>
    with SingleTickerProviderStateMixin, OverlayFocusReturn<WebSideDrawer> {
  final _portal = OverlayPortalController();
  final _heading = FocusNode(debugLabel: 'drawer heading');
  late final AnimationController _motion;

  /// What the drawer shows while it leaves. The caller may stop passing
  /// content once it closes.
  late WebSideDrawer _held = widget;

  WebOverlayMotion get _style => WebOverlayMotion.drawer.forContext(context);

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      value: widget.open ? 1 : 0,
      // Reduced motion swaps the slide for a 150 ms fade. The default would
      // run that fade at a twentieth of its time.
      animationBehavior: AnimationBehavior.preserve,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed &&
            !widget.open &&
            _portal.isShowing) {
          _portal.hide();
        }
      });
    if (widget.open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.open && !_portal.isShowing) _portal.show();
      });
    }
  }

  @override
  void dispose() {
    _heading.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WebSideDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open) _held = widget;
    if (widget.open == oldWidget.open) return;
    if (widget.restoreFocus) {
      if (widget.open) {
        rememberFocus();
      } else {
        returnFocus();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final style = _style;
      _motion
        ..duration = style.open
        ..reverseDuration = style.close;
      if (widget.open) {
        if (!_portal.isShowing) _portal.show();
        unawaited(_motion.forward());
      } else if (_portal.isShowing) {
        if (_motion.value == 0) {
          _portal.hide();
        } else {
          unawaited(_motion.reverse());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
        overlayLocation: OverlayChildLocation.rootOverlay,
        controller: _portal,
        overlayChildBuilder: _overlay,
        child: const SizedBox.shrink(),
      );

  Widget _overlay(BuildContext context) {
    final held = _held;
    final style = _style;
    final t = context.webTokens;
    final inset = MediaQuery.viewPaddingOf(context);
    return Positioned.fill(
      child: Stack(
        children: [
          AnimatedModalBarrier(
            color:
                _motion.drive(CurveTween(curve: style.routeScrimCurve)).drive(
                      ColorTween(
                        begin: t.colors.scrim.withValues(alpha: 0),
                        end: t.colors.scrim,
                      ),
                    ),
            dismissible: widget.open,
            onDismiss: widget.onDismiss,
            semanticsLabel: 'Close ${held.title.toLowerCase()}',
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IgnorePointer(
              ignoring: !widget.open,
              child: style.transition(
                _motion,
                CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape):
                        widget.onDismiss,
                  },
                  child: FocusScope(
                    node: overlayScope,
                    autofocus: true,
                    child: Semantics(
                      scopesRoute: true,
                      explicitChildNodes: true,
                      namesRoute: true,
                      label: held.title,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          boxShadow: context.shadows.drawer,
                        ),
                        child: Material(
                          key: const ValueKey('web-side-drawer'),
                          color: t.colors.bgPage,
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: PantasLayout.drawer,
                            height: MediaQuery.sizeOf(context).height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    PantasSpace.s20,
                                    PantasSpace.s16 + inset.top,
                                    PantasSpace.s20,
                                    PantasSpace.s16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Focus(
                                          key: held.headingKey,
                                          focusNode: _heading,
                                          autofocus: true,
                                          skipTraversal: true,
                                          child: Semantics(
                                            header: true,
                                            child: Text(
                                              held.title,
                                              style: PantasType.webH3.copyWith(
                                                color: t.colors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      PantasIconButton(
                                        tooltip: held.closeLabel,
                                        glyph: PantasIcons.close,
                                        size: PantasIconButtonSize.md,
                                        onPressed: widget.onDismiss,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                      PantasSpace.s20,
                                      PantasSpace.s4,
                                      PantasSpace.s20,
                                      PantasSpace.s20,
                                    ),
                                    child: held.body,
                                  ),
                                ),
                                if (held.foot != null)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: t.colors.divider,
                                          width: webHairline(context),
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        PantasSpace.s20,
                                        PantasSpace.s16,
                                        PantasSpace.s20,
                                        PantasSpace.s20 + inset.bottom,
                                      ),
                                      child: held.foot,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
