import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('SkeletonLoader', () {
    testWidgets('renders a box with given width and height', (tester) async {
      await tester.pumpApp(
        const SkeletonBox(width: 200, height: 16),
      );
      final box = tester.widget<Container>(find.byType(Container).last);
      expect(box.constraints?.maxWidth, 200);
    });

    testWidgets('SkeletonCard renders without error', (tester) async {
      await tester.pumpApp(const SkeletonCard());
      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('SkeletonCard contains multiple SkeletonBox widgets',
        (tester) async {
      await tester.pumpApp(const SkeletonCard());
      expect(find.byType(SkeletonBox), findsAtLeast(3));
    });
  });
}
