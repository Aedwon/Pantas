import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final titleColor = destructive ? colors.rust : colors.ink;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.ruleFaint,
              // ignore: avoid_redundant_argument_values
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: styles.bodyMedium.copyWith(color: titleColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: styles.bodySmall.copyWith(color: colors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right, size: 16, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
}
