// Wide reader: Immersion (docs/design/DECISIONS.md, "Wide reader: Immersion
// replaces the two-column layout (Nov 29)"). With full width on, at 1024 px
// and up, the lesson is one centered column whose text grows with the window.
// ignore_for_file: no_adjacent_strings_in_list
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../goldens/golden_harness.dart';
import '../../../helpers/held_picture_fixtures.dart';
import '../../../helpers/in_memory_database.dart';

const _column = ValueKey('web-reader-column');
const _frame = ValueKey('reader-figure-frame');
const _plate = ValueKey('reader-figure-plate');

/// The most characters a line may average (the column is 33 x body size).
const _mostCharacters = 75;

/// Paragraphs written as the lessons are: plain words, capitals, commas.
// Each paragraph is one string split over lines, not several list items.
const _typical = [
  'A passage discusses how bees pollinate flowers, how this process helps '
      'plants reproduce, and how declining bee populations threaten global '
      'food supplies. Which title fits best? A good title is not too narrow '
      'and not too broad. It matches the main idea of the passage.',
  'Think of choosing a title as finding the "just right" fit: not too narrow '
      '(missing parts of the passage), not too broad (could apply to many '
      'different passages), but matching the main idea precisely. Read the '
      'whole passage first, then check each choice against it.',
  'The Pauli exclusion principle says no two electrons in one atom can have '
      'the same set of all four quantum numbers. Consequently, one orbital can '
      'hold at most two electrons, with opposite spin quantum numbers. This is '
      'a practical pattern, not a rule without exceptions.',
];
const _first = 'Earth has layers.';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late AppDatabase db;
  late AppPreferencesRepository prefs;

  setUp(() {
    db = inMemoryDatabase();
    prefs = AppPreferencesRepository(db);
    addTearDown(db.close);
  });

  Future<void> pump(
    WidgetTester tester,
    double width,
    List<Map<String, Object?>> body, {
    double height = 900,
    String? saved,
  }) async {
    if (saved != null) await prefs.setDeviceValue('reader_full_width', saved);
    tester.view
      ..physicalSize = Size(width, height)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final scroll = ScrollController();
    final offset = ValueNotifier<double>(0);
    final progress = ValueNotifier<double>(0);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: WebReaderLayout(
              reader: readerFor('w-$width', body),
              controller: scroll,
              scrollOffset: offset,
              progress: progress,
              onBack: () {},
              onBookmark: () {},
              onLesson: (_) {},
              footer: const SizedBox(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The size a paragraph is drawn at, after every scaler.
  double bodySize(WidgetTester tester, String text) {
    final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
    return paragraph.textScaler.scale(paragraph.text.style!.fontSize!);
  }

  List<Map<String, Object?>> text() =>
      [paragraph(_first), paragraph('Rain falls.')];

  group('column width and body size follow the window', () {
    const cases = <(double, double, double)>[
      (1024, 660, 20),
      (1280, 704, 21.3333),
      (1440, 792, 24),
      (1728, 825, 25),
    ];
    for (final (width, column, size) in cases) {
      testWidgets('$width px: $column px column, $size px text', (
        tester,
      ) async {
        await pump(tester, width, text());
        expect(tester.getSize(find.byKey(_column)).width, closeTo(column, .01));
        expect(bodySize(tester, _first), closeTo(size, .01));
      });
    }

    testWidgets('full width off at 1440: 680 px column, 18 px text', (
      tester,
    ) async {
      await pump(tester, 1440, text(), saved: '0');
      expect(tester.getSize(find.byKey(_column)).width, 680);
      expect(bodySize(tester, _first), closeTo(18, .01));
    });

    testWidgets('every type size scales by body size over 18', (tester) async {
      final body = [
        heading('Core Concept', 'h2'),
        heading('A small heading', 'h3'),
        paragraph(_first),
        heading('Take note of this', 'blockquote'),
        {
          '_type': 'block',
          'style': 'normal',
          'listItem': 'bullet',
          'level': 1,
          'children': [
            {'_type': 'span', 'text': 'A list line'},
          ],
        },
      ];
      const texts = [
        'Age Word Problems',
        'Core Concept',
        'A small heading',
        _first,
        'Take note of this',
        'A list line',
      ];
      Future<List<double>> sizes({String? saved}) async {
        await tester.pumpWidget(const SizedBox());
        await pump(tester, 1440, body, saved: saved);
        return [
          for (final t in texts)
            () {
              final p = tester.renderObject<RenderParagraph>(
                find.descendant(
                  of: find.byKey(_column),
                  matching: find.text(t),
                ),
              );
              return p.textScaler.scale(p.text.style!.fontSize!);
            }(),
        ];
      }

      final on = await sizes();
      final off = await sizes(saved: '0');
      for (var i = 0; i < texts.length; i++) {
        expect(on[i], closeTo(off[i] * 24 / 18, .01), reason: texts[i]);
      }
    });
  });

  testWidgets('real Geist: 60 to 75 characters a line at 1280, 1440 and 1728', (
    tester,
  ) async {
    await tester.runAsync(loadGoldenFonts);
    for (final width in [1280.0, 1440.0, 1728.0]) {
      await pump(tester, width, [for (final p in _typical) paragraph(p)]);
      final full = <int>[];
      for (final text in _typical) {
        final rendered = tester.renderObject<RenderParagraph>(find.text(text));
        final painter = TextPainter(
          text: rendered.text,
          textDirection: TextDirection.ltr,
          textScaler: rendered.textScaler,
        )..layout(maxWidth: rendered.size.width);
        addTearDown(painter.dispose);
        final lengths = <int>[];
        var at = 0;
        while (at < text.length) {
          final line = painter.getLineBoundary(TextPosition(offset: at));
          if (line.end <= at) break;
          lengths.add(line.end - line.start);
          at = line.end;
        }
        // The last line of a paragraph is short by nature.
        full.addAll(lengths.take(lengths.length - 1));
      }
      expect(full.length, greaterThan(4), reason: '$width px');
      final mean = full.reduce((a, b) => a + b) / full.length;
      expect(
        mean,
        inInclusiveRange(60, _mostCharacters),
        reason: '$width px gave $mean characters a line',
      );
    }
  });

  group('figures sit inline in the one column', () {
    List<Map<String, Object?>> withFigures() => [
          paragraph('Anna is twice as old as Ben.'),
          pictureBlock(pictureUri(360, 208)),
          paragraph('Their ages add up to 36 years.'),
          pictureBlock(pictureUri(300, 300)),
          paragraph('So Ben is 12.'),
        ];

    testWidgets('every figure is in the text column at the column width', (
      tester,
    ) async {
      await pump(tester, 1440, withFigures());
      final column = find.byKey(_column);
      final frames = find.byKey(_frame);
      expect(frames, findsNWidgets(2));
      expect(find.byKey(_plate), findsNothing);
      final columnRect = tester.getRect(column);
      for (var i = 0; i < 2; i++) {
        final rect = tester.getRect(frames.at(i));
        expect(rect.width, columnRect.width);
        expect(rect.left, columnRect.left);
        expect(rect.right, lessThanOrEqualTo(columnRect.right));
      }
      expect(
        find.descendant(of: column, matching: frames),
        findsNWidgets(2),
      );
    });

    testWidgets('a figure follows the paragraph that introduces it', (
      tester,
    ) async {
      await pump(tester, 1440, withFigures());
      final intro = tester.getRect(find.text('Anna is twice as old as Ben.'));
      final figure = tester.getRect(find.byKey(_frame).first);
      final next = tester.getRect(find.text('Their ages add up to 36 years.'));
      expect(figure.top, greaterThan(intro.bottom - 1));
      expect(next.top, greaterThan(figure.bottom - 1));
    });

    testWidgets('a tall figure stops at 65% of the window height', (
      tester,
    ) async {
      await pump(
        tester,
        1440,
        [
          paragraph('A tall picture.'),
          pictureBlock(pictureUri(300, 1200)),
          paragraph('After it.'),
        ],
      );
      final rect = tester.getRect(find.byKey(_frame));
      expect(rect.height, lessThanOrEqualTo(900 * .65 + .01));
      expect(rect.width, tester.getSize(find.byKey(_column)).width);
      // The picture is centered when the cap applies.
      final picture = tester.getRect(
        find.descendant(
          of: find.byKey(_frame),
          matching: find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_FittedFigure',
          ),
        ),
      );
      expect(picture.center.dx, closeTo(rect.center.dx, 1));
      expect(picture.height, lessThan(rect.height));
    });

    testWidgets('a short figure is not stretched by the cap', (tester) async {
      await pump(tester, 1440, withFigures());
      expect(
        tester.getSize(find.byKey(_frame).first).height,
        lessThan(900 * .65),
      );
    });
  });

  group('the default is on, a saved choice wins', () {
    testWidgets('a text-only lesson opens at full width', (tester) async {
      await pump(tester, 1440, text());
      expect(tester.getSize(find.byKey(_column)).width, 792);
      expect(find.byTooltip('Standard width'), findsOneWidget);
    });

    testWidgets('a lesson with figures opens at full width', (tester) async {
      await pump(tester, 1440, [
        paragraph(_first),
        pictureBlock(pictureUri(360, 208)),
      ]);
      expect(tester.getSize(find.byKey(_column)).width, 792);
    });

    testWidgets('a saved off wins for a text-only lesson', (tester) async {
      await pump(tester, 1440, text(), saved: '0');
      expect(tester.getSize(find.byKey(_column)).width, 680);
      expect(find.byTooltip('Full width'), findsOneWidget);
    });

    testWidgets('a saved off wins for a lesson with figures', (tester) async {
      await pump(
        tester,
        1440,
        [paragraph(_first), pictureBlock(pictureUri(360, 208))],
        saved: '0',
      );
      expect(tester.getSize(find.byKey(_column)).width, 680);
      expect(
        tester.getSize(find.byKey(_frame)).width,
        tester.getSize(find.byKey(_column)).width,
      );
    });
  });
}
