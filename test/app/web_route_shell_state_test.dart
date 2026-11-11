import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GestureDetector(
          onTap: () => setState(() => taps++),
          child: Center(child: Text('taps $taps')),
        ),
      );
}

void main() {
  // 7X-2: turning a phone on its side crosses from the phone layout to the
  // tablet one. The page under the shell kept nothing across it.
  for (final (from, to) in [(393.0, 852.0), (852.0, 393.0), (393.0, 580.0)]) {
    testWidgets('the page keeps its state from $from to $to wide',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(from, 700);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WebRouteShell(path: '/study', child: _Counter()),
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      expect(find.text('taps 1'), findsOneWidget);

      tester.view.physicalSize = Size(to, 340);
      await tester.pump();

      expect(find.text('taps 1'), findsOneWidget);
    });
  }

  test('the layout tiers on either side differ, so the test is real', () {
    expect(webLayoutTier(width: 393, web: true), WebLayoutTier.phone);
    expect(webLayoutTier(width: 852, web: true), WebLayoutTier.tabletPortrait);
  });
}
