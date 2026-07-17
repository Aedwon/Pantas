import 'dart:math' as math;

import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/core/ui/theme/theme_preference.dart';
import 'package:flutter/material.dart';

/// The theme switch, which is the settings switch at three positions: a
/// hairline enclosure with the live segment filled solid ink.
///
/// This is the only component in the application permitted to draw an icon.
/// A theme control is the one control whose subject is the appearance itself,
/// so a sun and a crescent are the subject rather than decoration. Do not
/// generalize from this.
class ThemeControl extends StatelessWidget {
  const ThemeControl({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ThemePreference value;
  final ValueChanged<ThemePreference> onChanged;

  static const double height = 22;
  static const double segmentWidth = 30;
  static const double markSize = 12;

  static const double _stroke = 1.2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: segmentWidth * 3,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.rule, width: _stroke),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Row(
          children: [
            Expanded(
              child: _segment(
                context,
                ThemePreference.light,
                'Light theme',
                _Mark.sun,
              ),
            ),
            _divider(colors.rule),
            Expanded(
              child: _segment(
                context,
                ThemePreference.dark,
                'Dark theme',
                _Mark.moon,
              ),
            ),
            _divider(colors.rule),
            Expanded(
              child: _segment(
                context,
                ThemePreference.system,
                'Follow my phone',
                _Mark.half,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(Color color) =>
      SizedBox(width: _stroke, child: ColoredBox(color: color));

  Widget _segment(
    BuildContext context,
    ThemePreference preference,
    String label,
    _Mark mark,
  ) {
    final colors = context.colors;
    final live = preference == value;

    return Semantics(
      label: label,
      button: true,
      selected: live,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(preference),
        child: ColoredBox(
          color: live ? colors.ink : Colors.transparent,
          child: Center(
            child: CustomPaint(
              size: const Size.square(markSize),
              painter: _MarkPainter(
                mark: mark,
                color: live ? colors.background : colors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Mark { sun, moon, half }

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.mark, required this.color});

  final _Mark mark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    switch (mark) {
      case _Mark.sun:
        canvas.drawCircle(center, size.width * 0.19, stroke);
        for (var i = 0; i < 8; i++) {
          final angle = (math.pi / 4) * i;
          final unit = Offset(math.cos(angle), math.sin(angle));
          canvas.drawLine(
            center + unit * (size.width * 0.31),
            center + unit * (size.width * 0.47),
            stroke,
          );
        }
      case _Mark.moon:
        final outer = Path()
          ..addOval(Rect.fromCircle(center: center, radius: size.width * 0.42));
        final bite = Path()
          ..addOval(
            Rect.fromCircle(
              center: center.translate(size.width * 0.26, -size.width * 0.26),
              radius: size.width * 0.42,
            ),
          );
        canvas.drawPath(
          Path.combine(PathOperation.difference, outer, bite),
          stroke,
        );
      case _Mark.half:
        final rect = Rect.fromCircle(center: center, radius: size.width * 0.4);
        canvas.drawCircle(center, size.width * 0.4, stroke);
        canvas.drawArc(rect, math.pi / 2, math.pi, true, fill);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.mark != mark || old.color != color;
}
