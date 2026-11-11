import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/features/settings/presentation/widgets/pro_perks.dart';

class WebProHero extends StatelessWidget {
  const WebProHero({required this.heading, this.detail, super.key});
  final String heading;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final perkStyle = PantasType.webBody.copyWith(
      color: c.textPrimary,
      height: 1.3,
    );
    final headingColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PANTAS PRO',
          style: PantasType.webEyebrow.copyWith(color: c.accent),
        ),
        const SizedBox(height: PantasSpace.s8),
        Text(heading, style: PantasType.webH2.copyWith(color: c.textPrimary)),
        if (detail != null) ...[
          const SizedBox(height: PantasSpace.s8),
          Text(
            detail!,
            style: PantasType.webBody.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
    final features = Padding(
      padding: const EdgeInsets.only(top: PantasSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, feature) in proPerks.indexed) ...[
            if (index > 0) const SizedBox(height: PantasSpace.s8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(feature.$1, color: c.accent, size: PantasSize.icon),
                const SizedBox(width: PantasSpace.s12),
                Expanded(child: Text(feature.$2, style: perkStyle)),
              ],
            ),
          ],
        ],
      ),
    );
    return Container(
      key: const ValueKey('pro-hero'),
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s28,
        PantasSpace.s28,
        PantasSpace.s28,
        PantasSpace.s24,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PantasRadius.r2xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.surfaceCard, c.surfaceCard, c.accentTint],
          stops: const [0, .55, 1],
        ),
      ),
      // The dark edge takes up no room: the card is the same size in both
      // themes (6T-11).
      foregroundDecoration: dark
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(PantasRadius.r2xl),
              border: Border.all(color: c.edgeCard),
            )
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The perks take the width of the longest one, so none wraps while
          // the heading column has room (5Q-15). Too little room left for the
          // heading stacks the two.
          final scaler = MediaQuery.textScalerOf(context);
          var longest = 0.0;
          for (final (_, perk) in proPerks) {
            final painter = TextPainter(
              text: TextSpan(text: perk, style: perkStyle),
              textDirection: Directionality.of(context),
              textScaler: scaler,
              maxLines: 1,
            )..layout();
            if (painter.width > longest) longest = painter.width;
            painter.dispose();
          }
          // Icon, its gap, and a hair for rounding.
          final perksWidth = longest + PantasSize.icon + PantasSpace.s12 + 2;
          final headingWidth =
              constraints.maxWidth - PantasSpace.s24 - perksWidth;
          if (constraints.maxWidth < 544 || headingWidth < 200) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headingColumn,
                const SizedBox(height: PantasSpace.s24),
                features,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: headingColumn),
              const SizedBox(width: PantasSpace.s24),
              SizedBox(width: perksWidth, child: features),
            ],
          );
        },
      ),
    );
  }
}
