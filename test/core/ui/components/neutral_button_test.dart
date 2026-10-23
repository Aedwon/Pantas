import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

import '../../../helpers/accessibility.dart';

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });

  for (final brightness in Brightness.values) {
    testWidgets('existing button variants retain their colors in $brightness',
        (tester) async {
      final colors = brightness == Brightness.light
          ? PantasColors.light
          : PantasColors.dark;
      final pairs = [
        (PantasButtonVariant.primary, colors.accentFill, colors.onAccent),
        (
          PantasButtonVariant.secondary,
          colors.accentTint,
          brightness == Brightness.dark ? colors.label : colors.accent
        ),
        (PantasButtonVariant.tertiary, colors.transparent, colors.accent),
        (
          PantasButtonVariant.destructive,
          colors.destructive,
          colors.onDestructive
        ),
      ];
      for (final pair in pairs) {
        await pumpAccessibilitySurface(
          tester,
          PantasButton(label: 'Continue', variant: pair.$1, onPressed: () {}),
          brightness: brightness,
          disableAnimations: true,
        );
        final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
        expect(style.backgroundColor!.resolve({}), pair.$2);
        expect(style.foregroundColor!.resolve({}), pair.$3);
      }
    });
  }

  testWidgets('neutral button supports keyboard focus and activation',
      (tester) async {
    var taps = 0;
    await pumpAccessibilitySurface(
      tester,
      PantasButton(
        label: 'Quiz yourself, 5 questions',
        variant: PantasButtonVariant.neutral,
        onPressed: () => taps++,
      ),
      disableAnimations: true,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
  });

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('neutral button $brightness scale=$scale uses fill and label',
          (tester) async {
        var taps = 0;
        await pumpAccessibilitySurface(
          tester,
          PantasButton(
            label: 'Quiz yourself, 5 questions',
            variant: PantasButtonVariant.neutral,
            onPressed: () => taps++,
          ),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(320, 640),
          disableAnimations: true,
        );
        final colors = brightness == Brightness.light
            ? PantasColors.light
            : PantasColors.dark;
        final button = tester.widget<TextButton>(find.byType(TextButton));
        expect(button.style!.backgroundColor!.resolve({}), colors.fill);
        expect(button.style!.foregroundColor!.resolve({}), colors.label);
        expect(
          button.style!.shape!.resolve({}),
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        );
        expect(
          tester.getSize(find.byType(TextButton)).height,
          scale == 1 ? 52 : greaterThanOrEqualTo(52),
        );
        await tester.tap(find.byType(TextButton));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('neutral button retains shared press and reduced-motion behavior',
      (tester) async {
    final button = PantasButton(
      label: 'Quiz yourself, 5 questions',
      variant: PantasButtonVariant.neutral,
      onPressed: () {},
    );
    await pumpAccessibilitySurface(tester, button);
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(TextButton)));
    await tester.pump(const Duration(milliseconds: 140));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, .97);
    await gesture.up();
    await tester.pumpAndSettle();
    await pumpAccessibilitySurface(tester, button, disableAnimations: true);
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
      Duration.zero,
    );
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });
  testWidgets('neutral busy and disabled controls cannot trigger an action',
      (tester) async {
    var taps = 0;
    await pumpAccessibilitySurface(
      tester,
      PantasButton(
        label: 'Quiz yourself, 5 questions',
        variant: PantasButtonVariant.neutral,
        busy: true,
        onPressed: () => taps++,
      ),
      disableAnimations: true,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(TextButton));
    expect(taps, 0);
    await pumpAccessibilitySurface(
      tester,
      const PantasButton(
        label: 'Quiz yourself, 5 questions',
        variant: PantasButtonVariant.neutral,
      ),
    );
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
  });
}
