import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
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
    this.scrollable = true,
    super.key,
  });

  final Widget page;
  final Widget child;
  final String label;
  final bool open;
  final VoidCallback onDismiss;
  final bool bookmarks;
  final bool scrollable;

  @override
  State<PantasSheet> createState() => _PantasSheetState();
}

class _PantasSheetState extends State<PantasSheet> {
  double _dragDistance = 0;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final bookmarks = widget.bookmarks;
    final duration = Duration(
      milliseconds: bookmarks
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
          curve: bookmarks ? PantasCurves.slideC : PantasCurves.houseOut,
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
                      : Duration(milliseconds: bookmarks ? 350 : 300),
                  curve: bookmarks ? PantasCurves.ease : PantasCurves.linear,
                  builder: (context, wash, child) => ModalBarrier(
                    color: PantasColors.dark.background
                        .withValues(alpha: .34 * wash),
                    onDismiss: widget.onDismiss,
                    semanticsLabel: 'Close ${widget.label}',
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionalTranslation(
                    translation:
                        Offset(0, (bookmarks ? 1.05 : 1) * (1 - sheetProgress)),
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.escape):
                            widget.onDismiss,
                      },
                      child: FocusScope(
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
                                      maxHeight: constraints.maxHeight,
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
