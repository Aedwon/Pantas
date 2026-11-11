import 'dart:async';

import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_tap_area.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/skeleton_fade.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/presentation/widgets/home_columns.dart';

export 'package:pantas/core/ui/web/web_side_overlay.dart';

/// Where Home's plan is on its way in. While [loading] the board shapes
/// stand in; when the plan has [arrived] it fades in over them (the approved
/// splash hand-off). A failure ends loading without arriving, and swaps.
@immutable
class HomeWebLoadingFade {
  const HomeWebLoadingFade({required this.loading, required this.arrived});
  final bool loading;
  final bool arrived;
}

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
    this.loadingFade,
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

  /// Set by Home so the columns cross-fade from the board shapes to the plan.
  /// Null keeps the columns exactly as given.
  final HomeWebLoadingFade? loadingFade;

  Widget _body() {
    final body = HomeWebBody(
      today: today,
      notice: notice,
      performance: performance,
      onRecord: onRecord,
      onTendencies: onTendencies,
    );
    final fade = loadingFade;
    if (fade == null) return body;
    return SkeletonFade(
      loading: fade.loading,
      fade: fade.arrived,
      skeleton: HomeWebBody(
        today: const HomeWebLoading(more: true),
        notice: notice,
        performance: const HomeWebLoading(performance: true),
      ),
      content: body,
    );
  }

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
                const SizedBox(height: PantasSpace.s24),
                if (intro != null) ...[
                  intro!,
                  const SizedBox(height: PantasSpace.s24),
                ],
                _body(),
                if (footer != null) footer!,
              ],
            ),
          ),
        ),
      );
}

/// The two columns under the header: Today (and "More about you" and the
/// notice) on the left, Your performance on the right.
class HomeWebBody extends StatelessWidget {
  const HomeWebBody({
    required this.today,
    this.notice,
    this.performance,
    this.onRecord,
    this.onTendencies,
    super.key,
  });
  final Widget today;
  final Widget? notice;
  final Widget? performance;
  final VoidCallback? onRecord;
  final VoidCallback? onTendencies;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              today,
              if (onRecord != null && onTendencies != null) ...[
                const SizedBox(height: PantasSpace.s28),
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
                    const SizedBox(width: PantasSpace.s14),
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
                const SizedBox(height: PantasSpace.s28),
                notice!,
              ],
            ],
          );
          if (performance == null) {
            return Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: PantasLayout.tabletColumn, child: left),
            );
          }
          if (HomeColumns.stacks(constraints.maxWidth)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                left,
                const SizedBox(height: PantasSpace.s28),
                performance!,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: HomeColumns.primaryWidth(constraints.maxWidth),
                child: left,
              ),
              const SizedBox(width: PantasSpace.s28),
              Expanded(child: performance!),
            ],
          );
        },
      );
}

/// The notice icon, and the indent that lines the detail text under the title.
const double _noticeIconSize = PantasSize.icon + PantasSpace.s2;

/// The notice header's own corner: the card's radius less its 1 px rule.
const double _noticeInnerRadius = PantasRadius.lg - PantasBorder.ring;

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
    return WebCard(
      child: WebRow(
        title: title,
        titleStyle: PantasType.webLead.copyWith(color: t.colors.textPrimary),
        leading: Icon(icon, color: t.colors.accent, size: 24),
        leadingGap: PantasSpace.s14,
        chevron: WebRowChevron.always,
        divider: false,
        onPressed: onPressed,
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
      curve: PantasCurves.house,
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
        : PantasDurations.switchDuration;
    final toggleRadius = BorderRadius.only(
      topLeft: const Radius.circular(_noticeInnerRadius),
      bottomLeft: Radius.circular(
        expanded ? PantasSpace.s0 : _noticeInnerRadius,
      ),
      topRight: const Radius.circular(PantasRadius.sm),
      bottomRight: const Radius.circular(PantasRadius.sm),
    );
    return Container(
      decoration: BoxDecoration(
        color: t.colors.surfaceCard,
        borderRadius: BorderRadius.circular(PantasRadius.lg),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: t.colors.divider),
        borderRadius: BorderRadius.circular(PantasRadius.lg),
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
                    padding: const EdgeInsets.fromLTRB(
                      PantasBorder.ring,
                      PantasBorder.ring,
                      PantasSpace.s0,
                      PantasBorder.ring,
                    ),
                    child: WebKeyboardRing(
                      // The left corners follow the card's own, and the
                      // right ones are rounded like a row's, so the ring is
                      // a closed shape beside the dismiss button.
                      borderRadius: toggleRadius,
                      child: PantasTapArea(
                        onTap: onToggle,
                        borderRadius: toggleRadius,
                        focusRing: false,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 50),
                          child: Padding(
                            // 18 from the card's edge, less the 1 px rule
                            // inset.
                            padding: const EdgeInsets.only(
                              left: PantasSpace.s18 - PantasBorder.ring,
                              right: PantasSpace.s12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  icon ?? PantasIcons.addDate,
                                  size: _noticeIconSize,
                                  color: iconColor ?? t.colors.textSecondary,
                                ),
                                const SizedBox(width: PantasSpace.s12),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: PantasType.webTitleSm
                                        .copyWith(color: t.colors.textPrimary),
                                  ),
                                ),
                                if (detail != null) ...[
                                  const SizedBox(width: PantasSpace.s12),
                                  // One chevron turns, as the phone's does.
                                  AnimatedRotation(
                                    turns: expanded ? .5 : 0,
                                    duration: duration,
                                    curve: PantasCurves.house,
                                    child: Icon(
                                      Icons.expand_more,
                                      size: 16,
                                      color: t.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: PantasSpace.s6),
                  child: PantasIconButton(
                    tooltip: 'Dismiss',
                    onPressed: onClose,
                    glyph: PantasIcons.close,
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
            curve: PantasCurves.house,
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
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s18,
                PantasSpace.s0,
                PantasSpace.s18,
                PantasSpace.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The text lines up under the title: 18 px padding, 22 px
                  // icon and 12 px gap leave 34 px to indent (QA polish board,
                  // option D).
                  if (detail != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: _noticeIconSize + PantasSpace.s12,
                      ),
                      child: Text(detail!, style: t.sub),
                    ),
                  if (editor != null) ...[
                    const SizedBox(height: PantasSpace.s12),
                    editor!,
                  ],
                  const SizedBox(height: PantasSpace.s12),
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
                  const SizedBox(height: PantasSpace.s8),
                  SkeletonCard(height: performance ? 520 : 330),
                  if (more) ...[
                    const SizedBox(height: PantasSpace.s28),
                    const SkeletonCard(height: 96),
                  ],
                ],
              ),
      );
}
