import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

Map<String, Object?> _block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'text': text},
      ],
    };

ReaderContext _reader({required int sections}) => ReaderContext(
      lesson: Lesson(
        id: 'l1',
        topicId: 't1',
        title: 'Layers',
        summary: '',
        estimatedMinutes: 11,
        bodyJson: [
          for (var i = 0; i < sections; i++) ...[
            _block('Section $i', style: 'h2'),
            for (var p = 0; p < 6; p++)
              _block('Paragraph $p of section $i, long enough to be read.'),
          ],
        ],
      ),
      topicId: 't1',
      topicName: 'Earth Science',
      next: null,
      positionInTopic: 1,
      lessonsInTopic: 2,
      topicLessons: const [],
      isRead: false,
      isBookmarked: false,
      examId: 'e',
    );

/// 5R-3: the wheel moves the lesson wherever the pointer is on the page.
void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late AppDatabase db;
  late ScrollController scroll;
  late ValueNotifier<double> offset;
  late ValueNotifier<double> progress;

  setUp(() {
    db = inMemoryDatabase();
    addTearDown(db.close);
    scroll = ScrollController();
    offset = ValueNotifier<double>(0);
    progress = ValueNotifier<double>(0);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
  });

  Future<void> pump(
    WidgetTester tester, {
    int sections = 4,
    double width = 1440,
  }) async {
    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildDarkTheme(web: true),
          home: Scaffold(
            body: WebReaderLayout(
              reader: _reader(sections: sections),
              controller: scroll,
              scrollOffset: offset,
              progress: progress,
              onBack: () {},
              onBookmark: () {},
              onLesson: (_) {},
              footer: const SizedBox(height: 100),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> wheelAt(WidgetTester tester, double x, {double dy = 120}) async {
    await tester.sendEventToBinding(
      PointerScrollEvent(position: Offset(x, 450), scrollDelta: Offset(0, dy)),
    );
    await tester.pump();
  }

  for (final x in [720.0, 100.0, 40.0, 1300.0, 1430.0]) {
    testWidgets('the wheel at x=$x scrolls the lesson', (tester) async {
      await pump(tester);
      expect(scroll.position.maxScrollExtent, greaterThan(500));
      expect(scroll.offset, 0);
      await wheelAt(tester, x);
      expect(scroll.offset, 120, reason: 'one notch moves the lesson');
      await wheelAt(tester, x, dy: -120);
      expect(scroll.offset, 0);
    });
  }

  testWidgets('the wheel over the outline itself scrolls the lesson',
      (tester) async {
    await pump(tester);
    final box =
        tester.getRect(find.byKey(const ValueKey('web-reader-outline')));
    expect(box.left, greaterThan(0));
    await wheelAt(tester, box.center.dx);
    expect(scroll.offset, 120);
  });

  testWidgets('the wheel over the top bar scrolls the lesson too',
      (tester) async {
    await pump(tester);
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(720, 20),
        scrollDelta: Offset(0, 120),
      ),
    );
    await tester.pump();
    expect(scroll.offset, 120);
  });

  testWidgets('a sideways scroll over a margin does not move the lesson',
      (tester) async {
    await pump(tester);
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(100, 450),
        scrollDelta: Offset(120, 10),
      ),
    );
    await tester.pump();
    expect(scroll.offset, 0);
  });

  testWidgets('an outline that scrolls keeps the wheel for itself',
      (tester) async {
    // Forty sections make an outline taller than the window.
    await pump(tester, sections: 40);
    final outline = find.descendant(
      of: find.byKey(const ValueKey('web-reader-outline')),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(outline).position;
    expect(position.maxScrollExtent, greaterThan(0));
    final box =
        tester.getRect(find.byKey(const ValueKey('web-reader-outline')));
    await wheelAt(tester, box.center.dx);
    expect(position.pixels, 120, reason: 'the outline scrolls itself');
    expect(scroll.offset, 0, reason: 'and the lesson stays');
    // Over the right margin there is no outline: the lesson moves.
    await wheelAt(tester, 1300);
    expect(scroll.offset, 120);
    expect(position.pixels, 120);
  });
}
