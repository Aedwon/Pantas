import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PennantMark extends StatefulWidget {
  const PennantMark({
    required this.isSet,
    this.size = 21.0,
    this.color,
    this.animate = true,
    super.key,
  });

  final bool isSet;
  final double size;
  final Color? color;
  final bool animate;

  @override
  State<PennantMark> createState() => _PennantMarkState();
}

class _PennantMarkState extends State<PennantMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _sweep = Duration(milliseconds: 400);
  static const _curve = Cubic(0.22, 1, 0.36, 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.isSet ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(PennantMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSet != widget.isSet) {
      _sync();
    }
  }

  void _sync() {
    if (!widget.isSet) {
      // An outgoing mark does not animate.
      _controller.value = 0;
      return;
    }
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.animate && !reduceMotion) {
      _controller.animateTo(1, duration: _sweep, curve: _curve);
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultColor = widget.isSet ? colors.ink : colors.inkMuted;
    final effectiveColor = widget.color ?? defaultColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _PennantPainter(
              color: effectiveColor,
              fillProgress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _PennantPainter extends CustomPainter {
  const _PennantPainter({
    required this.color,
    required this.fillProgress,
  });

  final Color color;
  final double fillProgress;

  static Path _staffPath(double scale) => Path()
    ..moveTo(6 * scale, 3.2 * scale)
    ..relativeLineTo(0, 17.6 * scale);

  static Path _pennantPath(double scale) => Path()
    ..moveTo(6 * scale, 4.4 * scale)
    ..relativeLineTo(12.2 * scale, 0)
    ..lineTo(14 * scale, 9 * scale)
    ..lineTo(18.2 * scale, 13.6 * scale)
    ..lineTo(6 * scale, 13.6 * scale)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    if (fillProgress > 0) {
      canvas
        ..save()
        ..clipRect(
          Rect.fromLTWH(0, 0, size.width * fillProgress, size.height),
        )
        ..drawPath(
          _pennantPath(scale),
          Paint()
            ..style = PaintingStyle.fill
            ..color = color,
        )
        ..restore();
    }
    canvas
      ..drawPath(_staffPath(scale), stroke)
      ..drawPath(_pennantPath(scale), stroke);
  }

  @override
  bool shouldRepaint(covariant _PennantPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.fillProgress != fillProgress;
  }
}
