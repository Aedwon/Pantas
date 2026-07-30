import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A named block of Settings rows: a serif heading over a 1px ink rule.
///
/// The rule is ink rather than rule or ruleFaint, and that is not a detail.
/// A heading one step larger than its rows sitting on a faint rule is not a
/// hierarchy at all. The ink rule is where the heading's rank comes from,
/// and it is what allowed the whole screen to stay one flat scroll instead
/// of becoming a two-level menu.
///
/// Never boxed, never all-caps, per section_header.dart's standing rule.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.children,
    this.isFirst = false,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final bool isFirst;

  static const double gapBetweenGroups = 24;
  static const double headingSize = 17;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : gapBetweenGroups),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: styles.headlineSmall.copyWith(
              fontSize: headingSize,
              letterSpacing: -0.15,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            key: const Key('settingsGroupRule'),
            height: 1,
            decoration: BoxDecoration(color: colors.ink),
          ),
          ...children,
        ],
      ),
    );
  }
}
