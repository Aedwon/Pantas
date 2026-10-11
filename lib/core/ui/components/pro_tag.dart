import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class ProTag extends StatelessWidget {
  const ProTag({super.key});
  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('pro-tag-surface'),
        constraints: const BoxConstraints(minHeight: 20),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: context.colors.accentTint,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Pro',
          style: context.type.footnote.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark
                ? context.colors.label
                : context.colors.accent,
          ),
        ),
      );
}
