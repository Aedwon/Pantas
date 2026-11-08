import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

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

  group('the reader bar back control', () {
    testWidgets('is a named icon button with no label and no Esc hint',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        wide,
        WebReaderBackControl(label: 'Study', onPressed: () => taps++),
      );
      expect(find.byType(PantasIconButton), findsOneWidget);
      expect(find.byTooltip('Back to Study'), findsOneWidget);
      expect(find.text('Study'), findsNothing);
      expect(find.text('Esc'), findsNothing);
      await tester.tap(find.byType(PantasIconButton));
      expect(taps, 1);
    });

    testWidgets('hovers as a rounded rectangle, not a pill', (tester) async {
      await pumpDs(
        tester,
        wide,
        WebReaderBackControl(label: 'Study', onPressed: () {}),
      );
      await _hover(tester, find.byType(PantasIconButton));
      final style = tester.widget<IconButton>(find.byType(IconButton)).style!;
      final shape = style.shape!.resolve({WidgetState.hovered});
      expect(shape, isA<RoundedRectangleBorder>());
      expect(shape, isNot(isA<StadiumBorder>()));
      expect(
        (shape! as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(PantasRadius.md),
      );
      final wash = style.backgroundColor!.resolve({WidgetState.hovered})!;
      expect(wash.a, greaterThan(0));
      expect(wash, isNot(PantasColors.light.surfaceCard));
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
    });
  });
}
