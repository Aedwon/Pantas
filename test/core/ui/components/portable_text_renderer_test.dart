import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';
import 'package:pantas/core/ui/figures/gear_train_figure.dart';
import 'package:pantas/core/ui/figures/lesson_figure_widget.dart';

import '../../../helpers/pump_app.dart';

/// The markers are spans inside a rich paragraph rather than their own
/// `Text`, so `find.text` never sees them.
List<String> plainTexts(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((r) => r.text.toPlainText())
    .toList();

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

      expect(find.text('Content unavailable. Update the app.'), findsOneWidget);
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

      expect(find.text('Content unavailable. Update the app.'), findsOneWidget);
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

      expect(find.text('Content unavailable. Update the app.'), findsOneWidget);
    });
  });

  group('inline marks', () {
    TextSpan? findSpanWithText(InlineSpan root, String text) {
      TextSpan? found;
      root.visitChildren((span) {
        if (span is TextSpan && span.text == text) {
          found = span;
          return false;
        }
        return true;
      });
      return found;
    }

    testWidgets('strong mark renders bold', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'plain ', 'marks': <String>[]},
                {
                  '_type': 'span',
                  'text': 'important',
                  'marks': ['strong'],
                },
              ],
            },
          ],
        ),
      );

      final textWidget = tester.widget<Text>(find.text('plain important'));
      final span = findSpanWithText(textWidget.textSpan!, 'important');
      expect(span?.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('strike-through mark renders line-through', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {
                  '_type': 'span',
                  'text': 'wrong',
                  'marks': ['strike-through'],
                },
              ],
            },
          ],
        ),
      );

      final textWidget = tester.widget<Text>(find.text('wrong'));
      final span = findSpanWithText(textWidget.textSpan!, 'wrong');
      expect(
        span?.style?.decoration?.contains(TextDecoration.lineThrough),
        isTrue,
      );
    });

    testWidgets(r'inline latex \cancel renders Math, not placeholder',
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
                  'text': r'\cancel{2x}',
                  'marks': ['latex'],
                },
              ],
            },
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Math), findsOneWidget);
      expect(find.text('Content unavailable. Update the app.'), findsNothing);
    });

    testWidgets('em mark renders italic', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {
                  '_type': 'span',
                  'text': 'gently',
                  'marks': ['em'],
                },
              ],
            },
          ],
        ),
      );

      final textWidget = tester.widget<Text>(find.text('gently'));
      final span = findSpanWithText(textWidget.textSpan!, 'gently');
      expect(span?.style?.fontStyle, FontStyle.italic);
    });
  });

  group('list items', () {
    Map<String, dynamic> listBlock(String text, String kind, {int level = 1}) {
      return {
        '_type': 'block',
        'style': 'normal',
        'listItem': kind,
        'level': level,
        'children': [
          {'_type': 'span', 'text': text, 'marks': <String>[]},
        ],
      };
    }

    testWidgets('bullet items render with bullet markers', (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: [
            listBlock('First', 'bullet'),
            listBlock('Second', 'bullet'),
          ],
        ),
      );

      expect(find.text('•  First'), findsOneWidget);
      expect(find.text('•  Second'), findsOneWidget);
    });

    testWidgets('numbered items count up and reset after a normal block',
        (tester) async {
      await tester.pumpApp(
        PortableTextRenderer(
          blocks: [
            listBlock('Step one', 'number'),
            listBlock('Step two', 'number'),
            const {
              '_type': 'block',
              'style': 'normal',
              'children': [
                {'_type': 'span', 'text': 'A paragraph.', 'marks': <String>[]},
              ],
            },
            listBlock('Restarted', 'number'),
          ],
        ),
      );

      expect(find.text('1.  Step one'), findsOneWidget);
      expect(find.text('2.  Step two'), findsOneWidget);
      expect(find.text('1.  Restarted'), findsOneWidget);
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

  group('lesson figure and table blocks', () {
    testWidgets('dispatches figureSpec through the lesson wrapper', (
      tester,
    ) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'figureSpec',
              'spec': {
                'kind': 'gear-train',
                'gears': 3,
                'firstTurns': 'clockwise',
              },
              'semanticsLabel': 'Three meshed gears.',
            },
          ],
        ),
      );

      expect(find.byType(LessonFigureWidget), findsOneWidget);
      expect(find.byType(GearTrainFigure), findsOneWidget);
    });

    testWidgets('renders a table with rules and horizontal scrolling', (
      tester,
    ) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'table',
              'rows': [
                ['P', 'Q', 'P and Q'],
                ['T', 'T', 'T'],
                ['T', 'F', 'F'],
              ],
            },
          ],
        ),
      );

      expect(find.byType(Table), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsOneWidget,
      );
      expect(find.text('P and Q'), findsOneWidget);
      expect(find.text('F'), findsNWidgets(2));
    });

    testWidgets('a bad figureSpec uses lesson failure copy', (tester) async {
      await tester.pumpApp(
        const PortableTextRenderer(
          blocks: [
            {
              '_type': 'figureSpec',
              'spec': {'kind': 'gear-train', 'gears': 1},
              'semanticsLabel': 'Broken figure.',
            },
          ],
        ),
      );

      expect(
        find.text('This lesson needs a diagram that has not been drawn yet.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('a formula between two steps does not restart the numbering',
      (tester) async {
    await tester.pumpApp(
      const PortableTextRenderer(
        blocks: [
          {
            '_type': 'block',
            'listItem': 'number',
            'level': 1,
            'children': [
              {'_type': 'span', 'text': 'First step'},
            ],
          },
          {'_type': 'latex', 'latex': 'x = 3'},
          {
            '_type': 'block',
            'listItem': 'number',
            'level': 1,
            'children': [
              {'_type': 'span', 'text': 'Second step'},
            ],
          },
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Every worked example in Mathematics shows its working between the
    // steps, and that used to end the list.
    final markers = plainTexts(tester);
    expect(markers.any((t) => t.startsWith('1.')), isTrue);
    expect(markers.any((t) => t.startsWith('2.')), isTrue);
  });

  testWidgets('a paragraph does end the list', (tester) async {
    await tester.pumpApp(
      const PortableTextRenderer(
        blocks: [
          {
            '_type': 'block',
            'listItem': 'number',
            'level': 1,
            'children': [
              {'_type': 'span', 'text': 'One'},
            ],
          },
          {
            '_type': 'block',
            'children': [
              {'_type': 'span', 'text': 'A new thought'},
            ],
          },
          {
            '_type': 'block',
            'listItem': 'number',
            'level': 1,
            'children': [
              {'_type': 'span', 'text': 'A fresh list'},
            ],
          },
        ],
      ),
    );
    await tester.pumpAndSettle();

    final markers = plainTexts(tester);
    expect(markers.where((t) => t.startsWith('1.')).length, 2);
  });

  testWidgets('dollars in a block span render as maths, not as dollars',
      (tester) async {
    await tester.pumpApp(
      const PortableTextRenderer(
        blocks: [
          {
            '_type': 'block',
            'children': [
              {'_type': 'span', 'text': r'Solve $x + 1$ now'},
            ],
          },
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(plainTexts(tester).any((t) => t.contains(r'\$')), isFalse);
  });

  testWidgets('a heading takes its air above, not below', (tester) async {
    // Every block used to take the same 4 either side, so a heading had no
    // more air than the sentence before it. Aedwon: "text is too cramped.
    // there should be ample spacing before each header."
    await tester.pumpApp(
      const PortableTextRenderer(
        blocks: [
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {'text': 'The section that ended.', 'marks': <String>[]},
            ],
          },
          {
            '_type': 'block',
            'style': 'h2',
            'children': [
              {'text': 'A new section', 'marks': <String>[]},
            ],
          },
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {'text': 'Its first line.', 'marks': <String>[]},
            ],
          },
        ],
      ),
    );

    final beforeHeading = tester.getRect(find.text('The section that ended.'));
    final heading = tester.getRect(find.text('A new section'));
    final afterHeading = tester.getRect(find.text('Its first line.'));

    final above = heading.top - beforeHeading.bottom;
    final below = afterHeading.top - heading.bottom;

    // The gap belongs to the section the heading opens, so it is bound to
    // the line under it and separated from the one over it.
    expect(above, greaterThan(below * 2));
  });

  testWidgets('the opening block takes no gap above it', (tester) async {
    await tester.pumpApp(
      const PortableTextRenderer(
        blocks: [
          {
            '_type': 'block',
            'style': 'h2',
            'children': [
              {'text': 'Opens the lesson', 'marks': <String>[]},
            ],
          },
        ],
      ),
    );

    final renderer = tester.getRect(find.byType(PortableTextRenderer));
    final heading = tester.getRect(find.text('Opens the lesson'));

    expect(heading.top - renderer.top, lessThan(1));
  });
}
