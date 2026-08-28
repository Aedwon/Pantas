import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/components/settings_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// One row of the Settings ledger: a title, then a right-aligned value or a
/// control, then a fixed chevron column.
///
/// The chevron column is always reserved even when the row does not push.
/// That is what keeps every value in a group on one right edge, which is the
/// thing that stops the list looking ragged.
///
/// The visible box is 38 tall at normal text size. The tappable box is at
/// least 48 tall and grows with larger text.
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
  static const double tapHeight = 48;
  static const double chevronColumnWidth = 14;

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

    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1;
    final content = largeText
        ? Padding(
            key: const Key('settingsRowContent'),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: styles.bodyMedium.copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerRight, child: trailing),
              ],
            ),
          )
        : SizedBox(
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
                      ? const Align(
                          alignment: Alignment.centerRight,
                          child: InkChevron(size: 14),
                        )
                      : null,
                ),
              ],
            ),
          );

    final row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: largeText
          ? ConstrainedBox(
              constraints: const BoxConstraints(minHeight: tapHeight),
              child: content,
            )
          : SizedBox(
              height: tapHeight,
              child: Center(child: content),
            ),
    );

    if (control != null && onTap == null) return row;

    final switchValue =
        control is SettingsSwitch ? (control! as SettingsSwitch).value : null;
    return Semantics(
      label: title,
      value: switchValue == null ? value : null,
      toggled: switchValue,
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: row,
    );
  }
}
