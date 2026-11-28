import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

// ds-board: P03 and W04 overline 13
const double _overlinePx = 13;

/// "Try Pantas" at the left and Skip at the right (frames P03, P04, W03,
/// W04). No back, contents, bookmark or counter.
class FirstRunHeader extends StatelessWidget {
  const FirstRunHeader({
    required this.onSkip,
    this.height,
    this.divider = false,
    super.key,
  });

  final VoidCallback onSkip;

  /// A 1 px divider under the row (frame P03, the phone lesson).
  final bool divider;

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
          // ds-board: P03 and W04 overline 13
          fontSize: _overlinePx,
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
          // ds-board: eyebrow tracking 0.8 wide, 0.3 phone
          letterSpacing: wide ? 0.8 : 0.3,
        ),
      ),
    );
    return Container(
      // ds-board: P03 header row 58, W03 64
      height: height ?? (wide ? 64 : 58),
      decoration: divider && !wide
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.divider),
              ),
            )
          : null,
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
