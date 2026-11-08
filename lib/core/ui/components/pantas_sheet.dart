import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/tab_bar_visibility.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_shape.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

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

  /// Ties the sheet's place in the page to its copy on the root overlay.
  final LayerLink _pageArea = LayerLink();
  final OverlayPortalController _window = OverlayPortalController();

  /// Whether this sheet is the one hiding the phone tab bar. The bar floats
  /// above the page, so it would cover the sheet's footer button. Another
  /// owner (the Bookmarks sheet) that already hid it keeps it.
  bool _hidesBar = false;

  /// Whether this build draws the sheet on the root overlay (wide web).
  bool _windowMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.open) _hideBar();
  }

  // The overlay cannot be shown while the tree is building, so it opens just
  // after the frame.
  void _showWindow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _windowMode && widget.open && !_window.isShowing) {
        _window.show();
      }
    });
  }

  // The sheet has slid out: take its layer off the overlay.
  void _windowGone() {
    if (!widget.open && _window.isShowing) _window.hide();
    _showBar();
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
    final slideSheet = bookmarks || widget.readerContents;
    final duration = still
        ? Duration.zero
        : Duration(
            milliseconds: slideSheet
                ? widget.open
                    ? 450
                    : 400
                : widget.open
                    ? 420
                    : 320,
          );
    final endpoint = widget.open ? 1.0 : 0.0;
    final curve = slideSheet ? PantasCurves.slide : PantasCurves.house;
    final washDuration =
        still ? Duration.zero : Duration(milliseconds: slideSheet ? 350 : 300);
    final washCurve = slideSheet ? PantasCurves.fade : PantasCurves.linear;
    // On wide web the sheet sits in the page's column, but its scrim covers the
    // window, the sidebar included, as every dialog does. A scrim drawn inside
    // the column was a gray box with hard edges (5S-4).
    final overWindow =
        context.wideWeb && Overlay.maybeOf(context, rootOverlay: true) != null;
    _windowMode = overWindow;
    if (overWindow && widget.open) _showWindow();
    final page = TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? endpoint : 0, end: endpoint),
      duration: duration,
      curve: PantasCurves.scroll,
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
    );
    return PopScope(
      canPop: !widget.open,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.open) widget.onDismiss();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (overWindow) {
            return Stack(
              fit: StackFit.expand,
              children: [
                page,
                CompositedTransformTarget(
                  link: _pageArea,
                  child: const SizedBox.expand(),
                ),
                OverlayPortal(
                  controller: _window,
                  overlayLocation: OverlayChildLocation.rootOverlay,
                  overlayChildBuilder: (_) => _SheetWindowLayer(
                    key: const ValueKey('pantas-sheet-window-layer'),
                    open: widget.open,
                    still: still,
                    duration: duration,
                    curve: curve,
                    washDuration: washDuration,
                    washCurve: washCurve,
                    onGone: _windowGone,
                    wash: _wash,
                    panel: (progress) => CompositedTransformFollower(
                      link: _pageArea,
                      showWhenUnlinked: false,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: _panel(constraints, progress),
                        ),
                      ),
                    ),
                  ),
                  child: const SizedBox.shrink(),
                ),
              ],
            );
          }
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: still ? endpoint : 0, end: endpoint),
            duration: duration,
            curve: curve,
            // The bar returns once the sheet has left, not while it slides.
            onEnd: widget.open ? null : _showBar,
            builder: (context, sheetProgress, child) => Stack(
              fit: StackFit.expand,
              children: [
                page,
                if (widget.open || sheetProgress > 0) ...[
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: still ? endpoint : 0, end: endpoint),
                    duration: washDuration,
                    curve: washCurve,
                    builder: (context, wash, child) => _wash(wash),
                  ),
                  _panel(constraints, sheetProgress),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _wash(double wash) => ModalBarrier(
        color: PantasColors.dark.background.withValues(
          alpha: (widget.readerContents ? .32 : .34) * wash,
        ),
        onDismiss: widget.onDismiss,
        semanticsLabel: 'Close ${widget.label}',
      );

  Widget _panel(BoxConstraints constraints, double sheetProgress) {
    final bookmarks = widget.bookmarks;
    final slideSheet = bookmarks || widget.readerContents;
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: Offset(
          0,
          (slideSheet ? 1.05 : 1) * (1 - sheetProgress),
        ),
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): widget.onDismiss,
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
                          height:
                              bookmarks ? constraints.maxHeight * .74 : null,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification &&
                                  notification.dragDetails != null) {
                                _dragDistance = 0;
                              } else if (notification
                                      is OverscrollNotification &&
                                  notification.dragDetails != null &&
                                  notification.overscroll < 0) {
                                _dragDistance -= notification.overscroll;
                              } else if (notification
                                      is ScrollUpdateNotification &&
                                  notification.dragDetails != null &&
                                  notification.metrics.pixels <
                                      notification.metrics.minScrollExtent) {
                                _dragDistance -= notification.scrollDelta ?? 0;
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
    );
  }
}

/// The sheet and its scrim on the root overlay, for wide web. It animates
/// itself from [open], so the sheet inside the page needs no extra state.
class _SheetWindowLayer extends StatelessWidget {
  const _SheetWindowLayer({
    required this.open,
    required this.still,
    required this.duration,
    required this.curve,
    required this.washDuration,
    required this.washCurve,
    required this.onGone,
    required this.wash,
    required this.panel,
    super.key,
  });

  final bool open;
  final bool still;
  final Duration duration;
  final Curve curve;
  final Duration washDuration;
  final Curve washCurve;
  final VoidCallback onGone;
  final Widget Function(double wash) wash;
  final Widget Function(double progress) panel;

  @override
  Widget build(BuildContext context) {
    final endpoint = open ? 1.0 : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: still ? endpoint : 0, end: endpoint),
      duration: duration,
      curve: curve,
      onEnd: open ? null : onGone,
      builder: (context, progress, _) => Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: still ? endpoint : 0, end: endpoint),
            duration: washDuration,
            curve: washCurve,
            builder: (context, value, _) => wash(value),
          ),
          panel(progress),
        ],
      ),
    );
  }
}
