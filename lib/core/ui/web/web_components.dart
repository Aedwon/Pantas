import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/math_text.dart';
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
            : const Duration(milliseconds: 150),
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
    if (expand) return button;
    return Align(
      widthFactor: 1,
      heightFactor: 1,
      alignment: Alignment.centerLeft,
      child: button,
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
    return Container(
      clipBehavior: Clip.antiAlias,
      constraints:
          minHeight == null ? null : BoxConstraints(minHeight: minHeight!),
      alignment: minHeight == null ? null : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: selected
            ? (t.dark ? t.colors.accentTint : const Color(0xFFE4F1EE))
            : t.colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: t.dark && !selected ? Border.all(color: t.cardEdge) : null,
      ),
      // Drawn on top like the board inset outline; content stays put.
      foregroundDecoration: selected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: t.colors.accent, width: 2),
            )
          : null,
      padding: padding,
      child: child,
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

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final w = widget;
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final lineHeight = w.boardMetrics ? 1.3 : null;
    final hairline = w.boardMetrics ? webHairline(context) : .5;
    return Opacity(
      opacity: w.dimmed ? .45 : 1,
      child: Semantics(
        selected: w.selected,
        child: TextButton(
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
            backgroundColor: WidgetStateProperty.resolveWith(
              (s) => w.selected
                  ? t.colors.accentTint
                  : s.contains(WidgetState.hovered) ||
                          s.contains(WidgetState.focused)
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
                  padding: EdgeInsets.symmetric(vertical: w.compact ? 12 : 15),
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
                                style: t.style(
                                  14,
                                  color: t.colors.secondaryLabel,
                                  height: lineHeight,
                                ),
                              ),
                            if (large && w.value != null)
                              Text(w.value!, style: w.valueStyle ?? t.sub),
                          ],
                        ),
                      ),
                      if (!large && w.value != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          w.value!,
                          style: w.valueStyle ?? t.sub,
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
                            builder: (context, child) => Opacity(
                              opacity:
                                  _states.value.contains(WidgetState.hovered) ||
                                          _states.value
                                              .contains(WidgetState.focused)
                                      ? 1
                                      : 0,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  selected: selected == i,
                  child: TextButton(
                    onPressed: () => onChanged(i),
                    style: ButtonStyle(
                      animationDuration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 150),
                      elevation: WidgetStatePropertyAll(selected == i ? 1 : 0),
                      shadowColor: WidgetStatePropertyAll(
                        Colors.black.withValues(alpha: .1),
                      ),
                      minimumSize: const WidgetStatePropertyAll(Size(0, 34)),
                      visualDensity: VisualDensity.standard,
                      overlayColor:
                          const WidgetStatePropertyAll(Colors.transparent),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12),
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        accentLabels ? t.colors.accent : t.colors.label,
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        selected == i ? t.segmentOn : Colors.transparent,
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
      child: Container(
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
  const WebBackLink({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: const Offset(-6, 0),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.chevron_left, size: 20),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: t.colors.accent,
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
            textStyle: t.style(17),
          ),
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
