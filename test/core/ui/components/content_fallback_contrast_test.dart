import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
        'unknown content text contrasts with its actual fill $brightness',
        (tester) async {
      await pumpAccessibilitySurface(
        tester,
        const ContentRenderer(
          blocks: [
            {'_type': 'unknown'},
          ],
        ),
        brightness: brightness,
      );
      final text =
          tester.widget<Text>(find.text('This part cannot be shown yet.'));
      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('This part cannot be shown yet.'),
              matching: find.byType(Container),
            )
            .first,
      );
      expectContrast(
        text.style!.color!,
        (container.decoration! as BoxDecoration).color!,
      );
    });
  }
}
