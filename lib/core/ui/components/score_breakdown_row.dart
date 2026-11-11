import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/accuracy_bar.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// One row of a score breakdown (the system's StatRow): the name at the left,
/// "correct / total" and the percent at the right, and a 5 high accuracy bar
/// under them. Shared by the mock results and the assessment results.
///
/// The row pads 12 above and below with 8 between the line and the bar, and
/// a 0.5 `divider` rule sits under it unless [divider] is false. The phone
/// insets it 16; on wide screens the card supplies the 20 inset. At large
/// text the values stack under the name.
///
/// [ScoreBreakdownRow.value] is the same row for a percent the caller already
/// has: it prints [valueText] (or the rounded percent) in place of "correct /
/// total", can carry a [subtitle] and a [chevron] (the link variant), and
/// reads "No data" with an empty track when [accuracy] is null, never 0%.
class ScoreBreakdownRow extends StatelessWidget {
  const ScoreBreakdownRow({
    required this.name,
    required int this.correct,
    required int this.total,
    required this.divider,
    this.animatedAccuracy,
    super.key,
  })  : _accuracy = total == 0 ? 0 : correct / total,
        valueText = null,
        subtitle = null,
        chevron = false;

  const ScoreBreakdownRow.value({
    required this.name,
    required double? accuracy,
    required this.divider,
    this.valueText,
    this.subtitle,
    this.chevron = false,
    this.animatedAccuracy,
    super.key,
  })  : correct = null,
        total = null,
        _accuracy = accuracy;
  final String name;
  final int? correct;
  final int? total;
  final double? _accuracy;

  /// The printed value of a [ScoreBreakdownRow.value]; null prints the percent.
  final String? valueText;

  /// A second line under the name, in `text-secondary`.
  final String? subtitle;

  /// A 16 chevron at the end of the top line: the row opens a page.
  final bool chevron;

  /// Overrides the bar width while an entrance plays. Null uses the bar's own.
  final double? animatedAccuracy;
  final bool divider;
  double get accuracy => _accuracy ?? 0;
  bool get _empty => _accuracy == null;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final percent = '${(accuracy * 100).round()}%';
    final percentText = Text(
      valueText ?? percent,
      style: PantasType.webStatValue.copyWith(
        color: c.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    final values = _empty
        // The empty state is the 400 weight in the secondary ink (R3-O09).
        ? Text(
            'No data',
            style: PantasType.webStatValue.copyWith(
              fontWeight: FontWeight.w400,
              color: c.textSecondary,
            ),
          )
        : correct == null
            ? percentText
            : Wrap(
                spacing: PantasSpace.s14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$correct / $total',
                    style:
                        PantasType.webRowValue.copyWith(color: c.textSecondary),
                  ),
                  percentText,
                ],
              );
    // The name wraps to a second line instead of being cut: a long subject
    // such as "Language Proficiency (English & Filipino)" must read in full
    // on a phone, where the count and the percent sit beside it.
    final nameText = Text(
      name,
      style: PantasType.webRowTitleSettings.copyWith(color: c.textPrimary),
    );
    final title = subtitle == null
        ? nameText
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameText,
              Padding(
                padding: const EdgeInsets.only(top: PantasSpace.s2),
                child: Text(
                  subtitle!,
                  style: PantasType.webRowSub.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          );
    final end = chevron
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              values,
              const SizedBox(width: PantasSpace.s8),
              ExcludeSemantics(
                child: Icon(
                  PantasIcons.next,
                  size: PantasSize.icon - PantasSpace.s4,
                  color: c.iconChevron,
                ),
              ),
            ],
          )
        : values;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.wideWeb ? PantasSpace.s0 : PantasSpace.s16,
        vertical: PantasSpace.s12,
      ),
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  width: PantasBorder.hairline,
                  color: c.divider,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (large) ...[title, end] else
            Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: PantasSpace.s10),
                end,
              ],
            ),
          const SizedBox(height: PantasSpace.s8),
          if (_empty)
            // No data: the track alone, with no fill.
            ClipRRect(
              borderRadius: BorderRadius.circular(PantasRadius.full),
              child: Container(height: PantasSize.accuracyBar, color: c.fill),
            )
          else if (animatedAccuracy == null)
            AccuracyBar(accuracy: accuracy)
          else
            // An entrance clock drives the fill directly.
            ClipRRect(
              borderRadius: BorderRadius.circular(PantasRadius.full),
              child: Container(
                height: PantasSize.accuracyBar,
                color: c.fill,
                alignment: Alignment.centerLeft,
                child: LayoutBuilder(
                  builder: (context, box) => SizedBox(
                    width: math.max(
                      PantasSize.accuracyBar,
                      animatedAccuracy!.clamp(0, 1) * box.maxWidth,
                    ),
                    height: PantasSize.accuracyBar,
                    child: ColoredBox(
                      key: const ValueKey('accuracy-bar-fill'),
                      color: AccuracyBar.stepColor(c, accuracy),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
