import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';

/// How a wide web drawer, dialog or popover arrives and leaves. These carry the
/// phone sheet's numbers (`PantasSheet`), so an overlay moves the same on both.
class WebOverlayMotion {
  const WebOverlayMotion({
    required this.open,
    required this.close,
    required this.curve,
    required this.scrim,
    required this.scrimCurve,
    this.slide = Offset.zero,
    this.rise = 0,
    this.travel = 0,
    this.fade = false,
  });

  /// [drawer] for a panel of [width] at the right edge of a layer as large as
  /// the window. The fraction in [drawer] would measure the window, and the
  /// panel would spend most of the slide off screen.
  factory WebOverlayMotion.drawerOf(double width) => WebOverlayMotion(
        open: drawer.open,
        close: drawer.close,
        curve: drawer.curve,
        scrim: drawer.scrim,
        scrimCurve: drawer.scrimCurve,
        travel: width * drawer.slide.dx,
      );

  /// A drawer from the right edge: the phone's list sheet, turned sideways.
  static const drawer = WebOverlayMotion(
    open: Duration(milliseconds: 450),
    close: Duration(milliseconds: 400),
    curve: PantasCurves.slideC,
    scrim: Duration(milliseconds: 350),
    scrimCurve: PantasCurves.ease,
    slide: Offset(1.05, 0),
  );

  /// A centered dialog: the phone's form sheet.
  static const dialog = WebOverlayMotion(
    open: Duration(milliseconds: 420),
    close: Duration(milliseconds: 320),
    curve: PantasCurves.houseOut,
    scrim: Duration(milliseconds: 300),
    scrimCurve: PantasCurves.linear,
    rise: 24,
    fade: true,
  );

  /// A small popover or pane: the approved detail pane motion.
  static const popover = WebOverlayMotion(
    open: PantasDurations.base,
    close: PantasDurations.base,
    curve: PantasCurves.shared,
    scrim: PantasDurations.base,
    scrimCurve: PantasCurves.ease,
    rise: 8,
    fade: true,
  );

  /// A lesson reader over the page: the phone's reader rise (24 px and a fade,
  /// `PantasDurations.page` on edgeGrow), with the drawer's scrim.
  static const lesson = WebOverlayMotion(
    open: PantasDurations.page,
    close: PantasDurations.page,
    curve: PantasCurves.edgeGrow,
    scrim: Duration(milliseconds: 350),
    scrimCurve: PantasCurves.ease,
    rise: 24,
    fade: true,
  );

  final Duration open;
  final Duration close;
  final Curve curve;
  final Duration scrim;
  final Curve scrimCurve;

  /// Where the panel starts, as a fraction of its own size.
  final Offset slide;

  /// How far below its place the panel starts, in logical pixels.
  final double rise;

  /// How far right of its place the panel starts, in logical pixels.
  final double travel;
  final bool fade;

  /// The scrim's curve over a route as long as [open].
  Curve get routeScrimCurve {
    final end = scrim.inMicroseconds / open.inMicroseconds;
    return end >= 1 ? scrimCurve : Interval(0, end, curve: scrimCurve);
  }

  /// Draws [child] at [animation], which runs from 0 (away) to 1 (in place).
  Widget transition(Animation<double> animation, Widget child) =>
      AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final value = curve.transform(animation.value.clamp(0.0, 1.0));
          var panel = child!;
          if (rise != 0) {
            panel = Transform.translate(
              offset: Offset(0, rise * (1 - value)),
              child: panel,
            );
          }
          if (travel != 0) {
            panel = Transform.translate(
              offset: Offset(travel * (1 - value), 0),
              child: panel,
            );
          }
          if (slide != Offset.zero) {
            panel = FractionalTranslation(
              translation: slide * (1 - value),
              child: panel,
            );
          }
          if (fade) {
            panel = Opacity(opacity: value.clamp(0.0, 1.0), child: panel);
          }
          return panel;
        },
      );
}

/// Lets a page play a [WebOverlayLayer]'s exit before it leaves. The page keeps
/// one, passes it to the layer, and calls [close] with what leaving does. The
/// layer runs that once its exit has ended. With no layer to play it, or with
/// reduced motion, [close] leaves at once. A second [close] does nothing.
class WebOverlayExit {
  _WebOverlayLayerState? _layer;
  VoidCallback? _leave;
  bool _closing = false;

  /// True from the first [close], so the page can stop taking input.
  bool get closing => _closing;

  void close(VoidCallback leave) {
    if (_closing) return;
    final layer = _layer;
    if (layer == null) {
      leave();
      return;
    }
    _closing = true;
    _leave = leave;
    layer._play();
  }

  void _finish() {
    final leave = _leave;
    _leave = null;
    leave?.call();
  }
}

/// Draws a scrim and [child] over its parent and plays [motion] once, as the
/// layer first appears. A page that opens with the overlay already in place (a
/// direct address, a root modal) uses it, since no route is there to animate.
/// With reduced motion it is in place at once. Give it an [exit] to play the
/// motion backward before the page leaves.
class WebOverlayLayer extends StatefulWidget {
  const WebOverlayLayer({
    required this.motion,
    required this.child,
    this.alignment = Alignment.centerRight,
    this.barrierColor = const Color(0x47000000),
    this.barrierLabel,
    this.onDismiss,
    this.exit,
    super.key,
  });

  final WebOverlayMotion motion;
  final Widget child;
  final AlignmentGeometry alignment;
  final Color barrierColor;
  final String? barrierLabel;

  /// Tapping the scrim calls this. Null makes the scrim ignore taps.
  final VoidCallback? onDismiss;

  /// Asks the layer to play its exit. The scrim and [child] ignore input once
  /// it is closing.
  final WebOverlayExit? exit;

  @override
  State<WebOverlayLayer> createState() => _WebOverlayLayerState();
}

class _WebOverlayLayerState extends State<WebOverlayLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.motion.open,
    reverseDuration: widget.motion.close,
  );
  bool _started = false;

  @override
  void initState() {
    super.initState();
    widget.exit?._layer = this;
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) widget.exit?._finish();
    });
  }

  @override
  void didUpdateWidget(WebOverlayLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exit == widget.exit) return;
    if (oldWidget.exit?._layer == this) oldWidget.exit!._layer = null;
    widget.exit?._layer = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      unawaited(_controller.forward());
    }
  }

  /// Plays the exit. The exit's callback runs when the controller reaches 0.
  void _play() {
    setState(() {});
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 0;
    } else {
      unawaited(_controller.reverse());
    }
    if (mounted && _controller.isDismissed) widget.exit?._finish();
  }

  @override
  void dispose() {
    if (widget.exit?._layer == this) widget.exit!._layer = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final closing = widget.exit?.closing ?? false;
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedModalBarrier(
          color: _controller
              .drive(CurveTween(curve: widget.motion.routeScrimCurve))
              .drive(
                ColorTween(
                  begin: widget.barrierColor.withValues(alpha: 0),
                  end: widget.barrierColor,
                ),
              ),
          dismissible: widget.onDismiss != null && !closing,
          onDismiss: widget.onDismiss,
          semanticsLabel: widget.barrierLabel,
        ),
        Align(
          alignment: widget.alignment,
          child: IgnorePointer(
            ignoring: closing,
            child: widget.motion.transition(_controller, widget.child),
          ),
        ),
      ],
    );
  }
}

/// Shows [builder] over the window with [motion]. Use it in place of
/// `showDialog` or `showGeneralDialog` for a wide web overlay.
Future<T?> showWebOverlay<T>({
  required BuildContext context,
  required WebOverlayMotion motion,
  required WidgetBuilder builder,
  required String barrierLabel,
  Color? barrierColor,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) =>
    Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
      WebOverlayRoute<T>(
        motion: motion,
        builder: builder,
        barrierLabel: barrierLabel,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        still: MediaQuery.disableAnimationsOf(context),
      ),
    );

class WebOverlayRoute<T> extends PopupRoute<T> {
  WebOverlayRoute({
    required this.motion,
    required this.builder,
    required this.barrierLabel,
    this.barrierColor,
    this.barrierDismissible = true,
    this.still = false,
  });

  final WebOverlayMotion motion;
  final WidgetBuilder builder;

  /// Reduced motion: the overlay appears and leaves at once.
  final bool still;

  @override
  final Color? barrierColor;
  @override
  final bool barrierDismissible;
  @override
  final String barrierLabel;

  @override
  Curve get barrierCurve => motion.routeScrimCurve;

  @override
  Duration get transitionDuration => still ? Duration.zero : motion.open;

  @override
  Duration get reverseTransitionDuration =>
      still ? Duration.zero : motion.close;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: builder(context),
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      motion.transition(animation, child);
}
