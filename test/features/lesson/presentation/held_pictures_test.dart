// Pictures (SVG illustrations and lesson image blocks) follow the painter
// figures in the held reader: the figure column, the plate, the example's
// plate, and wide art inline (spec "4 Held", rules 6 and 7).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/held_reader.dart';
import 'package:pantas/core/ui/components/lesson_svg.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/held_picture_fixtures.dart';
import '../../../helpers/in_memory_database.dart';

const _plate = ValueKey('reader-figure-plate');

Future<void> _pump(
  WidgetTester tester,
  double width,
  List<Map<String, Object?>> body,
) async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final scroll = ScrollController();
  final offset = ValueNotifier<double>(0);
  final progress = ValueNotifier<double>(0);
  addTearDown(scroll.dispose);
  addTearDown(offset.dispose);
  addTearDown(progress.dispose);
  scroll.addListener(() => offset.value = scroll.offset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: WebReaderLayout(
            reader: readerFor('pictures-$width', body),
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

/// The picture that draws the plate: an SVG picture builds its own frame.
Finder _pictureOfPlate() => find.ancestor(
      of: find.byKey(_plate),
      matching: find.byType(SvgPicture),
    );

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  group('lessonHasMarginFigures', () {
    test('is true when the only figure is a picture 360x208', () {
      expect(
        lessonHasMarginFigures([
          paragraph('Text.'),
          pictureBlock(pictureUri(360, 208)),
        ]),
        isTrue,
      );
    });

    test('reads the size from width and height when there is no viewBox', () {
      expect(
        lessonHasMarginFigures([
          pictureBlock(pictureUri(360, 208, viewBox: false)),
        ]),
        isTrue,
      );
    });

    test('is false for a picture wider than 1.8 to 1', () {
      expect(
        lessonHasMarginFigures([pictureBlock(pictureUri(400, 150))]),
        isFalse,
      );
      expect(
        lessonHasMarginFigures([pictureBlock(pictureUri(361, 200))]),
        isFalse,
      );
      expect(
        lessonHasMarginFigures([pictureBlock(pictureUri(360, 200))]),
        isTrue,
      );
    });

    test('is false for a picture that cannot be read', () {
      expect(
        lessonHasMarginFigures([
          pictureBlock('data:image/svg+xml;base64,@@@'),
          pictureBlock(pictureUri(360, 208, sized: false)),
          pictureBlock('https://example.com/a.svg'),
          pictureBlock(''),
        ]),
        isFalse,
      );
    });
  });

  for (final (width, textRight, column) in [
    (1440.0, 172.0 + 640, 172.0 + 640 + 56),
    (1100.0, 76.0 + 600, 76.0 + 600 + 48),
  ]) {
    testWidgets('$width: a paragraph picture sits in the figure column',
        (tester) async {
      await _pump(tester, width, agePicturesLesson());
      expect(find.byType(HeldReader), findsOneWidget);
      final plate = tester.getRect(find.byKey(_plate));
      expect(_pictureOfPlate(), findsOneWidget);
      expect(plate.left, column);
      final paragraph =
          tester.getRect(find.textContaining('Anna is twice').first);
      expect(paragraph.right, lessThanOrEqualTo(textRight));
      // Level with its paragraph, as a painter figure is.
      expect((plate.top - paragraph.top).abs(), lessThan(24));
      // The walk-through parts after it are still in the text column.
      final why = tester.getRect(
        find.byKey(const ValueKey('walk-why-button')).first,
      );
      expect(why.right, lessThanOrEqualTo(textRight));
    });
  }

  testWidgets('an example whose problem has a picture gets it as its plate',
      (tester) async {
    await _pump(tester, 1440, [
      heading('Worked Examples', 'h2'),
      heading('Example 1', 'h3'),
      paragraph('Anna is twice as old as Ben.'),
      pictureBlock(pictureUri(360, 208)),
      paragraph('Solution:'),
      paragraph('Ben is 12.'),
    ]);
    expect(find.byType(HeldReader), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(_pictureOfPlate(), findsOneWidget);
    // Not left in the card as well.
    expect(find.byKey(const ValueKey('reader-figure-frame')), findsNothing);
    expect(tester.getRect(find.byKey(_plate)).left, 172 + 640 + 56);
  });

  testWidgets('a wide picture stays inline at the full text width',
      (tester) async {
    await _pump(tester, 1440, [
      paragraph('First.'),
      pictureBlock(pictureUri(360, 208)),
      paragraph('Second.'),
      pictureBlock(pictureUri(400, 150)),
      paragraph('Third.'),
    ]);
    expect(find.byKey(_plate), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(2));
    final frame = tester.getRect(
      find.byKey(const ValueKey('reader-figure-frame')),
    );
    expect(frame.left, 172);
    expect(frame.width, 640);
  });

  testWidgets('a picture that cannot be read stays inline', (tester) async {
    await _pump(tester, 1440, [
      paragraph('First.'),
      pictureBlock(pictureUri(360, 208)),
      paragraph('Second.'),
      pictureBlock('data:image/svg+xml;base64,@@@'),
      paragraph('Third.'),
    ]);
    expect(find.byKey(_plate), findsOneWidget);
    final failure = tester.getRect(
      find.byKey(const ValueKey('reader-image-failure')),
    );
    expect(failure.left, 172);
    expect(failure.width, 640);
  });

  testWidgets('a picture with no size in its markup stays inline',
      (tester) async {
    await _pump(tester, 1440, [
      paragraph('First.'),
      pictureBlock(pictureUri(360, 208)),
      paragraph('Second.'),
      pictureBlock(pictureUri(360, 208, sized: false)),
      paragraph('Third.'),
    ]);
    expect(find.byKey(_plate), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(2));
    // One in the figure column, one in the text.
    final lefts = [
      for (final e in find.byType(SvgPicture).evaluate())
        tester.getRect(find.byWidget(e.widget)).left,
    ]..sort();
    expect(lefts.first, lessThan(172 + 640));
    expect(lefts.last, greaterThanOrEqualTo(172 + 640 + 56));
  });

  testWidgets('a lesson with only a wide picture keeps the centered column',
      (tester) async {
    await _pump(tester, 1440, [
      paragraph('First.'),
      pictureBlock(pictureUri(400, 150)),
    ]);
    expect(find.byType(HeldReader), findsNothing);
    expect(find.byKey(const ValueKey('web-reader-column')), findsOneWidget);
  });

  test('the size is kept per URL and a URL past the bound still reads', () {
    final first = pictureUri(360, 208);
    expect(lessonSvgRatio(first), closeTo(360 / 208, 1e-9));
    expect(lessonSvgRatio(first), closeTo(360 / 208, 1e-9));
    // More than 64 other URLs push the first one out; it reads again.
    for (var i = 0; i < 70; i++) {
      expect(lessonSvgRatio(pictureUri(100.0 + i, 50)), isNotNull);
    }
    expect(lessonSvgRatio(first), closeTo(360 / 208, 1e-9));
    expect(lessonSvgRatio('data:image/svg+xml;base64,@@@'), isNull);
    expect(lessonSvgRatio('data:image/svg+xml;base64,@@@'), isNull);
  });

  testWidgets(
      'a picture in an example solution takes the plate and shows when '
      'the solution opens', (tester) async {
    await _pump(tester, 1440, [
      heading('Worked Examples', 'h2'),
      heading('Example 1', 'h3'),
      paragraph('Anna is twice as old as Ben.'),
      paragraph('Solution:'),
      paragraph('Ben is 12.'),
      pictureBlock(pictureUri(360, 208)),
    ]);
    // In the figure column, not in the card.
    expect(find.byKey(_plate), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byKey(const ValueKey('reader-figure-frame')), findsNothing);
    expect(tester.getRect(find.byKey(_plate)).left, 172 + 640 + 56);
    double opacity() => tester
        .widget<AnimatedOpacity>(
          find
              .ancestor(
                of: find.byKey(_plate),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        )
        .opacity;
    // The plate starts on the problem, which has no figure here, so the
    // solution's picture is hidden until the solution opens.
    expect(opacity(), 0);
    await tester.tap(find.byKey(const ValueKey('reader-solution-button')));
    await tester.pumpAndSettle();
    expect(opacity(), 1);
  });

  testWidgets(
      'walk-through: a picture after a Why? and a pair goes to the column '
      'and the parts render as before', (tester) async {
    final blocks = lessonBlocksFromMarkdown(r'''
## Core Concept

### Ages Today

Anna is twice as old as Ben.

:::why
Why call Ben's age $x$? Then Anna is $2x$.
:::

:::pair #age-sum
Right: $x + 2x = 36$
Wrong: $x + 2 = 36$
Anna is twice Ben, so her age is $2x$.
:::

Check the sum of both ages.

One more line about the ages.

Another line about the ages, so the passage is long enough for the plate.

A third line about the ages.

A fourth line about the ages.

A fifth line about the ages.

A last line about the ages.
''');
    final at = blocks.indexWhere(
      (b) => b.toString().contains('Check the sum'),
    );
    await _pump(tester, 1440, [
      ...blocks.sublist(0, at + 1),
      pictureBlock(pictureUri(360, 208)),
      ...blocks.sublist(at + 1),
    ]);
    expect(find.byType(HeldReader), findsOneWidget);
    final plate = tester.getRect(find.byKey(_plate));
    expect(plate.left, 172 + 640 + 56);
    final paragraph =
        tester.getRect(find.textContaining('Check the sum').first);
    expect((plate.top - paragraph.top).abs(), lessThan(24));
    // The parts are in the text column, as before.
    expect(find.byKey(const ValueKey('walk-pair-right')), findsOneWidget);
    expect(find.byKey(const ValueKey('walk-pair-wrong')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const ValueKey('walk-pair-right'))).right,
      lessThanOrEqualTo(172 + 640),
    );
    final why = find.byKey(const ValueKey('walk-why-button'));
    expect(why, findsOneWidget);
    expect(find.byKey(const ValueKey('walk-why-panel')), findsNothing);
    await tester.tap(why);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('walk-why-panel')), findsOneWidget);
  });

  // A picture cannot be authored inside a Why? panel: the walk-through parser
  // refuses a figure or illustration marker inside a :::why block (see
  // walkthrough_markdown.dart), so there is no panel picture to place.

  testWidgets('390: the picture stays inline in the text', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugWebPlatformOverride = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ContentRenderer(
              blocks: agePicturesLesson(),
              readerFigures: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(_plate), findsNothing);
    expect(find.byKey(const ValueKey('reader-figure-frame')), findsOneWidget);
    final frame = tester.getRect(
      find.byKey(const ValueKey('reader-figure-frame')),
    );
    expect(frame.left, 24);
    expect(frame.width, 342);
  });
}
