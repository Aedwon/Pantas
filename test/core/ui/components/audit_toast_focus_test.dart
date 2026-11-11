import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/toast.dart';
import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('hidden Undo cannot receive Tab or Enter', (tester) async {
    var undo = 0;
    var other = 0;
    await pumpAccessibilitySurface(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Toast(message: 'Hidden', visible: false, onUndo: () => undo++),
          TextButton(
            onPressed: () => other++,
            child: const Text('Visible action'),
          ),
        ],
      ),
      disableAnimations: true,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(undo, 0);
    expect(other, 1);
  });
}
