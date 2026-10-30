import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';

void main() {
  for (final error in [false, true]) {
    testWidgets('first route signals once after data settles, error=$error',
        (tester) async {
      var signals = 0;
      final ready = ValueNotifier<bool>(false);
      addTearDown(ready.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firstScreenSignalProvider
                .overrideWithValue(FirstScreenSignal(() => signals++)),
          ],
          child: MaterialApp(
            home: ValueListenableBuilder<bool>(
              valueListenable: ready,
              builder: (_, settled, __) => FirstScreenReady(
                ready: settled,
                child:
                    Text(settled ? (error ? 'Error' : 'Content') : 'Loading'),
              ),
            ),
          ),
        ),
      );
      expect(signals, 0);
      ready.value = true;
      await tester.pump();
      expect(find.text(error ? 'Error' : 'Content'), findsOneWidget);
      expect(signals, 1);
      ready.value = false;
      await tester.pump();
      ready.value = true;
      await tester.pump();
      expect(signals, 1);
    });
  }
}
