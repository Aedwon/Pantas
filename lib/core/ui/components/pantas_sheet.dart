import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/tab_bar_visibility.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/core/ui/theme/pantas_shape.dart';

/// Owns the sheet surface and the page behind it. The caller supplies contents.
class PantasSheet extends StatefulWidget {
  const PantasSheet({
    required this.page,
    required this.child,
    required this.label,
    required this.open,
    required this.onDismiss,
    this.bookmarks = false,
    this.readerContents = false,
    this.scrollable = true,
    this.topInset = 0,
    super.key,
  });

  final Widget page;
  final Widget child;
  final String label;
  final bool open;
  final VoidCallback onDismiss;
  final bool bookmarks;
  final bool readerContents;
  final bool scrollable;

  /// Space kept clear above the sheet, so a tall sheet stops short of the
  /// top of the screen (MK_Sheet: the page stays visible for 180 px).
  final double topInset;

  @override
  State<PantasSheet> createState() => _PantasSheetState();
}

class _PantasSheetState extends State<PantasSheet>
    with OverlayFocusReturn<PantasSheet> {
  double _dragDistance = 0;

  /// Whether this sheet is the one hiding the phone tab bar. The bar floats
  /// above the page, so it would cover the sheet's footer button. Another
  /// owner (the Bookmarks sheet) that already hid it keeps it.
  bool _hidesBar = false;

  @override
  void initState() {
    super.initState();
    if (widget.open) _hideBar();
  }

  @override
  void didUpdateWidget(PantasSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open == oldWidget.open) return;
    if (widget.open) {
      rememberFocus();
      _hideBar();
    } else {
      returnFocus();
    }
  }

  @override
  void dispose() {
    _showBar();
    super.dispose();
  }

  // The shell is building, or the tree is locked, so the bar changes a moment
  // later.
  void _hideBar() {
    if (_hidesBar || phoneTabBarHidden.value) return;
    _hidesBar = true;
    scheduleMicrotask(() {
      if (_hidesBar) phoneTabBarHidden.value = true;
    });
  }

  void _showBar() {
    if (!_hidesBar) return;
    _hidesBar = false;
    scheduleMicrotask(() {
      if (!_hidesBar) phoneTabBarHidden.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final bookmarks = widget.bookmarks;
    final readerContents = widget.readerContents;
    final slideSheet = bookmarks || readerContents;
    final duration = Duration(
      milliseconds: slideSheet
          ? widget.open
              ? 450
              : 400
          : widget.open
              ? 420
              : 320,
    );
    final endpoint = widget.open ? 1.0 : 0.0;
    return PopScope(
      canPop: !widget.open,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.open) widget.onDismiss();
      },
      child: LayoutBuilder(
        builder: (context, constraints) => TweenAnimationBuilder<double>(
          tween: Tween(begin: still ? endpoint : 0, end: endpoint),
          duration: still ? Duration.zero : duration,
          curve: slideSheet ? PantasCurves.slideC : PantasCurves.houseOut,
          // The bar returns once the sheet has left, not while it slides.
          onEnd: widget.open ? null : _showBar,
          builder: (context, sheetProgress, child) => Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: still ? endpoint : 0, end: endpoint),
                duration: still ? Duration.zero : duration,
                curve: PantasCurves.slideA,
                builder: (context, pageProgress, child) => Transform.translate(
                  key: const ValueKey('pantas-sheet-page-shift'),
                  offset: Offset(0, bookmarks ? 10 * pageProgress : 0),
                  child: Transform.scale(
                    key: const ValueKey('pantas-sheet-page-scale'),
                    scale: bookmarks ? 1 - .015 * pageProgress : 1,
                    child: child,
                  ),
                ),
                child: ExcludeFocus(
                  excluding: widget.open,
                  child: ExcludeSemantics(
                    excluding: widget.open,
                    child: widget.page,
                  ),
                ),
              ),
              if (widget.open || sheetProgress > 0) ...[
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: still ? endpoint : 0, end: endpoint),
                  duration: still
                      ? Duration.zero
                      : Duration(milliseconds: slideSheet ? 350 : 300),
                  curve: slideSheet ? PantasCurves.ease : PantasCurves.linear,
                  builder: (context, wash, child) => ModalBarrier(
                    color: PantasColors.dark.background.withValues(
                      alpha: (readerContents ? .32 : .34) * wash,
                    ),
                    onDismiss: widget.onDismiss,
                    semanticsLabel: 'Close ${widget.label}',
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionalTranslation(
                    translation: Offset(
                      0,
                      (slideSheet ? 1.05 : 1) * (1 - sheetProgress),
                    ),
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.escape):
                            widget.onDismiss,
                      },
                      child: FocusScope(
                        node: overlayScope,
                        child: Focus(
                          autofocus: widget.open,
                          child: Semantics(
                            scopesRoute: true,
                            namesRoute: true,
                            explicitChildNodes: true,
                            label: widget.label,
                            child: GestureDetector(
                              onVerticalDragStart: (_) => _dragDistance = 0,
                              onVerticalDragUpdate: (details) =>
                                  _dragDistance += details.delta.dy,
                              onVerticalDragEnd: (details) {
                                if (_dragDistance > 0 ||
                                    (details.primaryVelocity ?? 0) > 0) {
                                  widget.onDismiss();
                                }
                              },
                              child: DecoratedBox(
                                key: const ValueKey('pantas-sheet-surface'),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(
                                      PantasShape.floatingRadius,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: PantasColors.dark.background
                                          .withValues(alpha: .08),
                                      blurRadius: 30,
                                      offset: const Offset(0, -8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(
                                      PantasShape.floatingRadius,
                                    ),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: math.max(
                                        0,
                                        constraints.maxHeight - widget.topInset,
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      height: bookmarks
                                          ? constraints.maxHeight * .74
                                          : null,
                                      child: NotificationListener<
                                          ScrollNotification>(
                                        onNotification: (notification) {
                                          if (notification
                                                  is ScrollStartNotification &&
                                              notification.dragDetails !=
                                                  null) {
                                            _dragDistance = 0;
                                          } else if (notification
                                                  is OverscrollNotification &&
                                              notification.dragDetails !=
                                                  null &&
                                              notification.overscroll < 0) {
                                            _dragDistance -=
                                                notification.overscroll;
                                          } else if (notification
                                                  is ScrollUpdateNotification &&
                                              notification.dragDetails !=
                                                  null &&
                                              notification.metrics.pixels <
                                                  notification.metrics
                                                      .minScrollExtent) {
                                            _dragDistance -=
                                                notification.scrollDelta ?? 0;
                                          } else if (notification
                                                  is ScrollEndNotification &&
                                              _dragDistance > 0) {
                                            _dragDistance = 0;
                                            widget.onDismiss();
                                          }
                                          return false;
                                        },
                                        // No Scaffold above: without Material,
                                        // text gets the yellow-underline style.
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: widget.scrollable
                                              ? SingleChildScrollView(
                                                  child: widget.child,
                                                )
                                              : widget.child,
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
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
