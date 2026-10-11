import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('Cancel survives Tab from the field and clears on Enter',
      (tester) async {
    var value = '';
    await pumpAccessibilitySurface(
        tester, SearchField(title: 'Study', onChanged: (v) => value = v),);
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'math');
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.text('Cancel').hitTestable(), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(value, '');
    expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text, '',);
    expect(find.text('Study').hitTestable(), findsOneWidget);
  });
}
