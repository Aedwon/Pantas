import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A square of paper, folded, with a cut in it.
///
/// ```yaml
///     figureSpec:
///       kind: paper-fold
///       folds: [vertical, horizontal]
///       cut: notch          # notch | hole
///       at: interior        # interior | edge | corner | on-fold
/// ```
///
/// The folded sheet is drawn solid and the parts folded away are drawn in
/// faint rule, so a student can see what is underneath. **The unfolded
/// result is never drawn**: working it out is the question.
class PaperFoldFigure extends StatelessWidget {
  const PaperFoldFigure({
    required this.folds,
    required this.cut,
    required this.at,
    super.key,
  });

  static const kind = 'paper-fold';
  static const cuts = {'notch', 'hole'};
  static const places = {'interior', 'edge', 'corner', 'on-fold'};

  final List<String> folds;
  final String cut;
  final String at;

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

    return PaperFoldFigure(folds: folds, cut: cut, at: at);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A square of paper folded ${folds.length} '
          '${folds.length == 1 ? 'time' : 'times'}, with a $cut cut $at.',
      child: SizedBox(
        height: 140,
        child: CustomPaint(
          painter: _PaperPainter(
            folds: folds,
            cut: cut,
            at: at,
            ink: colors.ink,
            faint: colors.ruleFaint,
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
    required this.ink,
    required this.faint,
  });

  final List<String> folds;
  final String cut;
  final String at;
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

    final side = (size.height - 24).clamp(40.0, size.width - 24);
    final left = (size.width - side) / 2;
    const top = 12.0;
    final full = Rect.fromLTWH(left, top, side, side);

    // The whole sheet in faint rule, so the folded-away half is visible.
    canvas.drawRect(full, hidden);

    // Each fold halves the sheet. The folded sheet is the part that stays.
    var folded = full;
    for (final fold in folds) {
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
      'edge' => Offset(folded.right - 12, folded.center.dy),
      'on-fold' => Offset(folded.left, folded.center.dy),
      _ => folded.center,
    };

    if (cut == 'hole') {
      canvas.drawCircle(centre, 6, cutPaint);
    } else {
      final notch = Path()
        ..moveTo(centre.dx - 7, centre.dy + 6)
        ..lineTo(centre.dx, centre.dy - 7)
        ..lineTo(centre.dx + 7, centre.dy + 6)
        ..close();
      canvas.drawPath(notch, cutPaint);
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.folds.length != folds.length ||
      old.cut != cut ||
      old.at != at ||
      old.ink != ink;
}
