import 'package:flutter/material.dart';

enum OwnIconKind {
  questionsSheet,
  report,
  paused,
  streak,
  progressError,
  reorder,
  appearance,
  backup,
  about
}

class OwnIcon extends StatelessWidget {
  const OwnIcon(this.kind, {super.key});
  final OwnIconKind kind;
  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final color =
        (theme.color ?? Colors.black).withValues(alpha: theme.opacity ?? 1);
    final size = theme.size ?? 24;
    final painter = switch (kind) {
      OwnIconKind.questionsSheet => QuestionsSheetPainter(color),
      OwnIconKind.report => ReportPainter(color),
      OwnIconKind.paused => PausedPainter(color),
      OwnIconKind.streak => StreakPainter(color),
      OwnIconKind.progressError => ProgressErrorPainter(color),
      OwnIconKind.reorder => ReorderPainter(color),
      OwnIconKind.appearance => AppearancePainter(color),
      OwnIconKind.backup => BackupPainter(color),
      OwnIconKind.about => AboutPainter(color),
    };
    return CustomPaint(size: Size.square(size), painter: painter);
  }
}

/// Native 24-point outlines copied from IC_Final.
abstract class OwnIconPainter extends CustomPainter {
  const OwnIconPainter(this.color);
  final Color color;
  double get strokeWidth => 1.5;
  StrokeCap get strokeCap => StrokeCap.round;
  StrokeJoin get strokeJoin => StrokeJoin.round;
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 24, size.height / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap
      ..strokeJoin = strokeJoin;
    draw(canvas, stroke);
    canvas.restore();
  }

  void draw(Canvas canvas, Paint stroke);
  @override
  bool shouldRepaint(covariant OwnIconPainter oldDelegate) =>
      color != oldDelegate.color || runtimeType != oldDelegate.runtimeType;
}

class QuestionsSheetPainter extends OwnIconPainter {
  const QuestionsSheetPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(5.5, 5.5), 2.6, stroke)
      ..drawCircle(const Offset(12, 5.5), 2.6, stroke)
      ..drawCircle(const Offset(18.5, 5.5), 2.6, stroke)
      ..drawCircle(const Offset(5.5, 12), 2.6, stroke)
      ..drawCircle(const Offset(12, 12), 2.6, stroke)
      ..drawCircle(const Offset(18.5, 12), 2.6, stroke)
      ..drawCircle(const Offset(5.5, 18.5), 2.6, stroke)
      ..drawCircle(const Offset(12, 18.5), 2.6, stroke)
      ..drawCircle(const Offset(18.5, 18.5), 2.6, stroke);
  }
}

class ReportPainter extends OwnIconPainter {
  const ReportPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    // Phosphor chat-circle has a filled outline: 16/256 * 24 = 1.5.
    canvas
      ..save()
      ..scale(24 / 256);
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // IC_Final SVG: M128,24A104,104,0,0,0,36.18,176.88L24.83,210.93a16,16,0,0,
    // 0,20.24,20.24l34.05-11.35A104,104,0,1,0,128,24Zm0,192a87.87,87.87,0,0,1-
    // 44.06-11.81,8,8,0,0,0-6.54-.67L40,216,52.47,178.6a8,8,0,0,0-.66-6.54A88,
    // 88,0,1,1,128,216Z
    canvas
      ..drawPath(
        Path()
          ..moveTo(128, 24)
          ..arcToPoint(
            const Offset(36.18, 176.88),
            radius: const Radius.elliptical(104, 104),
            clockwise: false,
          )
          ..lineTo(24.83, 210.93)
          ..arcToPoint(
            const Offset(45.07, 231.17),
            radius: const Radius.elliptical(16, 16),
            clockwise: false,
          )
          ..lineTo(79.12, 219.82)
          ..arcToPoint(
            const Offset(128, 24),
            radius: const Radius.elliptical(104, 104),
            largeArc: true,
            clockwise: false,
          )
          ..close()
          ..moveTo(128, 216)
          ..arcToPoint(
            const Offset(83.94, 204.19),
            radius: const Radius.elliptical(87.87, 87.87),
          )
          ..arcToPoint(
            const Offset(77.4, 203.52),
            radius: const Radius.elliptical(8, 8),
            clockwise: false,
          )
          ..lineTo(40, 216)
          ..lineTo(52.47, 178.6)
          ..arcToPoint(
            const Offset(51.81, 172.06),
            radius: const Radius.elliptical(8, 8),
            clockwise: false,
          )
          ..arcToPoint(
            const Offset(128, 216),
            radius: const Radius.elliptical(88, 88),
            largeArc: true,
          )
          ..close(),
        fill,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(120, 76, 16, 64),
          const Radius.circular(8),
        ),
        fill,
      )
      ..drawCircle(const Offset(128, 166), 12, fill)
      ..restore();
  }
}

class PausedPainter extends OwnIconPainter {
  const PausedPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    // IC_Final SVG: M6.5 3.5h11M6.5 20.5h11M7.5 3.5c0 4.5 4.5 5.5 4.5 8.5s-4.5
    // 4-4.5 8.5M16.5 3.5c0 4.5-4.5 5.5-4.5 8.5s4.5 4 4.5 8.5
    canvas.drawPath(
      Path()
        ..moveTo(6.5, 3.5)
        ..lineTo(17.5, 3.5)
        ..moveTo(6.5, 20.5)
        ..lineTo(17.5, 20.5)
        ..moveTo(7.5, 3.5)
        ..cubicTo(7.5, 8, 12, 9, 12, 12)
        ..cubicTo(12, 15, 7.5, 16, 7.5, 20.5)
        ..moveTo(16.5, 3.5)
        ..cubicTo(16.5, 8, 12, 9, 12, 12)
        ..cubicTo(12, 15, 16.5, 16, 16.5, 20.5),
      stroke,
    );
  }
}

class StreakPainter extends OwnIconPainter {
  const StreakPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    // IC_Final SVG: M12 21c3.9 0 6.5-2.6 6.5-6.3 0-3.2-2.2-5.5-3.6-7.4-.4
    // 1.8-1.4 2.8-2.7 3.2.3-3-.7-5.7-3-7.5.4 3.6-3.7 6-3.7 11.7 0 3.7 2.6 6.3
    // 6.5 6.3z
    canvas.drawPath(
      Path()
        ..moveTo(12, 21)
        ..cubicTo(15.9, 21, 18.5, 18.4, 18.5, 14.7)
        ..cubicTo(18.5, 11.5, 16.3, 9.2, 14.9, 7.3)
        ..cubicTo(14.5, 9.1, 13.5, 10.1, 12.2, 10.5)
        ..cubicTo(12.5, 7.5, 11.5, 4.8, 9.2, 3)
        ..cubicTo(9.6, 6.6, 5.5, 9, 5.5, 14.7)
        ..cubicTo(5.5, 18.4, 8.1, 21, 12, 21)
        ..close(),
      stroke,
    );
  }
}

class ProgressErrorPainter extends OwnIconPainter {
  const ProgressErrorPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    // IC_Final SVG: M4.5 20V13M9.5 20V8M14.5 20v-5M19.5 20V4.5
    canvas.drawPath(
      Path()
        ..moveTo(4.5, 20)
        ..lineTo(4.5, 13)
        ..moveTo(9.5, 20)
        ..lineTo(9.5, 8)
        ..moveTo(14.5, 20)
        ..lineTo(14.5, 15)
        ..moveTo(19.5, 20)
        ..lineTo(19.5, 4.5),
      stroke,
    );
  }
}

class ReorderPainter extends OwnIconPainter {
  const ReorderPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    // IC_Final SVG: M5 9h14M5 12h14M5 15h14
    canvas.drawPath(
      Path()
        ..moveTo(5, 9)
        ..lineTo(19, 9)
        ..moveTo(5, 12)
        ..lineTo(19, 12)
        ..moveTo(5, 15)
        ..lineTo(19, 15),
      stroke,
    );
  }
}

class AppearancePainter extends OwnIconPainter {
  const AppearancePainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(12, 12), 8, stroke)
      // IC_Final SVG: M12 4a8 8 0 0 1 0 16z
      ..drawPath(
        Path()
          ..moveTo(12, 4)
          ..arcToPoint(
            const Offset(12, 20),
            radius: const Radius.elliptical(8, 8),
          )
          ..close(),
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
  }
}

class BackupPainter extends OwnIconPainter {
  const BackupPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    // IC_Final SVG: M7.2 18.5h9.6a4 4 0 0 0 .6-7.95A5.6 5.6 0 0 0 6.6 9.7a4.4
    // 4.4 0 0 0 .6 8.8z
    canvas
      ..drawPath(
        Path()
          ..moveTo(7.2, 18.5)
          ..lineTo(16.8, 18.5)
          ..arcToPoint(
            const Offset(17.4, 10.55),
            radius: const Radius.elliptical(4, 4),
            clockwise: false,
          )
          ..arcToPoint(
            const Offset(6.6, 9.7),
            radius: const Radius.elliptical(5.6, 5.6),
            clockwise: false,
          )
          ..arcToPoint(
            const Offset(7.2, 18.5),
            radius: const Radius.elliptical(4.4, 4.4),
            clockwise: false,
          )
          ..close(),
        stroke,
      )
      // IC_Final SVG: m9.6 13.7 2.4-2.4 2.4 2.4M12 11.4v5
      ..drawPath(
        Path()
          ..moveTo(9.6, 13.7)
          ..lineTo(12, 11.3)
          ..lineTo(14.4, 13.7)
          ..moveTo(12, 11.4)
          ..lineTo(12, 16.4),
        stroke,
      );
  }
}

class AboutPainter extends OwnIconPainter {
  const AboutPainter(super.color);
  @override
  void draw(Canvas canvas, Paint stroke) {
    canvas
      ..drawCircle(const Offset(12, 12), 8.5, stroke)
      // IC_Final SVG: M12 11v5.5
      ..drawPath(
        Path()
          ..moveTo(12, 11)
          ..lineTo(12, 16.5),
        stroke,
      )
      // IC_Final SVG: M12 7.6v.1
      ..drawPath(
        Path()
          ..moveTo(12, 7.6)
          ..lineTo(12, 7.7),
        stroke,
      );
  }
}
