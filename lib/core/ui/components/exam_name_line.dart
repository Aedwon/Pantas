import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
  static const double spaceBelow = 16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spaceBelow),
      child: Text(shortName, style: context.type.sectionHero),
    );
  }
}
