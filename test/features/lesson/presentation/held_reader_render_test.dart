// Renders the held reader, on the real Circles lesson, to PNG sheets under
// build/held-sheets (not committed). One sheet for each state of the boards,
// light and dark, plus a short run of frames of a held figure during scroll.
//
//   flutter test --tags golden --run-skipped \
//     test/features/lesson/presentation/held_reader_render_test.dart
@Tags(['golden'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/figure_highlight.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../goldens/golden_harness.dart';
import '../../../helpers/in_memory_database.dart';

const _out = 'build/held-sheets';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await loadGoldenFonts();
    // The chevron and the bookmark are Material icons: without the font a
    // sheet draws them as hollow squares, which is the capture, not the app.
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    // Without the math fonts the formulas draw as boxes.
    for (final family in [
      'Main-Regular',
      'Main-Italic',
      'Main-Bold',
      'Math-Italic',
      'AMS-Regular',
      'Size1-Regular',
      'Size2-Regular',
      'Size3-Regular',
      'Size4-Regular',
    ]) {
      final name = family.split('-').first;
      final loader = FontLoader('packages/flutter_math_fork/KaTeX_$name')
        ..addFont(
          rootBundle.load(
            'packages/flutter_math_fork/lib/katex_fonts/fonts/KaTeX_$family.ttf',
          ),
        );
      await loader.load();
    }
  });
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  final boundary = GlobalKey();

  Future<ScrollController> pump(
    WidgetTester tester, {
    required double width,
    required Brightness brightness,
    double height = 900,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
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
    scroll.addListener(() => offset.value = scroll.offset);
    final source = File('content/lessons/mathematics/geometry/circles.md')
        .readAsStringSync();
    final body = lessonBlocksFromMarkdown(
      source.substring(
        RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(source)!.end,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: brightness == Brightness.dark
              ? buildDarkTheme(web: true)
              : buildLightTheme(web: true),
          home: RepaintBoundary(
            key: boundary,
            child: Scaffold(
              body: WebReaderLayout(
                reader: ReaderContext(
                  lesson: Lesson(
                    id: 'c',
                    topicId: 't',
                    title: 'Circles (Radii, Diameters, Chords, Tangents, '
                        'Secants, Arcs, Sectors)',
                    summary: '',
                    estimatedMinutes: 13,
                    bodyJson: body,
                  ),
                  topicId: 't',
                  topicName: 'Geometry',
                  next: null,
                  positionInTopic: 2,
                  lessonsInTopic: 8,
                  topicLessons: const [
                    StudyLesson(
                      id: 'c',
                      title: 'Circles',
                      isRead: false,
                      isBookmarked: false,
                    ),
                  ],
                  isRead: false,
                  isBookmarked: false,
                  examId: 'e',
                ),
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
      ),
    );
    await tester.pumpAndSettle();
    return scroll;
  }

  Future<void> save(WidgetTester tester, String name) async {
    final object = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundary),
    );
    final image = (await tester.runAsync(object.toImage))!;
    final bytes = (await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.png),
    ))!;
    await tester.runAsync(() async {
      final file = File('$_out/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes.buffer.asUint8List());
    });
  }

  Future<double> offsetOf(WidgetTester tester, String text) async {
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    return scroll.position.pixels + tester.getTopLeft(find.text(text).first).dy;
  }

  for (final brightness in [Brightness.light, Brightness.dark]) {
    final name = brightness == Brightness.light ? 'light' : 'dark';
    testWidgets('sheets $name', (tester) async {
      final scroll = await pump(
        tester,
        width: 1440,
        brightness: brightness,
      );
      await save(tester, '1440-$name-1-top');
      final ex = await offsetOf(tester, 'Example 1');
      scroll.jumpTo(ex - 140);
      await tester.pumpAndSettle();
      await save(tester, '1440-$name-2-example1-closed');
      final ex4 = await offsetOf(tester, 'Example 4');
      scroll.jumpTo(ex4 - 140);
      await tester.pumpAndSettle();
      final show = find.byKey(const ValueKey('reader-solution-button'));
      await tester.ensureVisible(show.last);
      await tester.tap(show.last);
      await tester.pumpAndSettle();
      await save(tester, '1440-$name-3-example4-open');
      scroll.jumpTo(scroll.offset + 420);
      await tester.pumpAndSettle();
      await save(tester, '1440-$name-4-reading-step');
      scroll.jumpTo(scroll.offset + 360);
      await tester.pumpAndSettle();
      await save(tester, '1440-$name-5-card-end-pushes');
      if (brightness == Brightness.light) {
        scroll.jumpTo(0);
        await tester.pumpAndSettle();
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        addTearDown(mouse.removePointer);
        await mouse.moveTo(
          tester.getCenter(
            find.byWidgetPredicate(
              (w) => w is LinkedWord && w.text == 'Tangent',
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await save(tester, '1440-$name-6-linked-word-tangent');
      }
    });
  }

  testWidgets('sheets 1100 and 1920', (tester) async {
    for (final width in [1100.0, 1920.0]) {
      await pump(tester, width: width, brightness: Brightness.light);
      await save(tester, '${width.round()}-light-1-top');
    }
  });

  testWidgets('frames of a held figure during scroll', (tester) async {
    final scroll = await pump(
      tester,
      width: 1440,
      brightness: Brightness.light,
    );
    final start = await offsetOf(tester, 'Core Concept');
    scroll.jumpTo(start);
    await tester.pumpAndSettle();
    for (var i = 0; i < 8; i++) {
      scroll.jumpTo(start + i * 70.0);
      await tester.pump();
      await save(tester, 'frames/frame-${i.toString().padLeft(2, '0')}');
    }
  });
}
