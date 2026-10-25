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
/// The folded sheet is drawn solid and the parts folded away are drawn in
/// faint rule. Worked lesson diagrams may opt into the unfolded result;
/// question specs keep the default and never reveal it.
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
            faint: colors.fill,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  _PaperPainter({
    required this.folds,
    required this.cut,
    required this.at,
    required this.sheet,
    required this.showUnfolded,
    required this.ink,
    required this.faint,
  });

  final List<String> folds;
  final String cut;
  final String at;
  final String sheet;
  final bool showUnfolded;
  final Color ink;
  final Color faint;

  @override
  void paint(Canvas canvas, Size size) {
    final solid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ink;
    final hidden = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = faint;
    final cutPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = ink;

    final foldedArea = showUnfolded
        ? Rect.fromLTWH(8, 8, size.width / 2 - 12, size.height - 16)
        : Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    final full = _sheetRect(foldedArea);

    // The whole sheet in faint rule, so the folded-away half is visible.
    canvas.drawRect(full, hidden);

    // Each fold halves the sheet. The folded sheet is the part that stays.
    var folded = full;
    final foldLines = <(String, double)>[];
    for (final fold in folds) {
      foldLines.add(
        (fold, fold == 'vertical' ? folded.center.dx : folded.center.dy),
      );
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

  void _drawCut(Canvas canvas, Offset centre, Paint paint) {
    if (cut == 'hole') {
      canvas.drawCircle(centre, 6, paint);
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
      old.faint != faint;
}
