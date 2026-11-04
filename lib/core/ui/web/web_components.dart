import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

enum WebButtonVariant {
  primary,
  secondary,
  tertiary,
  white,
  danger,
  dangerOutline
}

/// Canvas buttons are natural width, including when placed in a wide column.
class WebButton extends StatelessWidget {
  const WebButton({
    required this.label,
    this.onPressed,
    this.variant = WebButtonVariant.primary,
    this.large = false,
    this.pill = false,
    this.keyHint,
    this.busy = false,
    this.tall = false,
    this.expand = false,
    this.icon,
    this.redText = false,
    this.height,
    this.fontSize,
    this.radius,
    super.key,
  });
  final String label;

  /// Board overrides for a smaller button: its height, text size and radius.
  final double? height;
  final double? fontSize;
  final double? radius;

  /// A tertiary button whose label is red (board `.btn3.red`).
  final bool redText;

  /// Drawn before the label, 8 px apart (board `.btn3` with an icon).
  final Widget? icon;
  final VoidCallback? onPressed;
  final WebButtonVariant variant;
  final bool large;
  final bool pill;
  final String? keyHint;
  final bool busy;

  /// 48 px onboarding height with the board's padding.
  final bool tall;

  /// Full width of the parent, label centered (board `width: 100%`).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    final showKeyHint = keyHint != null && WebKeyboardHints.visibleOf(context);
    final solid = variant == WebButtonVariant.primary ||
        variant == WebButtonVariant.danger;
    final danger = variant == WebButtonVariant.danger ||
        variant == WebButtonVariant.dangerOutline;
    final foreground = solid
        ? Colors.white
        : danger || redText
            ? c.wrongText
            : variant == WebButtonVariant.secondary
                ? t.tintText
                : variant == WebButtonVariant.tertiary
                    ? c.secondaryLabel
                    : c.label;
    Color background(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled) && !busy) {
        return t.disabledBackground;
      }
      final hover = states.contains(WidgetState.hovered);
      return switch (variant) {
        WebButtonVariant.primary => hover ? t.accentHover : c.accentFill,
        WebButtonVariant.danger => hover ? t.dangerHover : t.dangerFill,
        WebButtonVariant.secondary => hover ? t.secondaryHover : c.accentTint,
        WebButtonVariant.white => hover ? t.rowHover : c.surface,
        WebButtonVariant.tertiary =>
          hover ? t.disabledBackground : Colors.transparent,
        WebButtonVariant.dangerOutline =>
          hover ? c.wrongTint : Colors.transparent,
      };
    }

    final radius = this.radius ??
        (pill
            ? 99.0
            : large
                ? 14.0
                : 12.0);
    final height = this.height ??
        (tall
            ? 48.0
            : pill
                ? 46.0
                : large
                    ? 50.0
                    : 44.0);
    final button = TextButton(
      onPressed: busy ? null : onPressed,
      style: ButtonStyle(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.quick,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        minimumSize: WidgetStatePropertyAll(
          Size(expand ? double.infinity : 0, height),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.only(
            left: tall
                ? switch (variant) {
                    WebButtonVariant.primary => 22,
                    WebButtonVariant.tertiary => 16,
                    WebButtonVariant.white => 18,
                    _ => 18,
                  }
                : pill
                    ? 22
                    : variant == WebButtonVariant.tertiary
                        ? 14
                        : variant == WebButtonVariant.secondary ||
                                variant == WebButtonVariant.white ||
                                variant == WebButtonVariant.dangerOutline
                            ? 18
                            : 20,
            right: tall && variant == WebButtonVariant.tertiary
                ? 16
                : pill || showKeyHint
                    ? 14
                    : variant == WebButtonVariant.tertiary
                        ? 14
                        : variant == WebButtonVariant.secondary ||
                                variant == WebButtonVariant.white ||
                                variant == WebButtonVariant.dangerOutline
                            ? 18
                            : 20,
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(background),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled) && !busy
              ? t.disabledText
              : foreground,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStateProperty.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.focused)
                ? c.accent
                : variant == WebButtonVariant.dangerOutline
                    ? c.destructive
                    : variant == WebButtonVariant.white
                        ? (tall
                            ? Colors.transparent
                            : t.dark
                                ? t.cardEdge
                                : c.separator)
                        : Colors.transparent,
            width: s.contains(WidgetState.focused) ? 2 : 1,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        textStyle: WidgetStatePropertyAll(
          t.style(
            fontSize ?? (large ? 17 : 16),
            weight: FontWeight.w600,
            height: 1.2,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (busy) ...[
            SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
                value: MediaQuery.disableAnimationsOf(context) ? 1 : null,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Flexible(child: Text(label)),
          if (showKeyHint) ...[
            const SizedBox(width: 12),
            WebKeyHint(
              keyHint!,
              onButton: variant != WebButtonVariant.tertiary,
              enabled: onPressed != null,
            ),
          ],
        ],
      ),
    );
    // A button shrinks to 96% under a press, as the phone's chip does.
    final pressable = PressScale(
      scale: .96,
      enabled: onPressed != null && !busy,
      child: button,
    );
    if (expand) return pressable;
    return Align(
      widthFactor: 1,
      heightFactor: 1,
      alignment: Alignment.centerLeft,
      child: pressable,
    );
  }
}

class WebKeyHint extends StatelessWidget {
  const WebKeyHint(
    this.label, {
    this.onButton = false,
    this.keyboard = true,
    this.enabled = true,
    super.key,
  });
  final String label;
  final bool onButton;
  final bool keyboard;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    if (keyboard && !WebKeyboardHints.visibleOf(context)) {
      return const SizedBox.shrink();
    }
    final t = context.webTokens;
    return ExcludeSemantics(
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: onButton ? 7 : 6, vertical: 2),
        decoration: BoxDecoration(
          color:
              onButton && enabled ? Colors.white.withValues(alpha: .16) : null,
          borderRadius: BorderRadius.circular(onButton ? 6 : 5),
          border:
              !onButton || !enabled ? Border.all(color: t.strongDivider) : null,
        ),
        child: Text(
          label,
          style: t.style(
            onButton ? 12 : 11,
            height: 1.2,
            weight: FontWeight.w600,
            color: onButton && enabled
                ? Colors.white.withValues(alpha: .88)
                : t.dark
                    ? t.colors.secondaryLabel
                    : t.colors.tertiaryLabel,
          ),
        ),
      ),
    );
  }
}

class WebTextLink extends StatefulWidget {
  const WebTextLink({
    required this.label,
    required this.onPressed,
    this.arrow = true,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;

  /// The board's Home links are text only; other pages keep the arrow.
  final bool arrow;
  @override
  State<WebTextLink> createState() => _WebTextLinkState();
}

class _WebTextLinkState extends State<WebTextLink> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor:
              _hover && !t.dark ? const Color(0xFF075C4E) : t.colors.accent,
          overlayColor: Colors.transparent,
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: t.style(15, weight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label),
            if (widget.arrow) ...[
              const SizedBox(width: 4),
              AnimatedContainer(
                transform: Matrix4.translationValues(_hover ? 4 : 0, 0, 0),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 150),
                child: const Text('→'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WebCard extends StatelessWidget {
  const WebCard({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 18,
    this.selected = false,
    this.minHeight,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Picked card (board OB_Picker): accent tint and a 2 px accent outline.
  final bool selected;

  /// Shortest the card may be; its child is centered vertically.
  final double? minHeight;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    // Item 17, demo 4: the tint and the outline fade 160 ms on the ease. The
    // dark edge goes at once, since it takes up room the outline would cover.
    return FadingColor(
      color: selected
          ? (t.dark ? t.colors.accentTint : const Color(0xFFE4F1EE))
          : t.colors.surface,
      builder: (context, fill, _) => FadingColor(
        color: t.colors.accent.withValues(alpha: selected ? 1 : 0),
        builder: (context, outline, _) => Container(
          clipBehavior: Clip.antiAlias,
          constraints:
              minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
          alignment: minHeight == null ? null : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: t.dark && !selected ? Border.all(color: t.cardEdge) : null,
          ),
          // Drawn on top like the board inset outline; content stays put.
          foregroundDecoration: outline.a == 0
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: outline, width: 2),
                ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// One hairline at device resolution: the board's `.5px` rule is a whole
/// device pixel in the browser, not a half-covered pair.
double webHairline(BuildContext context) =>
    1 / MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0);

/// The board's 16 px row chevron (`m9.5 5.5 6.5 6.5-6.5 6.5`, 2.2 stroke).
class WebChevron extends StatelessWidget {
  const WebChevron({this.color, super.key});
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return ExcludeSemantics(
      child: CustomPaint(
        size: const Size.square(16),
        painter: _ChevronPainter(
          color ?? (t.dark ? t.colors.tertiaryLabel : const Color(0xFFB8B8BD)),
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.drawPath(
      Path()
        ..moveTo(9.5 * k, 5.5 * k)
        ..lineTo(16 * k, 12 * k)
        ..lineTo(9.5 * k, 18.5 * k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) => old.color != color;
}

/// Row chevron: absent, shown on hover only (board `.cv`), or always shown.
enum WebRowChevron { none, hover, always }

class WebRow extends StatefulWidget {
  const WebRow({
    required this.title,
    this.subtitle,
    this.wrapTitle = false,
    this.mathTitle = false,
    this.titleStyle,
    this.horizontalPadding = 20,
    this.titleColor,
    this.titleSuffix,
    this.value,
    this.valueStyle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.selected = false,
    this.dimmed = false,
    this.compact = false,
    this.divider = true,
    this.boardMetrics = false,
    this.leadingGap = 16,
    this.chevron = WebRowChevron.none,
    this.verticalPadding,
    this.subtitleStyle,
    this.enterFromSelected,
    this.selectedValueColor,
    super.key,
  });
  final String title;
  final bool wrapTitle;

  /// The title is a question stem that may hold `\$...\$` maths.
  final bool mathTitle;
  final String? subtitle;
  final TextStyle? titleStyle;
  final double horizontalPadding;
  final Color? titleColor;
  final Widget? titleSuffix;
  final String? value;
  final TextStyle? valueStyle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool selected;
  final bool dimmed;
  final bool compact;
  final bool divider;

  /// Home's rows: the board's line heights (22 and 18 px) and its one-pixel
  /// hairline, so a row is 71 px tall.
  final bool boardMetrics;

  /// Space between the leading widget and the title.
  final double leadingGap;
  final WebRowChevron chevron;

  /// Overrides the 12 (compact) or 15 px padding above and below the content.
  final double? verticalPadding;

  /// Overrides the 14 px secondary subtitle (Settings rows use 13 px).
  final TextStyle? subtitleStyle;

  /// Whether this row was selected just before it was built. A page that
  /// rebuilds its whole list (Settings opens each row as its own page) passes
  /// the earlier choice, so the tint and value color fade from it instead of
  /// appearing at once.
  final bool? enterFromSelected;

  /// The color the value text takes while the row is selected. The row fades
  /// the value between its [valueStyle] color and this one, with the tint.
  final Color? selectedValueColor;
  @override
  State<WebRow> createState() => _WebRowState();
}

class _WebRowState extends State<WebRow> {
  Widget _title(WebRow w, bool large, double? lineHeight, WebTokens t) {
    final lines = large || w.wrapTitle ? null : 1;
    final overflow =
        large || w.wrapTitle ? TextOverflow.visible : TextOverflow.ellipsis;
    final style =
        w.titleStyle ?? t.style(17, color: w.titleColor, height: lineHeight);
    return w.mathTitle
        ? MathText(w.title, style: style, maxLines: lines, overflow: overflow)
        : Text(w.title, maxLines: lines, overflow: overflow, style: style);
  }

  final _states = WidgetStatesController();

  // Only a row that is, or has been, selected carries the tint fade. Most rows
  // in a list never are, and they pay nothing for it.
  late bool _tracked = widget.selected || widget.enterFromSelected != null;
  late bool _from = widget.enterFromSelected ?? widget.selected;

  @override
  void didUpdateWidget(WebRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_tracked && oldWidget.selected != widget.selected) {
      _tracked = true;
      _from = oldWidget.selected;
    }
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // One tree for every row, so the first selection flip does not remount the
    // button and drop its focus and hover. A row that never is selected holds
    // a tween that does not move, and runs no animation.
    // Item 17, demo 4: the tint and the value color fade together, 160 ms on
    // the ease. Nothing else moves, and only this row rebuilds.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _from ? 1 : 0, end: widget.selected ? 1 : 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : PantasDurations.quick,
      curve: PantasCurves.ease,
      builder: (context, selection, _) => _row(context, selection),
    );
  }

  Widget _row(BuildContext context, double selection) {
    final t = context.webTokens;
    final w = widget;
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final lineHeight = w.boardMetrics ? 1.3 : null;
    final hairline = w.boardMetrics ? webHairline(context) : .5;
    final baseValue = w.valueStyle ?? t.sub;
    final valueStyle = w.selectedValueColor == null
        ? baseValue
        : baseValue.copyWith(
            color: Color.lerp(
              baseValue.color,
              w.selectedValueColor,
              selection,
            ),
          );
    final tint = t.colors.accentTint;
    final button = TextButton(
      statesController: _states,
      onPressed: w.dimmed ? null : w.onPressed,
      style: ButtonStyle(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 150),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: w.horizontalPadding),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 0)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        // A selected row's tint is the layer behind, which fades.
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => !w.selected &&
                  (s.contains(WidgetState.hovered) ||
                      s.contains(WidgetState.focused))
              ? t.rowHover
              : Colors.transparent,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      child: Row(
        children: [
          if (w.leading != null) ...[
            w.leading!,
            SizedBox(width: w.leadingGap),
          ],
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: w.verticalPadding ?? (w.compact ? 12 : 15),
              ),
              decoration: BoxDecoration(
                border: w.divider
                    ? Border(
                        bottom: BorderSide(
                          color: t.colors.separator,
                          width: hairline,
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (w.titleSuffix == null)
                          _title(w, large, lineHeight, t)
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: _title(w, large, lineHeight, t),
                              ),
                              const SizedBox(width: 6),
                              w.titleSuffix!,
                            ],
                          ),
                        if (w.subtitle != null)
                          Text(
                            w.subtitle!,
                            maxLines: large || w.wrapTitle ? null : 1,
                            overflow: large || w.wrapTitle
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: w.subtitleStyle ??
                                t.style(
                                  14,
                                  color: t.colors.secondaryLabel,
                                  height: lineHeight,
                                ),
                          ),
                        if (large && w.value != null)
                          Text(w.value!, style: valueStyle),
                      ],
                    ),
                  ),
                  if (!large && w.value != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      w.value!,
                      style: valueStyle,
                      textAlign: TextAlign.end,
                    ),
                  ],
                  if (w.trailing != null) ...[
                    const SizedBox(width: 12),
                    w.trailing!,
                  ],
                  if (w.chevron != WebRowChevron.none) ...[
                    const SizedBox(width: 12),
                    if (w.chevron == WebRowChevron.always)
                      const WebChevron()
                    else
                      ListenableBuilder(
                        listenable: _states,
                        builder: (context, child) => AnimatedOpacity(
                          opacity: _states.value
                                      .contains(WidgetState.hovered) ||
                                  _states.value.contains(WidgetState.focused)
                              ? 1
                              : 0,
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : PantasDurations.quick,
                          curve: PantasCurves.ease,
                          child: child,
                        ),
                        child: const WebChevron(),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return Opacity(
      opacity: w.dimmed ? .45 : 1,
      child: Semantics(
        selected: w.selected,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: _tracked
                  ? IgnorePointer(
                      child: ColoredBox(
                        color: tint.withValues(alpha: tint.a * selection),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            button,
          ],
        ),
      ),
    );
  }
}

class WebSegmentedControl extends StatelessWidget {
  const WebSegmentedControl({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.suffixes,
    this.accentLabels = false,
    super.key,
  })  : assert(labels.length > 1, 'At least two segments are required.'),
        assert(
          suffixes == null || suffixes.length == labels.length,
          'Suffixes must match labels.',
        ),
        assert(
          selected >= 0 && selected < labels.length,
          'Selected segment must exist.',
        );
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final List<Widget?>? suffixes;

  /// Performance's switch (board `.seg button`) sets every label in the accent.
  final bool accentLabels;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.disabledBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cell = constraints.maxWidth / labels.length;
            return Stack(
              children: [
                // One thumb slides under the labels (item 17, demo 7): 240 ms
                // on the shared ease. Only a translation changes.
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: IgnorePointer(
                      child: SlidingMarker(
                        key: const ValueKey('segmented-control-thumb'),
                        offsets: [
                          for (var i = 0; i < labels.length; i++) i * cell,
                        ],
                        lengths: List.filled(labels.length, cell),
                        index: selected,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: t.segmentOn,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Expanded(
                        child: Semantics(
                          selected: selected == i,
                          child: TextButton(
                            onPressed: () => onChanged(i),
                            style: ButtonStyle(
                              animationDuration:
                                  MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 150),
                              minimumSize:
                                  const WidgetStatePropertyAll(Size(0, 34)),
                              visualDensity: VisualDensity.standard,
                              overlayColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: const WidgetStatePropertyAll(
                                EdgeInsets.symmetric(horizontal: 12),
                              ),
                              foregroundColor: WidgetStatePropertyAll(
                                accentLabels ? t.colors.accent : t.colors.label,
                              ),
                              backgroundColor: const WidgetStatePropertyAll(
                                Colors.transparent,
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              textStyle: WidgetStatePropertyAll(
                                t.style(
                                  14,
                                  weight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            child: suffixes?[i] == null
                                ? Text(labels[i])
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(child: Text(labels[i])),
                                      if (suffixes?[i] != null) ...[
                                        const SizedBox(width: 6),
                                        suffixes![i]!,
                                      ],
                                    ],
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum WebOptionState { normal, selected, right, wrong, dimmed, readOnly }

class WebAnswerOption extends StatelessWidget {
  const WebAnswerOption({
    required this.letter,
    required this.child,
    this.state = WebOptionState.normal,
    this.onPressed,
    this.revealProgress = 1,
    this.revealFromSelected = false,
    this.badgeProgress = 1,
    this.badgeScale,
    super.key,
  });
  final bool revealFromSelected;
  final double revealProgress;
  final double badgeProgress;
  final double? badgeScale;
  final String letter;
  final Widget child;
  final WebOptionState state;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    final wrong = state == WebOptionState.wrong;
    final right = state == WebOptionState.right;
    final selected = state == WebOptionState.selected;
    final filled = selected || right || wrong;
    final active = state == WebOptionState.normal || selected;
    final border = right || wrong
        ? Color.lerp(
            revealFromSelected ? c.accent : Colors.transparent,
            wrong ? c.destructive : c.accent,
            revealProgress,
          )!
        : c.accent;
    return Opacity(
      opacity: state == WebOptionState.dimmed ? .42 : 1,
      child: Semantics(
        selected: selected,
        label: right
            ? 'Correct'
            : wrong
                ? 'Wrong'
                : null,
        child: TextButton(
          onPressed: active ? onPressed : null,
          style: ButtonStyle(
            animationDuration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            minimumSize:
                const WidgetStatePropertyAll(Size(double.infinity, 64)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
            padding: const WidgetStatePropertyAll(
              EdgeInsets.fromLTRB(16, 14, 18, 14),
            ),
            backgroundColor: WidgetStatePropertyAll(
              right
                  ? Color.lerp(c.surface, c.accentTint, revealProgress)
                  : wrong
                      ? Color.lerp(c.surface, c.wrongTint, revealProgress)
                      : c.surface,
            ),
            foregroundColor: WidgetStatePropertyAll(c.label),
            textStyle: WidgetStatePropertyAll(
              t.style(
                18,
                height: 1.4,
                weight: right ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            side: WidgetStateProperty.resolveWith(
              (s) => BorderSide(
                color: filled
                    ? border
                    : active &&
                            (s.contains(WidgetState.hovered) ||
                                s.contains(WidgetState.focused))
                        ? t.strongDivider
                        : Colors.transparent,
                width: filled ? 2 : 1.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: right || wrong
                      ? Color.lerp(
                          revealFromSelected ? c.accentFill : c.surface,
                          wrong ? c.destructive : c.accentFill,
                          badgeProgress,
                        )
                      : filled
                          ? c.accentFill
                          : null,
                  border: filled
                      ? null
                      : Border.all(color: t.strongDivider, width: 1.5),
                ),
                alignment: Alignment.center,
                child: right || wrong
                    ? Opacity(
                        opacity: badgeProgress,
                        child: Transform.scale(
                          scale: badgeScale ??
                              (badgeProgress < .6
                                  ? .4 + .75 * badgeProgress / .6
                                  : 1.15 - .15 * (badgeProgress - .6) / .4),
                          child: Icon(
                            right ? Icons.check : Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        letter,
                        style: t.style(
                          15,
                          height: 1.2,
                          weight: filled ? FontWeight.w700 : FontWeight.w600,
                          color: filled ? Colors.white : c.secondaryLabel,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

enum WebTextKind { h1, h2, h3, question, big, lead, sub, small, eyebrow }

class WebText extends StatelessWidget {
  const WebText(this.text, {this.kind = WebTextKind.sub, super.key});
  final String text;
  final WebTextKind kind;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final style = switch (kind) {
      WebTextKind.h1 => t.h1,
      WebTextKind.h2 => t.h2,
      WebTextKind.h3 => t.h3,
      WebTextKind.question => t.qtext,
      WebTextKind.big => t.big,
      WebTextKind.lead =>
        t.style(17, height: 1.45, color: t.colors.secondaryLabel),
      WebTextKind.sub => t.sub,
      WebTextKind.small => t.sm,
      WebTextKind.eyebrow => t.eb,
    };
    final result = Text(
      kind == WebTextKind.eyebrow ? text.toUpperCase() : text,
      style: style,
    );
    return kind == WebTextKind.eyebrow
        ? Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 9), child: result)
        : result;
  }
}

enum WebBarState { neutral, right, wrong }

/// Place in a bottom-aligned Stack with a 28px bottom and 24px side inset.
class WebBottomBar extends StatelessWidget {
  const WebBottomBar({
    required this.counter,
    required this.action,
    this.onCounterPressed,
    this.leading,
    this.hint,
    this.state = WebBarState.neutral,
    this.wide = false,
    this.compact = false,
    this.counterChevron = false,
    this.gap = 0,
    this.counterPadding,
    super.key,
  });
  final String counter;
  final VoidCallback? onCounterPressed;

  /// Space between the bar's items (board `gap`).
  final double gap;

  /// Padding around a plain counter. Defaults to 16 left and 12 right.
  final EdgeInsets? counterPadding;
  final Widget action;
  final Widget? leading;
  final String? hint;
  final WebBarState state;
  final bool wide;
  final bool compact;

  /// Question-session bar (board `.cnt`): the counter button ends in a small
  /// chevron-down and the bar's right padding is 9 px.
  final bool counterChevron;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: wide ? 1080 : 720),
      child: AnimatedContainer(
        // The phone bar's fade: 250 ms back to neutral, 300 ms to a result.
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : Duration(
                milliseconds: state == WebBarState.neutral ? 250 : 300,
              ),
        constraints: const BoxConstraints(minHeight: 64),
        padding: EdgeInsets.fromLTRB(8, 0, counterChevron ? 9 : 10, 0),
        decoration: BoxDecoration(
          color: switch (state) {
            WebBarState.neutral => c.surface,
            WebBarState.right => c.floatingRight,
            WebBarState.wrong => c.floatingWrong
          },
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: switch (state) {
              WebBarState.neutral =>
                t.dark ? c.separator : Colors.black.withValues(alpha: .06),
              WebBarState.right => c.accent.withValues(alpha: .26),
              WebBarState.wrong => c.destructive.withValues(alpha: .26)
            },
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: t.dark ? .4 : .10),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: gap)],
            if (onCounterPressed == null)
              Padding(
                padding:
                    counterPadding ?? const EdgeInsets.fromLTRB(16, 0, 12, 0),
                child: Text(
                  counter,
                  style: t.style(15, weight: FontWeight.w600).copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              )
            else
              TextButton(
                onPressed: onCounterPressed,
                style: TextButton.styleFrom(
                  foregroundColor: c.label,
                  minimumSize: const Size(0, 46),
                  padding: counterChevron
                      ? const EdgeInsets.fromLTRB(18, 0, 6, 0)
                      : const EdgeInsets.fromLTRB(16, 0, 12, 0),
                  textStyle: t.style(15, weight: FontWeight.w600).copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                child: counterChevron
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(counter),
                          const SizedBox(width: 8),
                          CustomPaint(
                            size: const Size.square(14),
                            painter: _DownChevronPainter(
                              t.dark
                                  ? c.secondaryLabel
                                  : const Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      )
                    : Text(counter),
              ),
            if (!compact || hint != null)
              Expanded(
                child: Text(
                  hint ?? '',
                  textAlign: TextAlign.center,
                  style: t.sm.copyWith(
                    color: t.dark ? c.secondaryLabel : c.tertiaryLabel,
                  ),
                ),
              ),
            if (gap > 0) SizedBox(width: gap),
            action,
          ],
        ),
      ),
    );
  }
}

class _DownChevronPainter extends CustomPainter {
  const _DownChevronPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    canvas.drawPath(
      Path()
        ..moveTo(6 * k, 9 * k)
        ..lineTo(12 * k, 15 * k)
        ..lineTo(18 * k, 9 * k),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_DownChevronPainter old) => old.color != color;
}

/// The board's 21 px flag: outlined, or filled when flagged.
class WebFlagIcon extends StatelessWidget {
  const WebFlagIcon({required this.flagged, super.key});
  final bool flagged;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return ExcludeSemantics(
      child: CustomPaint(
        size: const Size.square(21),
        painter: _FlagPainter(
          flagged: flagged,
          color: flagged
              ? t.colors.accent
              : t.dark
                  ? t.colors.secondaryLabel
                  : const Color(0xFF8E8E93),
        ),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  const _FlagPainter({required this.flagged, required this.color});
  final bool flagged;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawLine(Offset(6 * k, 3.2 * k), Offset(6 * k, 20.8 * k), stroke);
    final pennant = Path()
      ..moveTo(6 * k, 4.4 * k)
      ..lineTo(18.2 * k, 4.4 * k)
      ..lineTo(14 * k, 9 * k)
      ..lineTo(18.2 * k, 13.6 * k)
      ..lineTo(6 * k, 13.6 * k);
    if (flagged) {
      canvas.drawPath(
        pennant,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color,
      );
    }
    canvas.drawPath(pennant, stroke);
  }

  @override
  bool shouldRepaint(_FlagPainter old) =>
      old.flagged != flagged || old.color != color;
}

/// Shared 64px focus-mode header, with no sidebar.
class WebTopBar extends StatelessWidget {
  const WebTopBar({
    required this.leading,
    this.title,
    this.trailing,
    super.key,
  });
  final Widget leading;
  final Widget? title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(child: title ?? const SizedBox.shrink()),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      );
}

/// A 46 px round chevron button for a floating question bar (board `.ib`).
class WebBarArrow extends StatelessWidget {
  const WebBarArrow({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    super.key,
  });
  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: 46,
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 24),
        ),
      );
}

/// The board's `.back` link: 17 px accent text, 40 px tall, nudged 6 px left so
/// the arrow lines up with the page edge.
class WebBackLink extends StatelessWidget {
  const WebBackLink({
    required this.label,
    required this.onPressed,
    this.fontSize = 17,
    this.tightIcon = false,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;

  /// Settings pages set this link at 15 px (board `.back` with an override).
  final double fontSize;

  /// Board `.back` puts 2 px between the arrow and the label.
  final bool tightIcon;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final style = TextButton.styleFrom(
      foregroundColor: t.colors.accent,
      padding: EdgeInsets.zero,
      minimumSize: const Size(0, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      textStyle: t.style(fontSize),
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: const Offset(-6, 0),
        child: tightIcon
            ? TextButton(
                onPressed: onPressed,
                style: style,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_left, size: 20),
                    const SizedBox(width: 2),
                    Text(label),
                  ],
                ),
              )
            : TextButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.chevron_left, size: 20),
                label: Text(label),
                style: style,
              ),
      ),
    );
  }
}

/// The board's `.btn3.teal`: a natural-width text action, 11 px radius, 14 px
/// side padding, 16 px semibold accent label.
class WebTextAction extends StatelessWidget {
  const WebTextAction({
    required this.label,
    required this.onPressed,
    this.height = 42,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;
  final double height;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: t.colors.accent,
        minimumSize: Size(0, height),
        maximumSize: Size(double.infinity, height),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        textStyle: t.style(16, weight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// One column of the board's date picker (`.pk`): five 38 px rows 2 px apart
/// around the chosen value, 120 px wide. The chosen row is accent on the tint
/// and bold; the rest are muted. A row is picked by tapping it or by the
/// mouse wheel over the column. The rows slide a row to the new value, 240 ms
/// on the shared ease, as the phone's wheel glides. A pick made while one is
/// sliding takes over from where the rows are, never more than a row away.
class WebPickerColumn extends StatefulWidget {
  const WebPickerColumn({
    required this.values,
    required this.selectedIndex,
    required this.label,
    required this.onSelected,
    this.disabledIndices = const {},
    super.key,
  });
  final List<String> values;
  final int selectedIndex;
  final String label;
  final ValueChanged<int> onSelected;

  /// Values that can't be picked, such as days before today.
  final Set<int> disabledIndices;

  @override
  State<WebPickerColumn> createState() => _WebPickerColumnState();
}

class _WebPickerColumnState extends State<WebPickerColumn>
    with SingleTickerProviderStateMixin {
  static const _row = 38.0;
  static const _pitch = _row + 2;
  static const _height = _row * 5 + 2 * 4;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PantasDurations.base,
    value: 1,
  );
  late double _from = widget.selectedIndex.toDouble();

  /// Where the rows are, as the index shown in the middle slot.
  double get _position {
    final to = widget.selectedIndex.toDouble();
    return _from +
        (to - _from) * PantasCurves.shared.transform(_controller.value);
  }

  @override
  void didUpdateWidget(WebPickerColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == oldWidget.selectedIndex) return;
    final to = widget.selectedIndex.toDouble();
    final here = _from +
        (oldWidget.selectedIndex - _from) *
            PantasCurves.shared.transform(_controller.value);
    if (MediaQuery.disableAnimationsOf(context)) {
      _from = to;
      _controller.value = 1;
      return;
    }
    _from = here.clamp(to - 1, to + 1);
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _rowAt(BuildContext context, int index) {
    final t = context.webTokens;
    final chosen = index == widget.selectedIndex;
    final disabled = widget.disabledIndices.contains(index);
    return Semantics(
      button: true,
      selected: chosen,
      enabled: !disabled,
      label: '${widget.label} ${widget.values[index]}',
      excludeSemantics: true,
      child: TextButton(
        onPressed: disabled || chosen ? null : () => widget.onSelected(index),
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(120, _row)),
          maximumSize: const WidgetStatePropertyAll(Size(120, _row)),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => chosen
                ? t.colors.accentTint
                : s.contains(WidgetState.hovered) && !disabled
                    ? t.rowHover
                    : Colors.transparent,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          ),
        ),
        child: Text(
          widget.values[index],
          style: t.style(
            17,
            weight: chosen ? FontWeight.w700 : FontWeight.w400,
            color: chosen
                ? t.colors.accent
                : disabled
                    ? t.disabledText
                    : t.colors.tertiaryLabel,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerSignal: (event) {
          if (event is! PointerScrollEvent) return;
          final next =
              widget.selectedIndex + (event.scrollDelta.dy > 0 ? 1 : -1);
          if (next >= 0 &&
              next < widget.values.length &&
              !widget.disabledIndices.contains(next)) {
            widget.onSelected(next);
          }
        },
        child: SizedBox(
          width: 120,
          height: _height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final position = _position;
              return Stack(
                children: [
                  for (var index = position.floor() - 3;
                      index <= position.ceil() + 3;
                      index++)
                    if (index >= 0 && index < widget.values.length)
                      if ((index - position + 2) * _pitch case final top
                          when top + _row > 0 && top < _height)
                        Positioned(
                          top: top,
                          left: 0,
                          width: 120,
                          height: _row,
                          child: _rowAt(context, index),
                        ),
                ],
              );
            },
          ),
        ),
      );
}

/// Draws [modal] over the whole window, sidebar included, on the root overlay.
/// The boards' scrim covers the page and centers its dialog in the window, not
/// in the pane that opened it. [child] stays in place underneath.
///
/// The dialog fades and rises in as the phone's form sheet does, and leaves the
/// same way. A page that leaves from here asks [exit] to close with what
/// leaving does, so the route waits for the dialog to go before it pops.
class WebRootModal extends StatefulWidget {
  const WebRootModal({
    required this.child,
    required this.modal,
    this.onDismiss,
    this.exit,
    this.onBack,
    this.onEscape,
    super.key,
  });
  final Widget child;

  /// The dialog, centered over the scrim.
  final WidgetBuilder modal;

  /// Called when the scrim is tapped. Null leaves the scrim inert.
  final VoidCallback? onDismiss;

  /// Plays the dialog's exit before the page leaves. Without one the modal
  /// keeps its own, which only [onBack] uses.
  final WebOverlayExit? exit;

  /// What system Back does once the dialog has left. Null leaves Back to the
  /// route and to any PopScope inside the dialog.
  final VoidCallback? onBack;

  /// What Esc does. Null leaves Esc to the dialog.
  final VoidCallback? onEscape;
  @override
  State<WebRootModal> createState() => _WebRootModalState();
}

class _WebRootModalState extends State<WebRootModal> {
  final _controller = OverlayPortalController();
  final _own = WebOverlayExit();
  WebOverlayExit get _exit => widget.exit ?? _own;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_controller.isShowing) _controller.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final portal = OverlayPortal(
      controller: _controller,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (context) => WebOverlayLayer(
        motion: WebOverlayMotion.dialog,
        alignment: Alignment.center,
        // The board's gray would lighten a dark page.
        barrierColor: context.webTokens.dark
            ? Colors.black.withValues(alpha: .28)
            : const Color(0x521D1D1F),
        onDismiss: widget.onDismiss,
        exit: _exit,
        child: widget.onEscape == null
            ? widget.modal(context)
            : CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape):
                      widget.onEscape!,
                },
                child: Focus(autofocus: true, child: widget.modal(context)),
              ),
      ),
      child: widget.child,
    );
    final onBack = widget.onBack;
    if (onBack == null) return portal;
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit.close(onBack);
      },
      child: portal,
    );
  }
}

/// Full-page notice on wide web (boards SY_Error, SY_Update): a 60 px "P"
/// mark, heading, one lead line and a large natural-width button, centered.
class WebFullNotice extends StatelessWidget {
  const WebFullNotice({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
    this.lead,
    super.key,
  });
  final String title;
  final String? lead;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Scaffold(
      backgroundColor: t.colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    key: const ValueKey('web-notice-mark'),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: t.colors.accentFill,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'P',
                      style: t.style(
                        30,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(title, textAlign: TextAlign.center, style: t.h2),
                if (lead != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    lead!,
                    textAlign: TextAlign.center,
                    style: t.style(
                      17,
                      height: 1.45,
                      color: t.colors.secondaryLabel,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CallbackShortcuts(
                  bindings: {
                    if (onPressed != null)
                      const SingleActivator(
                        LogicalKeyboardKey.enter,
                        includeRepeats: false,
                      ): onPressed!,
                  },
                  child: Focus(
                    autofocus: true,
                    child: WebButton(
                      label: actionLabel,
                      onPressed: onPressed,
                      large: true,
                      keyHint: 'Enter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
