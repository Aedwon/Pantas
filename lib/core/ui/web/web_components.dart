import 'package:flutter/material.dart';
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
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final WebButtonVariant variant;
  final bool large;
  final bool pill;
  final String? keyHint;
  final bool busy;

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
        : danger
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

    final radius = pill
        ? 99.0
        : large
            ? 14.0
            : 12.0;
    final height = pill
        ? 46.0
        : large
            ? 50.0
            : 44.0;
    return Align(
      widthFactor: 1,
      heightFactor: 1,
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: busy ? null : onPressed,
        style: ButtonStyle(
          animationDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 150),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.standard,
          minimumSize: WidgetStatePropertyAll(Size(0, height)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.only(
              left: pill
                  ? 22
                  : variant == WebButtonVariant.tertiary
                      ? 14
                      : variant == WebButtonVariant.secondary ||
                              variant == WebButtonVariant.white ||
                              variant == WebButtonVariant.dangerOutline
                          ? 18
                          : 20,
              right: pill || showKeyHint
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
                          ? (t.dark ? t.cardEdge : c.separator)
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
            t.style(large ? 17 : 16, weight: FontWeight.w600, height: 1.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
            Flexible(child: Text(label)),
            if (showKeyHint) ...[
              const SizedBox(width: 12),
              WebKeyHint(keyHint!, onButton: true, enabled: onPressed != null),
            ],
          ],
        ),
      ),
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
  const WebTextLink({required this.label, required this.onPressed, super.key});
  final String label;
  final VoidCallback onPressed;
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
            const SizedBox(width: 4),
            AnimatedContainer(
              transform: Matrix4.translationValues(_hover ? 4 : 0, 0, 0),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              child: const Text('→'),
            ),
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
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: t.dark ? Border.all(color: t.cardEdge) : null,
      ),
      padding: padding,
      child: child,
    );
  }
}

class WebRow extends StatelessWidget {
  const WebRow({
    required this.title,
    this.subtitle,
    this.wrapTitle = false,
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
    super.key,
  });
  final String title;
  final bool wrapTitle;
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
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    return Opacity(
      opacity: dimmed ? .45 : 1,
      child: Semantics(
        selected: selected,
        child: TextButton(
          onPressed: dimmed ? null : onPressed,
          style: ButtonStyle(
            animationDuration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 150),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: horizontalPadding),
            ),
            minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 0)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
            backgroundColor: WidgetStateProperty.resolveWith(
              (s) => selected
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
              if (leading != null) ...[leading!, const SizedBox(width: 16)],
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: compact ? 12 : 15),
                  decoration: BoxDecoration(
                    border: divider
                        ? Border(
                            bottom: BorderSide(
                              color: t.colors.separator,
                              width: .5,
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
                            if (titleSuffix == null)
                              Text(
                                title,
                                maxLines: large || wrapTitle ? null : 1,
                                overflow: large || wrapTitle
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: titleStyle ??
                                    t.style(17, color: titleColor),
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      title,
                                      maxLines: large || wrapTitle ? null : 1,
                                      overflow: large || wrapTitle
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                      style: titleStyle ??
                                          t.style(17, color: titleColor),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  titleSuffix!,
                                ],
                              ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                maxLines: large || wrapTitle ? null : 1,
                                overflow: large || wrapTitle
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: t.style(
                                  14,
                                  color: t.colors.secondaryLabel,
                                ),
                              ),
                            if (large && value != null)
                              Text(value!, style: valueStyle ?? t.sub),
                          ],
                        ),
                      ),
                      if (!large && value != null) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            value!,
                            style: valueStyle ?? t.sub,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
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
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12),
                      ),
                      foregroundColor: WidgetStatePropertyAll(t.colors.label),
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
    super.key,
  });
  final String counter;
  final VoidCallback? onCounterPressed;
  final Widget action;
  final Widget? leading;
  final String? hint;
  final WebBarState state;
  final bool wide;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final c = t.colors;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: wide ? 1080 : 720),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.fromLTRB(8, 0, 10, 0),
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
            if (leading != null) leading!,
            if (onCounterPressed == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
                  textStyle: t.style(15, weight: FontWeight.w600).copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
                child: Text(counter),
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
            action,
          ],
        ),
      ),
    );
  }
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
