import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_tap.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_toast.dart';

import '../../../helpers/ds_matrix.dart';

Future<void> _hover(WidgetTester tester, Finder target) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(target));
  await tester.pumpAndSettle();
}

void main() {
  const wide = DsCell(1440, 1, dark: false);

  setUpAll(loadDsFonts);

  testWidgets('an icon button hovers as a rounded rectangle, not a circle',
      (tester) async {
    await pumpDs(
      tester,
      wide,
      PantasIconButton(
        tooltip: 'Close',
        glyph: PantasIcons.close,
        onPressed: () {},
      ),
    );
    await _hover(tester, find.byType(IconButton));
    final style = tester.widget<IconButton>(find.byType(IconButton)).style!;
    final shape = style.shape!.resolve({WidgetState.hovered});
    expect(shape, isA<RoundedRectangleBorder>());
    expect(shape, isNot(isA<CircleBorder>()));
    expect(
      style.backgroundColor!.resolve({WidgetState.hovered})!.a,
      greaterThan(0),
    );
  });

  testWidgets('a tap area washes as a rounded rectangle and answers Enter',
      (tester) async {
    var taps = 0;
    await pumpDs(
      tester,
      wide,
      SizedBox(
        width: 300,
        child: MockTap(
          onTap: () => taps++,
          radius: PantasRadius.sm,
          child: const SizedBox(height: 46, child: Text('Question 1')),
        ),
      ),
    );
    await _hover(tester, find.text('Question 1'));
    final box = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(MockTap),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.rectangle);
    expect(decoration.borderRadius, BorderRadius.circular(PantasRadius.sm));
    expect(decoration.color, PantasColors.light.surfaceHover);
    await tester.tap(find.text('Question 1'));
    expect(taps, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 2);
  });

  testWidgets('a back link hovers as a rounded rectangle, not a pill',
      (tester) async {
    await pumpDs(
      tester,
      wide,
      WebBackLink(label: 'Quiz', onPressed: () {}, nudge: false),
    );
    await _hover(tester, find.text('Quiz'));
    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
    final shape = style.shape!.resolve({WidgetState.hovered});
    expect(shape, isA<RoundedRectangleBorder>());
    expect(shape, isNot(isA<StadiumBorder>()));
    expect(
      (shape! as RoundedRectangleBorder).borderRadius,
      BorderRadius.circular(PantasRadius.back),
    );
  });

  testWidgets('a tertiary action hovers as a rounded rectangle, not a pill',
      (tester) async {
    await pumpDs(
      tester,
      wide,
      WebButton(
        label: 'Discard This Mock',
        kind: PantasButtonKind.tertiary,
        tone: PantasButtonTone.critical,
        onPressed: () {},
      ),
    );
    await _hover(tester, find.text('Discard This Mock'));
    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
    final shape = style.shape!.resolve({WidgetState.hovered});
    expect(shape, isA<RoundedRectangleBorder>());
    expect(shape, isNot(isA<StadiumBorder>()));
  });

  testWidgets('the mock message shows as the system Toast', (tester) async {
    await pumpDs(
      tester,
      wide,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showMockToast(context, 'Could not save'),
          child: const Text('go'),
        ),
      ),
      scroll: false,
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.byType(Toast), findsOneWidget);
    expect(find.text('Could not save'), findsOneWidget);
  });
}
