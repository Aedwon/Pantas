import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The Pro mark: the word "Pro" on the `pro` gold, in `on-pro` ink. The same
/// in both themes. Text 11/700, padding 1 by 6, `radius-xs`.
///
/// It is not interactive: no hover, press, focus or disabled state.
class ProMark extends StatelessWidget {
  const ProMark({super.key});

  /// The mark's optical height: 1 above and below the text (ProMark README,
  /// "Component internals"), half a `space-2`.
  static const double _padY = PantasSpace.s2 / 2;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('pro-tag-surface'),
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s6,
          vertical: _padY,
        ),
        decoration: BoxDecoration(
          color: context.colors.pro,
          borderRadius: BorderRadius.circular(PantasRadius.xs),
        ),
        child: Text(
          'Pro',
          style: PantasType.webPro.copyWith(color: context.colors.onPro),
        ),
      );
}

/// The earlier name of [ProMark]. Screens keep using it.
class ProTag extends ProMark {
  const ProTag({super.key});
}
