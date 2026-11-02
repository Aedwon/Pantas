import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A sheet of paper, folded, with a cut in it.
///
/// ```yaml
///     figureSpec:
///       kind: paper-fold
///       folds: [vertical, horizontal]
///       cut: notch          # notch | hole
///       at: interior        # interior | edge | corner | fold-corner | on-fold
///       sheet: square       # square | rectangle
///       showUnfolded: false
/// ```
///
/// The whole sheet is outlined, and every crease is a dashed line across it,
/// so words like "the shown creases" point at something drawn. The folded
/// sheet is drawn solid on top. Worked lesson diagrams may opt into the
/// unfolded result; question specs keep the default and never reveal it.
class PaperFoldFigure extends StatelessWidget {
  const PaperFoldFigure({
    required this.folds,
    required this.cut,
    required this.at,
    required this.sheet,
    required this.showUnfolded,
    super.key,
  });

  static const kind = 'paper-fold';
  static const cuts = {'notch', 'hole'};
  static const places = {
    'interior',
    'edge',
    'corner',
    'fold-corner',
    'on-fold',
  };
  static const sheets = {'square', 'rectangle'};

  final List<String> folds;
  final String cut;
  final String at;
  final String sheet;
  final bool showUnfolded;

  /// Null when the spec cannot be read.
  static PaperFoldFigure? fromSpec(Map<String, Object?> spec) {
    final raw = spec['folds'];
    if (raw is! List || raw.isEmpty || raw.length > 3) return null;
    final folds = <String>[];
    for (final f in raw) {
      if (f != 'vertical' && f != 'horizontal') return null;
      folds.add(f! as String);
    }

    final cut = spec['cut'] ?? 'hole';
    if (cut is! String || !cuts.contains(cut)) return null;

    final at = spec['at'] ?? 'interior';
    if (at is! String || !places.contains(at)) return null;

    final sheet = spec['sheet'] ?? 'square';
    if (sheet is! String || !sheets.contains(sheet)) return null;

    final showUnfolded = spec['showUnfolded'] ?? false;
    if (showUnfolded is! bool) return null;

    return PaperFoldFigure(
      folds: folds,
      cut: cut,
      at: at,
      sheet: sheet,
      showUnfolded: showUnfolded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A $sheet sheet of paper folded ${folds.length} '
          '${folds.length == 1 ? 'time' : 'times'}, with a $cut cut $at'
          '${showUnfolded ? ', then opened flat' : ''}.',
      child: SizedBox(
        height: 140,
        child: CustomPaint(
          painter: _PaperPainter(
            folds: folds,
            cut: cut,
            at: at,
            sheet: sheet,
            showUnfolded: showUnfolded,
            ink: colors.label,
            outline: colors.secondaryLabel,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Where the creases and the notch go, shared by the painter and its tests.
@visibleForTesting
abstract final class PaperFoldGeometry {
  /// Every crease of the opened sheet [full], as segments, for a sheet
  /// folded in the order [folds].
  ///
  /// Each fold halves what is left of the sheet. Its crease runs across the
  /// packet as it was when folded, then is carried back through the earlier
  /// folds, in reverse, as the sheet is opened.
  static List<(Offset, Offset)> creases(Rect full, List<String> folds) {
    var folded = full;
    final done = <(String, double)>[];
    final result = <(Offset, Offset)>[];
    for (final fold in folds) {
      final vertical = fold == 'vertical';
      final line = vertical ? folded.center.dx : folded.center.dy;
      var segments = <(Offset, Offset)>[
        if (vertical)
          (Offset(line, folded.top), Offset(line, folded.bottom))
        else
          (Offset(folded.left, line), Offset(folded.right, line)),
      ];
      for (final (earlier, at) in done.reversed) {
        segments = [
          ...segments,
          for (final (a, b) in segments)
            if (earlier == 'vertical')
              (Offset(2 * at - a.dx, a.dy), Offset(2 * at - b.dx, b.dy))
            else
              (Offset(a.dx, 2 * at - a.dy), Offset(b.dx, 2 * at - b.dy)),
        ];
      }
      result.addAll(segments);
      done.add((fold, line));
      folded = vertical
          ? Rect.fromLTRB(line, folded.top, folded.right, folded.bottom)
          : Rect.fromLTRB(folded.left, line, folded.right, folded.bottom);
    }
    return result;
  }

  /// A notch cut on the folded edge: its base lies along the edge and its
  /// tip points into the packet.
  static List<Offset> notchOnFold(Offset centre) => [
        Offset(centre.dx, centre.dy - 7),
        Offset(centre.dx + 10, centre.dy),
        Offset(centre.dx, centre.dy + 7),
      ];
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({
    required this.folds,
    required this.cut,
    required this.at,
    required this.sheet,
    required this.showUnfolded,
    required this.ink,
    required this.outline,
  });

  final List<String> folds;
  final String cut;
  final String at;
  final String sheet;
  final bool showUnfolded;
  final Color ink;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final solid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;
    final hidden = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = outline;
    final cutPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = ink;

    final foldedArea = showUnfolded
        ? Rect.fromLTWH(8, 8, size.width / 2 - 12, size.height - 16)
        : Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    final full = _sheetRect(foldedArea);

    // The whole sheet, so the folded-away part is visible.
    canvas.drawRect(full, hidden);

    // Each fold halves the sheet. The folded sheet is the part that stays.
    var folded = full;
    final foldLines = <(String, double)>[];
    for (final fold in folds) {
      final line = fold == 'vertical' ? folded.center.dx : folded.center.dy;
      foldLines.add((fold, line));
      folded = fold == 'vertical'
          ? Rect.fromLTWH(
              folded.left + folded.width / 2,
              folded.top,
              folded.width / 2,
              folded.height,
            )
          : Rect.fromLTWH(
              folded.left,
              folded.top + folded.height / 2,
              folded.width,
              folded.height / 2,
            );
    }
    for (final (a, b) in PaperFoldGeometry.creases(full, folds)) {
      _dashedLine(canvas, a, b, hidden);
    }
    canvas.drawRect(folded, solid);

    // Where the cut sits on the folded sheet.
    final centre = switch (at) {
      'corner' => folded.topLeft + const Offset(12, 12),
      'fold-corner' => folded.topLeft,
      'edge' => Offset(folded.right - 12, folded.center.dy),
      'on-fold' => Offset(folded.left, folded.center.dy),
      _ => folded.center,
    };

    _drawCut(canvas, centre, cutPaint);

    if (!showUnfolded) return;
    final openArea = Rect.fromLTWH(
      size.width / 2 + 4,
      8,
      size.width / 2 - 12,
      size.height - 16,
    );
    final opened = _sheetRect(openArea);
    canvas.drawRect(opened, solid);
    final scaleX = opened.width / full.width;
    final scaleY = opened.height / full.height;
    final cuts = _unfoldedCuts(centre, foldLines);
    for (final point in cuts) {
      final mapped = Offset(
        opened.left + (point.dx - full.left) * scaleX,
        opened.top + (point.dy - full.top) * scaleY,
      );
      if (cut == 'notch' && at == 'on-fold') {
        _drawDiamond(canvas, mapped, cutPaint);
      } else {
        _drawCut(canvas, mapped, cutPaint);
      }
    }
  }

  Rect _sheetRect(Rect area) {
    final ratio = sheet == 'rectangle' ? 1.45 : 1.0;
    final width = area.width.clamp(40.0, area.height * ratio);
    final height = width / ratio;
    return Rect.fromLTWH(
      area.left + (area.width - width) / 2,
      area.top + (area.height - height) / 2,
      width,
      height,
    );
  }

  List<Offset> _unfoldedCuts(
    Offset cutPoint,
    List<(String, double)> foldLines,
  ) {
    var points = <Offset>[cutPoint];
    for (final (fold, line) in foldLines.reversed) {
      final reflected = <Offset>[];
      for (final point in points) {
        reflected.add(
          fold == 'vertical'
              ? Offset(2 * line - point.dx, point.dy)
              : Offset(point.dx, 2 * line - point.dy),
        );
      }
      points = {...points, ...reflected}.toList();
    }
    return points;
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 5.0;
    const gap = 4.0;
    final length = (b - a).distance;
    final step = (b - a) / length;
    for (var at = 0.0; at < length; at += dash + gap) {
      canvas.drawLine(
        a + step * at,
        a + step * math.min(at + dash, length),
        paint,
      );
    }
  }

  void _drawCut(Canvas canvas, Offset centre, Paint paint) {
    if (cut == 'hole') {
      canvas.drawCircle(centre, 6, paint);
      return;
    }
    if (at == 'on-fold') {
      // The base lies along the folded edge and the tip points into the
      // packet, so opening the sheet joins two halves into one opening.
      canvas.drawPath(
        Path()..addPolygon(PaperFoldGeometry.notchOnFold(centre), true),
        paint,
      );
      return;
    }
    canvas.drawPath(
      Path()
        ..moveTo(centre.dx - 7, centre.dy + 6)
        ..lineTo(centre.dx, centre.dy - 7)
        ..lineTo(centre.dx + 7, centre.dy + 6)
        ..close(),
      paint,
    );
  }

  void _drawDiamond(Canvas canvas, Offset centre, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(centre.dx, centre.dy - 8)
        ..lineTo(centre.dx + 8, centre.dy)
        ..lineTo(centre.dx, centre.dy + 8)
        ..lineTo(centre.dx - 8, centre.dy)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      !listEquals(old.folds, folds) ||
      old.cut != cut ||
      old.at != at ||
      old.sheet != sheet ||
      old.showUnfolded != showUnfolded ||
      old.ink != ink ||
      old.outline != outline;
}
