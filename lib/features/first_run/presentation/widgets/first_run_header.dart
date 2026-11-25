import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// "Try Pantas" at the left and Skip at the right (frames P03, P04, W03,
/// W04). No back, contents, bookmark or counter.
class FirstRunHeader extends StatelessWidget {
  const FirstRunHeader({required this.onSkip, this.height, super.key});

  final VoidCallback onSkip;

  /// The row's height. Null takes the board's: 58 on a phone, 64 wide.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final colors = context.colors;
    final label = Semantics(
      label: 'Try Pantas',
      excludeSemantics: true,
      child: Text(
        // The wide board draws the overline in capitals.
        wide ? 'TRY PANTAS' : 'Try Pantas',
        style: PantasType.phoneSubhead.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: wide ? 0.8 : 0.3,
        ),
      ),
    );
    return Container(
      // ds-board: P03 header row 58, W03 64
      height: height ?? (wide ? 64 : 58),
      padding: EdgeInsets.symmetric(
        horizontal: wide ? PantasSpace.s24 : PantasSpace.s16,
      ),
      child: Row(
        children: [
          label,
          const Spacer(),
          if (wide)
            WebButton(
              label: 'Skip',
              kind: PantasButtonKind.tertiary,
              keyHint: 'Esc',
              onPressed: onSkip,
            )
          else
            PantasButton(
              label: 'Skip',
              variant: PantasButtonVariant.tertiary,
              onPressed: onSkip,
            ),
        ],
      ),
    );
  }
}
