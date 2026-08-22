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
          ink: colors.ink,
          inkMuted: colors.inkMuted,
          rule: colors.ruleFaint,
          board: colors.board,
          boardTint: colors.boardTint,
          labelStyle: context.textStyles.bodySmall.copyWith(color: colors.ink),
          mutedStyle: context.textStyles.bodySmall.copyWith(
            color: colors.inkMuted,
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
      Offset(center.dx - radius, center.dy - radius * 0.55),
      Offset(size.width * 0.66, 28),
    );
    final vascular = (spec['vascular']! as Map).cast<String, Object?>();
    final components = _stringList(vascular['components'])!;
    _leaderLabel(
      canvas,
      '${vascular['label']}\n${components.join(' + ')}',
      Offset(center.dx + radius * 0.50, center.dy - radius * 0.12),
      Offset(size.width * 0.66, 82),
    );
    _leaderLabel(
      canvas,
      spec['ground']! as String,
      Offset(center.dx, center.dy + radius * 0.20),
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

    final ribosome = Offset(size.width * 0.34, size.height * 0.30);
    canvas.drawCircle(ribosome, 3, Paint()..color = board);
    _label(canvas, 'ribosomes', Offset(ribosome.dx - 26, ribosome.dy - 22), 66);
    _arrow(canvas, ribosome, Offset(rough.left, rough.center.dy), _stroke);
    _arrow(
      canvas,
      Offset(rough.right, rough.center.dy),
      Offset(golgiX - 28, size.height * 0.62),
      _stroke,
    );
  }

  void _paintMetabolismCycle(Canvas canvas, Size size) {
    final photosynthesis =
        (spec['photosynthesis']! as Map).cast<String, Object?>();
    final respiration = (spec['respiration']! as Map).cast<String, Object?>();
    final left = Rect.fromLTWH(18, 46, size.width * 0.34, 92);
    final right = Rect.fromLTWH(size.width * 0.62, 46, size.width * 0.31, 92);
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
      Offset(left.left + 18, left.top + 27),
      left.width - 36,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'photosynthesis',
      Offset(left.left + 14, left.top + 50),
      left.width - 28,
      align: TextAlign.center,
    );
    _label(
      canvas,
      respiration['organelle']! as String,
      Offset(right.left + 12, right.top + 27),
      right.width - 24,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'cellular respiration',
      Offset(right.left + 6, right.top + 50),
      right.width - 12,
      align: TextAlign.center,
    );

    _arrow(
      canvas,
      Offset(left.right, left.center.dy - 16),
      Offset(right.left, right.center.dy - 16),
      _stroke,
    );
    _label(
      canvas,
      'glucose + oxygen',
      Offset(size.width * 0.38, 50),
      size.width * 0.22,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _arrow(
      canvas,
      Offset(right.left, right.center.dy + 25),
      Offset(left.right, left.center.dy + 25),
      _faint,
    );
    _label(
      canvas,
      'carbon dioxide + water',
      Offset(size.width * 0.36, 124),
      size.width * 0.27,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'sunlight + carbon dioxide + water',
      const Offset(12, 8),
      size.width * 0.48,
      style: mutedStyle,
    );
    _label(
      canvas,
      'ATP',
      Offset(right.center.dx - 12, right.bottom + 12),
      40,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
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
    canvas.drawOval(mito, _stroke);
    final cristae = Path()..moveTo(mito.left + 18, mito.center.dy);
    for (var i = 0; i < 5; i++) {
      final x = mito.left + 24 + i * 20;
      cristae
        ..lineTo(x, mito.center.dy - 18)
        ..lineTo(x + 10, mito.center.dy + 18);
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
        for (var j = 0; j < 3; j++) {
          final x = center.dx - 12 + j * 12;
          canvas
            ..drawLine(
              Offset(x - 5, center.dy - 9),
              Offset(x + 5, center.dy + 9),
              _stroke,
            )
            ..drawLine(
              Offset(x + 5, center.dy - 9),
              Offset(x - 5, center.dy + 9),
              _stroke,
            );
        }
      } else if (i == 1) {
        for (var j = -1; j <= 1; j++) {
          canvas
            ..drawLine(
              Offset(center.dx - 6, center.dy + j * 12 - 6),
              Offset(center.dx + 6, center.dy + j * 12 + 6),
              _stroke,
            )
            ..drawLine(
              Offset(center.dx + 6, center.dy + j * 12 - 6),
              Offset(center.dx - 6, center.dy + j * 12 + 6),
              _stroke,
            );
        }
      } else if (i == 2) {
        for (final side in <double>[-1, 1]) {
          for (var j = -1; j <= 1; j++) {
            canvas.drawLine(
              Offset(center.dx + side * 10, center.dy + j * 10),
              Offset(center.dx + side * 22, center.dy + j * 10 + side * 5),
              _stroke,
            );
          }
        }
      } else {
        canvas
          ..drawCircle(Offset(center.dx - 15, center.dy), 13, _faint)
          ..drawCircle(Offset(center.dx + 15, center.dy), 13, _faint);
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
    for (var i = 0; i < levels.length; i++) {
      final fromBottom = i;
      final t = fromBottom / (levels.length - 1);
      final width = size.width *
          (baseWidthFactor + (topWidthFactor - baseWidthFactor) * t);
      final y = size.height - 12 - levelHeight * (i + 1);
      final rect =
          Rect.fromLTWH(centerX - width / 2, y, width, levelHeight - 3);
      canvas.drawRect(rect, i == 0 ? _stroke : _faint);
      _label(
        canvas,
        '${levels[i]['label']}  ${levels[i]['energy']}',
        Offset(rect.left + 4, rect.center.dy - 8),
        rect.width - 8,
        style: i == 0 ? labelStyle.copyWith(color: board) : labelStyle,
        align: TextAlign.center,
      );
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
      final preferredBeak = 9.0 + generation * 5;
      for (var bird = 0; bird < 3; bird++) {
        final y = 60.0 + bird * 42;
        final head = Offset(x - 8, y);
        canvas.drawCircle(head, 9, _stroke);
        final beakLength =
            bird == 2 ? math.max(5.0, 12 - generation * 3) : preferredBeak;
        final beak = Path()
          ..moveTo(head.dx + 8, head.dy - 4)
          ..lineTo(head.dx + 8 + beakLength, head.dy)
          ..lineTo(head.dx + 8, head.dy + 4)
          ..close();
        canvas.drawPath(beak, _stroke);
        if (bird == 2 && generation == 2) {
          canvas.drawLine(
            Offset(head.dx - 12, head.dy - 12),
            Offset(head.dx + 16, head.dy + 12),
            _faint,
          );
        }
      }
    }
    _label(
      canvas,
      spec['selection']! as String,
      const Offset(14, 184),
      size.width - 28,
      style: mutedStyle,
      align: TextAlign.center,
    );
  }

  void _paintHeart(Canvas canvas, Size size) {
    final chamberWidth = size.width * 0.20;
    const chamberHeight = 54.0;
    final left = size.width * 0.28;
    final right = size.width * 0.52;
    const top = 35.0;
    const bottom = 101.0;
    final chambers = <Rect>[
      Rect.fromLTWH(left, top, chamberWidth, chamberHeight),
      Rect.fromLTWH(right, top, chamberWidth, chamberHeight),
      Rect.fromLTWH(left, bottom, chamberWidth, chamberHeight),
      Rect.fromLTWH(right, bottom, chamberWidth, chamberHeight),
    ];
    final labels = _stringList(spec['chambers'])!;
    for (var i = 0; i < chambers.length; i++) {
      canvas.drawRect(chambers[i], _stroke);
      _label(
        canvas,
        labels[i],
        Offset(chambers[i].left + 2, chambers[i].center.dy - 8),
        chambers[i].width - 4,
        align: TextAlign.center,
      );
    }
    _arrow(canvas, chambers[0].bottomCenter, chambers[2].topCenter, _faint);
    _arrow(canvas, chambers[1].bottomCenter, chambers[3].topCenter, _faint);

    final flows = _mapList(spec['flows'])!;
    _label(
      canvas,
      '${flows[0]['label']} → ${flows[0]['destination']}',
      const Offset(8, 52),
      size.width * 0.24,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      '${flows[1]['label']} → ${flows[1]['destination']}',
      Offset(size.width * 0.76, 52),
      size.width * 0.22,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _arrow(
      canvas,
      chambers[2].centerLeft,
      Offset(size.width * 0.20, chambers[2].center.dy),
      _stroke,
    );
    _arrow(
      canvas,
      chambers[3].centerRight,
      Offset(size.width * 0.82, chambers[3].center.dy),
      _stroke,
    );
  }

  void _leaderLabel(Canvas canvas, String text, Offset from, Offset labelAt) {
    canvas.drawLine(from, Offset(labelAt.dx - 6, labelAt.dy + 8), _faint);
    _label(canvas, text, labelAt, 132, maxLines: 3);
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
      _sameStrings(
        _stringList(photosynthesis['inputs']),
        const <String>['carbon dioxide', 'water', 'sunlight'],
      ) &&
      _sameStrings(
        _stringList(photosynthesis['outputs']),
        const <String>['glucose', 'oxygen'],
      ) &&
      respiration['organelle'] == 'mitochondrion' &&
      _sameStrings(
        _stringList(respiration['inputs']),
        const <String>['glucose', 'oxygen'],
      ) &&
      _sameStrings(
        _stringList(respiration['outputs']),
        const <String>['carbon dioxide', 'water', 'ATP'],
      );
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
  if (!_sameStrings(
    chambers,
    const <String>['atrium', 'atrium', 'ventricle', 'ventricle'],
  )) {
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
