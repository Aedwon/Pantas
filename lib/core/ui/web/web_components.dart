import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_back_link_ring.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';
import 'package:pantas/core/ui/web/web_keyboard_hints.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

export 'package:pantas/core/ui/web/web_keyboard_focus.dart';

enum WebButtonVariant {
  primary,
  secondary,
  tertiary,
  white,
  danger,
  dangerOutline
}

/// Canvas buttons are natural width, including when placed in a wide column.
///
/// The look is design system 4.0, Button. Name the [variant] (the older
/// names) or a [kind] and a [tone]; a [kind] wins. [size] names a size class;
/// without it the flags choose one: [large] is `btn--lg`, [pill] is
/// `btn--bar`, and [tall] is a 48 px button. [height] sets a minimum height
/// other than the class's, and the radius then follows the height rule.
/// [fontSize], [radius] and [sidePadding] are old board overrides: the
/// system's size classes now decide them, so they are not read.
class WebButton extends StatelessWidget {
  const WebButton({
    required this.label,
    this.onPressed,
    this.variant = WebButtonVariant.primary,
    this.kind,
    this.tone,
    this.size,
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
    this.sidePadding,
    super.key,
  });
  final String label;

  /// Not read: the size class decides the side padding.
  final double? sidePadding;

  /// A minimum height other than the size class's.
  final double? height;

  /// Not read: the size class decides the label style.
  final double? fontSize;

  /// Not read: the radius follows the height, and only filled bar, dialog and
  /// compact buttons are pills.
  final double? radius;

  /// A tertiary button whose label is red (board `.btn3.red`): the critical
  /// tone.
  final bool redText;

  /// Drawn before the label, 8 px apart (board `.btn3` with an icon).
  final Widget? icon;
  final VoidCallback? onPressed;
  final WebButtonVariant variant;

  /// The kind. When set it replaces [variant].
  final PantasButtonKind? kind;

  /// The tone. Null is the kind's default.
  final PantasButtonTone? tone;

  /// A size class. When set it replaces [large] and [pill].
  final PantasButtonSize? size;
  final bool large;
  final bool pill;
  final String? keyHint;
  final bool busy;

  /// 48 px, the onboarding height.
  final bool tall;

  /// Full width of the parent, label centered (board `width: 100%`).
  final bool expand;

  (PantasButtonKind, PantasButtonTone?) get _pair {
    final k = kind;
    if (k != null) {
      return (
        k,
        tone ??
            (redText && k == PantasButtonKind.tertiary
                ? PantasButtonTone.critical
                : null)
      );
    }
    return switch (variant) {
      WebButtonVariant.primary => (PantasButtonKind.primary, null),
      WebButtonVariant.secondary => (PantasButtonKind.secondary, null),
      WebButtonVariant.tertiary => (
          PantasButtonKind.tertiary,
          redText ? PantasButtonTone.critical : null
        ),
      WebButtonVariant.white => (PantasButtonKind.white, null),
      WebButtonVariant.danger => (
          PantasButtonKind.primary,
          PantasButtonTone.critical
        ),
      WebButtonVariant.dangerOutline => (
          PantasButtonKind.secondary,
          PantasButtonTone.critical
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.webTokens.colors;
    final showKeyHint = keyHintShown(context, keyHint);
    final (pairKind, pairTone) = _pair;
    final sizeClass = size ??
        (pill
            ? PantasButtonSize.bar
            : large
                ? PantasButtonSize.lg
                : PantasButtonSize.standard);
    final m = pantasButtonMetrics(
      sizeClass,
      pairKind,
      heightOverride: height ?? (tall ? PantasSize.btn + PantasSpace.s4 : null),
      keyHint: showKeyHint,
    );
    // A hint on a primary button hangs 6 px into the padding (`.kbd`).
    final padRight = showKeyHint &&
            pairKind == PantasButtonKind.primary &&
            sizeClass != PantasButtonSize.bar
        ? m.padRight - PantasSpace.s6
        : m.padRight;
    final enabled = onPressed != null || busy;
    final palette =
        pantasButtonPalette(c, pairKind, pairTone, enabled: enabled);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final button = TextButton(
      onPressed: busy ? null : onPressed,
      style: ButtonStyle(
        animationDuration: reduced ? Duration.zero : PantasDurations.short2,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        minimumSize: WidgetStatePropertyAll(
          Size(expand ? double.infinity : 0, m.height),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.only(
            left: m.padLeft,
            right: padRight,
            top: PantasSpace.s8,
            bottom: PantasSpace.s8,
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => enabled &&
                  (s.contains(WidgetState.hovered) ||
                      s.contains(WidgetState.pressed))
              ? palette.hoverFill
              : palette.fill,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => enabled &&
                  (s.contains(WidgetState.hovered) ||
                      s.contains(WidgetState.pressed))
              ? palette.hoverLabel
              : palette.label,
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        // The theme's inside ring is the old focus mark; this button draws
        // its own ring outside (OffsetFocusRing) and keeps only its control
        // ring.
        side: WidgetStatePropertyAll(palette.ring ?? BorderSide.none),
        shape: WidgetStatePropertyAll(m.shape()),
        textStyle: WidgetStatePropertyAll(m.style),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (busy) ...[
            PantasSpinner.inline(color: palette.label),
            SizedBox(width: m.gap),
          ],
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: palette.label, size: PantasSpace.s18),
              child: icon!,
            ),
            SizedBox(width: m.gap),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          if (showKeyHint) ...[
            SizedBox(width: m.gap),
            WebKeyHint(
              keyHint!,
              onButton: pairKind == PantasButtonKind.primary,
              enabled: onPressed != null,
            ),
          ],
        ],
      ),
    );
    // Pressed scales to 0.97 over 120 ms, back over 180 ms.
    final pressable = PressScale(
      scale: pantasPressScale,
      enabled: onPressed != null && !busy,
      child: OffsetFocusRing(
        borderRadius: BorderRadius.circular(m.radius),
        child: ButtonWidthLock(busy: busy, child: button),
      ),
    );
    if (expand) return pressable;
    final natural = Align(
      widthFactor: 1,
      heightFactor: 1,
      alignment: Alignment.centerLeft,
      child: pressable,
    );
    // A small button reaches 44 px on a layout that is touched.
    return m.height < PantasSize.targetTouch
        ? TouchTarget(child: natural)
        : natural;
  }
}

/// A chip that names a keyboard shortcut (design system 4.0, KeyHint).
///
/// Standalone it is 11/600 `text-secondary` in a 1 px `divider-strong` ring.
/// With [onButton] it sits in a primary or critical button: 12/600
/// `on-accent` on `kbd-on-fill`, no ring. A hint in a disabled button
/// ([enabled] false) is transparent with the ring and `text-disabled` text.
/// It is visual help only: the button keeps its own label.
class WebKeyHint extends StatelessWidget {
  const WebKeyHint(
    this.label, {
    this.onButton = false,
    this.keyboard = true,
    this.enabled = true,
    this.width,
    super.key,
  });
  final String label;

  /// True inside a primary or critical button.
  final bool onButton;
  final bool keyboard;

  /// False when the button around it is disabled.
  final bool enabled;

  /// A fixed width, with the label centered, when the board gives the hint
  /// one. The label's own width differs between platforms ("Cmd K" and
  /// "Ctrl K"), and the room beside it must not.
  final double? width;
  @override
  Widget build(BuildContext context) {
    if (keyboard && !WebKeyboardHints.visibleOf(context)) {
      return const SizedBox.shrink();
    }
    // A letter key that is switched off must not be advertised.
    if (keyboard &&
        isCharacterKeyHint(label) &&
        !LetterShortcutsScope.enabledOf(context)) {
      return const SizedBox.shrink();
    }
    final c = context.webTokens.colors;
    final filled = onButton && enabled;
    final style = filled ? PantasType.webTag : PantasType.webKeyHintSm;
    return ExcludeSemantics(
      child: Container(
        width: width,
        alignment: width == null ? null : Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: width != null
              ? PantasSpace.s0
              : filled
                  ? PantasSpace.s8
                  : PantasSpace.s6,
          vertical: PantasSpace.s2,
        ),
        decoration: BoxDecoration(
          color: filled ? c.kbdOnFill : null,
          borderRadius: BorderRadius.circular(PantasRadius.xs),
          border: filled ? null : Border.all(color: c.dividerStrong),
        ),
        child: Text(
          label,
          style: style.copyWith(
            color: filled
                ? c.onAccent
                : enabled
                    ? c.textSecondary
                    : c.textDisabled,
          ),
        ),
      ),
    );
  }
}

/// Secondary navigation: accent text with an arrow, never a box (design
/// system 4.0, TextLink). Hover turns the text `accent-hover` and nudges the
/// arrow 4 px right. The focus ring hugs the text (`radius-xs`). A null
/// [onPressed] is the disabled state.
class WebTextLink extends StatefulWidget {
  const WebTextLink({
    required this.label,
    required this.onPressed,
    this.arrow = true,
    this.style,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;

  /// Text style for a link set inside running text, so it matches the
  /// sentence around it. Defaults to the TextLink label, 15/600. An inline
  /// link takes no 44px touch box, so its lines keep the sentence's spacing.
  final TextStyle? style;

  /// The board's Home links are text only; other pages keep the arrow.
  final bool arrow;
  @override
  State<WebTextLink> createState() => _WebTextLinkState();
}

class _WebTextLinkState extends State<WebTextLink> {
  bool _hover = false;

  /// Phosphor `arrow-right`, Bold weight.
  static const IconData _arrow = PantasIcons.arrowRightBold;

  @override
  Widget build(BuildContext context) {
    final c = context.webTokens.colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final enabled = widget.onPressed != null;
    final hover = enabled && _hover;
    final color = !enabled
        ? c.textDisabled
        : hover
            ? c.accentHover
            : c.accent;
    final radius = BorderRadius.circular(PantasRadius.xs);
    final link = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color,
          disabledForegroundColor: color,
          overlayColor: Colors.transparent,
          animationDuration: reduced ? Duration.zero : PantasDurations.short2,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide.none,
          textStyle: widget.style ?? PantasType.webLink,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(widget.label)),
            if (widget.arrow) ...[
              const SizedBox(width: PantasSpace.s6),
              AnimatedContainer(
                transform: Matrix4.translationValues(
                  hover && !reduced ? PantasSpace.s4 : 0,
                  0,
                  0,
                ),
                duration: reduced ? Duration.zero : PantasDurations.nudge,
                curve: PantasCurves.move,
                child: ExcludeSemantics(
                  child: Icon(_arrow, size: PantasSpace.s16, color: color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    final pressable = PressScale(
      scale: pantasPressScale,
      enabled: enabled,
      child: OffsetFocusRing(borderRadius: radius, child: link),
    );
    // A link set inside a sentence wraps with the text, so it takes no 44px
    // box (inline links are exempt, WCAG 2.5.8); the box would open a gap
    // between the sentence's lines.
    return widget.style != null ? pressable : TouchTarget(child: pressable);
  }
}

/// The system's Card: a flat `surface-card` block, `radius-xl`, clipped, with
/// no shadow in light and a 1 `edge-card` inner edge in dark. A selected card
/// is `accent-tint` with a 2 `accent` ring. A floating card takes `elev-bar`
/// and the 1 `edge-bar` edge.
class WebCard extends StatelessWidget {
  const WebCard({
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = PantasRadius.xl,
    this.selected = false,
    this.minHeight,
    this.floating = false,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// A card that floats over other content, such as a popover: it gets the
  /// edge and the shadow of the floating question bar, so it reads as a
  /// separate surface where it lies over a card of the same color.
  final bool floating;

  /// Picked card (board OB_Picker): accent tint and a 2 px accent outline.
  final bool selected;

  /// Shortest the card may be; its child is centered vertically.
  final double? minHeight;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    // Item 17, demo 4: the tint and the outline fade 160 ms on the ease. The
    // dark edge is the board's inset outline: it is drawn over the card and
    // takes up no room, so a card is the same size in dark and light (6T-11).
    final edge = t.dark && !selected && !floating ? t.cardEdge : null;
    return FadingColor(
      color: selected ? t.colors.accentTint : t.colors.surfaceCard,
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
            border: floating ? Border.all(color: webFloatingEdge(t)) : null,
            boxShadow: floating ? webFloatingShadow(t, blur: 24, dy: 4) : null,
          ),
          // Drawn on top like the board inset outline; content stays put.
          foregroundDecoration: outline.a == 0
              ? edge == null
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(color: edge),
                    )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: outline,
                    width: PantasBorder.ringSelected,
                  ),
                ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// The edge of a surface that floats over the page (the question bar, a
/// popover).
Color webFloatingEdge(WebTokens t) => t.colors.edgeBar;

/// The shadow of a surface that floats over the page. A popover that sits
/// just above another floating surface asks for a tighter one, so its shadow
/// does not fall on the surface below.
List<BoxShadow> webFloatingShadow(
  WebTokens t, {
  double blur = 30,
  double dy = 10,
}) =>
    [
      BoxShadow(
        color:
            (t.dark ? PantasShadow.dark : PantasShadow.light).bar.first.color,
        blurRadius: blur,
        offset: Offset(0, dy),
      ),
    ];

/// One hairline at device resolution: the board's `.5px` rule is a whole
/// device pixel in the browser, not a half-covered pair.
double webHairline(BuildContext context) =>
    1 / MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0);

/// The 16 px row chevron (rule D178): the Bold Phosphor chevron in
/// `icon-chevron`. It is decorative and hidden from the screen reader.
class WebChevron extends StatelessWidget {
  const WebChevron({this.color, super.key});
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return ExcludeSemantics(
      child: Icon(
        PantasIcons.bold(PantasIcons.next),
        size: PantasSpace.s16,
        color: color ?? t.colors.iconChevron,
      ),
    );
  }
}

/// Row chevron: absent, shown on hover only (board `.cv`), or always shown.
enum WebRowChevron { none, hover, always }

/// The system's ListRow for wide screens: an optional leading widget, a title,
/// a subtitle, a value and a chevron, 13 above and below. Hover and press show
/// the `surface-hover` well and the chevron fades in; a selected row is
/// `accent-tint` with `text-on-tint-secondary` supporting text and an
/// `accent-tint-text` chevron; the keyboard ring sits inside the row. At large
/// text, and for a [wrapTitle] row when the title would lose its 6em, the
/// value stacks under the title. A row that truncates keeps its one line.
class WebRow extends StatefulWidget {
  const WebRow({
    required this.title,
    this.subtitle,
    this.wrapTitle = false,
    this.mathTitle = false,
    this.titleStyle,
    this.horizontalPadding = PantasLayout.rowInset,
    this.titleColor,
    this.titleSuffix,
    this.tooltipWhenCut = false,
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
    this.leadingGap = PantasSpace.s16,
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

  /// Shows the full title in a tooltip, only when the row cuts it short
  /// (5Q-16). A title that fits has nothing more to say.
  final bool tooltipWhenCut;
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
    final style = w.titleStyle ??
        PantasType.webRowTitle.copyWith(
          color: w.titleColor ??
              (w.dimmed ? t.colors.textSecondary : t.colors.textPrimary),
          height: lineHeight,
        );
    final text = w.mathTitle
        ? MathText(
            ContentRenderer.plainText(w.title),
            style: style,
            maxLines: lines,
            overflow: overflow,
          )
        : Text(w.title, maxLines: lines, overflow: overflow, style: style);
    if (!w.tooltipWhenCut || lines == null || w.mathTitle) return text;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: w.title, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout(maxWidth: constraints.maxWidth);
        final cut = painter.didExceedMaxLines;
        painter.dispose();
        return cut ? Tooltip(message: w.title, child: text) : text;
      },
    );
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
          : PantasDurations.short2,
      curve: PantasCurves.fade,
      builder: (context, selection, _) => _row(context, selection),
    );
  }

  Widget _row(BuildContext context, double selection) {
    final t = context.webTokens;
    final w = widget;
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    // ds-board: README type: web-label 14/600/1.3
    final lineHeight = w.boardMetrics ? 1.3 : null;
    final hairline =
        w.boardMetrics ? webHairline(context) : PantasBorder.hairline;
    final baseValue = w.valueStyle ??
        PantasType.webRowValue.copyWith(color: t.colors.textSecondary);
    final valueStyle = baseValue.copyWith(
      color: Color.lerp(
        baseValue.color,
        w.selectedValueColor ?? t.colors.textOnTintSecondary,
        selection,
      ),
    );
    final subStyle = w.subtitleStyle ??
        PantasType.webRowSub.copyWith(
          color: Color.lerp(
            t.colors.textSecondary,
            t.colors.textOnTintSecondary,
            selection,
          ),
          height: lineHeight,
        );
    final chevronColor = Color.lerp(
      t.colors.iconChevron,
      t.colors.accentTintText,
      selection,
    );
    const gap = PantasSpace.s12;
    final tint = t.colors.accentTint;
    final button = TextButton(
      statesController: _states,
      onPressed: w.dimmed ? null : w.onPressed,
      style: ButtonStyle(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.short2,
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: w.horizontalPadding),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 0)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        // A selected row's tint is the layer behind, which fades.
        // Pressing keeps the tint hovering gave. The row has no ink, so
        // without this the tint vanished on mouse down and the row looked idle.
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => !w.selected &&
                  (s.contains(WidgetState.hovered) ||
                      s.contains(WidgetState.pressed) ||
                      webKeyboardFocus(s))
              ? t.rowHover
              : Colors.transparent,
        ),
        // The keyboard ring is its own layer below, inside the row, so a
        // row at the end of a rounded card is not cut by the card's corner.
        side: const WidgetStatePropertyAll(BorderSide.none),
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
                vertical: w.verticalPadding ??
                    (w.compact ? PantasSpace.s12 : PantasLayout.rowPadY),
              ),
              decoration: BoxDecoration(
                border: w.divider
                    ? Border(
                        bottom: BorderSide(
                          color: t.colors.divider,
                          width: hairline,
                        ),
                      )
                    : null,
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  // Ruling 12: the value wraps under the title when the two
                  // no longer fit on one line, and the title keeps at least
                  // 6em of its own text beside a value.
                  final stacked = w.value != null &&
                      _stacks(
                        context,
                        box.maxWidth -
                            (w.chevron == WebRowChevron.none
                                ? PantasSpace.s0
                                : gap + PantasSpace.s16),
                        valueStyle,
                        large: large,
                      );
                  final release = stacked || large;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (w.titleSuffix == null)
                              _title(w, release, lineHeight, t)
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: _title(w, release, lineHeight, t),
                                  ),
                                  const SizedBox(width: PantasSpace.s6),
                                  w.titleSuffix!,
                                ],
                              ),
                            if (w.subtitle != null)
                              Text(
                                w.subtitle!,
                                maxLines: release || w.wrapTitle ? null : 1,
                                overflow: release || w.wrapTitle
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: subStyle,
                              ),
                            if (stacked) Text(w.value!, style: valueStyle),
                          ],
                        ),
                      ),
                      if (!stacked && w.value != null) ...[
                        const SizedBox(width: gap),
                        Text(
                          w.value!,
                          style: valueStyle,
                          textAlign: TextAlign.end,
                        ),
                      ],
                      if (w.trailing != null) ...[
                        const SizedBox(width: gap),
                        w.trailing!,
                      ],
                      if (w.chevron != WebRowChevron.none) ...[
                        const SizedBox(width: gap),
                        if (w.chevron == WebRowChevron.always)
                          WebChevron(color: chevronColor)
                        else
                          ListenableBuilder(
                            listenable: _states,
                            builder: (context, child) => AnimatedOpacity(
                              opacity:
                                  _states.value.contains(WidgetState.hovered) ||
                                          _states.value
                                              .contains(WidgetState.focused)
                                      ? 1
                                      : 0,
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : PantasDurations.short2,
                              curve: PantasCurves.fade,
                              child: child,
                            ),
                            child: WebChevron(color: chevronColor),
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
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
          Positioned.fill(
            child: IgnorePointer(
              child: ListenableBuilder(
                listenable: Listenable.merge([_states, webKeyboardInput]),
                builder: (context, _) {
                  final ring = webFocusRing(_states.value, t.colors.accent);
                  if (ring == null) return const SizedBox.shrink();
                  // Rounded and 3 in from the row's edge: it clears the 18
                  // corner of the card the row sits in (3K-6), where a square
                  // ring flush with the edge would be cut off.
                  return Padding(
                    padding: const EdgeInsets.all(
                      PantasSpace.s2 + PantasBorder.ring,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(ring),
                        borderRadius: BorderRadius.circular(PantasRadius.md),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Whether [valueStyle]'s value must go under the title in a row [width]
  /// wide. A row with a trailing widget or a maths title falls back to the
  /// large-text rule, since its text cannot be measured here.
  bool _stacks(
    BuildContext context,
    double width,
    TextStyle valueStyle, {
    required bool large,
  }) {
    final w = widget;
    // A row that asks for one line with an ellipsis (and maybe a tooltip,
    // 5Q-16) keeps that choice: it stacks only at large text.
    if (w.trailing != null || w.mathTitle || !w.wrapTitle) return large;
    final titleStyle = w.titleStyle ?? PantasType.webRowTitle;
    final scaler = MediaQuery.textScalerOf(context);
    double natural(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final result = painter.width;
      painter.dispose();
      return result;
    }

    const gap = PantasSpace.s12;
    final start = natural(w.title, titleStyle);
    final end = natural(w.value!, valueStyle);
    if (start + gap + end <= width) return false;
    final sixEm = scaler.scale(titleStyle.fontSize ?? PantasSpace.s16) * 6;
    return width - gap - end < (start < sixEm ? start : sixEm);
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

  /// The drawn segment: 34 (`btn-xs` less its 2 px of room), the system's
  /// `.seg__btn` min height. The track adds 2 px of padding around it.
  static const double _segment = PantasSize.btnXs - PantasSpace.s2;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    // On touch the segments are 44 high themselves; a transparent border keeps
    // the drawn segment 34 inside a 38 well (D190 item 2).
    final touch = switch (Theme.of(context).platform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.fuchsia =>
        true,
      _ => false,
    };
    final rowHeight = touch ? PantasSize.targetTouch : _segment;
    final thumbInset = (rowHeight - _segment) / 2;
    const well = _segment + PantasSpace.s2 * 2;
    final trackInset = touch ? (PantasSize.targetTouch - well) / 2 : 0.0;
    final radius = BorderRadius.circular(PantasRadius.sm);
    final shadow = (t.dark ? PantasShadow.dark : PantasShadow.light).segment;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cells are an equal share of the control, as on the board. A cell is
        // never narrower than the widest label needs, and a label never
        // wraps or shrinks: when the cells do not fit, the track scrolls
        // inside itself (the thumb is sized from the track, so it stays on
        // its segment).
        final scaler = MediaQuery.textScalerOf(context);
        double natural(int i) {
          if (suffixes?[i] != null) return 0;
          final painter = TextPainter(
            text: TextSpan(
              text: labels[i],
              style: PantasType.webLabel,
            ),
            textDirection: Directionality.of(context),
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          final width = painter.width + PantasSpace.s12 * 2;
          painter.dispose();
          return width;
        }

        final needs = [for (var i = 0; i < labels.length; i++) natural(i)];
        final widest = needs.reduce((a, b) => a > b ? a : b);
        final inner = constraints.maxWidth - PantasSpace.s2 * 2;
        final bounded = constraints.hasBoundedWidth;
        final equal = bounded ? inner / labels.length : 0.0;
        final total = needs.fold<double>(0, (sum, need) => sum + need);
        // Equal columns when the widest label fits its share; otherwise the
        // columns follow the labels' own widths, spread over the room; when
        // even those do not fit, the track scrolls.
        final List<double> cells;
        if (!bounded || equal >= widest) {
          cells = List.filled(labels.length, equal > widest ? equal : widest);
        } else if (total <= inner) {
          cells = [
            for (final need in needs) need + (inner - total) / labels.length,
          ];
        } else {
          cells = needs;
        }
        final scrolls =
            bounded && cells.fold<double>(0, (a, b) => a + b) > inner + .5;
        final offsets = <double>[];
        var at = 0.0;
        for (final c in cells) {
          offsets.add(at);
          at += c;
        }
        final track = Stack(
          children: [
            Positioned.fill(
              top: trackInset,
              bottom: trackInset,
              child: DecoratedBox(
                key: const ValueKey('segmented-control-track'),
                decoration: BoxDecoration(
                  color: t.disabledBackground,
                  borderRadius: radius,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: PantasSpace.s2,
                vertical: touch ? PantasSpace.s0 : PantasSpace.s2,
              ),
              child: SizedBox(
                width: cells.fold<double>(0, (a, b) => a + b),
                child: Stack(
                  children: [
                    // One thumb slides under the labels (item 17, demo 7):
                    // 240 ms on the shared ease. Only a translation changes.
                    Positioned.fill(
                      child: ExcludeSemantics(
                        child: IgnorePointer(
                          child: SlidingMarker(
                            key: const ValueKey('segmented-control-thumb'),
                            offsets: offsets,
                            lengths: cells,
                            index: selected,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: thumbInset,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: t.segmentOn,
                                  borderRadius: radius,
                                  boxShadow: shadow,
                                ),
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
                          SizedBox(
                            width: cells[i],
                            child: Semantics(
                              selected: selected == i,
                              inMutuallyExclusiveGroup: true,
                              child: TextButton(
                                onPressed: () => onChanged(i),
                                style: ButtonStyle(
                                  animationDuration:
                                      MediaQuery.disableAnimationsOf(context)
                                          ? Duration.zero
                                          : PantasDurations.short2,
                                  minimumSize: WidgetStatePropertyAll(
                                    Size(0, rowHeight),
                                  ),
                                  visualDensity: VisualDensity.standard,
                                  // An unselected cell answers the pointer
                                  // with an `opacity-hover` wash of
                                  // `text-primary`; the selected one already
                                  // has the thumb (5Q-9).
                                  overlayColor: WidgetStateProperty.resolveWith(
                                    (states) => selected != i &&
                                            states.contains(WidgetState.hovered)
                                        ? t.colors.textPrimary.withValues(
                                            alpha: PantasOpacity.hover,
                                          )
                                        : Colors.transparent,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(
                                      horizontal: PantasSpace.s12,
                                    ),
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    accentLabels
                                        ? t.colors.accent
                                        : selected == i
                                            ? t.colors.textPrimary
                                            : t.colors.textOnFill,
                                  ),
                                  backgroundColor: const WidgetStatePropertyAll(
                                    Colors.transparent,
                                  ),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: radius,
                                    ),
                                  ),
                                  textStyle: WidgetStatePropertyAll(
                                    PantasType.webLabel.copyWith(
                                      fontWeight: selected == i
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // A label never wraps and every label keeps
                                // its size (4N-8).
                                child: suffixes?[i] == null
                                    ? Text(
                                        labels[i],
                                        maxLines: 1,
                                        softWrap: false,
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              labels[i],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: PantasSpace.s6,
                                          ),
                                          suffixes![i]!,
                                        ],
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        if (!scrolls) return track;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: track,
        );
      },
    );
  }
}

enum WebOptionState { normal, selected, right, wrong, dimmed, readOnly }

/// A new question starts with no choice focused.
///
/// The ring that sat on the answer just given must not carry to the same
/// place on the next question, where it reads as a half-made pick. Call this
/// when a page swaps to another question: after the frame, a focused choice
/// lets go, and the page's own key node takes the focus back. A control that
/// is not a choice (Report, Leave) keeps its focus.
void releaseChoiceFocus(State state) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!state.mounted) return;
    final focused = FocusManager.instance.primaryFocus;
    final onChoice =
        focused?.context?.findAncestorWidgetOfExactType<WebAnswerOption>() !=
            null;
    if (onChoice) focused!.unfocus();
  });
  // A callback alone waits for the next frame, and nothing may have asked
  // for one.
  WidgetsBinding.instance.scheduleFrame();
}

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

  /// The words of an option: `web-option`, 600 on the right answer and
  /// `text-secondary` once the option is dimmed (no opacity, D49).
  static TextStyle textStyle(BuildContext context, WebOptionState state) {
    final c = context.webTokens.colors;
    return PantasType.webOption.copyWith(
      fontWeight:
          state == WebOptionState.right ? FontWeight.w600 : FontWeight.w400,
      color: state == WebOptionState.dimmed ? c.textSecondary : c.textPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    final wrong = state == WebOptionState.wrong;
    final right = state == WebOptionState.right;
    final selected = state == WebOptionState.selected;
    final dimmed = state == WebOptionState.dimmed;
    final filled = selected || right || wrong;
    final active = state == WebOptionState.normal || selected;
    final ringColor = right || wrong
        ? Color.lerp(
            revealFromSelected ? c.accent : Colors.transparent,
            wrong ? c.danger : c.accent,
            revealProgress,
          )!
        : c.accent;
    // The badge grows with the letter, so at 200% text it still holds it.
    final badge = math.max(
      PantasSize.optBadge,
      MediaQuery.textScalerOf(context).scale(PantasType.webLink.fontSize!) *
          2.15,
    );
    final badgeFill = right || wrong
        ? Color.lerp(
            revealFromSelected ? c.accentFill : c.surfaceCard,
            wrong ? c.dangerFill : c.accentFill,
            badgeProgress,
          )
        : selected
            ? c.accentFill
            : null;
    final letterColor = right || wrong
        ? Color.lerp(
            revealFromSelected ? c.onAccent : c.textSecondary,
            wrong ? c.onDanger : c.onAccent,
            badgeProgress,
          )!
        : selected
            ? c.onAccent
            : c.textSecondary;
    final markScale = badgeScale ??
        (badgeProgress < .6
            ? .4 + .75 * badgeProgress / .6
            : 1.15 - .15 * (badgeProgress - .6) / .4);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      checked: selected || wrong || (right && revealFromSelected),
      value: right
          ? 'correct answer'
          : wrong
              ? 'your answer, wrong'
              : null,
      child: TextButton(
        onPressed: active ? onPressed : null,
        style: ButtonStyle(
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : PantasDurations.short3,
          minimumSize: const WidgetStatePropertyAll(
            Size(double.infinity, PantasSize.optMin),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
          padding: const WidgetStatePropertyAll(
            EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s14,
              PantasSpace.s18,
              PantasSpace.s14,
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(
            right
                ? Color.lerp(c.surfaceCard, c.accentTint, revealProgress)
                : wrong
                    ? Color.lerp(c.surfaceCard, c.dangerTint, revealProgress)
                    : c.surfaceCard,
          ),
          foregroundColor: WidgetStatePropertyAll(
            dimmed ? c.textSecondary : c.textPrimary,
          ),
          textStyle: WidgetStatePropertyAll(textStyle(context, state)),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(PantasRadius.lg)),
            ),
          ),
          side: WidgetStateProperty.resolveWith((s) {
            if (webKeyboardFocus(s)) {
              // A selected option rings in text-primary, so focus never
              // looks like selection.
              return BorderSide(
                color: filled ? c.textPrimary : c.accent,
                width: PantasBorder.focus,
              );
            }
            return BorderSide(
              color: filled
                  ? ringColor
                  : active && s.contains(WidgetState.hovered)
                      ? c.dividerStrong
                      : Colors.transparent,
              width:
                  filled ? PantasBorder.ringSelected : PantasBorder.ringStrong,
            );
          }),
        ),
        child: Row(
          children: [
            Container(
              width: badge,
              height: badge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeFill,
                border: filled
                    ? null
                    : Border.all(
                        color: dimmed ? c.divider : c.borderControl,
                        width: PantasBorder.ringStrong,
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: PantasType.webLink.copyWith(
                  // ds-board: README type: web-glyph leading 1
                  height: 1,
                  fontWeight: filled ? FontWeight.w700 : FontWeight.w600,
                  color: letterColor,
                ),
              ),
            ),
            const SizedBox(width: PantasSpace.s16),
            Expanded(child: child),
            if (right || wrong) ...[
              const SizedBox(width: PantasSpace.s12),
              // The result shows at the right end, and the semantics carry
              // it as words, so the mark is decoration.
              ExcludeSemantics(
                child: Opacity(
                  opacity: badgeProgress,
                  child: Transform.scale(
                    scale: markScale,
                    child: Icon(
                      right ? PantasIcons.check : PantasIcons.close,
                      size: PantasSize.icon,
                      color: right ? c.accentTintText : c.dangerText,
                    ),
                  ),
                ),
              ),
            ],
          ],
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
        ? Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s4,
              PantasSpace.s0,
              PantasSpace.s4,
              PantasSpace.s8,
            ),
            child: result,
          )
        : result;
  }
}

enum WebBarState { neutral, right, wrong }

/// Place in a bottom-aligned Stack with a 28px bottom and 24px side inset.
///
/// From 1.5x text the hint takes its own line above the actions and the bar
/// becomes a rounded rectangle (FloatingBar, stacked).
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
    this.counterLabel,
    super.key,
  });
  final String counter;
  final VoidCallback? onCounterPressed;

  /// What a screen reader says for the counter button, when the visible text
  /// ("3 of 10") is not enough on its own.
  final String? counterLabel;

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
  /// chevron-down and the bar's right padding is 10 px.
  final bool counterChevron;

  /// Above 1.5x text the system stacks the bar (FloatingBar, ruling 5).
  static const double stackAboveScale = 1.5;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    final stacked = !compact &&
        hint != null &&
        MediaQuery.textScalerOf(context).scale(1) > stackAboveScale;
    final counterStyle = PantasType.webLink.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final counterWidget = onCounterPressed == null
        ? Padding(
            padding: counterPadding ??
                const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s0,
                  PantasSpace.s12,
                  PantasSpace.s0,
                ),
            child: Text(counter, style: counterStyle),
          )
        : Semantics(
            button: counterLabel != null ? true : null,
            label: counterLabel,
            excludeSemantics: counterLabel != null,
            onTap: counterLabel != null ? onCounterPressed : null,
            child: TextButton(
              onPressed: onCounterPressed,
              style: TextButton.styleFrom(
                foregroundColor: c.textPrimary,
                minimumSize: const Size(PantasSize.btnBar, PantasSize.btnBar),
                shape: PantasRadius.fullShape,
                padding: counterChevron
                    ? const EdgeInsets.fromLTRB(
                        PantasSpace.s18,
                        PantasSpace.s0,
                        PantasSpace.s6,
                        PantasSpace.s0,
                      )
                    : const EdgeInsets.fromLTRB(
                        PantasSpace.s16,
                        PantasSpace.s0,
                        PantasSpace.s12,
                        PantasSpace.s0,
                      ),
                textStyle: counterStyle,
              ),
              child: counterChevron
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(counter),
                        const SizedBox(width: PantasSpace.s8),
                        CustomPaint(
                          size: const Size.square(PantasSpace.s14),
                          painter: _DownChevronPainter(c.iconChevron),
                        ),
                      ],
                    )
                  : Text(counter),
            ),
          );
    // "Correct" and "Not this one" are read once, as a status (FloatingBar).
    final hintWidget = Semantics(
      liveRegion: true,
      child: Text(
        hint ?? '',
        textAlign: TextAlign.center,
        style: PantasType.webSmall.copyWith(
          color: state == WebBarState.neutral ? c.textSecondary : c.textPrimary,
        ),
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: wide ? PantasLayout.barMaxWide : PantasLayout.barMax,
      ),
      child: AnimatedContainer(
        // The bar's fade: 250 ms back to neutral, 300 ms to a result.
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : state == WebBarState.neutral
                ? PantasDurations.fade
                : PantasDurations.flip,
        constraints: const BoxConstraints(minHeight: PantasSize.bar),
        padding: EdgeInsets.fromLTRB(
          PantasSpace.s8,
          stacked ? PantasSpace.s8 : PantasSpace.s0,
          PantasSpace.s10,
          stacked ? PantasSpace.s8 : PantasSpace.s0,
        ),
        decoration: BoxDecoration(
          color: switch (state) {
            WebBarState.neutral => c.surfaceCard,
            WebBarState.right => c.accentBar,
            WebBarState.wrong => c.dangerBar
          },
          borderRadius: BorderRadius.circular(
            stacked ? PantasRadius.xl : PantasRadius.bar,
          ),
          border: Border.all(
            color: switch (state) {
              WebBarState.neutral => webFloatingEdge(t),
              WebBarState.right => c.accent.withValues(
                  alpha: PantasOpacity.barRing,
                ),
              WebBarState.wrong => c.danger.withValues(
                  alpha: PantasOpacity.barRing,
                )
            },
          ),
          boxShadow: webFloatingShadow(t),
        ),
        child: stacked
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s8,
                    ),
                    child: hintWidget,
                  ),
                  const SizedBox(height: PantasSpace.s4),
                  Row(
                    children: [
                      if (leading != null) ...[
                        leading!,
                        SizedBox(width: gap),
                      ],
                      counterWidget,
                      const Spacer(),
                      action,
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  if (leading != null) ...[leading!, SizedBox(width: gap)],
                  counterWidget,
                  if (!compact || hint != null) Expanded(child: hintWidget),
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

/// The board's flag on a pole, 20 px: outlined, or filled when flagged.
class WebFlagIcon extends StatelessWidget {
  const WebFlagIcon({required this.flagged, super.key});
  final bool flagged;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return ExcludeSemantics(
      child: CustomPaint(
        size: const Size.square(PantasSize.icon),
        painter: _FlagPainter(
          flagged: flagged,
          color: flagged ? t.colors.accent : t.colors.textSecondary,
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
        constraints: const BoxConstraints(minHeight: PantasLayout.focusHead),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s20),
          child: Row(
            children: [
              leading,
              const SizedBox(width: PantasSpace.s10),
              Expanded(child: title ?? const SizedBox.shrink()),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      );
}

/// The 44 px button a question page's top bar uses at its two ends. The
/// quiz and the assessment share it, so the ends sit at the same x.
///
/// It is a [PantasIconButton]: give a [glyph] or an [icon]. With [toggled]
/// set it is a toggle: the outline glyph when off, the Fill glyph in `accent`
/// when on.
class WebTopBarButton extends StatelessWidget {
  const WebTopBarButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.glyph,
    this.toggled,
    this.size = PantasIconButtonSize.standard,
    this.accent = false,
    super.key,
  });
  final String tooltip;
  final Widget? icon;
  final IconData? glyph;
  final bool? toggled;
  final PantasIconButtonSize size;
  final bool accent;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => PantasIconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: icon,
        glyph: glyph,
        toggled: toggled,
        size: size,
        accent: accent,
      );
}

/// A question page's top bar: the title centered on the page, not between
/// the two ends.
///
/// The ends differ in width (Leave and its Esc hint on the left, Report and
/// a "Saved" line on the right), so a title set between them drifts off the
/// center and moves when the right end changes. Here the title is laid out
/// alone, in the middle of the bar, and the two ends sit over it. Used by the
/// quiz and the assessment so their titles line up.
class WebCenteredTopBar extends StatelessWidget {
  const WebCenteredTopBar({
    required this.leading,
    required this.title,
    this.trailing,
    this.titleKey,
    super.key,
  });
  final Widget leading;
  final String title;
  final Widget? trailing;
  final Key? titleKey;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return SizedBox(
      height: PantasLayout.focusHead,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              key: titleKey,
              // Room for the widest end on both sides, so the title never
              // runs under a button. 192 is the nearest layout size to the
              // 200 the ends needed.
              padding: const EdgeInsets.symmetric(
                horizontal: PantasLayout.titleNarrow,
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PantasType.webRowSub.copyWith(
                  color: t.colors.textSecondary,
                ),
              ),
            ),
            Align(alignment: Alignment.centerLeft, child: leading),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing),
          ],
        ),
      ),
    );
  }
}

/// A 46 px (`size-btn-bar`) round chevron button for a floating question bar
/// (board `.ib`).
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
        dimension: PantasSize.btnBar,
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: PantasSpace.s24),
        ),
      );
}

/// Room after the label of a [WebBackLink], for its focus ring. The arrow
/// glyph has blank space of its own on the left; the label's last letter
/// has none, and the ring touched it. Top bars set the Esc hint right after
/// the link, where a 10 px gap used to be.
const double webBackLinkPadRight = PantasSpace.s10;

/// Room inside the back link's highlight before its arrow (back link A).
const double webBackLinkPadLeft = PantasSpace.s8;

/// The board's `.back` link: a 20 px Bold chevron and a 17 px accent label,
/// 2 px apart, 40 px tall with a 44 px touch target. It highlights as a
/// rounded rectangle of `radius-back` (11), never a pill. The highlight
/// reaches 14 px into the page margin with 8 px inside it, so the chevron
/// still sits 6 px left of the page edge (back link A). Hover washes the
/// accent at `opacity-hover`, turns the label `accent-hover` and nudges the
/// chevron 2 px left. [fontSize] and [tightIcon] are old Settings overrides:
/// the system sets one size and a 2 px gap, so they are not read.
class WebBackLink extends StatefulWidget {
  const WebBackLink({
    required this.label,
    required this.onPressed,
    this.fontSize,
    this.tightIcon = false,
    this.nudge = true,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;

  /// Moves the link into the page margin so the arrow sits 6 px left of the
  /// page edge, as the board's `.back` does. A link in a top bar that already
  /// sits on the bar's padding turns this off.
  final bool nudge;

  /// Not read: the label is 17 px.
  final double? fontSize;

  /// Not read: the chevron and the label are always 2 px apart.
  final bool tightIcon;

  @override
  State<WebBackLink> createState() => _WebBackLinkState();
}

class _WebBackLinkState extends State<WebBackLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.webTokens.colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    // The nudge puts the link's left end outside the page's clip, so the ring
    // is drawn in the overlay (5Q-11). Without one the ring is drawn here.
    final overlayRing = widget.nudge && WebBackLinkRing.supported(context);
    final radius = BorderRadius.circular(PantasRadius.back);
    final style = TextButton.styleFrom(
      padding: EdgeInsets.only(
        left: widget.nudge ? webBackLinkPadLeft : PantasSpace.s0,
        right: webBackLinkPadRight,
      ),
      minimumSize: const Size(0, PantasSize.back),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      textStyle: PantasType.webRowTitle,
      shape: RoundedRectangleBorder(borderRadius: radius),
      side: BorderSide.none,
      animationDuration: reduced ? Duration.zero : PantasDurations.short2,
    ).copyWith(
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)
                ? c.accentHover
                : c.accent,
      ),
      // The overlay draws the hover wash whole (5Q-11).
      backgroundColor: overlayRing
          ? null
          : WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.hovered) ||
                      s.contains(WidgetState.pressed)
                  ? c.accent.withValues(alpha: PantasOpacity.hover)
                  : Colors.transparent,
            ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    );
    final link = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: TextButton(
        onPressed: widget.onPressed,
        style: style,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              transform: Matrix4.translationValues(
                _hover && !reduced ? -PantasSpace.s2 : 0,
                0,
                0,
              ),
              duration: reduced ? Duration.zero : PantasDurations.nudge,
              curve: PantasCurves.move,
              child: ExcludeSemantics(
                child: Icon(
                  PantasIcons.bold(PantasIcons.back),
                  size: PantasSize.icon,
                ),
              ),
            ),
            const SizedBox(width: PantasSpace.s2),
            Flexible(child: Text(widget.label)),
          ],
        ),
      ),
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: Offset(
          widget.nudge ? -(PantasSpace.s6 + webBackLinkPadLeft) : 0,
          0,
        ),
        child: TouchTarget(
          child: PressScale(
            scale: pantasPressScale,
            child: overlayRing
                ? WebBackLinkRing(child: link)
                : OffsetFocusRing(borderRadius: radius, child: link),
          ),
        ),
      ),
    );
  }
}

/// The board's `.btn3.teal`: a natural-width text action. It is a tertiary
/// Button in the accent tone at 42 px (`btn--sm`), so it keeps a rounded
/// rectangle, never a pill.
class WebTextAction extends StatelessWidget {
  const WebTextAction({
    required this.label,
    required this.onPressed,
    this.height = PantasSize.btnSm,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;
  final double height;
  @override
  Widget build(BuildContext context) => WebButton(
        label: label,
        onPressed: onPressed,
        kind: PantasButtonKind.tertiary,
        tone: PantasButtonTone.accent,
        size: PantasButtonSize.sm,
        height: height == PantasSize.btnSm ? null : height,
      );
}

/// One column of the board's date picker (`.pk`): five rows 2 px apart around
/// the chosen value, 120 px wide. A row is the larger of 36 (`size-wheel-row`)
/// and the scaled line plus 16, so the rows and the band follow large text
/// (D190 item 6). The chosen row is accent on the tint
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
  static const double _width = PantasSpace.s40 * 3;

  /// The row height: the larger of `size-wheel-row` and the scaled line
  /// plus 16.
  double _row(BuildContext context) {
    final line = MediaQuery.textScalerOf(context)
            .scale(PantasType.webRowTitle.fontSize!) *
        PantasType.webRowTitle.height!;
    return line + PantasSpace.s16 > PantasSize.wheelRow
        ? line + PantasSpace.s16
        : PantasSize.wheelRow;
  }

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PantasDurations.medium1,
    value: 1,
  );
  late double _from = widget.selectedIndex.toDouble();

  /// Where the rows are, as the index shown in the middle slot.
  double get _position {
    final to = widget.selectedIndex.toDouble();
    return _from +
        (to - _from) * PantasCurves.move.transform(_controller.value);
  }

  @override
  void didUpdateWidget(WebPickerColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == oldWidget.selectedIndex) return;
    final to = widget.selectedIndex.toDouble();
    final here = _from +
        (oldWidget.selectedIndex - _from) *
            PantasCurves.move.transform(_controller.value);
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
    final row = _row(context);
    return Semantics(
      button: true,
      selected: chosen,
      enabled: !disabled,
      label: '${widget.label} ${widget.values[index]}',
      excludeSemantics: true,
      child: TextButton(
        onPressed: disabled || chosen ? null : () => widget.onSelected(index),
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(_width, row)),
          maximumSize: WidgetStatePropertyAll(Size(_width, row)),
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
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PantasRadius.sm),
            ),
          ),
        ),
        child: Text(
          widget.values[index],
          style: PantasType.webRowTitle.copyWith(
            fontWeight: chosen ? FontWeight.w700 : FontWeight.w400,
            color: chosen
                ? t.colors.accent
                : disabled
                    ? t.disabledText
                    : t.colors.textSecondary,
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
        child: Builder(
          builder: (context) {
            final row = _row(context);
            final pitch = row + PantasSpace.s2;
            final height = row * 5 + PantasSpace.s2 * 4;
            return SizedBox(
              width: _width,
              height: height,
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
                          if ((index - position + 2) * pitch case final top
                              when top + row > 0 && top < height)
                            Positioned(
                              top: top,
                              left: 0,
                              width: _width,
                              height: row,
                              child: _rowAt(context, index),
                            ),
                    ],
                  );
                },
              ),
            );
          },
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
        // `scrim` (z-overlay): one recipe for every modal.
        barrierColor: context.webTokens.colors.scrim,
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

  /// The "P" mark is a square of this size.
  static const double _markSize = PantasSpace.s56 + PantasSpace.s4;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Scaffold(
      backgroundColor: t.colors.bgPage,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s24),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: Container(
                    key: const ValueKey('web-notice-mark'),
                    width: _markSize,
                    height: _markSize,
                    decoration: BoxDecoration(
                      color: t.colors.accentFill,
                      borderRadius: BorderRadius.circular(PantasRadius.xl),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'P',
                      style: PantasType.webH1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: t.colors.onAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: PantasSpace.s16),
                Text(title, textAlign: TextAlign.center, style: t.h2),
                if (lead != null) ...[
                  const SizedBox(height: PantasSpace.s16),
                  Text(
                    lead!,
                    textAlign: TextAlign.center,
                    style: PantasType.webLead
                        .copyWith(color: t.colors.textSecondary),
                  ),
                ],
                const SizedBox(height: PantasSpace.s16),
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
