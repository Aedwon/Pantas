import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A hairline chevron. Material's `Icons.chevron_right` is a filled glyph and
/// cannot be drawn at stroke 1.4, which is what the row rule asks for.
///
/// Pointing down is a disclosure that is open; pointing right is either a
/// closed disclosure or a link.
class InkChevron extends StatelessWidget {
  const InkChevron({this.size = 12, this.pointsDown = false, super.key});

  final double size;
  final bool pointsDown;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: pointsDown ? 0.25 : 0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: CustomPaint(
        size: Size.square(size),
        painter: _ChevronPainter(color: context.colors.inkMuted),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final brush = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Inset so the stroke's own width stays inside the box rather than
    // clipping against it.
    final inset = size.width * 0.28;
    final path = Path()
      ..moveTo(inset, inset * 0.6)
      ..lineTo(size.width - inset, size.height / 2)
      ..lineTo(inset, size.height - inset * 0.6);

    canvas.drawPath(path, brush);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}
