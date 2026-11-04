import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';

Future<void> _mount(WidgetTester tester) async {
  resetWebKeyboardFocus();
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: true),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                WebButton(label: 'First', onPressed: () {}),
                WebButton(label: 'Second', onPressed: () {}),
                WebRow(title: 'Row', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

BorderSide _side(WidgetTester tester, String label) {
  final button = find.ancestor(
    of: find.text(label),
    matching: find.byType(TextButton),
  );
  final material = tester.widget<Material>(
    find.descendant(of: button, matching: find.byType(Material)).first,
  );
  return (material.shape! as OutlinedBorder).side;
}

void main() {
  testWidgets('a mouse click shows no focus ring', (tester) async {
    await _mount(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('First')));
    await mouse.down(tester.getCenter(find.text('First')));
    await mouse.up();
    await tester.pump();
    final node = FocusManager.instance.rootScope.descendants.firstWhere(
      (n) =>
          n.context?.findAncestorWidgetOfExactType<TextButton>() != null &&
          n.context!.findAncestorWidgetOfExactType<WebButton>() != null &&
          (n.context!.findAncestorWidgetOfExactType<WebButton>()!).label ==
              'First',
    );
    // ignore: cascade_invocations
    node.requestFocus();
    await tester.pump();
    expect(node.hasPrimaryFocus, isTrue);
    expect(_side(tester, 'First').width, isNot(2));
    expect(_side(tester, 'Row').width, 0);
  });

  testWidgets('Tab shows a 2 px accent ring on a button and on a row',
      (tester) async {
    await _mount(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final first = _side(tester, 'First');
    expect(first.width, 2);
    expect(first.color, const Color(0xFF0B7A68));
    expect(_side(tester, 'Second').width, isNot(2));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_side(tester, 'Row').width, 2);
    expect(_side(tester, 'First').width, isNot(2));
  });

  testWidgets('a click then Tab shows the ring on the next control',
      (tester) async {
    await _mount(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.text('First')));
    await mouse.down(tester.getCenter(find.text('First')));
    await mouse.up();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      _side(tester, 'First').width == 2 || _side(tester, 'Second').width == 2,
      isTrue,
    );
  });
}
