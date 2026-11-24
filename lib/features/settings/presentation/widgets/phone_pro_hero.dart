import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/settings/presentation/widgets/pro_perks.dart';

/// The teal hero of the phone Pro page (`.card--hero`, D126): `hero-start`
/// to `hero-mid` at 40% to `hero-end` at 160deg, `on-hero` text,
/// `on-hero-secondary` icons, radius 24, padding 26 by 22. No shadow (only
/// floating things have one). The eyebrow row (gold sparkle and PANTAS PRO)
/// opens the card on ST_ProFree and ST_ProPro; the lapsed state draws none.
class PhoneProHero extends StatelessWidget {
  const PhoneProHero({
    required this.heading,
    this.detail,
    this.eyebrow = true,
    super.key,
  });

  final String heading;
  final String? detail;

  /// The PANTAS PRO row inside the card; false on the lapsed state.
  final bool eyebrow;

  // ds-board: ST_ProFree hero radius 24 (Card README CHANGE)
  static const double _radius = 24;

  // ds-board: ST_ProFree eyebrow icon 20, gap 8 to the label
  static const double _eyebrowIcon = 20;

  // ds-board: ST_ProFree eyebrow label 13/700, tracking .14em, opacity .85
  static const double _eyebrowSize = 13;

  // ds-board: ST_ProFree eyebrow gold sparkle #FFD86B
  static const Color _gold = Color(0xFFFFD86B);

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
        borderRadius: BorderRadius.circular(_radius),
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
          if (eyebrow) ...[
            // ST_ProFree: a 20 gold sparkle and the label, 8 apart, then 20
            // to the heading.
            Row(
              children: [
                Icon(PantasIcons.sparkleFill, color: _gold, size: _eyebrowIcon),
                const SizedBox(width: PantasSpace.s8),
                Opacity(
                  opacity: .85,
                  child: Text(
                    'PANTAS PRO',
                    style: context.type.sectionHeader.copyWith(
                      color: c.onHero,
                      fontSize: _eyebrowSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: _eyebrowSize * .14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PantasSpace.s20),
          ],
          Text(
            heading,
            style: context.type.pageTitle.copyWith(color: c.onHero),
          ),
          if (detail != null) ...[
            const SizedBox(height: PantasSpace.s6),
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
