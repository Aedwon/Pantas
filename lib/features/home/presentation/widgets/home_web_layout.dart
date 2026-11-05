import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

export 'package:pantas/core/ui/web/web_side_overlay.dart';

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
                  // One pixel inside the card's own rule on its three sides, so
                  // the keyboard ring is whole instead of half under it
                  // (4N-7). The hover tint still reaches the rule, and runs to
                  // the dismiss button.
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(1, 1, 0, 1),
                    child: TextButton(
                      onPressed: onToggle,
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        // The web theme's compact density (desktop browsers)
                        // would shave the 52 px minimum and leave a band of
                        // card above the hover tint (3K-3).
                        visualDensity: VisualDensity.standard,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.only(left: 17, right: 12),
                        // The left corners follow the card's own, and the
                        // right ones are rounded like a row's, so the ring is
                        // a closed shape beside the dismiss button.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            bottomLeft: Radius.circular(expanded ? 0 : 15),
                            topRight: const Radius.circular(10),
                            bottomRight: const Radius.circular(10),
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
                        // Board `.btn3`: 16 px at the sides.
                        WebButton(
                          label: secondaryLabel!,
                          variant: WebButtonVariant.tertiary,
                          sidePadding: 16,
                          onPressed: onSecondary,
                        ),
                      if (primaryLabel != null)
                        // Board `.btn2`: 20 px at the sides, so "Add Exam
                        // Date" is 156 px wide (4N-3).
                        WebButton(
                          label: primaryLabel!,
                          variant: WebButtonVariant.secondary,
                          sidePadding: 20,
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
