import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_pull_to_advance.dart';

void main() {
  for (final label in ['Topic', 'Next in Math', 'Next in Earth Science']) {
    testWidgets('every pull phrase shows in full beside "$label"', (
      tester,
    ) async {
      final pull = WebPullController(vsync: tester);
      addTearDown(pull.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: WebPullLabel(
              pull: pull,
              label: label,
              style: const TextStyle(fontSize: 12, letterSpacing: 1),
            ),
          ),
        ),
      );
      final box = tester.getSize(find.byType(WebPullLabel));
      for (var i = 0; i < 3; i++) {
        final phrase = tester.getSize(
          find.descendant(
            of: find.byKey(ValueKey('web-next-label-$i')),
            matching: find.byType(Text),
          ),
        );
        expect(
          phrase.width,
          lessThanOrEqualTo(box.width),
          reason: 'phrase $i is wider than the box that clips it',
        );
      }
    });
  }
}
