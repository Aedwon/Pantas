import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/ink_checkbox.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  testWidgets('off draws a bordered box and no glyph', (tester) async {
    await _pump(tester, const InkCheckbox(state: InkCheckState.off));

    expect(find.byIcon(Icons.check), findsNothing);
    final box = tester.widget<Container>(find.byType(Container).first);
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, isNull);
    expect(decoration.border, isNotNull);
  });

  testWidgets('on fills and shows a check', (tester) async {
    await _pump(tester, const InkCheckbox(state: InkCheckState.on));

    expect(find.byIcon(Icons.check), findsOneWidget);
    final box = tester.widget<Container>(find.byType(Container).first);
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, isNotNull);
    expect(decoration.border, isNull);
  });

  testWidgets('partial fills but shows a bar, never a check', (tester) async {
    await _pump(tester, const InkCheckbox(state: InkCheckState.partial));

    expect(find.byIcon(Icons.check), findsNothing);
    final box = tester.widget<Container>(find.byType(Container).first);
    expect((box.decoration! as BoxDecoration).color, isNotNull);
    expect(
      tester.getSemantics(find.byType(InkCheckbox)),
      matchesSemantics(
        hasCheckedState: true,
        isCheckStateMixed: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
  });

  testWidgets('its semantic target is 48dp', (tester) async {
    await _pump(
      tester,
      InkCheckbox(state: InkCheckState.off, onTap: () {}),
    );
    expect(tester.getSize(find.byType(InkCheckbox)), const Size(48, 48));
  });

  testWidgets('the binary factory maps true and false onto on and off',
      (tester) async {
    await _pump(tester, const InkCheckbox.binary(isSelected: true));
    expect(find.byIcon(Icons.check), findsOneWidget);

    await _pump(tester, const InkCheckbox.binary(isSelected: false));
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('a tap fires only when one is given and it is enabled',
      (tester) async {
    var taps = 0;
    await _pump(
      tester,
      InkCheckbox(state: InkCheckState.off, onTap: () => taps++),
    );
    await tester.tap(find.byType(InkCheckbox));
    expect(taps, 1);

    // Disabled is not merely dimmed: it must not accept the tap either.
    await _pump(
      tester,
      InkCheckbox(
        state: InkCheckState.off,
        enabled: false,
        onTap: () => taps++,
      ),
    );
    await tester.tap(find.byType(InkCheckbox));
    expect(taps, 1);
  });

  testWidgets('it honours the size it is given', (tester) async {
    await _pump(tester, const InkCheckbox(state: InkCheckState.off, size: 22));

    final box = tester.widget<Container>(find.byType(Container).first);
    expect(box.constraints?.maxWidth ?? 0, 22);
  });
}
