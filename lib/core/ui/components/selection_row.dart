import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Board checkbox row, including a partial selection for topic groups.
class CheckboxRow extends StatelessWidget {
  const CheckboxRow({
    required this.title,
    required this.selected,
    required this.onTap,
    this.mixed = false,
    this.interactiveContent = false,
    this.content,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PantasSpace.s16,
      vertical: PantasSpace.s14,
    ),
    this.gap = PantasSpace.s12,
    this.minHeight = PantasSize.targetTouch,
    this.hoverFill = true,
    this.markSize = PantasSize.check,
    this.standardDensity = false,
    this.round = false,
    this.squareEdges = false,
    super.key,
  });
  final String title;
  final bool selected;
  final bool mixed;

  /// Wide web, for a row inside a card that clips its own corners: the hover
  /// fill runs edge to edge with square corners, as the web boards draw it.
  final bool squareEdges;

  /// Phone boards (QZ_Picker, ST_Included, BM_Edit) draw this check as a
  /// circle. Wide web keeps the rounded square.
  final bool round;
  final bool interactiveContent;
  final VoidCallback? onTap;
  final Widget? content;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  /// Space between the box and the label.
  final double gap;

  /// Shortest the row may be.
  final double minHeight;

  /// False when the container draws its own hover state.
  final bool hoverFill;

  /// Side of the check box. Nested rows on the web boards use 20.
  final double markSize;

  /// Board rows with fixed heights ignore the desktop compact density.
  final bool standardDensity;

  @override
  Widget build(BuildContext context) => _SelectionRow(
        standardDensity: standardDensity,
        markSize: markSize,
        round: round,
        squareEdges: squareEdges,
        title: title,
        selected: selected,
        mixed: mixed,
        radio: false,
        gap: gap,
        minHeight: minHeight,
        hoverFill: hoverFill,
        interactiveContent: interactiveContent,
        onTap: onTap,
        content: content,
        trailing: trailing,
        padding: padding,
      );
}

/// Board radio row. An optional preview sits above the label and control.
class RadioRow extends StatelessWidget {
  const RadioRow({
    required this.title,
    required this.selected,
    required this.onTap,
    this.content,
    this.trailing,
    this.preview,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PantasSpace.s16,
      vertical: PantasSpace.s14,
    ),
    this.showMark = true,
    super.key,
  });
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? content;
  final Widget? trailing;
  final Widget? preview;
  final EdgeInsetsGeometry padding;

  /// False when the container shows the selection instead (web exam cards).
  final bool showMark;

  @override
  Widget build(BuildContext context) => _SelectionRow(
        title: title,
        selected: selected,
        mixed: false,
        radio: true,
        showMark: showMark,
        onTap: onTap,
        content: content,
        trailing: trailing,
        preview: preview,
        padding: padding,
      );
}

class _SelectionRow extends StatefulWidget {
  const _SelectionRow({
    required this.title,
    required this.selected,
    required this.mixed,
    required this.radio,
    required this.onTap,
    required this.content,
    required this.trailing,
    required this.padding,
    this.preview,
    this.interactiveContent = false,
    this.showMark = true,
    this.gap = PantasSpace.s12,
    this.minHeight = PantasSize.targetTouch,
    this.hoverFill = true,
    this.markSize = PantasSize.check,
    this.standardDensity = false,
    this.round = false,
    this.squareEdges = false,
  });
  final bool squareEdges;
  final bool round;
  final bool standardDensity;
  final double markSize;
  final double gap;
  final double minHeight;
  final bool hoverFill;
  final String title;
  final bool interactiveContent;
  final bool selected;
  final bool mixed;
  final bool radio;
  final bool showMark;
  final VoidCallback? onTap;
  final Widget? content;
  final Widget? trailing;
  final Widget? preview;
  final EdgeInsetsGeometry padding;

  @override
  State<_SelectionRow> createState() => _SelectionRowState();
}

class _SelectionRowState extends State<_SelectionRow> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final c = context.colors;
    final web = context.webPlatform;
    final enabled = w.onTap != null;
    final row = Semantics(
      container: w.interactiveContent,
      explicitChildNodes: w.interactiveContent,
      label: w.interactiveContent ? w.title : null,
      checked: w.selected,
      mixed: w.mixed,
      inMutuallyExclusiveGroup: w.radio,
      enabled: enabled,
      child: TextButton(
        statesController: _states,
        onPressed: w.onTap,
        style: ButtonStyle(
          visualDensity: w.standardDensity ? VisualDensity.standard : null,
          minimumSize: WidgetStatePropertyAll(Size(0, w.minHeight)),
          padding: WidgetStatePropertyAll(w.padding),
          alignment: Alignment.centerLeft,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled) return Colors.transparent;
            // Cards (no mark) show selection on the card, not a row fill.
            if (web &&
                w.showMark &&
                w.hoverFill &&
                w.trailing == null &&
                states.contains(WidgetState.hovered)) {
              return context.webTokens.rowHover;
            }
            if (!web && states.contains(WidgetState.pressed)) {
              return c.divider.withValues(alpha: PantasOpacity.ripple);
            }
            return Colors.transparent;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: w.squareEdges
                  ? BorderRadius.zero
                  : BorderRadius.circular(PantasRadius.sm - PantasSpace.s2),
            ),
          ),
          side: WidgetStateProperty.resolveWith(
            // No ring on a row at rest (O_Consent) or after a click; one
            // shows only while the keyboard drives the focus.
            (states) => webFocusRing(states, c.accent) ?? BorderSide.none,
          ),
        ),
        child: Opacity(
          opacity: enabled ? 1 : PantasOpacity.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (w.preview != null) ...[
                w.preview!,
                const SizedBox(height: PantasSpace.s12),
              ],
              Row(
                children: [
                  if (w.showMark) ...[
                    ExcludeSemantics(
                      child: ListenableBuilder(
                        listenable: _states,
                        builder: (context, _) => _SelectionMark(
                          size: w.markSize,
                          selected: w.selected,
                          mixed: w.mixed,
                          radio: w.radio || (w.round && !context.wideWeb),
                          hovered: enabled &&
                              _states.value.contains(WidgetState.hovered),
                          pressed: enabled &&
                              _states.value.contains(WidgetState.pressed),
                        ),
                      ),
                    ),
                    SizedBox(width: w.gap),
                  ],
                  Expanded(
                    child: w.content ??
                        Text(
                          w.title,
                          style: PantasType.webRowTitleSettings
                              .copyWith(color: c.textPrimary),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final line = Row(
      children: [
        Expanded(
          child: w.interactiveContent ? row : MergeSemantics(child: row),
        ),
        if (w.trailing != null) w.trailing!,
      ],
    );
    // With a trailing control (the picker's chevron) the row's own button stops
    // short of it, so the hover fill covers the whole line instead.
    if (w.trailing != null && enabled && web && w.showMark && w.hoverFill) {
      return _HoverFill(color: context.webTokens.rowHover, child: line);
    }
    return line;
  }
}

/// Fills its whole area while the pointer is anywhere over it.
class _HoverFill extends StatefulWidget {
  const _HoverFill({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  State<_HoverFill> createState() => _HoverFillState();
}

class _HoverFillState extends State<_HoverFill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: ColoredBox(
          color: _hovered ? widget.color : Colors.transparent,
          child: widget.child,
        ),
      );
}

/// The Checkbox and Radio mark: 24 square (radius-sm) or round, a 1.5
/// `border-control` ring when off, `accent-fill` with a 14 `on-accent` check
/// when on. The check pops in over `dur-medium-3` on `motion-enter`.
class _SelectionMark extends StatelessWidget {
  const _SelectionMark({
    required this.selected,
    required this.mixed,
    required this.radio,
    this.hovered = false,
    this.pressed = false,
    this.size = PantasSize.check,
  });
  final bool selected;
  final bool mixed;
  final bool radio;
  final bool hovered;
  final bool pressed;
  final double size;

  /// The check drawn inside the mark, `size-check` 24 to 14.
  // ds-board: check glyph 14 (size-check 24 to 14)
  static const double _glyph = 14;
  static const double _pressedScale = 0.94;

  double get _radius => radio
      ? PantasRadius.full
      : size == PantasSize.check
          ? PantasRadius.sm
          : PantasRadius.sm - PantasSpace.s2;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = selected || mixed;
    final still = MediaQuery.disableAnimationsOf(context);
    return AnimatedScale(
      scale: pressed ? _pressedScale : 1,
      duration: still ? Duration.zero : PantasDurations.short3,
      curve: PantasCurves.move,
      child: Container(
        key: const ValueKey('selection-mark'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: on ? (hovered ? c.accentFillHover : c.accentFill) : null,
          borderRadius: BorderRadius.circular(_radius),
          border: on
              ? null
              : Border.all(
                  color: c.borderControl,
                  width: PantasBorder.ringStrong,
                ),
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: on ? 1 : 0),
          duration: still ? Duration.zero : PantasDurations.medium3,
          curve: PantasCurves.enter,
          builder: (context, value, child) => Opacity(
            key: const ValueKey('selection-opacity'),
            opacity: value.clamp(0, 1),
            child: Transform.scale(
              key: const ValueKey('selection-scale'),
              scale: .4 + .6 * value,
              child: child,
            ),
          ),
          child: Center(
            child: SizedBox.square(
              dimension: _glyph,
              child: CustomPaint(
                painter: _SelectionCheck(c.onAccent, dash: mixed),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The check (`M5 12.5l4.5 4.5L19 7`) or the mixed dash (`M6 12h12`) of the
/// system's 24 unit mask, drawn with a 3.2 round stroke.
class _SelectionCheck extends CustomPainter {
  const _SelectionCheck(this.color, {this.dash = false});
  final Color color;
  final bool dash;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final path = dash
        ? (Path()
          ..moveTo(6 * k, 12 * k)
          ..lineTo(18 * k, 12 * k))
        : (Path()
          ..moveTo(5 * k, 12.5 * k)
          ..lineTo(9.5 * k, 17 * k)
          ..lineTo(19 * k, 7 * k));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SelectionCheck oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dash != dash;
}
