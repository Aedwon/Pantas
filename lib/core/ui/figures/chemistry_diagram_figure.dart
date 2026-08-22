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
      const Offset(18, 37),
      width * 0.30,
      style: labelStyle.copyWith(color: rust),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'neutral',
      Offset(left + width * 0.39, 37),
      width * 0.22,
      style: labelStyle.copyWith(color: board),
      align: TextAlign.center,
    );
    _label(
      canvas,
      'basic',
      Offset(left + width * 0.70, 37),
      width * 0.30,
      style: mutedStyle,
      align: TextAlign.center,
    );

    final examples = _mapList(spec['examples'])!;
    for (final example in examples) {
      final ph = example['ph']! as int;
      final x = left + ph * step;
      canvas.drawLine(Offset(x, y - 11), Offset(x, y - 27), _faint);
      _label(
        canvas,
        example['label']! as String,
        Offset(x - 38, y - 48),
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
    canvas
      ..drawCircle(center, 28, nucleusPaint)
      ..drawCircle(Offset(center.dx - 9, center.dy), 8, _stroke)
      ..drawCircle(Offset(center.dx + 9, center.dy), 8, _faint);
    _label(
      canvas,
      '+',
      Offset(center.dx - 13, center.dy - 8),
      8,
      align: TextAlign.center,
    );
    _label(
      canvas,
      'neutral',
      Offset(center.dx + 1, center.dy - 7),
      28,
      style: mutedStyle,
      align: TextAlign.center,
    );

    final orbit1 =
        Rect.fromCenter(center: center, width: size.width * 0.54, height: 86);
    final orbit2 =
        Rect.fromCenter(center: center, width: size.width * 0.34, height: 142);
    canvas
      ..drawOval(orbit1, _faint)
      ..drawOval(orbit2, _faint);
    final electronPaint = Paint()
      ..color = ink
      ..style = PaintingStyle.fill;
    final e1 = Offset(orbit1.right, center.dy);
    final e2 = Offset(center.dx, orbit2.top);
    canvas
      ..drawCircle(e1, 4, electronPaint)
      ..drawCircle(e2, 4, electronPaint);
    _label(
      canvas,
      'electron (−)',
      Offset(e1.dx - 68, e1.dy + 9),
      72,
      style: mutedStyle,
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
    for (var i = 0; i < bonds.length; i++) {
      final x0 = slot * i;
      _label(
        canvas,
        bonds[i]['label']! as String,
        Offset(x0 + 4, 10),
        slot - 8,
        style: labelStyle,
        align: TextAlign.center,
      );
      if (i == 0) {
        final left = Offset(x0 + slot * 0.28, 88);
        final right = Offset(x0 + slot * 0.72, 88);
        canvas
          ..drawCircle(left, 18, _stroke)
          ..drawCircle(right, 18, _stroke)
          ..drawCircle(
            Offset(left.dx + 13, left.dy - 20),
            2.5,
            Paint()..color = ink,
          );
        _arrow(
          canvas,
          Offset(left.dx + 15, left.dy - 18),
          Offset(right.dx - 12, right.dy - 18),
          _stroke,
        );
        _label(
          canvas,
          '+',
          Offset(left.dx - 5, 116),
          12,
          align: TextAlign.center,
        );
        _label(
          canvas,
          '−',
          Offset(right.dx - 5, 116),
          12,
          align: TextAlign.center,
        );
      } else if (i == 1) {
        final left = Offset(x0 + slot * 0.32, 88);
        final right = Offset(x0 + slot * 0.68, 88);
        canvas
          ..drawCircle(left, 19, _stroke)
          ..drawCircle(right, 19, _stroke)
          ..drawCircle(
            Offset((left.dx + right.dx) / 2 - 3, 88),
            2.5,
            Paint()..color = board,
          )
          ..drawCircle(
            Offset((left.dx + right.dx) / 2 + 3, 88),
            2.5,
            Paint()..color = board,
          );
      } else {
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
          canvas.drawCircle(
            Offset(x0 + 15 + (dot % 4) * 25, 58 + (dot ~/ 4) * 58),
            2.3,
            Paint()..color = inkMuted,
          );
        }
      }
      _label(
        canvas,
        bonds[i]['electronAction']! as String,
        Offset(x0 + 6, 145),
        slot - 12,
        style: mutedStyle,
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
        final body = Rect.fromCenter(
          center: Offset(cx, 100),
          width: slot * 0.55,
          height: 76,
        );
        canvas
          ..drawRect(body, _stroke)
          ..drawLine(
            Offset(body.left, body.top + 20),
            Offset(body.right, body.top + 20),
            _stroke,
          );
        _arrow(canvas, Offset(cx, 49), Offset(cx, body.top + 16), _stroke);
      } else if (i == 1) {
        canvas
          ..drawOval(
            Rect.fromCenter(center: Offset(cx, 103), width: 50, height: 66),
            _stroke,
          )
          ..drawOval(
            Rect.fromCenter(center: Offset(cx, 103), width: 33, height: 45),
            _faint,
          );
        _label(
          canvas,
          'heat',
          Offset(cx - 20, 54),
          40,
          style: labelStyle.copyWith(color: amber),
          align: TextAlign.center,
        );
      } else if (i == 2) {
        final can =
            Rect.fromCenter(center: Offset(cx, 108), width: 48, height: 64);
        canvas
          ..drawRect(can, _stroke)
          ..drawArc(
            Rect.fromCircle(center: Offset(cx, 64), radius: 16),
            math.pi,
            math.pi,
            false,
            _stroke,
          );
        _arrow(canvas, Offset(cx, 64), Offset(cx + 10, 54), _stroke);
        _label(
          canvas,
          'heat',
          Offset(cx - 20, 154),
          40,
          style: labelStyle.copyWith(color: amber),
          align: TextAlign.center,
        );
      } else {
        final small =
            Rect.fromCenter(center: Offset(cx - 8, 103), width: 34, height: 50);
        final large =
            Rect.fromCenter(center: Offset(cx + 7, 103), width: 57, height: 76);
        canvas
          ..drawRect(large, _faint)
          ..drawRect(small, _stroke);
        for (var dot = 0; dot < 6; dot++) {
          canvas.drawCircle(
            Offset(
              large.left + 12 + (dot % 3) * 15,
              large.top + 18 + (dot ~/ 3) * 25,
            ),
            2.4,
            Paint()..color = ink,
          );
        }
      }
      _label(
        canvas,
        laws[i]['scene']! as String,
        Offset(x0 + 3, 176),
        slot - 6,
        style: mutedStyle,
        align: TextAlign.center,
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
        canvas.drawCircle(center, 28, _stroke);
      } else if (i == 1) {
        canvas.drawCircle(center, 30, _stroke);
        for (final d in <Offset>[
          const Offset(-13, -10),
          const Offset(10, -7),
          const Offset(-6, 13),
          const Offset(14, 11),
        ]) {
          canvas.drawCircle(center + d, 3, Paint()..color = ink);
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
          const Offset(0.16, 0.25),
          const Offset(0.38, 0.18),
          const Offset(0.65, 0.28),
          const Offset(0.80, 0.42),
          const Offset(0.28, 0.50),
          const Offset(0.52, 0.56),
          const Offset(0.72, 0.68),
          const Offset(0.20, 0.78),
          const Offset(0.45, 0.82),
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
          const Offset(0.72, 0.18),
          const Offset(0.42, 0.45),
          const Offset(0.84, 0.66),
          const Offset(0.20, 0.78),
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
      (12, 2),
      (12, 3),
      (13, 3),
      (13, 4),
      (14, 4),
      (14, 5),
      (15, 5),
      (15, 6),
    };
    final metalFill = Paint()..color = ink.withValues(alpha: .06);
    final metalloidFill = Paint()..color = ink.withValues(alpha: .24);
    final nonmetalFill = Paint()..color = ink.withValues(alpha: .14);
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
      ..moveTo(left + cellW * 12, top + cellH * 2)
      ..lineTo(left + cellW * 12, top + cellH * 3)
      ..lineTo(left + cellW * 13, top + cellH * 3)
      ..lineTo(left + cellW * 13, top + cellH * 4)
      ..lineTo(left + cellW * 14, top + cellH * 4)
      ..lineTo(left + cellW * 14, top + cellH * 5)
      ..lineTo(left + cellW * 15, top + cellH * 5)
      ..lineTo(left + cellW * 15, top + cellH * 6);
    canvas.drawPath(staircase, _stroke);
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
      Offset(left + cellW * 11.1, top + cellH * 6.2),
      cellW * 5.3,
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
        '${orbitals[i]['shape']} • max ${orbitals[i]['capacity']} e⁻',
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
      'same dissolved sugar, measured as:',
      Offset(size.width * 0.53, 29),
      size.width * 0.43,
      style: mutedStyle,
    );
    for (var i = 0; i < measures.length; i++) {
      final y = 78.0 + i * 28;
      canvas.drawLine(
        Offset(size.width * 0.55, y + 7),
        Offset(size.width * 0.61, y + 7),
        _faint,
      );
      _label(
        canvas,
        measures[i],
        Offset(size.width * 0.63, y),
        size.width * 0.33,
      );
    }
  }

  void _paintReactionEnergy(Canvas canvas, Size size) {
    final profiles = _mapList(spec['profiles'])!;
    final slot = size.width / 2;
    for (var i = 0; i < profiles.length; i++) {
      final x0 = slot * i + 18;
      final right = slot * (i + 1) - 18;
      const high = 57.0;
      const low = 137.0;
      canvas
        ..drawLine(Offset(x0, 22), Offset(x0, 168), _faint)
        ..drawLine(Offset(x0, 168), Offset(right, 168), _faint);
      final startY = i == 0 ? high : low;
      final endY = i == 0 ? low : high;
      final energyArrowPaint = Paint()
        ..color = i == 0 ? rust : board
        ..strokeWidth = 1.4;
      canvas
        ..drawLine(Offset(x0 + 22, startY), Offset(x0 + 70, startY), _stroke)
        ..drawLine(Offset(right - 70, endY), Offset(right - 22, endY), _stroke);
      final path = Path()
        ..moveTo(x0 + 70, startY)
        ..quadraticBezierTo((x0 + right) / 2, 34, right - 70, endY);
      canvas.drawPath(path, _stroke);
      _arrow(
        canvas,
        Offset((x0 + right) / 2 + 24, startY),
        Offset((x0 + right) / 2 + 24, endY),
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
        '${profiles[i]['energy']} energy',
        Offset(x0 + 36, 178),
        right - x0 - 72,
        style: mutedStyle,
        align: TextAlign.center,
      );
    }
  }

  void _particle(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 3.2, Paint()..color = ink);
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
