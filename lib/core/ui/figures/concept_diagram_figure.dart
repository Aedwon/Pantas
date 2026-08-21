import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A labeled relationship diagram for sequences, flows, and hierarchies.
class ConceptDiagramFigure extends StatelessWidget {
  const ConceptDiagramFigure({
    required this.type,
    required this.nodes,
    required this.edges,
    super.key,
  });

  static const kind = 'concept-diagram';
  static const _types = {'sequence', 'flow', 'hierarchy', 'venn'};

  final String type;
  final List<String> nodes;
  final List<(int, int)> edges;

  static ConceptDiagramFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    final rawNodes = spec['nodes'];
    final rawEdges = spec['edges'];
    if (type is! String || !_types.contains(type)) return null;
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
    return ConceptDiagramFigure(type: type, nodes: nodes, edges: edges);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A $type diagram with ${nodes.join(', ')}.',
      child: SizedBox(
        height: 190,
        child: CustomPaint(
          size: Size.infinite,
          painter: _ConceptDiagramPainter(
            type: type,
            nodes: nodes,
            edges: edges,
            ink: colors.ink,
            faint: colors.ruleFaint,
            labelStyle: context.textStyles.bodySmall.copyWith(
              color: colors.ink,
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
    required this.labelStyle,
  });

  final String type;
  final List<String> nodes;
  final List<(int, int)> edges;
  final Color ink;
  final Color faint;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final centers = type == 'hierarchy'
        ? _hierarchyCenters(size)
        : type == 'venn'
            ? _vennCenters(size)
            : _rowCenters(size);

    for (final edge in edges) {
      final from = centers[edge.$1];
      final to = centers[edge.$2];
      canvas.drawLine(from, to, faintStroke);
      _drawArrowHead(canvas, from, to, faintStroke);
    }

    for (var i = 0; i < nodes.length; i++) {
      final center = centers[i];
      final nodeBounds = type == 'venn'
          ? Rect.fromCircle(center: center, radius: 36)
          : Rect.fromCenter(center: center, width: 78, height: 42);
      if (type == 'venn') {
        canvas.drawOval(nodeBounds, stroke);
      } else {
        canvas.drawRect(nodeBounds, stroke);
      }
      final painter = TextPainter(
        text: TextSpan(text: nodes[i], style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: nodeBounds.width - 8);
      painter.paint(
        canvas,
        Offset(
          center.dx - painter.width / 2,
          center.dy - painter.height / 2,
        ),
      );
    }
  }

  List<Offset> _rowCenters(Size size) {
    final slot = size.width / nodes.length;
    return [
      for (var i = 0; i < nodes.length; i++)
        Offset(slot * (i + 0.5), size.height / 2),
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

  List<Offset> _vennCenters(Size size) {
    final center = size.center(Offset.zero);
    const radius = 34.0;
    return [
      for (var i = 0; i < nodes.length; i++)
        center +
            Offset(
              math.cos(i * 2 * math.pi / nodes.length) * radius,
              math.sin(i * 2 * math.pi / nodes.length) * radius,
            ),
    ];
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

  @override
  bool shouldRepaint(_ConceptDiagramPainter oldDelegate) =>
      oldDelegate.type != type ||
      !listEquals(oldDelegate.nodes, nodes) ||
      !listEquals(oldDelegate.edges, edges) ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint;
}
