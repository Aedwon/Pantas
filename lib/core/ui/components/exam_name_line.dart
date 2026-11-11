import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The selected exam's short name, under a tab's header.
///
/// **One component because the three tabs had drifted apart.** All three
/// printed it at `displaySmall`, but Study added 6px above it that the others
/// did not, and the gap below it was 14 on Study, 20 on Quiz and 16 on
/// Progress. Aedwon saw the difference jumping between tabs.
///
/// The spacing lives here so it cannot drift again: a tab supplies the name
/// and nothing else.
class ExamNameLine extends StatelessWidget {
  const ExamNameLine(this.shortName, {super.key});

  final String shortName;

  /// The gap between the name and whatever the tab puts under it.
  static const double spaceBelow = PantasSpace.s16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spaceBelow),
      child: Text(shortName, style: context.type.sectionHero),
    );
  }
}

/// The exam chip of the week strip: a calendar tile with the exam name and the
/// days left beside it.
///
/// The tile is 2.625rem wide (42 at default text, so "DEC" fits at 200 percent
/// text), at least 36 high, `radius-sm`, with a 1.5 `text-primary` outline. The
/// day is `web-glyph`, the month `web-pro` in `text-secondary`. The name is
/// `web-chip-name` and the days left `web-small`. The chip is not interactive.
/// An empty chip ([ExamChip.empty]) draws a dashed `border-control` tile with
/// "--" and "DATE"; the "Add Date" link is the [trailing] widget.
///
/// The divider rule and the wrap under the days belong to the week strip.
class ExamChip extends StatelessWidget {
  const ExamChip({
    required String this.name,
    required String this.day,
    required String this.month,
    this.daysLeft,
    super.key,
  })  : trailing = null,
        empty = false;

  /// No exam date yet: a dashed tile and, beside it, [trailing].
  const ExamChip.empty({this.trailing, super.key})
      : name = null,
        day = null,
        month = null,
        daysLeft = null,
        empty = true;

  final String? name;
  final String? day;
  final String? month;
  final String? daysLeft;
  final Widget? trailing;
  final bool empty;

  /// The tile's width in rem: 2.625 x 16.
  static const double _tileWidth = PantasSpace.s16 * 2.625;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final width = MediaQuery.textScalerOf(context).scale(_tileWidth);
    final tile = ConstrainedBox(
      key: const ValueKey('exam-chip-tile'),
      constraints: BoxConstraints(
        minWidth: width,
        maxWidth: width,
        minHeight: PantasSize.btnXs,
      ),
      child: CustomPaint(
        foregroundPainter: _TileOutline(
          color: empty ? c.borderControl : c.textPrimary,
          dashed: empty,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              empty ? '--' : day!,
              style: PantasType.webGlyph.copyWith(
                color: empty ? c.textSecondary : c.textPrimary,
              ),
            ),
            Text(
              empty ? 'DATE' : month!.toUpperCase(),
              style: PantasType.webPro.copyWith(
                // ds-board: ExamChip README: month 11/700 tile
                height: 1,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        const SizedBox(width: PantasSpace.s10),
        Flexible(
          child: empty
              ? (trailing ?? const SizedBox.shrink())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name!,
                      style:
                          PantasType.webChipName.copyWith(color: c.textPrimary),
                    ),
                    if (daysLeft != null)
                      Text(
                        daysLeft!,
                        style: PantasType.webSmall
                            .copyWith(color: c.textSecondary),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// The calendar tile's 1.5 outline, inside the box, solid or dashed.
class _TileOutline extends CustomPainter {
  const _TileOutline({required this.color, required this.dashed});
  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    const w = PantasBorder.ringStrong;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(w / 2),
      const Radius.circular(PantasRadius.sm - w / 2),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    if (!dashed) {
      canvas.drawRRect(rrect, paint);
      return;
    }
    const dash = PantasSpace.s4;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash * 2) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_TileOutline old) =>
      old.color != color || old.dashed != dashed;
}
