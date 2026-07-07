import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The Settings bar: a back chevron and a serif title, and nothing else.
///
/// Not a Material AppBar. Spec 8 asked for a large app bar and the identity
/// bans it, along with its elevation and its title animation.
class SettingsBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsBar({required this.title, super.key});

  final String title;

  static const double height = 46;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final canPop = Navigator.of(context).canPop();

    return SizedBox(
      height: height,
      child: Row(
        children: [
          if (canPop)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: SizedBox(
                width: 30,
                height: height,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '‹',
                    style: styles.bodyLarge.copyWith(
                      fontSize: 19,
                      color: colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
          Text(
            title,
            style: styles.headlineSmall.copyWith(fontSize: 17),
          ),
        ],
      ),
    );
  }
}
