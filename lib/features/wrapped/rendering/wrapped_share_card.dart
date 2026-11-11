import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/wrapped/domain/wrapped_payload.dart';

// The light palette by value, not by theme lookup. A share card is rendered
// off screen to a PNG and must not follow the reader's dark mode: what they
// post looks the same whatever their phone is set to.
const PantasColors _palette = PantasColors.light;

/// The share card gradient (`.card--share`): `hero-start` to `share-end` at
/// 165 degrees. CSS angles run clockwise from "up", so 165 degrees points
/// down and slightly to the right.
final LinearGradient wrappedShareGradient = LinearGradient(
  begin: const Alignment(-0.2588, -0.9659),
  end: const Alignment(0.2588, 0.9659),
  colors: [_palette.heroStart, _palette.shareEnd],
);

class WrappedShareCard extends StatelessWidget {
  const WrappedShareCard({
    required this.payload,
    required this.includeArchetype,
    super.key,
  });

  final WrappedPayload payload;
  final bool includeArchetype;

  static const Size outputSize = Size(1080, 1920);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primarySlide = payload.slides.isEmpty ? null : payload.slides.first;
    // The card is a picture of fixed proportions, so it ignores the reader's
    // text size.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        // The share card gradient from the design system, in the light palette.
        // It is the most public thing the app makes: the one artifact a student
        // posts, seen by people who have never opened Pantas.
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: wrappedShareGradient),
          child: Padding(
            padding: const EdgeInsets.all(PantasSpace.s32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantas Wrapped',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _palette.onHeroSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PantasSpace.s10),
                // The rule under the wordmark, which is the device every ruled
                // surface in the app opens with.
                SizedBox(
                  width: double.infinity,
                  height: PantasBorder.ringStrong,
                  child: ColoredBox(color: _palette.onHero),
                ),
                const Spacer(),
                Text(
                  payload.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: _palette.onHero,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PantasSpace.s18),
                if (primarySlide != null)
                  Text(
                    primarySlide.body,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: _palette.onHero),
                  ),
                if (includeArchetype) ...[
                  const SizedBox(height: PantasSpace.s24),
                  Text(
                    payload.archetypeId.replaceAll('_', ' ').toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: _palette.onHeroSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  'pantas.study/wrapped',
                  style: TextStyle(color: _palette.onHeroSecondary),
                ),
                const SizedBox(height: PantasSpace.s8),
                Text(
                  'Watermarked by Pantas',
                  style: TextStyle(color: _palette.onHeroSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
