import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// The two-state control for a Settings row.
///
/// Off is entirely hollow: an outlined box holding an outlined square. On is
/// entirely solid: the box fills with ink and the square reverses out in the
/// page color. The state is carried by the whole object rather than by the
/// square's position, which is why both the fill and the position change.
///
/// Presentation only. The whole row is the tap target, so there is no
/// onChanged here.
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({required this.value, super.key});

  final bool value;

  static const double width = 32;
  static const double height = 18;
  static const double knobSize = 12;

  static const double _stroke = 1.2;
  static const double _inset = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Off sits at rule, one step lighter than inkMuted, so an off row recedes
    // into the page's ruling and on is the only ink in the column.
    final outline = value ? colors.ink : colors.rule;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: value ? colors.ink : null,
          border: Border.all(color: outline, width: _stroke),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _inset - _stroke),
            child: SizedBox(
              width: knobSize,
              height: knobSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: value ? colors.background : null,
                  border: value
                      ? null
                      : Border.all(color: colors.rule, width: _stroke),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
