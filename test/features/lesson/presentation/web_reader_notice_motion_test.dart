import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../core/ui/motion/preview_curves.dart';
import '../../../helpers/in_memory_database.dart';

// The wide reader's "Bookmarked" toast and "Picked up where you left off"
// banner move as the phone's toast does: 250 ms in, 300 ms out, houseOut, with
// a 12 px rise.
const _first = StudyLesson(
  id: 'l1',
  title: 'Layers',
  estimatedMinutes: 11,
  isRead: true,
  isBookmarked: false,
);

ReaderContext _reader({required bool bookmarked}) => ReaderContext(
      lesson: const Lesson(
        id: 'l1',
        topicId: 't1',
        title: 'Layers',
        summary: '',
        estimatedMinutes: 11,
        bodyJson: [
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {'text': 'Earth has several layers.'},
            ],
          },
        ],
      ),
      topicId: 't1',
      topicName: 'Earth Science',
      next: null,
      positionInTopic: 1,
      lessonsInTopic: 1,
      topicLessons: const [_first],
      isRead: true,
      isBookmarked: bookmarked,
      examId: 'e',
    );

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late ScrollController scroll;
  late ValueNotifier<double> offset;
  late ValueNotifier<double> progress;
  late AppDatabase db;

  Future<void> pump(
    WidgetTester tester, {
    bool bookmarked = false,
    bool resumed = false,
    bool reduced = false,
  }) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Scaffold(
            body: WebReaderLayout(
              reader: _reader(bookmarked: bookmarked),
              controller: scroll,
              scrollOffset: offset,
              progress: progress,
              onBack: () {},
              onBookmark: () {},
              onLesson: (_) {},
              footer: const SizedBox(),
              resumed: resumed,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  setUp(() {
    scroll = ScrollController();
    offset = ValueNotifier<double>(0);
    progress = ValueNotifier<double>(0);
    db = inMemoryDatabase();
  });
  tearDown(() {
    unawaited(db.close());
    scroll.dispose();
    offset.dispose();
    progress.dispose();
  });

  Finder toast() => find.text('Bookmarked');
  double opacityOf(WidgetTester tester, Finder text) => tester
      .widget<Opacity>(
        find.ancestor(of: text, matching: find.byType(Opacity)).first,
      )
      .opacity;

  testWidgets('the Bookmarked toast fades in, then fades out and leaves',
      (tester) async {
    await pump(tester);
    expect(toast(), findsNothing);
    await pump(tester, bookmarked: true);
    await tester.pump(const Duration(milliseconds: 125));
    final mid = opacityOf(tester, toast());
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    expect(mid, closeTo(previewBezier(.3, .9, .3, 1, 125 / 250), .03));
    await tester.pump(const Duration(milliseconds: 125));
    expect(opacityOf(tester, toast()), 1);
    // The toast shows for 3 s, then leaves over 300 ms and is removed.
    await tester.pump(const Duration(milliseconds: 2750));
    await tester.pump(const Duration(milliseconds: 150));
    final leaving = opacityOf(tester, toast());
    expect(leaving, greaterThan(0));
    expect(leaving, lessThan(1));
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();
    expect(toast(), findsNothing);
  });

  testWidgets('reduced motion shows and removes the toast at once',
      (tester) async {
    await pump(tester, reduced: true);
    await pump(tester, bookmarked: true, reduced: true);
    expect(opacityOf(tester, toast()), 1);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(toast(), findsNothing);
  });

  testWidgets('the resume banner fades in and rises, and leaves on Start Over',
      (tester) async {
    await pump(tester, resumed: true);
    const text = 'Picked up where you left off';
    expect(find.text(text), findsOneWidget);
    expect(opacityOf(tester, find.text(text)), 0);
    await tester.pump(const Duration(milliseconds: 100));
    final mid = opacityOf(tester, find.text(text));
    expect(mid, greaterThan(0));
    expect(mid, lessThan(1));
    final rise = tester
        .widget<Transform>(find.byKey(const ValueKey('web-reader-notice-rise')))
        .transform
        .getTranslation()
        .y;
    expect(rise, greaterThan(0));
    expect(rise, lessThan(12));
    await tester.pump(const Duration(milliseconds: 160));
    expect(opacityOf(tester, find.text(text)), 1);
    await tester.tap(find.text('Start Over'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final leaving = opacityOf(tester, find.text(text));
    expect(leaving, greaterThan(0));
    expect(leaving, lessThan(1));
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();
    expect(find.text(text), findsNothing);
  });

  testWidgets('reduced motion shows and removes the banner at once',
      (tester) async {
    await pump(tester, resumed: true, reduced: true);
    const text = 'Picked up where you left off';
    expect(opacityOf(tester, find.text(text)), 1);
    await tester.tap(find.text('Start Over'));
    await tester.pump();
    expect(find.text(text), findsNothing);
  });

  testWidgets('bookmarking swaps the banner for the toast, banner fading out',
      (tester) async {
    await pump(tester, resumed: true);
    await tester.pump(const Duration(milliseconds: 300));
    await pump(tester, resumed: true, bookmarked: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Picked up where you left off'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();
    expect(find.text('Picked up where you left off'), findsNothing);
    expect(toast(), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
