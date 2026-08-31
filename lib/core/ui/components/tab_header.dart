import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// The title at the top of a tab.
///
/// **One header, because there were three.** Study drew its own row at 17px,
/// Quiz used an `AppBar` at 18 with a fixed 56 height, and Progress used a
/// bare `AppBar` that took the Material default for its height, its background
/// and its title size. The three tabs sat at three different distances from
/// the top and printed their names at three different sizes, which is what
/// Aedwon saw jumping between them.
///
/// Home is deliberately not one of these: it opens on a masthead that greets
/// the student by name, not on a tab title.
class TabHeader extends StatelessWidget {
  const TabHeader({required this.title, this.trailing, super.key});

  final String title;

  /// A single action on the right, such as Study's search.
  final Widget? trailing;

  /// The gap under the header, exposed so a tab can assert on it rather than
  /// re-measure it.
  static const double spaceBelow = 14;

  /// The title row's height, fixed so a tab with a trailing action puts its
  /// title in exactly the same place as a tab without one. Left to the
  /// content, Study's search icon pushed its title half a pixel below Quiz's.
  static const double rowHeight = 34;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: spaceBelow),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: rowHeight),
        child: largeText && trailing != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: context.textStyles.headlineMedium),
                  Align(alignment: Alignment.centerRight, child: trailing),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.textStyles.headlineMedium,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
      ),
    );
  }
}
