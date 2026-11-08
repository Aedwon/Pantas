import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/tab_bar_visibility.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
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
    // One recipe for every sheet: 450ms in and 400ms out on `motion-slide`,
    // the scrim over 350ms on `motion-fade`.
    final duration = still
        ? Duration.zero
        : widget.open
            ? PantasDurations.long1
            : PantasDurations.drawerClose;
    final endpoint = widget.open ? 1.0 : 0.0;
    const curve = PantasCurves.slide;
    final washDuration = still ? Duration.zero : PantasDurations.switchDuration;
    const washCurve = PantasCurves.fade;
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

  /// The sheet starts just past its own height, as the slide recipe draws it.
  static const double _travel = 1.05;

  Widget get _body => widget.scrollable
      ? SingleChildScrollView(child: widget.child)
      : widget.child;

  Widget _wash(double wash) => ModalBarrier(
        color: context.colors.scrim.withValues(
          alpha: context.colors.scrim.a * wash,
        ),
        onDismiss: widget.onDismiss,
        semanticsLabel: 'Close ${widget.label}',
      );

  Widget _panel(BoxConstraints constraints, double sheetProgress) {
    final bookmarks = widget.bookmarks;
    final colors = context.colors;
    const topRadius = BorderRadius.vertical(
      top: Radius.circular(PantasRadius.lg),
    );
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: Offset(0, _travel * (1 - sheetProgress)),
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
                      color: colors.surfaceModal,
                      borderRadius: topRadius,
                      boxShadow: context.shadows.sheet,
                    ),
                    child: ClipRRect(
                      borderRadius: topRadius,
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const PantasSheetGrabber(),
                                  if (bookmarks)
                                    Expanded(child: _body)
                                  else
                                    Flexible(child: _body),
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

/// The 36 by 5 drag handle: decorative, `divider-strong`, with 8 above it.
/// A sheet laid out by hand uses it too.
class PantasSheetGrabber extends StatelessWidget {
  const PantasSheetGrabber({super.key});

  /// `.sheet__grab` is 36 wide and 5 high. The system sets no token for it, so
  /// this is the one place that states it; hand-laid sheets read it here.
  static const double width = PantasSpace.s32 + PantasSpace.s4;
  static const double height = PantasSpace.s4 + 1;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(top: PantasSpace.s8),
          child: Center(
            child: DecoratedBox(
              key: const ValueKey('pantas-sheet-grabber'),
              decoration: BoxDecoration(
                color: context.colors.dividerStrong,
                borderRadius: BorderRadius.circular(PantasRadius.full),
              ),
              child: const SizedBox(width: width, height: height),
            ),
          ),
        ),
      );
}
