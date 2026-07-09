import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpPull(
    WidgetTester tester, {
    String? nextTitle = 'Next Lesson',
    VoidCallback? onAdvance,
  }) async {
    await tester.pumpApp(
      Scaffold(
        body: PullToAdvance(
          nextTitle: nextTitle,
          onAdvance: onAdvance ?? () {},
          child: Container(
            color: Colors.white,
            child: const Center(child: Text('Current Content')),
          ),
        ),
      ),
    );
  }

  testWidgets('the handle names the next lesson', (tester) async {
    await pumpPull(tester, nextTitle: 'Real and Imaginary Number Systems');

    expect(
      find.textContaining('Real and Imaginary Number Systems'),
      findsOneWidget,
    );
  });

  testWidgets('no next lesson draws no handle', (tester) async {
    await pumpPull(tester, nextTitle: null, onAdvance: null);

    expect(find.byKey(const ValueKey('pull-handle')), findsNothing);
  });

  testWidgets('a drag short of the threshold settles back', (tester) async {
    var advanced = false;
    await pumpPull(tester, onAdvance: () => advanced = true);

    await tester.drag(find.byType(PullToAdvance), const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(advanced, isFalse);
  });

  testWidgets('a drag past the threshold commits', (tester) async {
    var advanced = false;
    await pumpPull(tester, onAdvance: () => advanced = true);

    await tester.drag(find.byType(PullToAdvance), const Offset(0, -120));
    await tester.pumpAndSettle();

    expect(advanced, isTrue);
  });

  testWidgets('the handle arms past the threshold', (tester) async {
    await pumpPull(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PullToAdvance)),
    );
    await gesture.moveBy(const Offset(0, -130));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      tester.getSize(find.byKey(const ValueKey('pull-handle'))).width,
      52,
    );

    await gesture.up();
  });
}
