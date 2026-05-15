import 'package:cached_network_image/cached_network_image.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('block type', () {
    testWidgets('normal block renders its text content', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'Hello world', 'marks': <String>[]},
              ],
            },
          ],
        ),
      );

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('h2 block uses a larger text style than normal',
        (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'h2',
              'children': [
                {'_type': 'span', 'text': 'A Heading', 'marks': <String>[]},
              ],
            },
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
        const PortableTextRenderer(
          blocks: [
            {'_type': 'someNewType', 'data': 'x'},
          ],
        ),
      );

      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });

  group('inline latex span', () {
    testWidgets('renders Math widget for span with latex mark', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'See ', 'marks': <String>[]},
                {
                  '_type': 'span',
                  'text': 'E=mc^2',
                  'marks': ['latex'],
                },
              ],
            },
          ],
        ),
      );

      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('malformed inline latex renders placeholder, does not throw',
        (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {
                  '_type': 'span',
                  'text': r'\badcommand{{{',
                  'marks': ['latex'],
                },
              ],
            },
          ],
        ),
      );

      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });

  group('latex block type', () {
    testWidgets('renders display-mode Math widget', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {'_type': 'latex', 'body': r'\sum_{i=1}^{n} x_i'},
          ],
        ),
      );

      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('malformed latex block renders placeholder, does not throw',
        (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {'_type': 'latex', 'body': r'\bad{{{'},
          ],
        ),
      );

      expect(find.text('Content unavailable — update the app'), findsOneWidget);
    });
  });

  group('image block type', () {
    testWidgets('renders CachedNetworkImage for image block', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'image',
              'asset': {'url': 'https://cdn.sanity.io/images/test/image.jpg'},
            },
          ],
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
