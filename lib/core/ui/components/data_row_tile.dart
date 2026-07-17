import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DataRowTile extends StatelessWidget {
  const DataRowTile({
    required this.title,
    this.subtext,
    this.primaryFigure,
    this.secondaryFigure,
    this.primaryIsActive = true,
    this.primaryColor,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtext;

  /// Right-aligned, 52px wide. Null renders an empty column, never a dash.
  final String? primaryFigure;
  final String? secondaryFigure;

  /// The active column is `ink` at 600 and may carry a severity colour.
  /// The inactive one is `inkMuted` at 400 and never carries colour.
  final bool primaryIsActive;
  final Color? primaryColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    Widget buildFigureColumn(
      String? figureText, {
      required bool isActive,
      Color? color,
    }) {
      if (figureText == null) {
        return const SizedBox(width: 52);
      }
      final style = styles.bodyRegular.copyWith(
        fontSize: 13,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        color: isActive ? (color ?? colors.ink) : colors.inkMuted,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

      return SizedBox(
        width: 52,
        child: Text(
          figureText,
          style: style,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // A figure row is exactly 38 tall, which is the shipped rule and the
    // one every table already drawn depends on. A row that carries a
    // subtext holds two lines and cannot: it keeps the same 4px padding
    // and takes the height its two lines need.
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final fixedHeight = (subtext == null && textScale <= 1.0) ? 38.0 : null;

    final content = SizedBox(
      height: fixedHeight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 38),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: styles.bodyMedium.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtext != null)
                      Text(
                        subtext!,
                        style: styles.bodySmall.copyWith(
                          color: colors.inkMuted,
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              buildFigureColumn(
                primaryFigure,
                isActive: primaryIsActive,
                color: primaryIsActive ? primaryColor : null,
              ),
              if (secondaryFigure != null)
                buildFigureColumn(
                  secondaryFigure,
                  isActive: !primaryIsActive,
                ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      child: content,
    );
  }
}
