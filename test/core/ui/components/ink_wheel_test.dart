import 'package:cse_cet_reviewer/core/ui/components/ink_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('the wheel shows its values and starts on the selected one',
      (tester) async {
    await tester.pumpApp(
      SizedBox(
        height: InkWheel.itemHeight * InkWheel.visibleItems,
        child: InkWheel<int>(
          values: const [10, 11, 12, 13, 14],
          selectedIndex: 2,
          onSelected: (_) {},
          labelBuilder: (value) => '$value',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('scrolling reports the new index', (tester) async {
    int? reported;
    await tester.pumpApp(
      SizedBox(
        height: InkWheel.itemHeight * InkWheel.visibleItems,
        child: InkWheel<int>(
          values: const [10, 11, 12, 13, 14],
          selectedIndex: 2,
          onSelected: (index) => reported = index,
          labelBuilder: (value) => '$value',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(InkWheel<int>),
      const Offset(0, -InkWheel.itemHeight),
    );
    await tester.pumpAndSettle();

    expect(reported, 3);
  });

  testWidgets('an empty list renders without throwing', (tester) async {
    await tester.pumpApp(
      SizedBox(
        height: InkWheel.itemHeight * InkWheel.visibleItems,
        child: InkWheel<int>(
          values: const [],
          selectedIndex: 0,
          onSelected: (_) {},
          labelBuilder: (value) => '$value',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(InkWheel<int>), findsOneWidget);
  });
}
