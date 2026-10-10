import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_shape.dart';

/// The header and explanation belong outside the rounded group of rows.
class GroupedSection extends StatelessWidget {
  const GroupedSection({
    required this.children,
    this.header,
    this.footer,
    super.key,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
              child: Text(
                header!.toUpperCase(),
                style: context.type.sectionHeader,
              ),
            ),
          DecoratedBox(
            key: const ValueKey('grouped-section-surface'),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(PantasShape.groupRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PantasShape.groupRadius),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
              child: Text(
                footer!,
                style: context.type.footnote.copyWith(height: 1.4),
              ),
            ),
        ],
      );
}
