import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    super.key,
  });
  final String title;
  final bool selected;
  final bool mixed;
  final bool interactiveContent;
  final VoidCallback? onTap;
  final Widget? content;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => _SelectionRow(
        title: title,
        selected: selected,
        mixed: mixed,
        radio: false,
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
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

class _SelectionRow extends StatelessWidget {
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
  });
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
  Widget build(BuildContext context) {
    final c = context.colors;
    final web = context.webPlatform;
    final enabled = onTap != null;
    final row = Semantics(
      container: interactiveContent,
      explicitChildNodes: interactiveContent,
      label: interactiveContent ? title : null,
      checked: selected,
      mixed: mixed,
      inMutuallyExclusiveGroup: radio,
      enabled: enabled,
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
          padding: WidgetStatePropertyAll(padding),
          alignment: Alignment.centerLeft,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (!enabled) return Colors.transparent;
            if (web && states.contains(WidgetState.hovered)) {
              return context.webTokens.rowHover;
            }
            if (!web && states.contains(WidgetState.pressed)) {
              return c.separator.withValues(alpha: .3);
            }
            return Colors.transparent;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? BorderSide(color: c.accent, width: 2)
                : BorderSide.none,
          ),
        ),
        child: Opacity(
          opacity: enabled ? 1 : .45,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (preview != null) ...[preview!, const SizedBox(height: 12)],
              Row(
                children: [
                  if (showMark) ...[
                    ExcludeSemantics(
                      child: _SelectionMark(
                        selected: selected,
                        mixed: mixed,
                        radio: radio,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: content ?? Text(title, style: context.type.body),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return Row(
      children: [
        Expanded(child: interactiveContent ? row : MergeSemantics(child: row)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({
    required this.selected,
    required this.mixed,
    required this.radio,
  });
  final bool selected;
  final bool mixed;
  final bool radio;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = selected || mixed;
    return Container(
      key: const ValueKey('selection-mark'),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: on ? c.accentFill : null,
        borderRadius: BorderRadius.circular(radio ? 99 : 7),
        border: on ? null : Border.all(color: c.controlOutline, width: 1.5),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: on ? 1 : 0),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 220),
        curve: PantasCurves.popB,
        builder: (context, value, child) => Opacity(
          key: const ValueKey('selection-opacity'),
          opacity: value.clamp(0, 1),
          child: Transform.scale(
            key: const ValueKey('selection-scale'),
            scale: .5 + .5 * value,
            child: child,
          ),
        ),
        child: Center(
          child: mixed
              ? Container(width: 10, height: 2.5, color: c.onAccent)
              : SizedBox.square(
                  dimension: 16,
                  child: CustomPaint(painter: _SelectionCheck(c.onAccent)),
                ),
        ),
      ),
    );
  }
}

class _SelectionCheck extends CustomPainter {
  const _SelectionCheck(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 5 / 24, size.height * 12.5 / 24)
      ..lineTo(size.width * 9.5 / 24, size.height * 17 / 24)
      ..lineTo(size.width * 19 / 24, size.height * 7 / 24);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SelectionCheck oldDelegate) => oldDelegate.color != color;
}
