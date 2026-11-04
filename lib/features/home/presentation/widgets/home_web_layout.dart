import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Home's two canvas columns. The shell already owns the sidebar.
class HomeWebLayout extends StatelessWidget {
  const HomeWebLayout({
    required this.header,
    required this.today,
    this.intro,
    this.notice,
    this.performance,
    this.onRecord,
    this.onTendencies,
    this.footer,
    super.key,
  });
  final Widget header;
  final Widget today;

  /// Spans both columns under the header (the exam day title).
  final Widget? intro;
  final Widget? notice;
  final Widget? performance;
  final VoidCallback? onRecord;
  final VoidCallback? onTendencies;

  /// Sits at the very bottom, under both columns.
  final Widget? footer;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        // The shell ends at the window bottom, so rows scroll to the edge and
        // the page's own margin sits after the last one.
        padding: EdgeInsets.only(bottom: context.webPageBottomInset),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 26),
                if (intro != null) ...[intro!, const SizedBox(height: 26)],
                LayoutBuilder(
                  builder: (context, constraints) {
                    final left = Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        today,
                        if (onRecord != null && onTendencies != null) ...[
                          const SizedBox(height: 28),
                          const WebText(
                            'More about you',
                            kind: WebTextKind.eyebrow,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _MoreRow(
                                  title: 'Your record',
                                  icon: Icons.show_chart,
                                  onPressed: onRecord!,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _MoreRow(
                                  title: 'Your tendencies',
                                  icon: Icons.auto_awesome_outlined,
                                  onPressed: onTendencies!,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // The board puts every notice after "More about you".
                        if (notice != null) ...[
                          const SizedBox(height: 28),
                          notice!,
                        ],
                      ],
                    );
                    if (performance == null) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(width: 640, child: left),
                      );
                    }
                    if (constraints.maxWidth < 848) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          left,
                          const SizedBox(height: 28),
                          performance!,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width:
                              480 + (constraints.maxWidth - 848) * 1.45 / 2.45,
                          child: left,
                        ),
                        const SizedBox(width: 28),
                        Expanded(child: performance!),
                      ],
                    );
                  },
                ),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      );
}

/// "More about you" card: white, 16 px radius, as on the Home (Main) board,
/// with the row hover fill.
class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.title,
    required this.icon,
    required this.onPressed,
  });
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: t.dark ? Border.all(color: t.cardEdge) : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 60)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.fromLTRB(20, 18, 18, 18),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.hovered) || webKeyboardFocus(s)
                ? t.rowHover
                : t.dark
                    ? t.colors.surface
                    : Colors.white,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          side: WidgetStateProperty.resolveWith(
            (s) => webFocusRing(s, t.colors.accent),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: t.colors.accent, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: t.style(17, color: t.colors.label)),
            ),
            const WebChevron(),
          ],
        ),
      ),
    );
  }
}

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

/// Scrolls so the whole box at [context] is in view, with the page's bottom
/// margin under it. `Scrollable.ensureVisible` stops at the window edge, which
/// leaves a card against it while the page end has room to spare.
void _revealWithMargin(BuildContext context, Duration duration) {
  final scrollable = Scrollable.maybeOf(context);
  final box = context.findRenderObject();
  if (scrollable == null || box is! RenderBox) return;
  final viewport = RenderAbstractViewport.maybeOf(box);
  if (viewport == null) return;
  final position = scrollable.position;
  final target =
      (viewport.getOffsetToReveal(box, 1).offset + context.webPageBottomInset)
          .clamp(position.minScrollExtent, position.maxScrollExtent);
  if (target <= position.pixels) return;
  unawaited(
    position.animateTo(
      target,
      duration: duration,
      curve: PantasCurves.houseOut,
    ),
  );
}

class HomeWebNotice extends StatelessWidget {
  const HomeWebNotice({
    required this.title,
    required this.onClose,
    this.detail,
    this.expanded = false,
    this.onToggle,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.editor,
    this.icon,
    this.iconColor,
    super.key,
  });
  final String title;
  final String? detail;
  final bool expanded;
  final VoidCallback onClose;
  final VoidCallback? onToggle;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? editor;
  final IconData? icon;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    // Board `.notice`: a 1 px inset rule drawn over the card, so it adds no
    // layout; `.nh` is 52 px tall with 18 px left and 6 px right padding;
    // `.nb` has 18 px sides, 16 px bottom and 12 px between its parts.
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 350);
    return Container(
      decoration: BoxDecoration(
        color: t.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: t.colors.separator),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              children: [
                Expanded(
                  // The hover tint is clipped to the card's own top corner, and
                  // runs to the dismiss button.
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      bottomLeft: Radius.circular(expanded ? 0 : 16),
                    ),
                    child: TextButton(
                      onPressed: onToggle,
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        // The web theme's compact density (desktop browsers)
                        // would shave the 52 px minimum and leave a band of
                        // card above the hover tint (3K-3).
                        visualDensity: VisualDensity.standard,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 52),
                        padding: const EdgeInsets.only(left: 18, right: 12),
                        // The hover tint follows the card's own corners.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            bottomLeft: Radius.circular(expanded ? 0 : 16),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon ?? PantasIcons.addDate,
                            size: 22,
                            color: iconColor ?? t.colors.secondaryLabel,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: t.style(16, weight: FontWeight.w600),
                            ),
                          ),
                          if (detail != null) ...[
                            const SizedBox(width: 12),
                            // One chevron turns, as the phone's does.
                            AnimatedRotation(
                              turns: expanded ? .5 : 0,
                              duration: duration,
                              curve: PantasCurves.houseOut,
                              child: Icon(
                                Icons.expand_more,
                                size: 16,
                                color: t.colors.secondaryLabel,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox.square(
                    dimension: 44,
                    child: IconButton(
                      tooltip: 'Dismiss',
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        size: 16,
                        color: t.colors.secondaryLabel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The detail opens and closes as the phone's strip does: height and
          // opacity together.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: expanded ? 1 : 0, end: expanded ? 1 : 0),
            duration: duration,
            curve: PantasCurves.houseOut,
            // The notice sits at the foot of Home. Once it has opened, scroll
            // so its buttons are not left below the window, with the page's
            // own bottom margin under the card (3K-2).
            onEnd: expanded && Scrollable.maybeOf(context) != null
                ? () => WidgetsBinding.instance.addPostFrameCallback((_) {
                      // After the layout of the finished height.
                      if (!context.mounted) return;
                      _revealWithMargin(context, duration);
                    })
                : null,
            builder: (context, value, child) => !expanded && value == 0
                ? const SizedBox.shrink()
                : ClipRect(
                    child: Align(
                      heightFactor: value,
                      child: Opacity(
                        opacity: value,
                        child: ExcludeFocus(
                          excluding: !expanded,
                          child: ExcludeSemantics(
                            excluding: !expanded,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The text lines up under the title: 18 px padding, 22 px
                  // icon and 12 px gap leave 34 px to indent (QA polish board,
                  // option D).
                  if (detail != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 34),
                      child: Text(detail!, style: t.sub),
                    ),
                  if (editor != null) ...[
                    const SizedBox(height: 12),
                    editor!,
                  ],
                  const SizedBox(height: 12),
                  // The buttons sit at the right edge, the quiet one first.
                  Wrap(
                    spacing: 12,
                    alignment: WrapAlignment.end,
                    children: [
                      if (secondaryLabel != null)
                        WebButton(
                          label: secondaryLabel!,
                          variant: WebButtonVariant.tertiary,
                          onPressed: onSecondary,
                        ),
                      if (primaryLabel != null)
                        WebButton(
                          label: primaryLabel!,
                          variant: WebButtonVariant.secondary,
                          onPressed: onPrimary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// L_PlanSlow. Shapes appear only after 300ms. No invented progress or
/// loading text.
class HomeWebLoading extends StatelessWidget {
  const HomeWebLoading({
    this.performance = false,
    this.header = false,
    this.more = false,
    super.key,
  });
  final bool performance;
  final bool header;
  final bool more;

  @override
  Widget build(BuildContext context) => SkeletonPulse(
        child: header
            ? const SkeletonCard(height: 66)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SkeletonBlock(
                      width: performance ? 140 : 80,
                      height: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SkeletonCard(height: performance ? 520 : 330),
                  if (more) ...[
                    const SizedBox(height: 28),
                    const SkeletonCard(height: 96),
                  ],
                ],
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
