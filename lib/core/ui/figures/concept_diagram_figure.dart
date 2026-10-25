import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A labeled relationship diagram for sequences, flows, hierarchies, and
/// physics diagrams.
class ConceptDiagramFigure extends StatelessWidget {
  const ConceptDiagramFigure({
    required this.type,
    this.nodes = const [],
    this.edges = const [],
    this.sets,
    this.regions,
    this.center,
    this.overlaps,
    this.singleRegions,
    this.boxes,
    this.sections,
    this.root,
    this.branches,
    this.totalLeaves,
    this.clues,
    this.conclusion,
    this.mainIdea,
    this.details,
    this.forces,
    this.masses,
    this.distance,
    this.comparison,
    this.incidentAngle,
    this.reflectedAngle,
    this.labels,
    this.angles,
    this.vectorItems,
    this.additionComponents,
    this.resultant,
    this.magnitude,
    this.angle,
    this.unit,
    this.componentMap,
    this.netForce,
    this.body,
    this.orbiting,
    this.orbitVectors,
    this.waveLabels,
    this.wavelength,
    this.frequency,
    this.speed,
    super.key,
  });

  static const kind = 'concept-diagram';
  static const _types = {
    'sequence',
    'flow',
    'hierarchy',
    'venn',
    'nested-boxes',
    'conic-sections',
    'tree',
    'inference',
    'main-idea',
    'free-body',
    'gravitational-force',
    'ray-reflection',
    'vector-diagram',
    'vector-addition',
    'vector-components',
    'tug-of-war',
    'circular-orbit',
    'wave',
  };

  final String type;
  final List<String> nodes;
  final List<(int, int)> edges;
  final List<String>? sets;
  final Map<String, String>? regions;
  final String? center;
  final Map<String, String>? overlaps;
  final Map<String, String>? singleRegions;
  final List<String>? boxes;
  final List<String>? sections;
  final String? root;
  final List<Map<String, Object?>>? branches;
  final int? totalLeaves;
  final List<String>? clues;
  final String? conclusion;
  final String? mainIdea;
  final List<String>? details;
  final List<Map<String, Object?>>? forces;
  final List<String>? masses;
  final String? distance;
  final String? comparison;
  final double? incidentAngle;
  final double? reflectedAngle;
  final List<String>? labels;
  final List<String>? angles;
  final List<Map<String, Object?>>? vectorItems;
  final List<Map<String, Object?>>? additionComponents;
  final Map<String, Object?>? resultant;
  final double? magnitude;
  final double? angle;
  final String? unit;
  final Map<String, String>? componentMap;
  final Map<String, String>? netForce;
  final String? body;
  final String? orbiting;
  final Map<String, String>? orbitVectors;
  final Map<String, String>? waveLabels;
  final String? wavelength;
  final String? frequency;
  final String? speed;

  static ConceptDiagramFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    if (type is! String || !_types.contains(type)) return null;

    if (type == 'venn') {
      final rawSets = spec['sets'];
      if (rawSets is! List || (rawSets.length != 2 && rawSets.length != 3)) {
        return null;
      }
      final sets = <String>[];
      for (final s in rawSets) {
        if (s is! String || s.trim().isEmpty) return null;
        sets.add(s);
      }

      if (sets.length == 2) {
        final rawRegions = spec['regions'];
        if (rawRegions is! Map) return null;
        final regions = <String, String>{};
        for (final k in ['left', 'overlap', 'right', 'outside', 'total']) {
          final val = rawRegions[k];
          if (val == null) return null;
          final str = val.toString().trim();
          if (str.isEmpty) return null;
          regions[k] = str;
        }
        return ConceptDiagramFigure(
          type: type,
          sets: sets,
          regions: regions,
        );
      } else {
        final center = spec['center'];
        if (center is! String || center.trim().isEmpty) return null;
        final rawOverlaps = spec['overlaps'];
        if (rawOverlaps is! Map) return null;
        final overlaps = <String, String>{};
        for (final k in ['ab', 'bc', 'ca']) {
          final val = rawOverlaps[k];
          if (val == null) return null;
          final str = val.toString().trim();
          if (str.isEmpty) return null;
          overlaps[k] = str;
        }
        Map<String, String>? singleRegions;
        final rawSingle = spec['singleRegions'];
        if (rawSingle is Map) {
          singleRegions = <String, String>{};
          for (final entry in rawSingle.entries) {
            if (entry.key is String && entry.value != null) {
              singleRegions[entry.key as String] = entry.value.toString();
            }
          }
        }
        return ConceptDiagramFigure(
          type: type,
          sets: sets,
          center: center,
          overlaps: overlaps,
          singleRegions: singleRegions,
        );
      }
    }

    if (type == 'nested-boxes') {
      final rawBoxes = spec['boxes'];
      if (rawBoxes is! List || rawBoxes.isEmpty) return null;
      final boxes = <String>[];
      for (final b in rawBoxes) {
        if (b is! String || b.trim().isEmpty) return null;
        boxes.add(b);
      }
      return ConceptDiagramFigure(type: type, boxes: boxes);
    }

    if (type == 'conic-sections') {
      final rawSections = spec['sections'];
      if (rawSections is! List || rawSections.isEmpty) return null;
      final sections = <String>[];
      for (final s in rawSections) {
        if (s is! String || s.trim().isEmpty) return null;
        sections.add(s);
      }
      return ConceptDiagramFigure(type: type, sections: sections);
    }

    if (type == 'tree') {
      final root = spec['root'];
      if (root is! String || root.trim().isEmpty) return null;
      final rawBranches = spec['branches'];
      if (rawBranches is! List || rawBranches.isEmpty) return null;
      final branches = <Map<String, Object?>>[];
      for (final b in rawBranches) {
        if (b is! Map) return null;
        final name = b['name'];
        if (name is! String || name.trim().isEmpty) return null;
        final leaves = b['leaves'];
        if (leaves is int) {
          if (leaves <= 0) return null;
        } else if (leaves is List) {
          if (leaves.isEmpty) return null;
          for (final l in leaves) {
            if (l is! String || l.trim().isEmpty) return null;
          }
        } else {
          return null;
        }
        branches.add(b.cast<String, Object?>());
      }
      final totalLeaves = spec['totalLeaves'];
      if (totalLeaves is! int || totalLeaves <= 0) return null;
      return ConceptDiagramFigure(
        type: type,
        root: root,
        branches: branches,
        totalLeaves: totalLeaves,
      );
    }

    if (type == 'inference') {
      final rawClues = spec['clues'];
      if (rawClues is! List || rawClues.isEmpty) return null;
      final clues = <String>[];
      for (final c in rawClues) {
        if (c is! String || c.trim().isEmpty) return null;
        clues.add(c);
      }
      final conclusion = spec['conclusion'];
      if (conclusion is! String || conclusion.trim().isEmpty) return null;
      return ConceptDiagramFigure(
        type: type,
        clues: clues,
        conclusion: conclusion,
      );
    }

    if (type == 'main-idea') {
      final mainIdea = spec['mainIdea'];
      if (mainIdea is! String || mainIdea.trim().isEmpty) return null;
      final rawDetails = spec['details'];
      if (rawDetails is! List || rawDetails.isEmpty) return null;
      final details = <String>[];
      for (final d in rawDetails) {
        if (d is! String || d.trim().isEmpty) return null;
        details.add(d);
      }
      return ConceptDiagramFigure(
        type: type,
        mainIdea: mainIdea,
        details: details,
      );
    }

    if (type == 'free-body') {
      final rawForces = spec['forces'];
      if (rawForces is! List || rawForces.isEmpty) return null;
      final forces = <Map<String, Object?>>[];
      for (final f in rawForces) {
        if (f is! Map) return null;
        final label = f['label'];
        if (label is! String || label.trim().isEmpty) return null;
        final dir = f['direction'];
        if (dir != 'up' && dir != 'down' && dir != 'left' && dir != 'right') {
          return null;
        }
        forces.add(f.cast<String, Object?>());
      }
      return ConceptDiagramFigure(
        type: type,
        forces: forces,
      );
    }

    if (type == 'tug-of-war') {
      final rawForces = spec['forces'];
      if (rawForces is! List || rawForces.length < 2) return null;
      final forces = <Map<String, Object?>>[];
      for (final f in rawForces) {
        if (f is! Map) return null;
        final label = f['label'];
        if (label is! String || label.trim().isEmpty) return null;
        final dir = f['direction'];
        if (dir != 'left' && dir != 'right') return null;
        final mag = f['magnitude'];
        if (mag is! num || !mag.isFinite || mag <= 0) return null;
        forces.add(f.cast<String, Object?>());
      }
      final rawNet = spec['netForce'];
      if (rawNet is! Map) return null;
      final netLabel = rawNet['label'];
      if (netLabel is! String || netLabel.trim().isEmpty) return null;
      final netDir = rawNet['direction'];
      if (netDir != 'left' && netDir != 'right') return null;
      final netForce = <String, String>{
        'label': netLabel,
        'direction': netDir as String,
      };
      return ConceptDiagramFigure(
        type: type,
        forces: forces,
        netForce: netForce,
      );
    }

    if (type == 'gravitational-force') {
      final rawMasses = spec['masses'];
      if (rawMasses is! List || rawMasses.length != 2) return null;
      final masses = <String>[];
      for (final m in rawMasses) {
        if (m is! String || m.trim().isEmpty) return null;
        masses.add(m);
      }
      final distance = spec['distance'];
      if (distance is! String || distance.trim().isEmpty) return null;
      final comparison = spec['comparison'];
      if (comparison is! String || comparison.trim().isEmpty) return null;
      return ConceptDiagramFigure(
        type: type,
        masses: masses,
        distance: distance,
        comparison: comparison,
      );
    }

    if (type == 'ray-reflection') {
      final rawLabels = spec['labels'];
      if (rawLabels is! List || rawLabels.isEmpty) return null;
      final labels = <String>[];
      for (final l in rawLabels) {
        if (l is! String || l.trim().isEmpty) return null;
        labels.add(l);
      }

      final incidentAngle = spec['incidentAngle'];
      final reflectedAngle = spec['reflectedAngle'];
      if (incidentAngle != null || reflectedAngle != null) {
        if (incidentAngle is! num ||
            reflectedAngle is! num ||
            !incidentAngle.isFinite ||
            !reflectedAngle.isFinite ||
            incidentAngle <= 0 ||
            incidentAngle >= 90 ||
            reflectedAngle <= 0 ||
            reflectedAngle >= 90 ||
            labels.length != 2) {
          return null;
        }
        return ConceptDiagramFigure(
          type: type,
          labels: labels,
          incidentAngle: incidentAngle.toDouble(),
          reflectedAngle: reflectedAngle.toDouble(),
        );
      } else {
        final rawAngles = spec['angles'];
        if (rawAngles is! List || rawAngles.length != 2 || labels.length != 3) {
          return null;
        }
        final angles = <String>[];
        for (final a in rawAngles) {
          if (a is! String || a.trim().isEmpty) return null;
          angles.add(a);
        }
        return ConceptDiagramFigure(
          type: type,
          labels: labels,
          angles: angles,
        );
      }
    }

    if (type == 'vector-diagram') {
      final rawVectors = spec['vectors'];
      if (rawVectors is! List || rawVectors.isEmpty) return null;
      final vectors = <Map<String, Object?>>[];
      for (final v in rawVectors) {
        if (v is! Map) return null;
        final label = v['label'];
        if (label is! String || label.trim().isEmpty) return null;
        final angle = v['angle'];
        if (angle is! num || !angle.isFinite) return null;
        final mag = v['magnitude'];
        if (mag is! num || !mag.isFinite || mag <= 0) return null;
        vectors.add(v.cast<String, Object?>());
      }
      return ConceptDiagramFigure(
        type: type,
        vectorItems: vectors,
      );
    }

    if (type == 'vector-addition') {
      final rawComponents = spec['components'];
      if (rawComponents is! List || rawComponents.length < 2) return null;
      final components = <Map<String, Object?>>[];
      for (final c in rawComponents) {
        if (c is! Map) return null;
        final label = c['label'];
        if (label is! String || label.trim().isEmpty) return null;
        final dx = c['dx'];
        final dy = c['dy'];
        if (dx is! num || dy is! num || !dx.isFinite || !dy.isFinite) {
          return null;
        }
        components.add(c.cast<String, Object?>());
      }
      final rawResultant = spec['resultant'];
      if (rawResultant is! Map) return null;
      final resLabel = rawResultant['label'];
      if (resLabel is! String || resLabel.trim().isEmpty) return null;
      final rdx = rawResultant['dx'];
      final rdy = rawResultant['dy'];
      if (rdx is! num || rdy is! num || !rdx.isFinite || !rdy.isFinite) {
        return null;
      }
      return ConceptDiagramFigure(
        type: type,
        additionComponents: components,
        resultant: rawResultant.cast<String, Object?>(),
      );
    }

    if (type == 'vector-components') {
      final magnitude = spec['magnitude'];
      final angle = spec['angle'];
      final unit = spec['unit'];
      final rawComponents = spec['components'];
      if (magnitude is! num ||
          !magnitude.isFinite ||
          magnitude <= 0 ||
          angle is! num ||
          !angle.isFinite ||
          angle < 0 ||
          angle > 360 ||
          unit is! String ||
          unit.trim().isEmpty ||
          rawComponents is! Map) {
        return null;
      }
      final h = rawComponents['horizontal'];
      final v = rawComponents['vertical'];
      if (h is! String ||
          v is! String ||
          h.trim().isEmpty ||
          v.trim().isEmpty) {
        return null;
      }
      return ConceptDiagramFigure(
        type: type,
        magnitude: magnitude.toDouble(),
        angle: angle.toDouble(),
        unit: unit,
        componentMap: {
          'horizontal': h,
          'vertical': v,
        },
      );
    }

    if (type == 'circular-orbit') {
      final body = spec['body'];
      final orbiting = spec['orbiting'];
      final rawVectors = spec['vectors'];
      if (body is! String ||
          body.trim().isEmpty ||
          orbiting is! String ||
          orbiting.trim().isEmpty ||
          rawVectors is! Map) {
        return null;
      }
      final vel = rawVectors['velocity'];
      final acc = rawVectors['acceleration'];
      if (vel is! String ||
          acc is! String ||
          vel.trim().isEmpty ||
          acc.trim().isEmpty) {
        return null;
      }
      return ConceptDiagramFigure(
        type: type,
        body: body,
        orbiting: orbiting,
        orbitVectors: {
          'velocity': vel,
          'acceleration': acc,
        },
      );
    }

    if (type == 'wave') {
      final rawLabels = spec['labels'];
      if (rawLabels is! Map || rawLabels.isEmpty) return null;
      final waveLabels = <String, String>{};
      for (final entry in rawLabels.entries) {
        if (entry.key is! String ||
            entry.value is! String ||
            (entry.key as String).trim().isEmpty ||
            (entry.value as String).trim().isEmpty) {
          return null;
        }
        waveLabels[entry.key as String] = entry.value as String;
      }
      final wavelength = spec['wavelength'];
      if (wavelength != null &&
          (wavelength is! String || wavelength.trim().isEmpty)) {
        return null;
      }
      final frequency = spec['frequency'];
      if (frequency != null &&
          (frequency is! String || frequency.trim().isEmpty)) {
        return null;
      }
      final speed = spec['speed'];
      if (speed != null && (speed is! String || speed.trim().isEmpty)) {
        return null;
      }
      return ConceptDiagramFigure(
        type: type,
        waveLabels: waveLabels,
        wavelength: wavelength as String?,
        frequency: frequency as String?,
        speed: speed as String?,
      );
    }

    // Default node-and-edge sequence/flow/hierarchy
    final rawNodes = spec['nodes'];
    final rawEdges = spec['edges'];
    if (rawNodes is! List || rawNodes.length < 2 || rawNodes.length > 12) {
      return null;
    }
    if (rawEdges is! List || rawEdges.length > 24) return null;

    final nodes = <String>[];
    for (final node in rawNodes) {
      if (node is! String || node.trim().isEmpty || node.length > 40) {
        return null;
      }
      nodes.add(node);
    }

    final edges = <(int, int)>[];
    for (final edge in rawEdges) {
      if (edge is! List || edge.length != 2) return null;
      final from = edge[0];
      final to = edge[1];
      if (from is! int ||
          to is! int ||
          from < 0 ||
          to < 0 ||
          from >= nodes.length ||
          to >= nodes.length ||
          from == to) {
        return null;
      }
      edges.add((from, to));
    }

    return ConceptDiagramFigure(
      type: type,
      nodes: nodes,
      edges: edges,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A $type diagram.',
      child: SizedBox(
        height: 220,
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConceptDiagramPainter(
            type: type,
            nodes: nodes,
            edges: edges,
            sets: sets,
            regions: regions,
            center: center,
            overlaps: overlaps,
            singleRegions: singleRegions,
            boxes: boxes,
            sections: sections,
            root: root,
            branches: branches,
            totalLeaves: totalLeaves,
            clues: clues,
            conclusion: conclusion,
            mainIdea: mainIdea,
            details: details,
            forces: forces,
            masses: masses,
            distance: distance,
            comparison: comparison,
            incidentAngle: incidentAngle,
            reflectedAngle: reflectedAngle,
            labels: labels,
            angles: angles,
            vectorItems: vectorItems,
            additionComponents: additionComponents,
            resultant: resultant,
            magnitude: magnitude,
            angle: angle,
            unit: unit,
            componentMap: componentMap,
            netForce: netForce,
            body: body,
            orbiting: orbiting,
            orbitVectors: orbitVectors,
            waveLabels: waveLabels,
            wavelength: wavelength,
            frequency: frequency,
            speed: speed,
            ink: colors.label,
            faint: colors.fill,
            background: colors.background,
            labelStyle: context.type.subhead.copyWith(
              color: colors.label,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConceptDiagramPainter extends CustomPainter {
  _ConceptDiagramPainter({
    required this.type,
    required this.nodes,
    required this.edges,
    required this.ink,
    required this.faint,
    required this.background,
    required this.labelStyle,
    this.sets,
    this.regions,
    this.center,
    this.overlaps,
    this.singleRegions,
    this.boxes,
    this.sections,
    this.root,
    this.branches,
    this.totalLeaves,
    this.clues,
    this.conclusion,
    this.mainIdea,
    this.details,
    this.forces,
    this.masses,
    this.distance,
    this.comparison,
    this.incidentAngle,
    this.reflectedAngle,
    this.labels,
    this.angles,
    this.vectorItems,
    this.additionComponents,
    this.resultant,
    this.magnitude,
    this.angle,
    this.unit,
    this.componentMap,
    this.netForce,
    this.body,
    this.orbiting,
    this.orbitVectors,
    this.waveLabels,
    this.wavelength,
    this.frequency,
    this.speed,
  });

  final String type;
  final List<String> nodes;
  final List<(int, int)> edges;
  final List<String>? sets;
  final Map<String, String>? regions;
  final String? center;
  final Map<String, String>? overlaps;
  final Map<String, String>? singleRegions;
  final List<String>? boxes;
  final List<String>? sections;
  final String? root;
  final List<Map<String, Object?>>? branches;
  final int? totalLeaves;
  final List<String>? clues;
  final String? conclusion;
  final String? mainIdea;
  final List<String>? details;
  final List<Map<String, Object?>>? forces;
  final List<String>? masses;
  final String? distance;
  final String? comparison;
  final double? incidentAngle;
  final double? reflectedAngle;
  final List<String>? labels;
  final List<String>? angles;
  final List<Map<String, Object?>>? vectorItems;
  final List<Map<String, Object?>>? additionComponents;
  final Map<String, Object?>? resultant;
  final double? magnitude;
  final double? angle;
  final String? unit;
  final Map<String, String>? componentMap;
  final Map<String, String>? netForce;
  final String? body;
  final String? orbiting;
  final Map<String, String>? orbitVectors;
  final Map<String, String>? waveLabels;
  final String? wavelength;
  final String? frequency;
  final String? speed;
  final Color ink;
  final Color faint;
  final Color background;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case 'venn':
        _drawVenn(canvas, size);
      case 'nested-boxes':
        _drawNestedBoxes(canvas, size);
      case 'conic-sections':
        _drawConicSections(canvas, size);
      case 'tree':
        _drawTree(canvas, size);
      case 'inference':
        _drawInference(canvas, size);
      case 'main-idea':
        _drawMainIdea(canvas, size);
      case 'free-body':
        _drawFreeBody(canvas, size);
      case 'gravitational-force':
        _drawGravitationalForce(canvas, size);
      case 'ray-reflection':
        _drawRayReflection(canvas, size);
      case 'vector-diagram':
        _drawVectorDiagram(canvas, size);
      case 'vector-addition':
        _drawVectorAddition(canvas, size);
      case 'vector-components':
        _drawVectorComponents(canvas, size);
      case 'tug-of-war':
        _drawTugOfWar(canvas, size);
      case 'circular-orbit':
        _drawCircularOrbit(canvas, size);
      case 'wave':
        _drawWave(canvas, size);
      default:
        _drawDefaultSequence(canvas, size);
    }
  }

  void _drawDefaultSequence(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final centers =
        type == 'hierarchy' ? _hierarchyCenters(size) : _rowCenters(size);
    final count = math.min(nodes.length, centers.length);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fill = Paint()
      ..color = background
      ..style = PaintingStyle.fill;

    for (final edge in edges) {
      if (edge.$1 >= count || edge.$2 >= count) continue;
      final from = centers[edge.$1];
      final to = centers[edge.$2];
      canvas.drawLine(from, to, stroke);
      _drawArrowHead(canvas, from, to, stroke);
    }

    const boxWidth = 72.0;
    const boxHeight = 36.0;
    for (var i = 0; i < count; i++) {
      final center = centers[i];
      final rect = Rect.fromCenter(
        center: center,
        width: boxWidth,
        height: boxHeight,
      );
      canvas
        ..drawRect(rect, fill)
        ..drawRect(rect, stroke);

      final painter = TextPainter(
        text: TextSpan(text: nodes[i], style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: boxWidth - 8);
      painter.paint(
        canvas,
        Offset(
          center.dx - painter.width / 2,
          center.dy - painter.height / 2,
        ),
      );
    }
  }

  void _drawVenn(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final outerBox = Rect.fromLTWH(16, 12, size.width - 32, size.height - 24);
    canvas.drawRect(outerBox, faintStroke);

    if (sets != null && sets!.length == 3) {
      _drawText(
        canvas,
        'Universal Set',
        Offset(outerBox.left + 6, outerBox.top + 4),
      );
      final c = outerBox.center;
      const r = 50.0;
      final cA = Offset(c.dx - 32, c.dy - 20);
      final cB = Offset(c.dx + 32, c.dy - 20);
      final cC = Offset(c.dx, c.dy + 30);
      canvas
        ..drawCircle(cA, r, stroke)
        ..drawCircle(cB, r, stroke)
        ..drawCircle(cC, r, stroke);

      _drawText(canvas, sets![0], Offset(cA.dx - 35, cA.dy - 55));
      _drawText(canvas, sets![1], Offset(cB.dx - 10, cB.dy - 55));
      _drawText(canvas, sets![2], Offset(cC.dx - 40, cC.dy + 45));

      _drawText(canvas, center ?? '5', Offset(c.dx - 4, c.dy - 6));
      _drawText(canvas, overlaps?['ab'] ?? '10', Offset(c.dx - 4, cA.dy - 10));
      _drawText(canvas, overlaps?['bc'] ?? '5', Offset(c.dx + 16, c.dy + 12));
      _drawText(canvas, overlaps?['ca'] ?? '7', Offset(c.dx - 24, c.dy + 12));
      return;
    }

    // 2-circle Venn
    _drawText(
      canvas,
      'Total = ${regions?['total'] ?? '40'}',
      Offset(outerBox.left + 8, outerBox.top + 6),
    );
    _drawText(
      canvas,
      'Outside: ${regions?['outside'] ?? '5'}',
      Offset(outerBox.right - 70, outerBox.bottom - 20),
    );

    final cy = outerBox.center.dy;
    final c1 = Offset(outerBox.center.dx - 45, cy);
    final c2 = Offset(outerBox.center.dx + 45, cy);
    const r = 62.0;
    canvas
      ..drawCircle(c1, r, stroke)
      ..drawCircle(c2, r, stroke);

    _drawText(
      canvas,
      sets != null && sets!.isNotEmpty ? sets![0] : 'Set A',
      Offset(c1.dx - 40, c1.dy - 74),
    );
    _drawText(
      canvas,
      sets != null && sets!.length > 1 ? sets![1] : 'Set B',
      Offset(c2.dx - 10, c2.dy - 74),
    );

    _drawText(canvas, regions?['left'] ?? '17', Offset(c1.dx - 28, cy - 8));
    _drawText(
      canvas,
      regions?['overlap'] ?? '8',
      Offset(outerBox.center.dx - 4, cy - 8),
    );
    _drawText(canvas, regions?['right'] ?? '10', Offset(c2.dx + 16, cy - 8));
  }

  void _drawNestedBoxes(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final realBox = Rect.fromLTWH(16, 12, size.width - 32, size.height - 24);
    canvas.drawRect(realBox, stroke);
    _drawText(
      canvas,
      'Real Numbers',
      Offset(realBox.left + 8, realBox.top + 6),
    );

    final irratBox = Rect.fromLTWH(size.width - 140, 42, 112, size.height - 66);
    canvas.drawRect(irratBox, stroke);
    _drawText(
      canvas,
      'Irrational Numbers',
      Offset(irratBox.left + 6, irratBox.top + 8),
    );

    final ratBox = Rect.fromLTWH(28, 42, size.width - 180, size.height - 66);
    canvas.drawRect(ratBox, stroke);
    _drawText(
      canvas,
      'Rational Numbers',
      Offset(ratBox.left + 6, ratBox.top + 6),
    );

    final intBox = Rect.fromLTWH(38, 70, ratBox.width - 20, ratBox.height - 36);
    canvas.drawRect(intBox, stroke);
    _drawText(canvas, 'Integers', Offset(intBox.left + 6, intBox.top + 4));

    final wholeBox =
        Rect.fromLTWH(48, 96, intBox.width - 20, intBox.height - 34);
    canvas.drawRect(wholeBox, stroke);
    _drawText(
      canvas,
      'Whole Numbers',
      Offset(wholeBox.left + 6, wholeBox.top + 4),
    );

    final natBox =
        Rect.fromLTWH(58, 122, wholeBox.width - 20, wholeBox.height - 34);
    canvas.drawRect(natBox, stroke);
    _drawText(
      canvas,
      'Natural Numbers',
      Offset(natBox.left + 6, natBox.top + 4),
    );
  }

  void _drawConicSections(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cx = size.width * 0.4;
    final cy = size.height / 2;

    final topApex = Offset(cx, cy);
    canvas
      ..drawLine(topApex, Offset(cx - 50, cy - 80), stroke)
      ..drawLine(topApex, Offset(cx + 50, cy - 80), stroke)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy - 80),
          width: 100,
          height: 24,
        ),
        stroke,
      )
      ..drawLine(topApex, Offset(cx - 50, cy + 80), stroke)
      ..drawLine(topApex, Offset(cx + 50, cy + 80), stroke)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 80),
          width: 100,
          height: 24,
        ),
        stroke,
      )
      ..drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy - 50),
          width: 62,
          height: 16,
        ),
        faintStroke,
      );
    _drawText(
      canvas,
      'Circle (horizontal cut)',
      Offset(cx + 65, cy - 56),
    );

    _drawText(
      canvas,
      'Ellipse (tilted cut)',
      Offset(cx + 65, cy - 30),
    );

    _drawText(
      canvas,
      'Parabola (parallel cut)',
      Offset(cx + 65, cy + 20),
    );

    _drawText(
      canvas,
      'Hyperbola (vertical cut)',
      Offset(cx + 65, cy + 50),
    );
  }

  void _drawTree(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    const rootX = 40.0;
    final rootY = size.height / 2;
    _drawText(canvas, root ?? 'Outfits', Offset(rootX - 25, rootY - 8));

    final branchCount = branches?.length ?? 4;
    const branchX = 140.0;
    final leafX = size.width - 70;

    for (var i = 0; i < branchCount; i++) {
      final by = 25.0 + i * (size.height - 50) / (branchCount - 1);
      canvas.drawLine(
        Offset(rootX + 20, rootY),
        Offset(branchX - 10, by),
        stroke,
      );
      final bName = branches != null && i < branches!.length
          ? (branches![i]['name'] as String? ?? 'Shirt ${i + 1}')
          : 'Shirt ${i + 1}';
      _drawText(canvas, bName, Offset(branchX, by - 7));

      for (var j = 0; j < 3; j++) {
        final ly = by - 12 + j * 12;
        canvas.drawLine(
          Offset(branchX + 50, by),
          Offset(leafX - 10, ly),
          stroke,
        );
        _drawText(canvas, 'Pants ${j + 1}', Offset(leafX, ly - 6));
      }
    }
  }

  void _drawInference(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final clueItems =
        clues ?? ['Clue phrase 1', 'Clue phrase 2', 'Clue phrase 3'];
    final slotW = size.width / clueItems.length;

    for (var i = 0; i < clueItems.length; i++) {
      final box = Rect.fromLTWH(slotW * i + 8, 20, slotW - 16, 42);
      canvas.drawRect(box, stroke);
      _drawText(canvas, clueItems[i], Offset(box.left + 8, box.top + 14));

      final start = Offset(box.center.dx, box.bottom);
      final end = Offset(size.width / 2, size.height - 60);
      _drawDashedLine(canvas, start, end, faintStroke);
      _drawArrowHead(canvas, start, end, faintStroke);
    }

    final conclBox = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 40),
      width: 180,
      height: 42,
    );
    canvas.drawRect(conclBox, stroke);
    _drawText(
      canvas,
      conclusion ?? 'Inference / Conclusion',
      Offset(conclBox.left + 12, conclBox.top + 14),
    );
  }

  void _drawMainIdea(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final mainBox = Rect.fromCenter(
      center: Offset(size.width / 2, 40),
      width: size.width - 48,
      height: 44,
    );
    canvas.drawRect(mainBox, stroke);
    _drawText(
      canvas,
      mainIdea ?? 'Topic sentence / Main idea',
      Offset(mainBox.left + 16, mainBox.top + 14),
    );

    final detailItems = details ??
        ['Supporting detail 1', 'Supporting detail 2', 'Supporting detail 3'];
    final slotW = size.width / detailItems.length;

    for (var i = 0; i < detailItems.length; i++) {
      final box =
          Rect.fromLTWH(slotW * i + 10, size.height - 60, slotW - 20, 42);
      canvas.drawRect(box, stroke);
      _drawText(canvas, detailItems[i], Offset(box.left + 6, box.top + 14));

      final start = Offset(box.center.dx, box.top);
      final end = Offset(box.center.dx, mainBox.bottom);
      canvas.drawLine(start, end, faintStroke);
      _drawArrowHead(canvas, start, end, faintStroke);
    }
  }

  void _drawFreeBody(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final fill = Paint()
      ..color = background
      ..style = PaintingStyle.fill;

    final center = size.center(Offset.zero);
    final box = Rect.fromCenter(center: center, width: 64, height: 64);
    canvas
      ..drawRect(box, fill)
      ..drawRect(box, stroke);
    _drawText(canvas, 'Box (m)', Offset(center.dx - 20, center.dy - 6));

    _drawArrow(
      canvas,
      Offset(center.dx, box.top),
      Offset(center.dx, box.top - 55),
      stroke,
    );
    _drawText(
      canvas,
      'Normal Force (Fn)',
      Offset(center.dx + 8, box.top - 50),
    );

    _drawArrow(
      canvas,
      Offset(center.dx, box.bottom),
      Offset(center.dx, box.bottom + 55),
      stroke,
    );
    _drawText(
      canvas,
      'Weight (Fg = mg)',
      Offset(center.dx + 8, box.bottom + 38),
    );
  }

  void _drawGravitationalForce(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final y1 = size.height * 0.38;
    final s1 = Offset(70, y1);
    final s2 = Offset(210, y1);
    canvas.drawCircle(s1, 24, stroke);
    _drawText(
      canvas,
      masses != null && masses!.isNotEmpty ? masses![0] : 'm1',
      Offset(s1.dx - 8, s1.dy - 6),
    );

    canvas.drawCircle(s2, 16, stroke);
    _drawText(
      canvas,
      masses != null && masses!.length > 1 ? masses![1] : 'm2',
      Offset(s2.dx - 8, s2.dy - 6),
    );

    _drawArrow(canvas, s1, Offset(s1.dx + 40, y1), stroke);
    _drawText(canvas, 'F', Offset(s1.dx + 20, y1 - 18));

    _drawArrow(canvas, s2, Offset(s2.dx - 40, y1), stroke);
    _drawText(canvas, 'F', Offset(s2.dx - 30, y1 - 18));

    _drawDashedLine(
      canvas,
      Offset(s1.dx, y1 + 32),
      Offset(s2.dx, y1 + 32),
      faintStroke,
    );
    _drawText(
      canvas,
      'distance = ${distance ?? 'r'}',
      Offset((s1.dx + s2.dx) / 2 - 28, y1 + 36),
    );

    final inset = Rect.fromLTWH(size.width - 150, 16, 134, size.height - 32);
    canvas.drawRect(inset, faintStroke);
    _drawText(
      canvas,
      'At double distance (2r):',
      Offset(inset.left + 6, inset.top + 6),
    );
    final iy = inset.center.dy + 8;
    canvas
      ..drawCircle(Offset(inset.left + 24, iy), 14, stroke)
      ..drawCircle(Offset(inset.right - 24, iy), 10, stroke);
    _drawArrow(
      canvas,
      Offset(inset.left + 24, iy),
      Offset(inset.left + 40, iy),
      stroke,
    );
    _drawArrow(
      canvas,
      Offset(inset.right - 24, iy),
      Offset(inset.right - 40, iy),
      stroke,
    );
    _drawText(
      canvas,
      'Force = F / 4',
      Offset(inset.left + 28, inset.bottom - 22),
    );
  }

  void _drawRayReflection(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final mirrorY = size.height - 40;
    const mirrorLeft = 40.0;
    final mirrorRight = size.width - 40;
    final center = Offset(size.width / 2, mirrorY);

    canvas.drawLine(
      Offset(mirrorLeft, mirrorY),
      Offset(mirrorRight, mirrorY),
      stroke,
    );
    for (var x = mirrorLeft; x <= mirrorRight; x += 10) {
      canvas.drawLine(
        Offset(x, mirrorY),
        Offset(x - 6, mirrorY + 8),
        faintStroke,
      );
    }
    _drawText(canvas, 'Flat mirror', Offset(mirrorLeft, mirrorY + 12));

    _drawDashedLine(canvas, Offset(center.dx, 20), center, faintStroke);
    _drawText(canvas, 'Normal line', Offset(center.dx + 4, 22));

    final incStart = Offset(center.dx - 90, 45);
    _drawArrow(canvas, incStart, center, stroke);
    _drawText(
      canvas,
      incidentAngle != null
          ? '${incidentAngle!.toInt()}°'
          : (labels != null && labels!.isNotEmpty
              ? labels![0]
              : 'Angle of incidence (θi)'),
      Offset(center.dx - 80, mirrorY - 60),
    );

    final refEnd = Offset(center.dx + 90, 45);
    _drawArrow(canvas, center, refEnd, stroke);
    _drawText(
      canvas,
      reflectedAngle != null
          ? '${reflectedAngle!.toInt()}°'
          : (labels != null && labels!.length > 2
              ? labels![2]
              : 'Angle of reflection (θr)'),
      Offset(center.dx + 16, mirrorY - 60),
    );

    canvas
      ..drawArc(
        Rect.fromCircle(center: center, radius: 28),
        -math.pi / 2 - 0.7,
        0.7,
        false,
        faintStroke,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: 28),
        -math.pi / 2,
        0.7,
        false,
        faintStroke,
      );
  }

  void _drawVectorDiagram(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final origin = Offset(60, size.height - 50);

    final v1End = Offset(origin.dx + 90, origin.dy);
    _drawArrow(canvas, origin, v1End, stroke);
    final l1 = vectorItems != null && vectorItems!.isNotEmpty
        ? (vectorItems![0]['label'] as String? ?? '5 N East')
        : '5 N East';
    _drawText(
      canvas,
      l1,
      Offset(origin.dx + 10, origin.dy + 8),
    );

    final v2End = Offset(origin.dx + 140, origin.dy - 100);
    _drawArrow(canvas, origin, v2End, stroke);
    final l2 = vectorItems != null && vectorItems!.length > 1
        ? (vectorItems![1]['label'] as String? ?? '8 N Northeast')
        : '8 N Northeast';
    _drawText(
      canvas,
      l2,
      Offset(v2End.dx - 30, v2End.dy - 16),
    );
  }

  void _drawVectorAddition(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final start = Offset(60, size.height - 40);
    final corner = Offset(start.dx + 140, start.dy);
    final tip = Offset(corner.dx, corner.dy - 110);

    final l1 = additionComponents != null && additionComponents!.isNotEmpty
        ? (additionComponents![0]['label'] as String? ?? '3 km East')
        : '3 km East';
    _drawArrow(canvas, start, corner, stroke);
    _drawText(
      canvas,
      l1,
      Offset((start.dx + corner.dx) / 2 - 20, start.dy + 8),
    );

    final l2 = additionComponents != null && additionComponents!.length > 1
        ? (additionComponents![1]['label'] as String? ?? '4 km North')
        : '4 km North';
    _drawArrow(canvas, corner, tip, stroke);
    _drawText(
      canvas,
      l2,
      Offset(corner.dx + 8, (corner.dy + tip.dy) / 2),
    );

    canvas.drawRect(
      Rect.fromLTWH(corner.dx - 12, corner.dy - 12, 12, 12),
      faintStroke,
    );

    final resLabel = resultant != null
        ? (resultant!['label'] as String? ?? 'Resultant = 5 km')
        : 'Resultant = 5 km';
    _drawArrow(canvas, start, tip, stroke);
    _drawText(
      canvas,
      resLabel,
      Offset((start.dx + tip.dx) / 2 - 55, (start.dy + tip.dy) / 2 - 14),
    );
  }

  void _drawVectorComponents(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final origin = Offset(60, size.height - 40);
    final mag = magnitude ?? 10.0;
    final deg = angle ?? 30.0;
    final rad = deg * math.pi / 180;
    const len = 160.0;

    final tip = Offset(
      origin.dx + math.cos(rad) * len,
      origin.dy - math.sin(rad) * len,
    );
    final corner = Offset(tip.dx, origin.dy);

    _drawArrow(canvas, origin, tip, stroke);
    _drawText(
      canvas,
      '${mag.toInt()} ${unit ?? 'N'} at ${deg.toInt()}°',
      Offset((origin.dx + tip.dx) / 2 - 20, (origin.dy + tip.dy) / 2 - 18),
    );

    final hText =
        componentMap?['horizontal'] ?? '${mag.toInt()} cos(${deg.toInt()}°)';
    _drawArrow(canvas, origin, corner, stroke);
    _drawText(
      canvas,
      hText,
      Offset((origin.dx + corner.dx) / 2 - 25, origin.dy + 8),
    );

    final vText =
        componentMap?['vertical'] ?? '${mag.toInt()} sin(${deg.toInt()}°)';
    _drawDashedLine(canvas, tip, corner, faintStroke);
    _drawText(
      canvas,
      vText,
      Offset(corner.dx + 8, (tip.dy + corner.dy) / 2),
    );

    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: 30),
      -rad,
      rad,
      false,
      faintStroke,
    );
    _drawText(
      canvas,
      '${deg.toInt()}°',
      Offset(origin.dx + 35, origin.dy - 16),
    );
  }

  void _drawTugOfWar(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final cy = size.height * 0.4;
    final cx = size.width / 2;

    canvas
      ..drawLine(Offset(40, cy), Offset(size.width - 40, cy), stroke)
      ..drawCircle(Offset(cx, cy), 5, Paint()..color = ink);

    final lA = forces != null && forces!.isNotEmpty
        ? (forces![0]['label'] as String? ?? 'Team A: 600 N (Left)')
        : 'Team A: 600 N (Left)';
    _drawArrow(canvas, Offset(cx, cy), Offset(cx - 110, cy), stroke);
    _drawText(canvas, lA, Offset(cx - 130, cy - 22));

    final lB = forces != null && forces!.length > 1
        ? (forces![1]['label'] as String? ?? 'Team B: 450 N (Right)')
        : 'Team B: 450 N (Right)';
    _drawArrow(canvas, Offset(cx, cy), Offset(cx + 80, cy), stroke);
    _drawText(canvas, lB, Offset(cx + 20, cy - 22));

    final netY = cy + 45;
    final netText = netForce?['label'] ?? 'Net Force = 150 N to the Left';
    _drawArrow(canvas, Offset(cx, netY), Offset(cx - 50, netY), stroke);
    _drawText(
      canvas,
      netText,
      Offset(cx - 100, netY + 8),
    );
  }

  void _drawCircularOrbit(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = size.center(Offset.zero);
    canvas.drawCircle(center, 32, stroke);
    _drawText(canvas, body ?? 'Earth', Offset(center.dx - 14, center.dy - 6));

    const r = 70.0;
    canvas.drawCircle(center, r, faintStroke);

    final satPos = Offset(center.dx, center.dy - r);
    canvas.drawRect(
      Rect.fromCenter(center: satPos, width: 12, height: 12),
      Paint()..color = ink,
    );
    _drawText(
      canvas,
      orbiting ?? 'Satellite',
      Offset(satPos.dx + 10, satPos.dy - 12),
    );

    _drawArrow(canvas, satPos, Offset(satPos.dx - 55, satPos.dy), stroke);
    _drawText(
      canvas,
      orbitVectors?['velocity'] ?? 'v (tangent)',
      Offset(satPos.dx - 65, satPos.dy - 16),
    );

    _drawArrow(canvas, satPos, Offset(satPos.dx, satPos.dy + 40), stroke);
    _drawText(
      canvas,
      orbitVectors?['acceleration'] ?? 'ac (inward)',
      Offset(satPos.dx + 6, satPos.dy + 15),
    );
  }

  void _drawWave(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cy = size.height * 0.52;
    canvas.drawLine(Offset(20, cy), Offset(size.width - 20, cy), faintStroke);
    _drawText(canvas, 'Resting line', Offset(24, cy + 4));

    final path = Path();
    const wavelengthPx = 140.0;
    const ampPx = 36.0;
    for (var i = 0; i <= 100; i++) {
      final x = 40.0 + i * (size.width - 80) / 100;
      final y = cy - math.sin((x - 40) / wavelengthPx * 2 * math.pi) * ampPx;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, stroke);

    final crest1 = Offset(40 + wavelengthPx / 4, cy - ampPx);
    final crest2 = Offset(crest1.dx + wavelengthPx, cy - ampPx);
    final dimY = crest1.dy - 14;
    canvas.drawLine(
      Offset(crest1.dx, dimY),
      Offset(crest2.dx, dimY),
      faintStroke,
    );
    _drawArrowHead(
      canvas,
      Offset(crest1.dx + 8, dimY),
      Offset(crest1.dx, dimY),
      faintStroke,
    );
    _drawArrowHead(
      canvas,
      Offset(crest2.dx - 8, dimY),
      Offset(crest2.dx, dimY),
      faintStroke,
    );
    final waveLabel = waveLabels?['wavelength'] ??
        (wavelength != null ? 'Wavelength = $wavelength' : 'Wavelength (λ)');
    _drawText(
      canvas,
      waveLabel,
      Offset((crest1.dx + crest2.dx) / 2 - 40, dimY - 14),
    );

    final ampX = crest1.dx + wavelengthPx / 2;
    _drawDashedLine(
      canvas,
      Offset(ampX, cy),
      Offset(ampX, cy + ampPx),
      faintStroke,
    );
    final ampLabel = waveLabels?['amplitude'] ?? 'Amplitude (A)';
    _drawText(canvas, ampLabel, Offset(ampX + 6, cy + 12));

    final info = [
      if (waveLabels?['frequency'] != null)
        'Frequency: ${waveLabels!['frequency']}'
      else if (frequency != null)
        'Frequency: $frequency',
      if (waveLabels?['speed'] != null)
        'Speed: ${waveLabels!['speed']}'
      else if (speed != null)
        'Speed: $speed',
    ].join('   ');
    if (info.isNotEmpty) {
      _drawText(canvas, info, Offset(size.width / 2 - 50, size.height - 20));
    } else {
      _drawArrow(
        canvas,
        Offset(size.width - 90, 20),
        Offset(size.width - 30, 20),
        stroke,
      );
      final dirLabel = waveLabels?['direction'] ?? 'Travel direction';
      _drawText(canvas, dirLabel, Offset(size.width - 100, 6));
    }
  }

  List<Offset> _rowCenters(Size size) {
    final count = nodes.isEmpty ? 2 : nodes.length;
    final slot = size.width / count;
    return [
      for (var i = 0; i < count; i++) Offset(slot * (i + 0.5), size.height / 2),
    ];
  }

  List<Offset> _hierarchyCenters(Size size) {
    final centers = <Offset>[Offset(size.width / 2, 35)];
    final childCount = nodes.length - 1;
    final slot = size.width / childCount;
    for (var i = 0; i < childCount; i++) {
      centers.add(Offset(slot * (i + 0.5), size.height - 40));
    }
    return centers;
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    final count = (distance / 6).floor();
    for (var i = 0; i < count; i += 2) {
      final start = p1 + (p2 - p1) * (i / count);
      final end = p1 + (p2 - p1) * ((i + 1) / count);
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);
    _drawArrowHead(canvas, from, to, paint);
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    const length = 7.0;
    for (final turn in [-0.45, 0.45]) {
      canvas.drawLine(
        to,
        to -
            Offset(
              math.cos(angle + turn) * length,
              math.sin(angle + turn) * length,
            ),
        paint,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ConceptDiagramPainter oldDelegate) =>
      oldDelegate.type != type ||
      !listEquals(oldDelegate.nodes, nodes) ||
      !listEquals(oldDelegate.edges, edges) ||
      !listEquals(oldDelegate.sets, sets) ||
      !mapEquals(oldDelegate.regions, regions) ||
      oldDelegate.center != center ||
      !mapEquals(oldDelegate.overlaps, overlaps) ||
      !mapEquals(oldDelegate.singleRegions, singleRegions) ||
      !listEquals(oldDelegate.boxes, boxes) ||
      !listEquals(oldDelegate.sections, sections) ||
      oldDelegate.root != root ||
      !listEquals(oldDelegate.branches, branches) ||
      oldDelegate.totalLeaves != totalLeaves ||
      !listEquals(oldDelegate.clues, clues) ||
      oldDelegate.conclusion != conclusion ||
      oldDelegate.mainIdea != mainIdea ||
      !listEquals(oldDelegate.details, details) ||
      !listEquals(oldDelegate.forces, forces) ||
      !listEquals(oldDelegate.masses, masses) ||
      oldDelegate.distance != distance ||
      oldDelegate.comparison != comparison ||
      oldDelegate.incidentAngle != incidentAngle ||
      oldDelegate.reflectedAngle != reflectedAngle ||
      !listEquals(oldDelegate.labels, labels) ||
      !listEquals(oldDelegate.angles, angles) ||
      !listEquals(oldDelegate.vectorItems, vectorItems) ||
      !listEquals(oldDelegate.additionComponents, additionComponents) ||
      !mapEquals(oldDelegate.resultant, resultant) ||
      oldDelegate.magnitude != magnitude ||
      oldDelegate.angle != angle ||
      oldDelegate.unit != unit ||
      !mapEquals(oldDelegate.componentMap, componentMap) ||
      !mapEquals(oldDelegate.netForce, netForce) ||
      oldDelegate.body != body ||
      oldDelegate.orbiting != orbiting ||
      !mapEquals(oldDelegate.orbitVectors, orbitVectors) ||
      !mapEquals(oldDelegate.waveLabels, waveLabels) ||
      oldDelegate.wavelength != wavelength ||
      oldDelegate.frequency != frequency ||
      oldDelegate.speed != speed ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint ||
      oldDelegate.background != background;
}
