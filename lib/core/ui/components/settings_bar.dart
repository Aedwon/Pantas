import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/back_chevron.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// The Settings bar: a back chevron and a serif title, and nothing else.
///
/// Not a Material AppBar. Spec 8 asked for a large app bar and the identity
/// bans it, along with its elevation and its title animation.
class SettingsBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsBar({required this.title, this.backLabel, super.key});

  final String title;
  final String? backLabel;

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
      child: Stack(
        children: [
          // Centered title
          Align(
            alignment: Alignment.center,
            child: Text(
              title,
              style: styles.headlineSmall.copyWith(fontSize: 17),
            ),
          ),
          // Back button on the left
          if (canPop)
            Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                label: 'Back',
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BackChevron(color: colors.inkMuted),
                      if (backLabel != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          backLabel!,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
