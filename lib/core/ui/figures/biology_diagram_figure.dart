import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Original lesson diagrams for the eight biology briefs in original-code-a.
class BiologyDiagramFigure extends StatelessWidget {
  const BiologyDiagramFigure._({
    required this.type,
    required Map<String, Object?> spec,
  }) : _spec = spec;

  static const kind = 'biology-diagram';

  final String type;
  final Map<String, Object?> _spec;

  static BiologyDiagramFigure? fromSpec(Map<String, Object?> spec) {
    if (spec['kind'] != kind || !_hasIllustrationKey(spec)) return null;
    final type = spec['type'];
    if (type is! String) return null;

    final valid = switch (type) {
      'stem-tissues' => _validStemTissues(spec),
      'cell-protein-flow' => _validCellProteinFlow(spec),
      'photosynthesis-respiration-cycle' => _validMetabolismCycle(spec),
      'organelle-comparison' => _validOrganelleComparison(spec),
      'mitosis-stages' => _validMitosis(spec),
      'energy-pyramid' => _validEnergyPyramid(spec),
      'natural-selection-generations' => _validNaturalSelection(spec),
      'heart-circulation' => _validHeart(spec),
      _ => false,
    };
    if (!valid) return null;

    return BiologyDiagramFigure._(
      type: type,
      spec: Map<String, Object?>.unmodifiable(spec),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 210,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BiologyDiagramPainter(
          type: type,
          spec: _spec,
          ink: colors.label,
          inkMuted: colors.secondaryLabel,
          rule: colors.fill,
          board: colors.accent,
          boardTint: colors.accentTint,
          labelStyle: context.type.subhead.copyWith(color: colors.label),
          mutedStyle: context.type.subhead.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ),
    );
  }
}

class _BiologyDiagramPainter extends CustomPainter {
  _BiologyDiagramPainter({
    required this.type,
    required this.spec,
    required this.ink,
    required this.inkMuted,
    required this.rule,
    required this.board,
    required this.boardTint,
    required this.labelStyle,
    required this.mutedStyle,
  });

  final String type;
  final Map<String, Object?> spec;
  final Color ink;
  final Color inkMuted;
  final Color rule;
  final Color board;
  final Color boardTint;
  final TextStyle labelStyle;
  final TextStyle mutedStyle;

  Paint get _stroke => Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  Paint get _faint => Paint()
    ..color = rule
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Paint get _semanticStroke => Paint()
    ..color = board
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  Paint get _semanticFill => Paint()..color = board;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'stem-tissues':
        _paintStemTissues(canvas, size);
      case 'cell-protein-flow':
        _paintCell(canvas, size);
      case 'photosynthesis-respiration-cycle':
        _paintMetabolismCycle(canvas, size);
      case 'organelle-comparison':
        _paintOrganelles(canvas, size);
      case 'mitosis-stages':
        _paintMitosis(canvas, size);
      case 'energy-pyramid':
        _paintEnergyPyramid(canvas, size);
      case 'natural-selection-generations':
        _paintNaturalSelection(canvas, size);
      case 'heart-circulation':
        _paintHeart(canvas, size);
    }
  }

  void _paintStemTissues(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.36, size.height * 0.50);
    final radius = math.min(size.width * 0.25, size.height * 0.40);
    canvas
      ..drawCircle(center, radius, _stroke)
      ..drawCircle(center, radius * 0.82, _faint);

    final bundlePaint = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final c = Offset(
        center.dx + math.cos(angle) * radius * 0.58,
        center.dy + math.sin(angle) * radius * 0.58,
      );
      canvas
        ..drawCircle(c, 8, bundlePaint)
        ..drawLine(
          Offset(c.dx - 3, c.dy - 5),
          Offset(c.dx - 3, c.dy + 5),
          _faint,
        )
        ..drawLine(
          Offset(c.dx + 3, c.dy - 5),
          Offset(c.dx + 3, c.dy + 5),
          _faint,
        );
    }

    _leaderLabel(
      canvas,
      spec['outer']! as String,
      Offset(
        center.dx + math.cos(-math.pi / 4) * radius,
        center.dy + math.sin(-math.pi / 4) * radius,
      ),
      Offset(size.width * 0.66, 28),
    );
    final vascular = (spec['vascular']! as Map).cast<String, Object?>();
    final components = _stringList(vascular['components'])!;
    const vascularAngle = -math.pi / 4;
    _leaderLabel(
      canvas,
      '${vascular['label']}\n${components.join(' + ')}',
      Offset(
        center.dx + math.cos(vascularAngle) * radius * 0.58,
        center.dy + math.sin(vascularAngle) * radius * 0.58,
      ),
      Offset(size.width * 0.66, 82),
    );
    _leaderLabel(
      canvas,
      spec['ground']! as String,
      Offset(
        center.dx + math.cos(math.pi / 6) * radius * 0.82,
        center.dy + math.sin(math.pi / 6) * radius * 0.82,
      ),
      Offset(size.width * 0.66, 142),
    );
  }

  void _paintCell(Canvas canvas, Size size) {
    final cellRect = Rect.fromLTWH(18, 18, size.width - 36, size.height - 38);
    canvas.drawOval(cellRect, _stroke);

    final nucleus = Offset(size.width * 0.28, size.height * 0.48);
    canvas.drawCircle(nucleus, 28, _stroke);
    _label(canvas, 'nucleus', Offset(nucleus.dx - 24, nucleus.dy - 8), 54);

    final mito = Rect.fromCenter(
      center: Offset(size.width * 0.72, size.height * 0.31),
      width: 54,
      height: 24,
    );
    canvas
      ..drawOval(mito, _stroke)
      ..drawArc(mito.deflate(6), 0, math.pi * 1.6, false, _faint);
    _label(canvas, 'mitochondria', Offset(mito.left - 8, mito.bottom + 5), 74);

    final rough = Rect.fromLTWH(size.width * 0.43, 60, 74, 28);
    final smooth = Rect.fromLTWH(size.width * 0.43, 116, 74, 24);
    canvas
      ..drawRect(rough, _stroke)
      ..drawRect(smooth, _faint);
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(rough.left + 8 + i * 13, rough.top - 3),
        2.2,
        Paint()..color = ink,
      );
    }
    _label(canvas, 'rough ER', Offset(rough.left + 8, rough.top + 7), 62);
    _label(canvas, 'smooth ER', Offset(smooth.left + 7, smooth.top + 5), 62);

    final ribosomeTarget = Offset(rough.left + 8, rough.top - 3);
    _callout(canvas, ribosomeTarget, Offset(size.width * 0.19, 28), ink);
    _label(
      canvas,
      'ribosomes',
      Offset(size.width * 0.08, 8),
      size.width * 0.28,
      align: TextAlign.center,
    );

    final golgiX = size.width * 0.73;
    for (var i = 0; i < 4; i++) {
      final y = size.height * 0.58 + i * 7;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(golgiX, y),
          width: 54 - i * 5,
          height: 16,
        ),
        math.pi * 0.12,
        math.pi * 0.76,
        false,
        _stroke,
      );
    }
    _label(
      canvas,
      'Golgi apparatus',
      Offset(golgiX - 42, size.height * 0.76),
      88,
    );

    final proteinPath = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final proteinStart = Offset(rough.left + 8, rough.top - 3);
    final proteinTurn = Offset(rough.left - 5, size.height * 0.52);
    final proteinEnd = Offset(golgiX - 28, size.height * 0.62);
    canvas.drawLine(proteinStart, proteinTurn, proteinPath);
    _arrow(canvas, proteinTurn, proteinEnd, proteinPath);
    _label(
      canvas,
      'protein flow',
      Offset(size.width * 0.36, size.height * 0.86),
      size.width * 0.34,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
  }

  void _paintMetabolismCycle(Canvas canvas, Size size) {
    final photosynthesis =
        (spec['photosynthesis']! as Map).cast<String, Object?>();
    final respiration = (spec['respiration']! as Map).cast<String, Object?>();
    final left = Rect.fromLTWH(20, 64, size.width * 0.30, 68);
    final right = Rect.fromLTWH(size.width * 0.66, 64, size.width * 0.28, 68);
    final semantic = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas
      ..drawOval(left, semantic)
      ..drawOval(right, _stroke);
    _label(
      canvas,
      photosynthesis['organelle']! as String,
      Offset(left.left + 8, left.top + 19),
      left.width - 16,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'photosynthesis',
      Offset(left.left + 8, left.top + 41),
      left.width - 16,
      align: TextAlign.center,
    );
    _label(
      canvas,
      respiration['organelle']! as String,
      Offset(right.left + 6, right.top + 19),
      right.width - 12,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'cellular respiration',
      Offset(right.left + 4, right.top + 41),
      right.width - 8,
      align: TextAlign.center,
    );

    _arrow(
      canvas,
      Offset(left.right, left.center.dy - 12),
      Offset(right.left, right.center.dy - 12),
      _stroke,
    );
    _label(
      canvas,
      'glucose + oxygen',
      Offset(size.width * 0.37, 38),
      size.width * 0.27,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _arrow(
      canvas,
      Offset(right.left, right.center.dy + 12),
      Offset(left.right, left.center.dy + 12),
      _stroke,
    );
    _label(
      canvas,
      'carbon dioxide + water',
      Offset(size.width * 0.36, 142),
      size.width * 0.29,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'sunlight + carbon dioxide + water',
      const Offset(8, 8),
      size.width * 0.42,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _arrow(
      canvas,
      Offset(left.center.dx, 42),
      Offset(left.center.dx, left.top),
      _stroke,
    );
    _label(
      canvas,
      'ATP',
      Offset(right.center.dx - 28, 178),
      56,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _arrow(
      canvas,
      Offset(right.center.dx, right.bottom),
      Offset(right.center.dx, 174),
      _stroke,
    );
  }

  void _paintOrganelles(Canvas canvas, Size size) {
    final semantic = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final chloroplast = Rect.fromCenter(
      center: Offset(size.width * 0.28, size.height * 0.46),
      width: size.width * 0.34,
      height: 90,
    );
    canvas.drawOval(chloroplast, semantic);
    for (var i = 0; i < 4; i++) {
      final x = chloroplast.left + 28 + i * 22;
      canvas
        ..drawLine(
          Offset(x, chloroplast.top + 24),
          Offset(x, chloroplast.bottom - 24),
          semantic,
        )
        ..drawLine(
          Offset(x + 5, chloroplast.top + 28),
          Offset(x + 5, chloroplast.bottom - 28),
          semantic,
        );
    }
    _label(
      canvas,
      'chloroplast',
      Offset(chloroplast.left, chloroplast.bottom + 9),
      chloroplast.width,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'photosynthesis',
      Offset(chloroplast.left, chloroplast.bottom + 29),
      chloroplast.width,
      style: mutedStyle,
      align: TextAlign.center,
    );

    final mito = Rect.fromCenter(
      center: Offset(size.width * 0.73, size.height * 0.46),
      width: size.width * 0.34,
      height: 90,
    );
    final bean = _beanPath(mito);
    canvas.drawPath(bean, _stroke);
    final cristae = Path()..moveTo(mito.left + 24, mito.center.dy - 2);
    for (var i = 0; i < 5; i++) {
      final x = mito.left + 24 + i * 20;
      cristae
        ..cubicTo(
          x - 8,
          mito.center.dy - 18,
          x + 8,
          mito.center.dy - 18,
          x + 3,
          mito.center.dy - 2,
        )
        ..cubicTo(
          x - 2,
          mito.center.dy + 14,
          x + 10,
          mito.center.dy + 14,
          x + 9,
          mito.center.dy + 18,
        );
    }
    canvas.drawPath(cristae, _stroke);
    _label(
      canvas,
      'mitochondrion',
      Offset(mito.left, mito.bottom + 9),
      mito.width,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'cellular respiration',
      Offset(mito.left, mito.bottom + 29),
      mito.width,
      style: mutedStyle,
      align: TextAlign.center,
    );
  }

  void _paintMitosis(Canvas canvas, Size size) {
    final stages = _mapList(spec['stages'])!;
    final slot = size.width / stages.length;
    for (var i = 0; i < stages.length; i++) {
      final center = Offset(slot * (i + 0.5), 84);
      canvas.drawCircle(center, math.min(slot * 0.31, 35), _stroke);
      if (i == 0) {
        _drawXChromosomes(canvas, center, _stroke, scale: 0.78);
      } else if (i == 1) {
        _drawXChromosomes(canvas, center, _stroke, scale: 0.70);
      } else if (i == 2) {
        for (final side in <double>[-1, 1]) {
          for (var j = -1; j <= 1; j++) {
            _drawChromatid(
              canvas,
              Offset(center.dx + side * 19, center.dy + j * 11),
              side,
              _stroke,
            );
          }
        }
      } else {
        canvas
          ..drawCircle(Offset(center.dx - 15, center.dy), 13, _faint)
          ..drawCircle(Offset(center.dx + 15, center.dy), 13, _faint);
        for (final nucleusCenter in <Offset>[
          Offset(center.dx - 15, center.dy),
          Offset(center.dx + 15, center.dy),
        ]) {
          for (var j = -1; j <= 1; j++) {
            canvas.drawLine(
              Offset(nucleusCenter.dx - 4, nucleusCenter.dy + j * 5),
              Offset(nucleusCenter.dx + 4, nucleusCenter.dy + j * 5),
              _faint,
            );
          }
        }
      }
      _label(
        canvas,
        stages[i]['phase']! as String,
        Offset(slot * i + 2, 133),
        slot - 4,
        align: TextAlign.center,
      );
      _label(
        canvas,
        stages[i]['state']! as String,
        Offset(slot * i + 3, 153),
        slot - 6,
        style: mutedStyle,
        align: TextAlign.center,
        maxLines: 3,
      );
    }
  }

  void _paintEnergyPyramid(Canvas canvas, Size size) {
    final levels = _mapList(spec['levels'])!;
    final centerX = size.width * 0.50;
    const baseWidthFactor = 0.78;
    const topWidthFactor = 0.24;
    final levelHeight = (size.height - 24) / levels.length;
    final pyramidStyle = labelStyle.copyWith(
      fontSize: (labelStyle.fontSize ?? 12) * 0.78,
      height: 1,
    );
    for (var i = 0; i < levels.length; i++) {
      final fromBottom = i;
      final t = fromBottom / (levels.length - 1);
      final width = size.width *
          (baseWidthFactor + (topWidthFactor - baseWidthFactor) * t);
      final y = size.height - 12 - levelHeight * (i + 1);
      final rect = Rect.fromLTWH(
        centerX - width / 2,
        y,
        width,
        levelHeight - 3,
      );
      canvas.drawRect(rect, i == 0 ? _stroke : _faint);
      TextPainter(
        text: TextSpan(
          text: _pyramidLabel(levels[i]),
          style: i == 0 ? pyramidStyle.copyWith(color: board) : pyramidStyle,
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 2,
      )
        ..layout(minWidth: rect.width - 12, maxWidth: rect.width - 12)
        ..paint(canvas, Offset(rect.left + 6, rect.center.dy - 9));
    }
  }

  void _paintNaturalSelection(Canvas canvas, Size size) {
    final generations = spec['generations']! as int;
    final slot = size.width / generations;
    for (var generation = 0; generation < generations; generation++) {
      final x = slot * (generation + 0.5);
      _label(
        canvas,
        'generation ${generation + 1}',
        Offset(slot * generation + 2, 10),
        slot - 4,
        style: mutedStyle,
        align: TextAlign.center,
      );
      final preferredBeak = 9.0 + generation * 4;
      final lessSuitedCount = 2 - generation;
      for (var bird = 0; bird < 4; bird++) {
        final y = 62.0 + bird * 28;
        final head = Offset(x - 8, y);
        canvas.drawCircle(head, 9, _stroke);
        final lessSuited = bird >= 4 - lessSuitedCount;
        final beakLength = lessSuited ? 5.0 : preferredBeak;
        final beak = Path()
          ..moveTo(head.dx + 8, head.dy - 4)
          ..lineTo(head.dx + 8 + beakLength, head.dy)
          ..lineTo(head.dx + 8, head.dy + 4)
          ..close();
        canvas.drawPath(beak, lessSuited ? _faint : _stroke);
        if (!lessSuited) {
          canvas.drawLine(
            Offset(head.dx + 8 + beakLength, head.dy),
            Offset(x + 42, 44),
            _semanticStroke,
          );
        }
      }
      for (var food = 0; food < 3; food++) {
        canvas.drawCircle(
          Offset(x + 42 + (food.isEven ? 0 : 5), 40 + food * 5),
          2.5,
          _semanticFill,
        );
      }
    }
    _label(
      canvas,
      'available food',
      const Offset(12, 174),
      size.width * 0.28,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      spec['selection']! as String,
      Offset(size.width * 0.29, 174),
      size.width * 0.67,
      style: mutedStyle,
      align: TextAlign.center,
    );
  }

  void _paintHeart(Canvas canvas, Size size) {
    final chamberWidth = size.width * 0.19;
    const chamberHeight = 48.0;
    final left = size.width * 0.31;
    final right = size.width * 0.50;
    const top = 42.0;
    const bottom = 102.0;
    final chambers = <Rect>[
      Rect.fromLTWH(left, top, chamberWidth, chamberHeight),
      Rect.fromLTWH(right, top, chamberWidth, chamberHeight),
      Rect.fromLTWH(left, bottom, chamberWidth, chamberHeight),
      Rect.fromLTWH(right, bottom, chamberWidth, chamberHeight),
    ];
    const labels = <String>[
      'right atrium',
      'left atrium',
      'right ventricle',
      'left ventricle',
    ];
    for (var i = 0; i < chambers.length; i++) {
      canvas.drawRect(chambers[i], _stroke);
      _label(
        canvas,
        labels[i],
        Offset(chambers[i].left + 3, chambers[i].center.dy - 15),
        chambers[i].width - 6,
        align: TextAlign.center,
      );
    }
    _arrow(canvas, chambers[0].bottomCenter, chambers[2].topCenter, _stroke);
    _arrow(canvas, chambers[1].bottomCenter, chambers[3].topCenter, _stroke);

    final flows = _mapList(spec['flows'])!;
    final pulmonaryPathX = size.width * 0.28;
    final systemicPathX = size.width * 0.92;
    final pulmonaryExit = Offset(pulmonaryPathX, chambers[2].center.dy);
    final systemicExit = Offset(systemicPathX, chambers[3].center.dy);
    final pulmonaryTop = chambers[1].top - 18;
    final systemicBottom = chambers[2].bottom + 18;
    final bodyReturnX = size.width * 0.23;
    _routeArrow(canvas, chambers[2].centerLeft, pulmonaryExit, _stroke);
    canvas.drawLine(
      pulmonaryExit,
      Offset(pulmonaryExit.dx, pulmonaryTop),
      _stroke,
    );
    _routeArrow(
      canvas,
      Offset(pulmonaryExit.dx, pulmonaryTop),
      Offset(chambers[1].topCenter.dx, pulmonaryTop),
      _stroke,
    );
    _routeArrow(
      canvas,
      Offset(chambers[1].topCenter.dx, pulmonaryTop),
      chambers[1].topCenter,
      _stroke,
    );
    _routeArrow(canvas, chambers[3].centerRight, systemicExit, _stroke);
    canvas.drawLine(
      systemicExit,
      Offset(systemicExit.dx, systemicBottom),
      _stroke,
    );
    _routeArrow(
      canvas,
      Offset(systemicExit.dx, systemicBottom),
      Offset(bodyReturnX, systemicBottom),
      _stroke,
    );
    _routeArrow(
      canvas,
      Offset(bodyReturnX, systemicBottom),
      Offset(bodyReturnX, chambers[0].center.dy),
      _stroke,
    );
    _routeArrow(
      canvas,
      Offset(bodyReturnX, chambers[0].center.dy),
      chambers[0].centerLeft,
      _stroke,
    );
    _label(
      canvas,
      '${flows[0]['label']}\n${flows[0]['destination']}',
      const Offset(4, 72),
      size.width * 0.20,
      style: mutedStyle,
      align: TextAlign.center,
      maxLines: 3,
    );
    _label(
      canvas,
      '${flows[1]['label']}\n${flows[1]['destination']}',
      Offset(size.width * 0.78, 72),
      size.width * 0.16,
      style: mutedStyle,
      align: TextAlign.center,
      maxLines: 3,
    );
    _label(
      canvas,
      'blood flow',
      Offset(size.width * 0.39, 178),
      size.width * 0.22,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
  }

  void _leaderLabel(Canvas canvas, String text, Offset from, Offset labelAt) {
    final labelPoint = Offset(labelAt.dx - 6, labelAt.dy + 8);
    _arrow(canvas, labelPoint, from, _faint);
    _label(canvas, text, labelAt, 132, maxLines: 3);
  }

  void _callout(Canvas canvas, Offset target, Offset labelPoint, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    _arrow(canvas, labelPoint, target, paint);
  }

  void _routeArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    _arrow(canvas, from, to, paint);
  }

  String _pyramidLabel(Map<String, Object?> level) {
    final label = level['label']! as String;
    final energy = level['energy']! as String;
    if (label.length > 16) {
      final words = label.split(' ');
      return '${words.first}\n${words.skip(1).join(' ')}  $energy';
    }
    return '$label  $energy';
  }

  Path _beanPath(Rect rect) {
    final center = rect.center;
    final halfWidth = rect.width / 2;
    final halfHeight = rect.height / 2;
    return Path()
      ..moveTo(center.dx - halfWidth * 0.85, center.dy)
      ..cubicTo(
        center.dx - halfWidth * 1.05,
        center.dy - halfHeight * 0.64,
        center.dx - halfWidth * 0.40,
        center.dy - halfHeight * 1.04,
        center.dx + halfWidth * 0.10,
        center.dy - halfHeight * 0.82,
      )
      ..cubicTo(
        center.dx + halfWidth * 0.72,
        center.dy - halfHeight * 0.64,
        center.dx + halfWidth * 1.00,
        center.dy - halfHeight * 0.08,
        center.dx + halfWidth * 0.78,
        center.dy + halfHeight * 0.45,
      )
      ..cubicTo(
        center.dx + halfWidth * 0.56,
        center.dy + halfHeight * 0.98,
        center.dx - halfWidth * 0.16,
        center.dy + halfHeight * 0.88,
        center.dx - halfWidth * 0.62,
        center.dy + halfHeight * 0.58,
      )
      ..cubicTo(
        center.dx - halfWidth * 0.96,
        center.dy + halfHeight * 0.36,
        center.dx - halfWidth * 1.02,
        center.dy + halfHeight * 0.08,
        center.dx - halfWidth * 0.85,
        center.dy,
      )
      ..close();
  }

  void _drawXChromosomes(
    Canvas canvas,
    Offset center,
    Paint paint, {
    double scale = 1,
  }) {
    for (var j = -1; j <= 1; j++) {
      final x = center.dx + j * 16 * scale;
      _drawXChromosome(canvas, Offset(x, center.dy), paint, scale: scale);
    }
  }

  void _drawXChromosome(
    Canvas canvas,
    Offset center,
    Paint paint, {
    double scale = 1,
  }) {
    final width = 5 * scale;
    final height = 9 * scale;
    canvas
      ..drawLine(
        Offset(center.dx - width, center.dy - height),
        Offset(center.dx + width, center.dy + height),
        paint,
      )
      ..drawLine(
        Offset(center.dx + width, center.dy - height),
        Offset(center.dx - width, center.dy + height),
        paint,
      );
  }

  void _drawChromatid(Canvas canvas, Offset center, double side, Paint paint) {
    final path = Path()
      ..moveTo(center.dx + side * 6, center.dy - 6)
      ..lineTo(center.dx - side * 2, center.dy)
      ..lineTo(center.dx + side * 6, center.dy + 6);
    canvas.drawPath(path, paint);
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    final delta = to - from;
    final length = delta.distance;
    if (length == 0) return;
    final ux = delta.dx / length;
    final uy = delta.dy / length;
    final left = Offset(to.dx - ux * 8 - uy * 4, to.dy - uy * 8 + ux * 4);
    final right = Offset(to.dx - ux * 8 + uy * 4, to.dy - uy * 8 - ux * 4);
    canvas
      ..drawLine(to, left, paint)
      ..drawLine(to, right, paint);
  }

  void _label(
    Canvas canvas,
    String text,
    Offset offset,
    double width, {
    TextStyle? style,
    TextAlign align = TextAlign.left,
    int maxLines = 2,
  }) {
    TextPainter(
      text: TextSpan(text: text, style: style ?? labelStyle),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
    )
      ..layout(maxWidth: width)
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_BiologyDiagramPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.spec.toString() != spec.toString() ||
        oldDelegate.ink != ink ||
        oldDelegate.rule != rule ||
        oldDelegate.board != board;
  }
}

bool _validStemTissues(Map<String, Object?> spec) {
  if (!_nonEmptyString(spec['outer']) || !_nonEmptyString(spec['ground'])) {
    return false;
  }
  final vascular = _stringObjectMap(spec['vascular']);
  if (vascular == null || vascular['label'] != 'vascular tissue') return false;
  final components = _stringList(vascular['components']);
  return components != null &&
      components.length == 2 &&
      components[0] == 'xylem' &&
      components[1] == 'phloem';
}

bool _validCellProteinFlow(Map<String, Object?> spec) {
  const expectedLabels = <String>[
    'nucleus',
    'mitochondria',
    'ribosomes',
    'rough ER',
    'smooth ER',
    'Golgi apparatus',
  ];
  const expectedFlow = <String>['ribosomes', 'rough ER', 'Golgi apparatus'];
  final labels = _stringList(spec['labels']);
  final flow = _stringList(spec['proteinFlow']);
  return _sameStrings(labels, expectedLabels) &&
      _sameStrings(flow, expectedFlow);
}

bool _validMetabolismCycle(Map<String, Object?> spec) {
  final photosynthesis = _stringObjectMap(spec['photosynthesis']);
  final respiration = _stringObjectMap(spec['respiration']);
  if (photosynthesis == null ||
      respiration == null ||
      spec['loopsBack'] != true) {
    return false;
  }
  return photosynthesis['organelle'] == 'chloroplast' &&
      _sameStrings(_stringList(photosynthesis['inputs']), const <String>[
        'carbon dioxide',
        'water',
        'sunlight',
      ]) &&
      _sameStrings(_stringList(photosynthesis['outputs']), const <String>[
        'glucose',
        'oxygen',
      ]) &&
      respiration['organelle'] == 'mitochondrion' &&
      _sameStrings(_stringList(respiration['inputs']), const <String>[
        'glucose',
        'oxygen',
      ]) &&
      _sameStrings(_stringList(respiration['outputs']), const <String>[
        'carbon dioxide',
        'water',
        'ATP',
      ]);
}

bool _validOrganelleComparison(Map<String, Object?> spec) {
  final organelles = _mapList(spec['organelles']);
  if (organelles == null || organelles.length != 2) return false;
  return organelles[0]['name'] == 'chloroplast' &&
      organelles[0]['shape'] == 'disc' &&
      organelles[0]['appearance'] == 'green' &&
      organelles[0]['process'] == 'photosynthesis' &&
      organelles[1]['name'] == 'mitochondrion' &&
      organelles[1]['shape'] == 'bean' &&
      organelles[1]['appearance'] == 'folded inner membranes/cristae' &&
      organelles[1]['process'] == 'cellular respiration';
}

bool _validMitosis(Map<String, Object?> spec) {
  final stages = _mapList(spec['stages']);
  if (stages == null || stages.length != 4) return false;
  const phases = <String>['prophase', 'metaphase', 'anaphase', 'telophase'];
  const states = <String>[
    'condensing chromosomes',
    'chromosomes lined up in the middle',
    'chromosomes pulled to opposite ends',
    'two forming nuclei',
  ];
  for (var i = 0; i < stages.length; i++) {
    if (stages[i]['phase'] != phases[i] || stages[i]['state'] != states[i]) {
      return false;
    }
  }
  return true;
}

bool _validEnergyPyramid(Map<String, Object?> spec) {
  final levels = _mapList(spec['levels']);
  if (levels == null || levels.length != 4) return false;
  const labels = <String>[
    'producers',
    'primary consumers',
    'secondary consumers',
    'tertiary consumers',
  ];
  const energy = <String>['100%', '10%', '1%', '0.1%'];
  for (var i = 0; i < levels.length; i++) {
    if (levels[i]['label'] != labels[i] || levels[i]['energy'] != energy[i]) {
      return false;
    }
  }
  return true;
}

bool _validNaturalSelection(Map<String, Object?> spec) {
  return spec['generations'] == 3 &&
      spec['trait'] == 'beak shape' &&
      spec['selection'] ==
          'better match to available food becomes more common' &&
      spec['lessSuited'] == 'rarer over time';
}

bool _validHeart(Map<String, Object?> spec) {
  if (spec['layout'] != 'atria-above-ventricles') return false;
  final chambers = _stringList(spec['chambers']);
  if (!_sameStrings(chambers, const <String>[
    'atrium',
    'atrium',
    'ventricle',
    'ventricle',
  ])) {
    return false;
  }
  final flows = _mapList(spec['flows']);
  return flows != null &&
      flows.length == 2 &&
      flows[0]['label'] == 'pulmonary' &&
      flows[0]['destination'] == 'lungs' &&
      flows[1]['label'] == 'systemic' &&
      flows[1]['destination'] == 'body';
}

bool _hasIllustrationKey(Map<String, Object?> spec) {
  final key = spec['illustrationKey'];
  return key is String && key.trim().isNotEmpty;
}

bool _nonEmptyString(Object? value) =>
    value is String && value.trim().isNotEmpty;

Map<String, Object?>? _stringObjectMap(Object? value) {
  if (value is! Map) return null;
  for (final key in value.keys) {
    if (key is! String) return null;
  }
  return value.cast<String, Object?>();
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
    final map = _stringObjectMap(item);
    if (map == null) return null;
    result.add(map);
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
