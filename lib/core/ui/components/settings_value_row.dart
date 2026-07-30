import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// One row of the Settings ledger: a title, then a right-aligned value or a
/// control, then a fixed chevron column.
///
/// The chevron column is always reserved even when the row does not push.
/// That is what keeps every value in a group on one right edge, which is the
/// thing that stops the list looking ragged.
///
/// The visible box is 38 tall. The tappable box is 44, gained by 3px of
/// transparent bleed above and below, because a hit region in Flutter cannot
/// exceed its own box and 44 is the accessibility floor.
class SettingsValueRow extends StatelessWidget {
  const SettingsValueRow({
    required this.title,
    this.value,
    this.valueIsInk = false,
    this.control,
    this.showChevron = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String? value;
  final bool valueIsInk;
  final Widget? control;
  final bool showChevron;
  final VoidCallback? onTap;

  static const double contentHeight = 38;
  static const double tapHeight = 44;
  static const double chevronColumnWidth = 11;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final trailing = control ??
        (value == null
            ? const SizedBox.shrink()
            : Text(
                value!,
                style: styles.labelLarge.copyWith(
                  color: valueIsInk ? colors.ink : colors.inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ));

    final content = SizedBox(
      key: const Key('settingsRowContent'),
      height: contentHeight,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: styles.bodyMedium.copyWith(fontSize: 14.5),
            ),
          ),
          const SizedBox(width: 10),
          trailing,
          SizedBox(
            width: chevronColumnWidth,
            child: showChevron
                ? Text(
                    '›',
                    textAlign: TextAlign.right,
                    style: styles.bodyMedium.copyWith(color: colors.inkMuted),
                  )
                : null,
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: tapHeight,
        child: Center(child: content),
      ),
    );
  }
}
