import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

import '../../../helpers/accessibility.dart';

void main() {
  test('disabled action role survives copies and theme interpolation', () {
    const light = PantasColors.light;
    const dark = PantasColors.dark;
    expect(light.disabledActionLabel, const Color(0xFFB8B8BD));
    expect(dark.disabledActionLabel, const Color(0xFF949494));
    expect(light.copyWith().disabledActionLabel, light.disabledActionLabel);
    final changed = light.copyWith(disabledActionLabel: Colors.orange);
    expect(changed.disabledActionLabel, Colors.orange);
    expect(changed.tertiaryLabel, light.tertiaryLabel);
    expect(
      light.lerp(dark, .5).disabledActionLabel,
      Color.lerp(const Color(0xFFB8B8BD), const Color(0xFF949494), .5),
    );
    expect(light.lerp(null, .5).disabledActionLabel, light.disabledActionLabel);
  });
  for (final brightness in Brightness.values) {
    testWidgets('disabled foreground opt-in preserves other states $brightness',
        (tester) async {
      final colors = brightness == Brightness.dark
          ? PantasColors.dark
          : PantasColors.light;
      Future<Color?> foreground(PantasButton button) async {
        await pumpAccessibilitySurface(
          tester,
          button,
          brightness: brightness,
          disableAnimations: true,
        );
        return tester
            .widget<TextButton>(find.byType(TextButton))
            .style!
            .foregroundColor!
            .resolve({});
      }

      for (final variant in PantasButtonVariant.values) {
        expect(
          await foreground(PantasButton(label: 'Check', variant: variant)),
          colors.tertiaryLabel,
        );
        expect(
          await foreground(
            PantasButton(
              label: 'Check',
              variant: variant,
              disabledForeground: colors.disabledActionLabel,
            ),
          ),
          colors.disabledActionLabel,
        );
      }
      expect(
        await foreground(
          PantasButton(
            label: 'Check',
            onPressed: () {},
            disabledForeground: colors.disabledActionLabel,
          ),
        ),
        colors.onAccent,
      );
      expect(
        await foreground(
          PantasButton(
            label: 'Check',
            busy: true,
            disabledForeground: colors.disabledActionLabel,
          ),
        ),
        colors.onAccent,
      );
      expect(
        await foreground(
          PantasButton(
            label: 'Check',
            disabledOpacity: .35,
            disabledForeground: colors.disabledActionLabel,
          ),
        ),
        colors.onAccent,
      );
    });
  }
}
