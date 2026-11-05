import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The three Today lists are right drawers. Date editing is a centered dialog.
class HomeWebOverlay extends StatefulWidget {
  const HomeWebOverlay({
    required this.page,
    required this.child,
    required this.open,
    required this.onDismiss,
    required this.label,
    this.drawer = false,
    this.dialogWidth = 560,
    super.key,
  });
  final Widget page;
  final Widget child;
  final bool open;
  final VoidCallback onDismiss;
  final String label;
  final bool drawer;
  final double dialogWidth;
  @override
  State<HomeWebOverlay> createState() => _HomeWebOverlayState();
}

class _HomeWebOverlayState extends State<HomeWebOverlay>
    with SingleTickerProviderStateMixin, OverlayFocusReturn<HomeWebOverlay> {
  final _portal = OverlayPortalController();
  late final AnimationController _motion;

  /// What the overlay shows while it leaves. The parent may stop passing
  /// content once it closes, so the last open widget stays on screen until the
  /// slide ends.
  late HomeWebOverlay _held = widget;

  WebOverlayMotion get _style =>
      _held.drawer ? WebOverlayMotion.drawer : WebOverlayMotion.dialog;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed &&
            !widget.open &&
            _portal.isShowing) {
          _portal.hide();
        }
      });
    if (widget.open) {
      _portal.show();
      _motion.value = 1;
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeWebOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open) _held = widget;
    if (widget.open != oldWidget.open) {
      // The page behind drops its focus while the overlay is open.
      if (widget.open) {
        rememberFocus();
      } else {
        returnFocus();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final still = MediaQuery.disableAnimationsOf(context);
        _motion
          ..duration = _style.open
          ..reverseDuration = _style.close;
        if (widget.open) {
          _portal.show();
          if (still) {
            _motion.value = 1;
          } else {
            unawaited(_motion.forward());
          }
        } else if (_portal.isShowing) {
          if (still || _motion.value == 0) {
            _motion.value = 0;
            _portal.hide();
          } else {
            unawaited(_motion.reverse());
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !widget.open,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && widget.open) widget.onDismiss();
        },
        child: OverlayPortal(
          overlayLocation: OverlayChildLocation.rootOverlay,
          controller: _portal,
          overlayChildBuilder: _overlay,
          child: ExcludeFocus(
            excluding: widget.open,
            child: ExcludeSemantics(excluding: widget.open, child: widget.page),
          ),
        ),
      );

  Widget _overlay(BuildContext context) {
    final held = _held;
    final style = _style;
    return Positioned.fill(
      child: Stack(
        children: [
          AnimatedModalBarrier(
            color:
                _motion.drive(CurveTween(curve: style.routeScrimCurve)).drive(
                      ColorTween(
                        begin: Colors.black.withValues(alpha: 0),
                        end: Colors.black.withValues(alpha: .28),
                      ),
                    ),
            dismissible: widget.open,
            onDismiss: widget.onDismiss,
            semanticsLabel: 'Close ${held.label}',
          ),
          Align(
            alignment: held.drawer ? Alignment.centerRight : Alignment.center,
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
                    child: Focus(
                      child: Semantics(
                        scopesRoute: true,
                        explicitChildNodes: true,
                        namesRoute: true,
                        label: held.label,
                        child: Material(
                          key: ValueKey(
                            held.drawer ? 'home-web-drawer' : 'home-web-dialog',
                          ),
                          color: held.drawer
                              ? context.webTokens.colors.background
                              : context.webTokens.colors.surface,
                          borderRadius:
                              held.drawer ? null : BorderRadius.circular(22),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: held.drawer ? 440 : held.dialogWidth,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.sizeOf(context).height -
                                    (held.drawer ? 0 : 48),
                              ),
                              child: held.drawer
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        held.child,
                                        // Board `.ib`: 44 px, centred on
                                        // the header's title block.
                                        Positioned(
                                          top: 26.5,
                                          right: 16,
                                          child: IconButton(
                                            tooltip: 'Close',
                                            onPressed: widget.onDismiss,
                                            style: IconButton.styleFrom(
                                              fixedSize: const Size(44, 44),
                                              visualDensity:
                                                  VisualDensity.standard,
                                            ),
                                            icon: const Icon(
                                              Icons.close,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        held.child,
                                        Positioned(
                                          top: 14,
                                          right: 16,
                                          child: IconButton(
                                            tooltip: 'Close',
                                            onPressed: widget.onDismiss,
                                            icon: const Icon(
                                              Icons.close,
                                              size: 18,
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

/// Board drawer rows: a 22 px box holding a 20 px ring or a 22 px check.
class HomeDrawerRing extends StatelessWidget {
  const HomeDrawerRing(this.fraction, {required this.done, super.key});
  final double fraction;
  final bool done;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 22,
        child: done
            ? const FittedBox(child: CheckMark())
            : Center(
                child: fraction > 0
                    ? ProgressRing(fraction: fraction, size: 21)
                    : ProgressRing(
                        fraction: 0,
                        size: 20,
                        emptyStrokeWidth: 2,
                        emptyTrackColor: context.webTokens.dark
                            ? null
                            : const Color(0xFFD1D1D6),
                      ),
              ),
      );
}

/// One row of the Reviews and New questions drawers, on Home and on the Quiz
/// tab: the title, the ring of what is done and the count.
class HomeDrawerQuestionRow extends StatelessWidget {
  const HomeDrawerQuestionRow({
    required this.title,
    required this.done,
    required this.total,
    this.last = false,
    super.key,
  });
  final String title;
  final int done;
  final int total;
  final bool last;

  @override
  Widget build(BuildContext context) => WebRow(
        title: title,
        wrapTitle: true,
        titleStyle: context.webTokens.style(16, height: 1.3),
        boardMetrics: true,
        divider: !last,
        value: '$total',
        compact: true,
        leading: HomeDrawerRing(
          total == 0 ? 0 : done / total,
          done: done == total,
        ),
      );
}

class HomeWebQuestionsSheet extends StatelessWidget {
  const HomeWebQuestionsSheet({
    required this.title,
    required this.done,
    required this.total,
    required this.rows,
    required this.startLabel,
    this.onStart,
    this.busy = false,
    this.failure,
    super.key,
  });
  final String title;
  final int done;
  final int total;
  final List<Widget> rows;
  final String startLabel;
  final VoidCallback? onStart;
  final bool busy;
  final Widget? failure;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          if (onStart != null && !busy)
            const SingleActivator(
              LogicalKeyboardKey.enter,
              includeRepeats: false,
            ): onStart!,
        },
        child: Focus(
          autofocus: true,
          skipTraversal: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WebText(title, kind: WebTextKind.h2),
                    Text(
                      '$done of $total${title == 'Lessons' ? ' read' : ''}',
                      style: context.webTokens.sub,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: title == 'Lessons'
                        ? Column(mainAxisSize: MainAxisSize.min, children: rows)
                        : WebCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: rows,
                            ),
                          ),
                  ),
                ),
              ),
              if (failure != null) failure!,
              if (onStart != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: context.webTokens.colors.separator,
                        width: webHairline(context),
                      ),
                    ),
                  ),
                  child: WebButton(
                    label: startLabel,
                    keyHint: 'Enter',
                    large: true,
                    expand: true,
                    onPressed: onStart,
                    busy: busy,
                  ),
                ),
            ],
          ),
        ),
      );
}
