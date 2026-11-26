import 'package:flutter/painting.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

/// The teal gradient of the Pro hero on phone and web (`.card--hero`, D126):
/// `hero-start` to `hero-mid` at 40% to `hero-end` at 160deg.
LinearGradient proHeroGradient(PantasColors c) => LinearGradient(
      // CSS 160deg: down, leaning a little to the right.
      begin: const Alignment(-0.342, -0.94),
      end: const Alignment(0.342, 0.94),
      colors: [c.heroStart, c.heroMid, c.heroEnd],
      stops: const [0, .4, 1],
    );
