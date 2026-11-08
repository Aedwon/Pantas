import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The phone list (the system's GroupedList): a header, one rounded group of
/// rows (`surface-card`, `radius-lg`, a 1 `edge-card` edge in dark) and a
/// footer. The header and explanation belong outside the rounded group.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    required this.children,
    this.header,
    this.footer,
    this.headerStyle,
    this.radius = PantasRadius.lg,
    super.key,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;
  final TextStyle? headerStyle;

  /// Corner radius of the group, for a board that draws it at another size.
  final double radius;

  /// The 7 between the group and its header or footer (phone board).
  static const double _edgeGap = PantasSpace.s6 + PantasSpace.s2 / 2;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s0,
                PantasSpace.s16,
                _edgeGap,
              ),
              child: Text(
                header!.toUpperCase(),
                style: headerStyle ??
                    PantasType.phoneSectionHeader
                        .copyWith(color: context.colors.textSecondary),
              ),
            ),
          DecoratedBox(
            key: const ValueKey('grouped-section-surface'),
            decoration: BoxDecoration(
              color: context.colors.surfaceCard,
              border: Theme.of(context).brightness == Brightness.dark
                  ? Border.all(color: context.colors.edgeCard)
                  : null,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                _edgeGap,
                PantasSpace.s16,
                PantasSpace.s0,
              ),
              child: Text(
                footer!,
                style: PantasType.webSmall
                    .copyWith(color: context.colors.textSecondary),
              ),
            ),
        ],
      );
}
