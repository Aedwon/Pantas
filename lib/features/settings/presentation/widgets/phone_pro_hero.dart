import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/settings/presentation/widgets/pro_perks.dart';

/// The teal hero of the phone Pro page (`.card--hero`, D126): `hero-start`
/// to `hero-mid` at 40% to `hero-end` at 160deg, `on-hero` text,
/// `on-hero-secondary` icons, radius 22, padding 26 by 22. No shadow (only
/// floating things have one).
class PhoneProHero extends StatelessWidget {
  const PhoneProHero({required this.heading, this.detail, super.key});

  final String heading;
  final String? detail;

  // ds-board: ST_ProPMA phone hero icons, 21px (Card README `.hero-list`)
  static const double _iconSize = 21;

  // ds-board: ST_ProPMA phone hero padding 26 by 22 (Card README)
  static const double _padX = 22;
  // ds-board: ST_ProPMA phone hero padding 26 by 22 (Card README)
  static const double _padY = 26;

  // ds-board: `.card--hero` gradient at 160deg, as an alignment pair
  static const Alignment _from = Alignment(-0.342, -0.94);
  // ds-board: `.card--hero` gradient at 160deg, as an alignment pair
  static const Alignment _to = Alignment(0.342, 0.94);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      key: const ValueKey('pro-hero-phone'),
      padding: const EdgeInsets.symmetric(horizontal: _padX, vertical: _padY),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PantasRadius.r2xl),
        gradient: LinearGradient(
          // CSS 160deg: down, leaning a little to the right.
          begin: _from,
          end: _to,
          colors: [c.heroStart, c.heroMid, c.heroEnd],
          stops: const [0, .4, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: context.type.pageTitle.copyWith(color: c.onHero),
          ),
          if (detail != null) ...[
            const SizedBox(height: PantasSpace.s8),
            Text(detail!, style: context.type.body.copyWith(color: c.onHero)),
          ],
          const SizedBox(height: PantasSpace.s20),
          for (final (icon, text) in proPerks)
            Padding(
              padding: const EdgeInsets.only(bottom: PantasSpace.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: c.onHeroSecondary, size: _iconSize),
                  const SizedBox(width: PantasSpace.s12),
                  Expanded(
                    child: Text(
                      text,
                      style: context.type.subhead.copyWith(
                        fontWeight: FontWeight.w500,
                        color: c.onHero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
