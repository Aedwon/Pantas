import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/hover_shape.dart';

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

  group('the reader bar back control', () {
    testWidgets('is the BackLink with the parent name and the Esc hint (D192)',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        wide,
        WebReaderBackControl(label: 'Study', onPressed: () => taps++),
      );
      expect(find.byType(WebBackLink), findsOneWidget);
      expect(find.text('Study'), findsOneWidget);
      expect(find.byType(WebKeyHint), findsOneWidget);
      await tester.tap(find.text('Study'));
      expect(taps, 1);
    });

    testWidgets('hovers as a rounded rectangle, not a pill', (tester) async {
      await pumpDs(
        tester,
        wide,
        WebReaderBackControl(label: 'Study', onPressed: () {}),
      );
      await _hover(tester, find.text('Study'));
      final style = tester
          .widget<TextButton>(
            find.descendant(
              of: find.byType(WebBackLink),
              matching: find.byType(TextButton),
            ),
          )
          .style!;
      final shape = style.shape!.resolve({WidgetState.hovered});
      expect(shape, isA<RoundedRectangleBorder>());
      expect(shape, isNot(isA<StadiumBorder>()));
      expect(
        (shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(PantasRadius.back),
      );
      expectHitArea(
        tester,
        find.byType(WebBackLink),
        min: const Size(44, 40),
        reason: 'BackLink is size-back (40) high on a fine pointer',
      );
      // The teal wash itself is the BackLink's, tested with the component.
    });
  });

  group('a tap area on custom content', () {
    testWidgets('washes as a rounded rectangle and answers Enter',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        wide,
        SizedBox(
          width: 300,
          child: ReaderTap(
            onTap: () => taps++,
            child: const SizedBox(height: 36, child: Text('Core concept')),
          ),
        ),
      );
      await _hover(tester, find.text('Core concept'));
      final box = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(ReaderTap),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, BorderRadius.circular(PantasRadius.md));
      expect(decoration.color, PantasColors.light.surfaceHover);
      await tester.tap(find.text('Core concept'));
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 2);
    });

    testWidgets('a disabled one takes no wash and no tap', (tester) async {
      await pumpDs(
        tester,
        wide,
        const SizedBox(
          width: 300,
          child: ReaderTap(
            key: ValueKey('off'),
            onTap: null,
            child: SizedBox(height: 36, child: Text('Core concept')),
          ),
        ),
      );
      await expectTapAreaInert(
        tester,
        find.byKey(const ValueKey('off')),
        () => 0,
      );
    });
  });

  group('a text button', () {
    testWidgets('hovers as a rounded rectangle, not a pill', (tester) async {
      await pumpDs(
        tester,
        wide,
        PantasButton(
          label: 'Back to Home',
          kind: PantasButtonKind.tertiary,
          fullWidth: false,
          onPressed: () {},
        ),
      );
      await _hover(tester, find.text('Back to Home'));
      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      final shape = style.shape!.resolve({WidgetState.hovered});
      expect(shape, isA<RoundedRectangleBorder>());
      expect(shape, isNot(isA<StadiumBorder>()));
      expectHitArea(tester, find.byType(PantasButton));
    });

    testWidgets('a disabled one takes no wash and no tap', (tester) async {
      await pumpDs(
        tester,
        wide,
        const PantasButton(
          label: 'Back to Home',
          kind: PantasButtonKind.tertiary,
          fullWidth: false,
        ),
      );
      await expectDisabledInert(
        tester,
        find.descendant(
          of: find.byType(PantasButton),
          matching: find.byType(TextButton),
        ),
      );
    });
  });
}
