import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Original lesson diagrams for reading-comprehension concepts that need a
/// structured visual rather than an image asset.
class ReadingDiagramFigure extends StatelessWidget {
  const ReadingDiagramFigure._({
    required this.type,
    required Map<String, Object?> spec,
  }) : _spec = spec;

  static const kind = 'reading-diagram';

  final String type;
  final Map<String, Object?> _spec;

  static ReadingDiagramFigure? fromSpec(Map<String, Object?> spec) {
    if (spec['kind'] != kind || !_hasIllustrationKey(spec)) return null;
    final type = spec['type'];
    if (type is! String) return null;

    final valid = switch (type) {
      'plot-arc' => _validPlotArc(spec),
      'rhetorical-appeals' => _validRhetoricalAppeals(spec),
      _ => false,
    };
    if (!valid) return null;

    return ReadingDiagramFigure._(
      type: type,
      spec: Map<String, Object?>.unmodifiable(spec),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: type == 'plot-arc' ? 178 : 190,
      child: CustomPaint(
        size: Size.infinite,
        painter: _ReadingDiagramPainter(
          type: type,
          spec: _spec,
          ink: colors.label,
          inkMuted: colors.secondaryLabel,
          rule: colors.fill,
          board: colors.accent,
          labelStyle: context.type.subhead.copyWith(color: colors.label),
          mutedStyle: context.type.subhead.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ),
    );
  }
}

class _ReadingDiagramPainter extends CustomPainter {
  _ReadingDiagramPainter({
    required this.type,
    required this.spec,
    required this.ink,
    required this.inkMuted,
    required this.rule,
    required this.board,
    required this.labelStyle,
    required this.mutedStyle,
  });

  final String type;
  final Map<String, Object?> spec;
  final Color ink;
  final Color inkMuted;
  final Color rule;
  final Color board;
  final TextStyle labelStyle;
  final TextStyle mutedStyle;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'plot-arc':
        _paintPlotArc(canvas, size);
      case 'rhetorical-appeals':
        _paintRhetoricalAppeals(canvas, size);
    }
  }

  void _paintPlotArc(Canvas canvas, Size size) {
    final stages = _stringList(spec['stages'])!;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final faint = Paint()
      ..color = rule
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final point = Paint()
      ..color = board
      ..style = PaintingStyle.fill;

    final baselineY = size.height - 36;
    canvas.drawLine(
      Offset(18, baselineY),
      Offset(size.width - 18, baselineY),
      faint,
    );
    _arrow(canvas, Offset(18, baselineY), const Offset(18, 20), faint);
    canvas
      ..save()
      ..translate(5, baselineY - 6)
      ..rotate(-math.pi / 2);
    _label(
      canvas,
      'tension',
      Offset.zero,
      maxWidth: 48,
      style: mutedStyle,
    );
    canvas.restore();

    final points = <Offset>[
      Offset(size.width * 0.10, baselineY - 12),
      Offset(size.width * 0.38, size.height * 0.48),
      Offset(size.width * 0.64, size.height * 0.20),
      Offset(size.width * 0.90, baselineY - 18),
    ];
    final path = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..lineTo(points[3].dx, points[3].dy);
    canvas.drawPath(path, stroke);

    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4, point);
      final width = i == 1 ? 88.0 : 72.0;
      final x = (points[i].dx - width / 2).clamp(2.0, size.width - width - 2);
      _label(
        canvas,
        stages[i],
        Offset(x, baselineY + 7),
        maxWidth: width,
        style: mutedStyle,
        align: TextAlign.center,
      );
    }
  }

  void _paintRhetoricalAppeals(Canvas canvas, Size size) {
    final appeals = _mapList(spec['appeals'])!;
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final faint = Paint()
      ..color = rule
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final podium = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.46,
      size.width * 0.20,
      size.height * 0.34,
    );
    canvas
      ..drawRect(podium, stroke)
      ..drawLine(
        Offset(podium.left - 8, podium.top),
        Offset(podium.right + 8, podium.top),
        stroke,
      );
    _centeredLabel(
      canvas,
      spec['source']! as String,
      centerX: podium.center.dx,
      top: podium.bottom + 5,
      maxWidth: podium.width,
      style: mutedStyle,
    );

    final audienceX = size.width * 0.90;
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 2; col++) {
        final center = Offset(
          audienceX - col * 20,
          size.height * 0.60 + row * 26,
        );
        canvas
          ..drawCircle(center, 5, stroke)
          ..drawLine(
            Offset(center.dx, center.dy + 5),
            Offset(center.dx, center.dy + 18),
            stroke,
          );
      }
    }
    _centeredLabel(
      canvas,
      spec['target']! as String,
      centerX: audienceX - 10,
      top: size.height - 21,
      maxWidth: size.width * 0.22,
      style: mutedStyle,
    );

    final starts = <Offset>[
      Offset(podium.right + 6, podium.top + 8),
      Offset(podium.right + 6, podium.center.dy),
      Offset(podium.right + 6, podium.bottom - 8),
    ];
    final ends = <Offset>[
      Offset(size.width * 0.67, size.height * 0.20),
      Offset(size.width * 0.72, size.height * 0.43),
      Offset(size.width * 0.68, size.height * 0.70),
    ];

    for (var i = 0; i < appeals.length; i++) {
      _arrow(canvas, starts[i], ends[i], stroke);
      final label = '${appeals[i]['label']} (${appeals[i]['meaning']})';
      _label(
        canvas,
        label,
        Offset(ends[i].dx - 78, ends[i].dy - 28),
        maxWidth: 150,
        style: labelStyle,
        align: TextAlign.center,
      );
      canvas.drawLine(
        Offset(ends[i].dx + 4, ends[i].dy),
        Offset(audienceX - 16, size.height * (0.58 + 0.04 * i)),
        faint,
      );
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    final delta = to - from;
    final length = delta.distance;
    if (length == 0) return;
    final ux = delta.dx / length;
    final uy = delta.dy / length;
    final left = Offset(
      to.dx - ux * 9 - uy * 4,
      to.dy - uy * 9 + ux * 4,
    );
    final right = Offset(
      to.dx - ux * 9 + uy * 4,
      to.dy - uy * 9 - ux * 4,
    );
    canvas
      ..drawLine(to, left, paint)
      ..drawLine(to, right, paint);
  }

  void _label(
    Canvas canvas,
    String text,
    Offset offset, {
    required double maxWidth,
    required TextStyle style,
    TextAlign align = TextAlign.left,
  }) {
    TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 2,
    )
      ..layout(
        minWidth: align == TextAlign.center ? maxWidth : 0,
        maxWidth: maxWidth,
      )
      ..paint(canvas, offset);
  }

  void _centeredLabel(
    Canvas canvas,
    String text, {
    required double centerX,
    required double top,
    required double maxWidth,
    required TextStyle style,
  }) {
    _label(
      canvas,
      text,
      Offset(centerX - maxWidth / 2, top),
      maxWidth: maxWidth,
      style: style,
      align: TextAlign.center,
    );
  }

  @override
  bool shouldRepaint(_ReadingDiagramPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.spec.toString() != spec.toString() ||
        oldDelegate.ink != ink ||
        oldDelegate.inkMuted != inkMuted ||
        oldDelegate.rule != rule ||
        oldDelegate.board != board;
  }
}

bool _validPlotArc(Map<String, Object?> spec) {
  final stages = _stringList(spec['stages']);
  return spec['shape'] == 'rise-peak-fall' &&
      _sameStrings(
        stages,
        const <String>[
          'introduction',
          'rising action',
          'climax',
          'resolution',
        ],
      );
}

bool _validRhetoricalAppeals(Map<String, Object?> spec) {
  if (spec['source'] != 'podium' || spec['target'] != 'audience') {
    return false;
  }
  final appeals = _mapList(spec['appeals']);
  if (appeals == null || appeals.length != 3) return false;
  const expected = <(String, String)>[
    ('ethos', 'credibility'),
    ('pathos', 'emotion'),
    ('logos', 'logic'),
  ];
  for (var i = 0; i < expected.length; i++) {
    if (appeals[i]['label'] != expected[i].$1 ||
        appeals[i]['meaning'] != expected[i].$2) {
      return false;
    }
  }
  return true;
}

bool _hasIllustrationKey(Map<String, Object?> spec) {
  final key = spec['illustrationKey'];
  return key is String && key.trim().isNotEmpty;
}

List<String>? _stringList(Object? value) {
  if (value is! List || value.isEmpty) return null;
  final result = <String>[];
  for (final item in value) {
    if (item is! String || item.trim().isEmpty) return null;
    result.add(item);
  }
  return result;
}

List<Map<String, Object?>>? _mapList(Object? value) {
  if (value is! List || value.isEmpty) return null;
  final result = <Map<String, Object?>>[];
  for (final item in value) {
    if (item is! Map) return null;
    for (final key in item.keys) {
      if (key is! String) return null;
    }
    result.add(item.cast<String, Object?>());
  }
  return result;
}

bool _sameStrings(List<String>? actual, List<String> expected) {
  if (actual == null || actual.length != expected.length) return false;
  for (var i = 0; i < expected.length; i++) {
    if (actual[i] != expected[i]) return false;
  }
  return true;
}
