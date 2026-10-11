import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import '../../../helpers/accessibility.dart';

void main() {
  testWidgets('failed image exposes failure and working Retry semantics',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpAccessibilitySurface(
          tester,
          const ContentRenderer(blocks: [
            {
              '_type': 'image',
              'asset': {'url': 'https://example.invalid/test.png'},
              'alt': 'A diagram',
            }
          ],),);
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),);
      await tester.pump();
      expect(find.text('Image could not load.'), findsOneWidget);
      expect(find.bySemanticsLabel('Image could not load.'), findsOneWidget);
      expect(find.bySemanticsLabel('Retry'), findsOneWidget);
      final before = tester.widget<Image>(find.byType(Image)).key;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(tester.widget<Image>(find.byType(Image)).key, isNot(before));
    } finally {
      semantics.dispose();
    }
  });
}
