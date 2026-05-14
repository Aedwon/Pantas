import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('block type', () {
    testWidgets('normal block renders its text content', (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'Hello world', 'marks': []}
              ]
            }
          ],
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('h2 block uses a larger text style than normal',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'h2',
              'children': [
                {'_type': 'span', 'text': 'A Heading', 'marks': []}
              ]
            }
          ],
        ),
      );

      final textWidget = tester.widget<Text>(find.text('A Heading'));
      expect(textWidget.style?.fontSize, greaterThanOrEqualTo(18));
    });
  });

  group('unknown block type', () {
    testWidgets('renders placeholder for unrecognised block type',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {'_type': 'someNewType', 'data': 'x'}
          ],
        ),
      );

      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });

  group('inline latex span', () {
    testWidgets('renders Math widget for span with latex mark', (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'See ', 'marks': []},
                {
                  '_type': 'span',
                  'text': 'E=mc^2',
                  'marks': ['latex']
                },
              ]
            }
          ],
        ),
      );

      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('malformed inline latex renders placeholder, does not throw',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: const [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {
                  '_type': 'span',
                  'text': r'\badcommand{{{',
                  'marks': ['latex']
                },
              ]
            }
          ],
        ),
      );

      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });
}
