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

    final content = SizedBox(
      height: 38,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SizedBox(
          height: 30,
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
