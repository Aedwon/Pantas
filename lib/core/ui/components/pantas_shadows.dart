import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_shadow.dart';

/// The elevation recipes of the active theme (`elev-toast`, `elev-modal`,
/// `elev-sheet`, ...). The dark set carries the 1px edge inside the shadow.
extension PantasShadowContext on BuildContext {
  PantasShadow get shadows => Theme.of(this).brightness == Brightness.dark
      ? PantasShadow.dark
      : PantasShadow.light;
}
