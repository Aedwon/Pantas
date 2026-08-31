import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Original lesson diagrams for the ten chemistry briefs in original-code-a.
class ChemistryDiagramFigure extends StatelessWidget {
  const ChemistryDiagramFigure._({
    required this.type,
    required Map<String, Object?> spec,
  }) : _spec = spec;

  static const kind = 'chemistry-diagram';

  final String type;
  final Map<String, Object?> _spec;

  static ChemistryDiagramFigure? fromSpec(Map<String, Object?> spec) {
    if (spec['kind'] != kind || !_hasIllustrationKey(spec)) return null;
    final type = spec['type'];
    if (type is! String) return null;

    final valid = switch (type) {
      'ph-scale' => _validPhScale(spec),
      'atom-particles' => _validAtom(spec),
      'bond-types' => _validBondTypes(spec),
      'gas-laws-gallery' => _validGasLaws(spec),
      'atomic-models' => _validAtomicModels(spec),
      'particle-states' => _validParticleStates(spec),
      'periodic-regions' => _validPeriodicRegions(spec),
      'orbital-shapes' => _validOrbitalShapes(spec),
      'solution-concentration' => _validSolution(spec),
      'reaction-energy' => _validReactionEnergy(spec),
      _ => false,
    };
    if (!valid) return null;

    return ChemistryDiagramFigure._(
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
        painter: _ChemistryDiagramPainter(
          type: type,
          spec: _spec,
          ink: colors.ink,
          inkMuted: colors.inkMuted,
          rule: colors.ruleFaint,
          board: colors.board,
          rust: colors.rust,
          amber: colors.amber,
          labelStyle: context.textStyles.bodySmall.copyWith(color: colors.ink),
          mutedStyle: context.textStyles.bodySmall.copyWith(
            color: colors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _ChemistryDiagramPainter extends CustomPainter {
  _ChemistryDiagramPainter({
    required this.type,
    required this.spec,
    required this.ink,
    required this.inkMuted,
    required this.rule,
    required this.board,
    required this.rust,
    required this.amber,
    required this.labelStyle,
    required this.mutedStyle,
  });

  final String type;
  final Map<String, Object?> spec;
  final Color ink;
  final Color inkMuted;
  final Color rule;
  final Color board;
  final Color rust;
  final Color amber;
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
      case 'ph-scale':
        _paintPhScale(canvas, size);
      case 'atom-particles':
        _paintAtom(canvas, size);
      case 'bond-types':
        _paintBondTypes(canvas, size);
      case 'gas-laws-gallery':
        _paintGasLaws(canvas, size);
      case 'atomic-models':
        _paintAtomicModels(canvas, size);
      case 'particle-states':
        _paintParticleStates(canvas, size);
      case 'periodic-regions':
        _paintPeriodicRegions(canvas, size);
      case 'orbital-shapes':
        _paintOrbitalShapes(canvas, size);
      case 'solution-concentration':
        _paintSolution(canvas, size);
      case 'reaction-energy':
        _paintReactionEnergy(canvas, size);
    }
  }

  void _paintPhScale(Canvas canvas, Size size) {
    const left = 18.0;
    final right = size.width - 18;
    final width = right - left;
    const y = 91.0;
    final step = width / 14;
    final scaleRect = Rect.fromLTWH(left, y - 2.5, width, 5);
    final gradient = LinearGradient(
      colors: <Color>[
        const HSLColor.fromAHSL(1, 0, .68, .46).toColor(),
        const HSLColor.fromAHSL(1, 55, .72, .50).toColor(),
        const HSLColor.fromAHSL(1, 120, .54, .39).toColor(),
        const HSLColor.fromAHSL(1, 220, .62, .50).toColor(),
        const HSLColor.fromAHSL(1, 275, .56, .47).toColor(),
      ],
      stops: const <double>[0, .29, .5, .79, 1],
    );
    canvas.drawRect(
      scaleRect,
      Paint()..shader = gradient.createShader(scaleRect),
    );
    for (var i = 0; i <= 14; i++) {
      final x = left + i * step;
      canvas.drawLine(Offset(x, y - 8), Offset(x, y + 8), _stroke);
      _label(
        canvas,
        '$i',
        Offset(x - 8, y + 13),
        16,
        style: mutedStyle,
        align: TextAlign.center,
      );
    }
    _label(
      canvas,
      'acidic',
      const Offset(18, 13),
      width * 0.30,
      style: labelStyle.copyWith(color: rust),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'neutral',
      Offset(left + width * 0.39, 13),
      width * 0.22,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'basic',
      Offset(left + width * 0.70, 13),
      width * 0.30,
      style: labelStyle.copyWith(color: amber),
      align: TextAlign.center,
    );

    final examples = _mapList(spec['examples'])!;
    for (final example in examples) {
      final ph = example['ph']! as int;
      final x = left + ph * step;
      canvas.drawLine(Offset(x, y - 11), Offset(x, y - 31), _stroke);
      _label(
        canvas,
        example['label']! as String,
        Offset(x - 38, y - 54),
        76,
        style: mutedStyle,
        align: TextAlign.center,
      );
    }
  }

  void _paintAtom(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.48);
    final nucleusPaint = Paint()
      ..color = board
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, 31, nucleusPaint);
    _particleWithCharge(
      canvas,
      Offset(center.dx - 10, center.dy - 7),
      '+',
      rust,
    );
    _particleWithCharge(
      canvas,
      Offset(center.dx + 10, center.dy - 7),
      '0',
      inkMuted,
    );
    _particleWithCharge(
      canvas,
      Offset(center.dx - 10, center.dy + 12),
      '+',
      rust,
    );
    _particleWithCharge(
      canvas,
      Offset(center.dx + 10, center.dy + 12),
      '0',
      inkMuted,
    );

    final orbit1 =
        Rect.fromCenter(center: center, width: size.width * 0.54, height: 86);
    final orbit2 =
        Rect.fromCenter(center: center, width: size.width * 0.34, height: 142);
    canvas
      ..drawOval(orbit1, _faint)
      ..drawOval(orbit2, _faint);
    final e1 = Offset(orbit1.right, center.dy);
    final e2 = Offset(center.dx, orbit2.top);
    final e3 = Offset(orbit2.left, center.dy + 3);
    for (final electron in <Offset>[e1, e2, e3]) {
      _particleWithCharge(canvas, electron, '−', ink);
    }
    _label(
      canvas,
      'electrons (−)',
      Offset(size.width * 0.68, 15),
      size.width * 0.25,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'dense nucleus',
      Offset(center.dx - 48, center.dy + 38),
      96,
      style: mutedStyle,
      align: TextAlign.center,
    );
  }

  void _paintBondTypes(Canvas canvas, Size size) {
    final bonds = _mapList(spec['bondTypes'])!;
    final slot = size.width / 3;
    final titleStyle = labelStyle.copyWith(fontWeight: FontWeight.w600);
    final electronPaint = Paint()..color = amber;
    for (var i = 0; i < bonds.length; i++) {
      final x0 = slot * i;
      _label(
        canvas,
        bonds[i]['label']! as String,
        Offset(x0 + 4, 10),
        slot - 8,
        style: titleStyle,
        align: TextAlign.center,
      );
      if (i == 0) {
        final left = Offset(x0 + slot * 0.27, 88);
        final right = Offset(x0 + slot * 0.73, 88);
        canvas
          ..drawCircle(left, 18, _stroke)
          ..drawCircle(right, 18, _stroke)
          ..drawCircle(left, 18, Paint()..color = rust.withValues(alpha: .1))
          ..drawCircle(right, 18, Paint()..color = board.withValues(alpha: .1));
        _label(
          canvas,
          'metal',
          Offset(left.dx - 20, 47),
          40,
          style: mutedStyle,
          align: TextAlign.center,
        );
        _label(
          canvas,
          'nonmetal',
          Offset(right.dx - 27, 47),
          54,
          style: mutedStyle,
          align: TextAlign.center,
        );
        canvas.drawCircle(
          Offset(left.dx + 8, left.dy - 22),
          3.5,
          electronPaint,
        );
        _curvedArrow(
          canvas,
          Offset(left.dx + 8, left.dy - 19),
          Offset(right.dx - 8, right.dy - 19),
          _stroke,
        );
        canvas.drawCircle(
          Offset((left.dx + right.dx) / 2, left.dy - 19),
          3.5,
          electronPaint,
        );
        _label(
          canvas,
          '+',
          Offset(left.dx - 5, 111),
          10,
          style: labelStyle.copyWith(color: rust),
          align: TextAlign.center,
        );
        _label(
          canvas,
          '−',
          Offset(right.dx - 5, 111),
          10,
          style: labelStyle.copyWith(color: board),
          align: TextAlign.center,
        );
      } else if (i == 1) {
        final left = Offset(x0 + slot * 0.32, 88);
        final right = Offset(x0 + slot * 0.68, 88);
        canvas
          ..drawCircle(left, 19, _stroke)
          ..drawCircle(right, 19, _stroke);
        final sharedY = (left.dy + right.dy) / 2;
        canvas
          ..drawCircle(
            Offset((left.dx + right.dx) / 2 - 4, sharedY),
            3.5,
            electronPaint,
          )
          ..drawCircle(
            Offset((left.dx + right.dx) / 2 + 4, sharedY),
            3.5,
            electronPaint,
          )
          ..drawLine(
            Offset(left.dx + 18, sharedY),
            Offset(right.dx - 18, sharedY),
            _faint,
          );
        _label(
          canvas,
          'nonmetals share',
          Offset(x0 + 7, 47),
          slot - 14,
          style: mutedStyle,
          align: TextAlign.center,
        );
      } else {
        final electronSea = Rect.fromLTWH(
          x0 + 8,
          43,
          slot - 16,
          93,
        );
        canvas.drawRect(
          electronSea,
          Paint()..color = inkMuted.withValues(alpha: .12),
        );
        for (var row = 0; row < 2; row++) {
          for (var col = 0; col < 3; col++) {
            canvas.drawCircle(
              Offset(x0 + 25 + col * 30, 73 + row * 30),
              9,
              _stroke,
            );
          }
        }
        for (var dot = 0; dot < 8; dot++) {
          final electron = Offset(
            x0 + 15 + (dot % 4) * 25,
            58 + (dot ~/ 4) * 58,
          );
          canvas.drawCircle(electron, 2.8, electronPaint);
          _arrow(
            canvas,
            electron + const Offset(-6, 0),
            electron + const Offset(6, 0),
            Paint()
              ..color = amber.withValues(alpha: .7)
              ..strokeWidth = 1,
          );
        }
      }
      _label(
        canvas,
        bonds[i]['electronAction']! as String,
        Offset(x0 + 6, 145),
        slot - 12,
        style: mutedStyle.copyWith(fontSize: 11),
        align: TextAlign.center,
        maxLines: 3,
      );
    }
  }

  void _paintGasLaws(Canvas canvas, Size size) {
    final laws = _mapList(spec['laws'])!;
    final slot = size.width / 4;
    for (var i = 0; i < laws.length; i++) {
      final x0 = slot * i;
      _label(
        canvas,
        laws[i]['label']! as String,
        Offset(x0 + 2, 7),
        slot - 4,
        align: TextAlign.center,
      );
      final cx = x0 + slot / 2;
      if (i == 0) {
        final body = Rect.fromLTWH(x0 + slot * .23, 61, slot * .54, 80);
        canvas
          ..drawRect(body, _stroke)
          ..drawLine(
            Offset(body.left, body.top + 20),
            Offset(body.right, body.top + 20),
            _stroke,
          );
        _arrow(
          canvas,
          Offset(cx, body.top - 15),
          Offset(cx, body.top + 4),
          _stroke,
        );
        for (var dot = 0; dot < 6; dot++) {
          canvas.drawCircle(
            Offset(
              body.left + 15 + (dot % 3) * 18,
              body.top + 42 + (dot ~/ 3) * 20,
            ),
            2.5,
            Paint()..color = amber,
          );
        }
      } else if (i == 1) {
        final small = Offset(cx - 19, 101);
        final large = Offset(cx + 16, 91);
        canvas
          ..drawOval(
            Rect.fromCenter(center: small, width: 26, height: 34),
            _stroke,
          )
          ..drawOval(
            Rect.fromCenter(center: large, width: 43, height: 57),
            _stroke,
          )
          ..drawLine(
            Offset(small.dx + 8, small.dy + 17),
            Offset(small.dx + 8, small.dy + 22),
            _stroke,
          )
          ..drawLine(
            Offset(large.dx - 5, large.dy + 28),
            Offset(large.dx - 5, large.dy + 33),
            _stroke,
          );
        _arrow(
          canvas,
          Offset(small.dx + 15, 87),
          Offset(large.dx - 23, 75),
          _stroke,
        );
        _heatWaves(canvas, Offset(cx, 144));
        _label(
          canvas,
          'heat',
          Offset(cx - 20, 151),
          40,
          style: labelStyle.copyWith(color: amber),
          align: TextAlign.center,
        );
      } else if (i == 2) {
        final can =
            Rect.fromCenter(center: Offset(cx, 105), width: 45, height: 68);
        canvas
          ..drawRect(can, _stroke)
          ..drawLine(
            Offset(can.left, can.top),
            Offset(can.right, can.top),
            _stroke,
          )
          ..drawCircle(Offset(cx, 102), 12, _stroke)
          ..drawLine(Offset(cx, 102), Offset(cx + 5, 94), _stroke);
        _heatWaves(canvas, Offset(cx, 145));
        _label(
          canvas,
          'P↑',
          Offset(cx - 12, 95),
          24,
          style: labelStyle.copyWith(fontWeight: FontWeight.w600),
          align: TextAlign.center,
        );
        _label(
          canvas,
          'heat',
          Offset(cx - 20, 151),
          40,
          style: labelStyle.copyWith(color: amber),
          align: TextAlign.center,
        );
      } else {
        final small = Rect.fromLTWH(cx - 30, 80, 24, 48);
        final large = Rect.fromLTWH(cx - 1, 67, 42, 75);
        canvas
          ..drawRect(small, _faint)
          ..drawRect(large, _stroke);
        _arrow(
          canvas,
          Offset(small.right + 1, 104),
          Offset(large.left - 2, 104),
          _stroke,
        );
        for (var dot = 0; dot < 7; dot++) {
          canvas.drawCircle(
            Offset(
              large.left + 11 + (dot % 3) * 13,
              large.top + 18 + (dot ~/ 3) * 22,
            ),
            2.4,
            Paint()..color = amber,
          );
        }
        for (var dot = 0; dot < 3; dot++) {
          canvas.drawCircle(
            Offset(x0 + 8 + dot * 8, 103),
            2.4,
            Paint()..color = amber,
          );
        }
      }
      _label(
        canvas,
        laws[i]['scene']! as String,
        Offset(x0 + 3, 176),
        slot - 6,
        style: mutedStyle.copyWith(fontSize: 10),
        align: TextAlign.center,
        maxLines: 3,
      );
    }
  }

  void _paintAtomicModels(Canvas canvas, Size size) {
    final models = _mapList(spec['models'])!;
    final slot = size.width / 4;
    for (var i = 0; i < models.length; i++) {
      final cx = slot * (i + 0.5);
      _label(
        canvas,
        models[i]['label']! as String,
        Offset(slot * i + 2, 8),
        slot - 4,
        align: TextAlign.center,
      );
      final center = Offset(cx, 93);
      if (i == 0) {
        canvas
          ..drawCircle(center, 28, Paint()..color = ink.withValues(alpha: .18))
          ..drawCircle(center, 28, _stroke);
      } else if (i == 1) {
        canvas
          ..drawCircle(center, 30, Paint()..color = rust.withValues(alpha: .12))
          ..drawCircle(center, 30, _stroke);
        _label(
          canvas,
          '+',
          Offset(center.dx - 20, center.dy - 8),
          40,
          style: mutedStyle,
          align: TextAlign.center,
        );
        for (final d in <Offset>[
          const Offset(-13, -10),
          const Offset(10, -7),
          const Offset(-6, 13),
          const Offset(14, 11),
        ]) {
          canvas.drawCircle(center + d, 3, Paint()..color = amber);
        }
      } else if (i == 2) {
        canvas
          ..drawCircle(center, 7, Paint()..color = board)
          ..drawOval(
            Rect.fromCenter(center: center, width: 65, height: 25),
            _faint,
          )
          ..drawOval(
            Rect.fromCenter(center: center, width: 28, height: 65),
            _faint,
          );
      } else {
        for (var ring = 0; ring < 5; ring++) {
          canvas.drawCircle(
            center,
            9.0 + ring * 7,
            Paint()..color = inkMuted.withValues(alpha: 0.18),
          );
        }
        canvas.drawCircle(center, 6, Paint()..color = board);
      }
      _label(
        canvas,
        models[i]['model']! as String,
        Offset(slot * i + 3, 143),
        slot - 6,
        style: mutedStyle,
        align: TextAlign.center,
        maxLines: 3,
      );
    }
  }

  void _paintParticleStates(Canvas canvas, Size size) {
    final states = _mapList(spec['states'])!;
    final slot = size.width / 3;
    for (var i = 0; i < states.length; i++) {
      final box = Rect.fromLTWH(slot * i + 10, 42, slot - 20, 104);
      canvas.drawRect(box, _stroke);
      if (i == 0) {
        for (var row = 0; row < 4; row++) {
          for (var col = 0; col < 4; col++) {
            _particle(
              canvas,
              Offset(
                box.left + 18 + col * (box.width - 36) / 3,
                box.top + 18 + row * (box.height - 36) / 3,
              ),
            );
          }
        }
      } else if (i == 1) {
        final points = <Offset>[
          const Offset(0.22, 0.22),
          const Offset(0.48, 0.17),
          const Offset(0.74, 0.27),
          const Offset(0.34, 0.42),
          const Offset(0.60, 0.48),
          const Offset(0.80, 0.56),
          const Offset(0.20, 0.69),
          const Offset(0.47, 0.76),
          const Offset(0.72, 0.80),
          const Offset(0.39, 0.60),
        ];
        for (final point in points) {
          _particle(
            canvas,
            Offset(
              box.left + point.dx * box.width,
              box.top + point.dy * box.height,
            ),
          );
        }
      } else {
        final points = <Offset>[
          const Offset(0.15, 0.20),
          const Offset(0.76, 0.18),
          const Offset(0.42, 0.45),
          const Offset(0.84, 0.66),
          const Offset(0.20, 0.78),
          const Offset(0.66, 0.82),
        ];
        for (var pointIndex = 0; pointIndex < points.length; pointIndex++) {
          final point = points[pointIndex];
          final particleCenter = Offset(
            box.left + point.dx * box.width,
            box.top + point.dy * box.height,
          );
          _particle(
            canvas,
            particleCenter,
          );
          final direction =
              pointIndex.isEven ? const Offset(10, -5) : const Offset(-10, 5);
          _arrow(
            canvas,
            particleCenter - direction * .55,
            particleCenter + direction * .55,
            Paint()
              ..color = amber.withValues(alpha: .8)
              ..strokeWidth = 1,
          );
          _particle(canvas, particleCenter);
        }
      }
      _label(
        canvas,
        states[i]['label']! as String,
        Offset(slot * i + 5, 12),
        slot - 10,
        align: TextAlign.center,
      );
      _label(
        canvas,
        states[i]['arrangement']! as String,
        Offset(slot * i + 6, 158),
        slot - 12,
        style: mutedStyle,
        align: TextAlign.center,
        maxLines: 3,
      );
    }
  }

  void _paintPeriodicRegions(Canvas canvas, Size size) {
    const cols = 18;
    const rows = 7;
    const left = 22.0;
    const top = 24.0;
    final cellW = (size.width - 44) / cols;
    const cellH = 20.0;
    const metalloids = <(int, int)>{
      (12, 1),
      (13, 3),
      (13, 2),
      (14, 3),
      (14, 4),
      (15, 4),
      (15, 5),
      (16, 5),
    };
    final metalFill = Paint()..color = board.withValues(alpha: .28);
    final metalloidFill = Paint()..color = amber.withValues(alpha: .40);
    final nonmetalFill = Paint()..color = rust.withValues(alpha: .24);
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final occupied = row > 1 ||
            col < 2 ||
            col > 11 ||
            (row == 1 && (col == 0 || col > 11));
        if (!occupied) continue;
        final cell = Rect.fromLTWH(
          left + col * cellW,
          top + row * cellH,
          cellW,
          cellH,
        );
        final regionPaint = metalloids.contains((col, row))
            ? metalloidFill
            : col >= 15 || (row < 2 && col > 11)
                ? nonmetalFill
                : metalFill;
        canvas
          ..drawRect(cell, regionPaint)
          ..drawRect(cell, _faint);
      }
    }
    final staircase = Path()
      ..moveTo(left + cellW * 12, top + cellH * 1)
      ..lineTo(left + cellW * 13, top + cellH * 1)
      ..lineTo(left + cellW * 13, top + cellH * 2)
      ..lineTo(left + cellW * 14, top + cellH * 2)
      ..lineTo(left + cellW * 14, top + cellH * 3)
      ..lineTo(left + cellW * 15, top + cellH * 3)
      ..lineTo(left + cellW * 15, top + cellH * 4)
      ..lineTo(left + cellW * 16, top + cellH * 4)
      ..lineTo(left + cellW * 16, top + cellH * 5)
      ..lineTo(left + cellW * 17, top + cellH * 5)
      ..lineTo(left + cellW * 17, top + cellH * 6);
    canvas.drawPath(
      staircase,
      Paint()
        ..color = amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _label(
      canvas,
      'metals',
      Offset(left + cellW * 4, top + cellH * 4.1),
      cellW * 5,
      style: labelStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'nonmetals',
      Offset(left + cellW * 14.4, top + cellH * 1.2),
      cellW * 3.5,
      style: mutedStyle,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'metalloids',
      Offset(left + cellW * 10.8, top + cellH * 6.1),
      cellW * 5.8,
      style: labelStyle,
      align: TextAlign.center,
    );
  }

  void _paintOrbitalShapes(Canvas canvas, Size size) {
    final orbitals = _mapList(spec['orbitals'])!;
    final slot = size.width / 3;
    for (var i = 0; i < orbitals.length; i++) {
      final center = Offset(slot * (i + 0.5), 93);
      if (i == 0) {
        canvas.drawCircle(center, 34, _stroke);
      } else if (i == 1) {
        canvas
          ..drawOval(
            Rect.fromCenter(
              center: Offset(center.dx - 23, center.dy),
              width: 46,
              height: 62,
            ),
            _stroke,
          )
          ..drawOval(
            Rect.fromCenter(
              center: Offset(center.dx + 23, center.dy),
              width: 46,
              height: 62,
            ),
            _stroke,
          );
      } else {
        for (final d in <Offset>[
          const Offset(-22, -22),
          const Offset(22, -22),
          const Offset(-22, 22),
          const Offset(22, 22),
        ]) {
          canvas.drawOval(
            Rect.fromCenter(center: center + d, width: 38, height: 50),
            _stroke,
          );
        }
      }
      _label(
        canvas,
        '${orbitals[i]['label']} orbital',
        Offset(slot * i + 3, 12),
        slot - 6,
        align: TextAlign.center,
      );
      _label(
        canvas,
        '${orbitals[i]['shape']} • max ${orbitals[i]['capacity']} e-',
        Offset(slot * i + 3, 157),
        slot - 6,
        style: mutedStyle,
        align: TextAlign.center,
      );
    }
  }

  void _paintSolution(Canvas canvas, Size size) {
    final beaker = Path()
      ..moveTo(30, 32)
      ..lineTo(42, 164)
      ..lineTo(size.width * 0.43, 164)
      ..lineTo(size.width * 0.47, 32);
    canvas
      ..drawPath(beaker, _stroke)
      ..drawLine(
        const Offset(39, 80),
        Offset(size.width * 0.455, 80),
        Paint()
          ..color = board
          ..strokeWidth = 2,
      );
    for (var i = 0; i < 10; i++) {
      final x = 58.0 + (i % 5) * 28;
      final y = 99.0 + (i ~/ 5) * 31;
      canvas.drawCircle(Offset(x, y), 3.2, Paint()..color = ink);
    }
    _label(
      canvas,
      'solvent: ${spec['solvent']}',
      const Offset(55, 50),
      130,
      style: labelStyle.copyWith(color: board),
    );
    _label(
      canvas,
      'solute: ${spec['solute']}',
      const Offset(65, 132),
      110,
      style: mutedStyle,
    );

    final measures = _stringList(spec['measures'])!;
    _label(
      canvas,
      'same sugar, four measures:',
      Offset(size.width * 0.53, 28),
      size.width * 0.43,
      style: mutedStyle,
    );
    for (var i = 0; i < measures.length; i++) {
      final y = 68.0 + i * 27;
      final cue = switch (measures[i]) {
        'molarity' => 'mol / L solution',
        'molality' => 'mol / kg solvent',
        'percent by mass' => 'mass solute / mass solution',
        'percent by volume' => 'volume solute / volume solution',
        _ => measures[i],
      };
      canvas.drawCircle(
        Offset(size.width * 0.55, y + 8),
        3,
        Paint()..color = amber,
      );
      _label(
        canvas,
        measures[i],
        Offset(size.width * 0.59, y),
        size.width * 0.38,
        style: labelStyle.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
      );
      _label(
        canvas,
        cue,
        Offset(size.width * 0.59, y + 13),
        size.width * 0.38,
        style: mutedStyle.copyWith(fontSize: 10),
      );
    }
  }

  void _paintReactionEnergy(Canvas canvas, Size size) {
    final profiles = _mapList(spec['profiles'])!;
    final slot = size.width / 2;
    for (var i = 0; i < profiles.length; i++) {
      final x0 = slot * i + 18;
      final right = slot * (i + 1) - 18;
      const high = 82.0;
      const low = 137.0;
      final axisPaint = Paint()
        ..color = inkMuted
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas
        ..drawLine(Offset(x0 + 14, 31), Offset(x0 + 14, 168), axisPaint)
        ..drawLine(Offset(x0 + 14, 168), Offset(right, 168), axisPaint);
      final startY = i == 0 ? high : low;
      final endY = i == 0 ? low : high;
      final energyArrowPaint = Paint()
        ..color = i == 0 ? rust : board
        ..strokeWidth = 1.4;
      final startX = x0 + 30;
      final endX = right - 12;
      final peakX = (startX + endX) / 2;
      canvas
        ..drawLine(Offset(startX, startY), Offset(peakX - 28, startY), _stroke)
        ..drawLine(Offset(peakX + 28, endY), Offset(endX, endY), _stroke);
      final path = Path()
        ..moveTo(peakX - 28, startY)
        ..cubicTo(peakX - 18, startY, peakX - 19, 40, peakX, 40)
        ..cubicTo(peakX + 19, 40, peakX + 18, endY, peakX + 28, endY);
      canvas.drawPath(path, _stroke);
      _arrow(
        canvas,
        Offset(peakX + 45, startY),
        Offset(peakX + 45, endY),
        energyArrowPaint,
      );
      _label(
        canvas,
        profiles[i]['label']! as String,
        Offset(x0, 4),
        right - x0,
        style: i == 0
            ? labelStyle.copyWith(color: rust)
            : labelStyle.copyWith(color: board),
        align: TextAlign.center,
      );
      _label(
        canvas,
        'Energy',
        Offset(x0 + 1, 22),
        45,
        style: mutedStyle.copyWith(fontSize: 9),
      );
      _label(
        canvas,
        'Reactants',
        Offset(startX - 5, startY - 17),
        52,
        style: mutedStyle.copyWith(fontSize: 9),
        align: TextAlign.center,
      );
      _label(
        canvas,
        'Products',
        Offset(endX - 47, endY - 17),
        52,
        style: mutedStyle.copyWith(fontSize: 9),
        align: TextAlign.center,
      );
      _label(
        canvas,
        'activation',
        Offset(peakX - 27, 22),
        54,
        style: mutedStyle.copyWith(fontSize: 9),
        align: TextAlign.center,
      );
      _label(
        canvas,
        '${profiles[i]['energy']} energy',
        Offset(x0 + 36, 174),
        right - x0 - 72,
        style: mutedStyle,
        align: TextAlign.center,
      );
      _label(
        canvas,
        'Reaction progress',
        Offset(x0 + 41, 191),
        right - x0 - 30,
        style: mutedStyle.copyWith(fontSize: 9),
        align: TextAlign.center,
      );
    }
  }

  void _particle(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 3.2, Paint()..color = ink);
  }

  void _particleWithCharge(
    Canvas canvas,
    Offset center,
    String charge,
    Color color,
  ) {
    canvas
      ..drawCircle(center, 8, Paint()..color = color.withValues(alpha: .12))
      ..drawCircle(
        center,
        8,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    _label(
      canvas,
      charge,
      Offset(center.dx - 6, center.dy - 7),
      12,
      style: labelStyle.copyWith(
        color: ink,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      align: TextAlign.center,
      maxLines: 1,
    );
  }

  void _curvedArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(
        (from.dx + to.dx) / 2,
        from.dy - 14,
        to.dx,
        to.dy,
      );
    canvas.drawPath(path, paint);
    _arrow(canvas, to - const Offset(10, 0), to, paint);
  }

  void _heatWaves(Canvas canvas, Offset center) {
    final heatPaint = Paint()
      ..color = amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = -1; i <= 1; i++) {
      final x = center.dx + i * 8;
      canvas.drawArc(
        Rect.fromLTWH(x - 3, center.dy - 8, 6, 16),
        -math.pi / 2,
        math.pi,
        false,
        heatPaint,
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
  bool shouldRepaint(_ChemistryDiagramPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.spec.toString() != spec.toString() ||
        oldDelegate.ink != ink ||
        oldDelegate.inkMuted != inkMuted ||
        oldDelegate.rule != rule ||
        oldDelegate.board != board ||
        oldDelegate.rust != rust ||
        oldDelegate.amber != amber;
  }
}

bool _validPhScale(Map<String, Object?> spec) {
  if (spec['min'] != 0 || spec['max'] != 14 || spec['neutral'] != 7) {
    return false;
  }
  if (!_sameStrings(
    _stringList(spec['regions']),
    const <String>['acidic', 'neutral', 'basic'],
  )) {
    return false;
  }
  final examples = _mapList(spec['examples']);
  return examples != null &&
      examples.length == 3 &&
      examples[0]['label'] == 'lemon juice' &&
      examples[0]['ph'] == 2 &&
      examples[1]['label'] == 'pure water' &&
      examples[1]['ph'] == 7 &&
      examples[2]['label'] == 'soap' &&
      examples[2]['ph'] == 10;
}

bool _validAtom(Map<String, Object?> spec) {
  return _sameStrings(
        _stringList(spec['nucleus']),
        const <String>['proton (+)', 'neutron (neutral)'],
      ) &&
      _sameStrings(
        _stringList(spec['orbiting']),
        const <String>['electron (-)'],
      );
}

bool _validBondTypes(Map<String, Object?> spec) {
  final bonds = _mapList(spec['bondTypes']);
  if (bonds == null || bonds.length != 3) return false;
  return bonds[0]['label'] == 'ionic' &&
      _sameStrings(
        _stringList(bonds[0]['participants']),
        const <String>['metal', 'nonmetal'],
      ) &&
      bonds[0]['electronAction'] == 'transfer' &&
      bonds[0]['result'] == 'positive and negative ions' &&
      bonds[1]['label'] == 'covalent' &&
      _sameStrings(
        _stringList(bonds[1]['participants']),
        const <String>['nonmetal', 'nonmetal'],
      ) &&
      bonds[1]['electronAction'] == 'share a pair of electrons' &&
      bonds[2]['label'] == 'metallic' &&
      _sameStrings(
        _stringList(bonds[2]['participants']),
        const <String>['metal atoms'],
      ) &&
      bonds[2]['electronAction'] == 'sea of free-moving electrons';
}

bool _validGasLaws(Map<String, Object?> spec) {
  final laws = _mapList(spec['laws']);
  if (laws == null || laws.length != 4) return false;
  const labels = <String>["Boyle's", "Charles's", "Gay-Lussac's", "Avogadro's"];
  const scenes = <String>[
    'piston compressed',
    'balloon expands when heated',
    'sealed rigid can, pressure rises when heated',
    'container grows as more gas particles are added',
  ];
  for (var i = 0; i < laws.length; i++) {
    if (laws[i]['label'] != labels[i] || laws[i]['scene'] != scenes[i]) {
      return false;
    }
  }
  return true;
}

bool _validAtomicModels(Map<String, Object?> spec) {
  final models = _mapList(spec['models']);
  if (models == null || models.length != 4) return false;
  const labels = <String>['Dalton', 'Thomson', 'Rutherford', 'modern'];
  const descriptions = <String>[
    'solid sphere',
    'plum pudding with embedded electrons',
    'electrons orbiting a tiny dense nucleus',
    'electron cloud around a nucleus',
  ];
  for (var i = 0; i < models.length; i++) {
    if (models[i]['label'] != labels[i] ||
        models[i]['model'] != descriptions[i]) {
      return false;
    }
  }
  return true;
}

bool _validParticleStates(Map<String, Object?> spec) {
  final states = _mapList(spec['states']);
  if (states == null || states.length != 3) return false;
  const labels = <String>['solid', 'liquid', 'gas'];
  const arrangements = <String>[
    'tightly packed fixed grid',
    'close together disordered',
    'spread far apart moving freely',
  ];
  for (var i = 0; i < states.length; i++) {
    if (states[i]['label'] != labels[i] ||
        states[i]['arrangement'] != arrangements[i]) {
      return false;
    }
  }
  return true;
}

bool _validPeriodicRegions(Map<String, Object?> spec) {
  final regions = _mapList(spec['regions']);
  return regions != null &&
      regions.length == 3 &&
      regions[0]['label'] == 'metals' &&
      regions[0]['location'] == 'left and center' &&
      regions[1]['label'] == 'nonmetals' &&
      regions[1]['location'] == 'far right' &&
      regions[2]['label'] == 'metalloids' &&
      regions[2]['location'] == 'staircase boundary';
}

bool _validOrbitalShapes(Map<String, Object?> spec) {
  final orbitals = _mapList(spec['orbitals']);
  if (orbitals == null || orbitals.length != 3) return false;
  const labels = <String>['s', 'p', 'd'];
  const shapes = <String>['sphere', 'dumbbell', 'four-lobed cloverleaf'];
  const capacities = <int>[2, 6, 10];
  for (var i = 0; i < orbitals.length; i++) {
    if (orbitals[i]['label'] != labels[i] ||
        orbitals[i]['shape'] != shapes[i] ||
        orbitals[i]['capacity'] != capacities[i]) {
      return false;
    }
  }
  return true;
}

bool _validSolution(Map<String, Object?> spec) {
  return spec['solute'] == 'sugar' &&
      spec['solvent'] == 'water' &&
      _sameStrings(
        _stringList(spec['measures']),
        const <String>[
          'molarity',
          'molality',
          'percent by mass',
          'percent by volume',
        ],
      );
}

bool _validReactionEnergy(Map<String, Object?> spec) {
  final profiles = _mapList(spec['profiles']);
  return profiles != null &&
      profiles.length == 2 &&
      profiles[0]['label'] == 'exothermic' &&
      profiles[0]['reactants'] == 'high' &&
      profiles[0]['products'] == 'lower' &&
      profiles[0]['energy'] == 'released' &&
      profiles[1]['label'] == 'endothermic' &&
      profiles[1]['reactants'] == 'low' &&
      profiles[1]['products'] == 'higher' &&
      profiles[1]['energy'] == 'absorbed';
}

bool _hasIllustrationKey(Map<String, Object?> spec) {
  final key = spec['illustrationKey'];
  return key is String && key.trim().isNotEmpty;
}

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
