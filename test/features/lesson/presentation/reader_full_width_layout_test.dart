import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_skeletons.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

Map<String, Object?> _block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'text': text},
      ],
    };

final _reader = ReaderContext(
  lesson: Lesson(
    id: 'l1',
    topicId: 't1',
    title: 'Layers',
    summary: '',
    estimatedMinutes: 11,
    bodyJson: [
      _block('Core Concept', style: 'h2'),
      _block('Earth has several layers.'),
      {
        '_type': 'table',
        'semanticsLabel': 'Layers',
        'rows': [
          ['Layer', 'Depth'],
          ['Crust', '35 km'],
        ],
      },
      _block('Examples', style: 'h2'),
      _block('Traps to Watch For', style: 'h2'),
    ],
  ),
  topicId: 't1',
  topicName: 'Earth Science',
  next: null,
  positionInTopic: 1,
  lessonsInTopic: 1,
  topicLessons: const [],
  isRead: false,
  isBookmarked: false,
  examId: 'e',
);

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late AppDatabase db;
  late AppPreferencesRepository prefs;
  late ScrollController scroll;
  late ValueNotifier<double> offset;
  late ValueNotifier<double> progress;

  setUp(() async {
    db = inMemoryDatabase();
    prefs = AppPreferencesRepository(db);
    addTearDown(db.close);
    scroll = ScrollController();
    offset = ValueNotifier<double>(0);
    progress = ValueNotifier<double>(0);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
    // Aedwon's pick B, Nov 28: with no saved choice a text-only lesson starts
    // at the standard width, so these tests save nothing first.
  });

  Future<void> pump(WidgetTester tester, double width) async {
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
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: WebReaderLayout(
              reader: _reader,
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

  Finder semanticsOf(String label) => find.ancestor(
        of: find.byKey(const ValueKey('web-reader-width-control')),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == label,
        ),
      );

  final column = find.byKey(const ValueKey('web-reader-column'));
  final control = find.byKey(const ValueKey('web-reader-width-control'));

  testWidgets('the column stays 680 px until the student widens it', (
    tester,
  ) async {
    await pump(tester, 1920);
    expect(tester.getSize(column).width, 680);
    expect(find.byTooltip('Full width'), findsOneWidget);
    expect(find.byTooltip('Standard width'), findsNothing);
  });

  testWidgets('a button in the top bar toggles an 800 px column', (
    tester,
  ) async {
    await pump(tester, 1920);
    final bookmark = find.byTooltip('Bookmark this lesson (B)');
    expect(
      tester.getTopRight(control).dx,
      lessThanOrEqualTo(tester.getTopLeft(bookmark).dx),
    );
    expect(tester.getSize(control), const Size(44, 44));
    // The bar is the top 60 px of the reader.
    expect(tester.getRect(control).bottom, lessThanOrEqualTo(60));

    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(tester.getSize(column).width, 800);
    expect(find.byTooltip('Standard width'), findsOneWidget);

    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(tester.getSize(column).width, 680);
    expect(find.byTooltip('Full width'), findsOneWidget);
  });

  testWidgets('the control says whether full width is on', (tester) async {
    await pump(tester, 1920);
    final semantics = tester.ensureSemantics();
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(semanticsOf('Full width')),
      isSemantics(
        isButton: true,
        hasToggledState: true,
        isToggled: false,
        hasTapAction: true,
        label: 'Full width',
      ),
    );
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(semanticsOf('Standard width')),
      isSemantics(
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        label: 'Standard width',
      ),
    );
    semantics.dispose();
  });

  testWidgets('the choice is saved on this device', (tester) async {
    await pump(tester, 1920);
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(await prefs.deviceValue('reader_full_width'), '1');
  });

  testWidgets('a saved choice opens every lesson at full width', (
    tester,
  ) async {
    await prefs.setDeviceValue('reader_full_width', '1');
    await pump(tester, 1920);
    await tester.pumpAndSettle();
    expect(tester.getSize(column).width, 800);
    expect(find.byTooltip('Standard width'), findsOneWidget);
  });

  testWidgets('figures take the width of the wider column', (tester) async {
    await pump(tester, 1920);
    final frame = find.byKey(const ValueKey('reader-figure-frame'));
    expect(tester.getSize(frame).width, 680);
    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(tester.getSize(frame).width, 800);
    expect(tester.getSize(frame).width, tester.getSize(column).width);
  });

  testWidgets('the loading frame is as wide as the column it waits for', (
    tester,
  ) async {
    final content = openTestContentDatabase();
    await seedContentExam(
      content,
      examId: 'e',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
    );
    await SyncActiveContextStore(db).clearStable();
    await prefs.setDeviceValue('reader_full_width', '1');
    tester.view
      ..physicalSize = const Size(1920, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    final never = Completer<ReaderContext?>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
          readerContextProvider('l1').overrideWith((_) => never.future),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: const LessonPage(lessonId: 'l1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final skeleton = find.byType(ReaderSkeleton);
    expect(skeleton, findsOneWidget);
    expect(
      tester
          .getSize(
            find.ancestor(of: skeleton, matching: find.byType(SizedBox)).first,
          )
          .width,
      800,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the loading frame is 680 px with no saved choice', (
    tester,
  ) async {
    final content = openTestContentDatabase();
    await seedContentExam(
      content,
      examId: 'e',
      code: 'CSE',
      name: 'CSE',
      shortName: 'CSE',
    );
    await SyncActiveContextStore(db).clearStable();
    tester.view
      ..physicalSize = const Size(1920, 900)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    final never = Completer<ReaderContext?>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(content),
          appPreferencesRepositoryProvider.overrideWithValue(prefs),
          readerContextProvider('l1').overrideWith((_) => never.future),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: const LessonPage(lessonId: 'l1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final skeleton = find.byType(ReaderSkeleton);
    expect(skeleton, findsOneWidget);
    expect(
      tester
          .getSize(
            find.ancestor(of: skeleton, matching: find.byType(SizedBox)).first,
          )
          .width,
      680,
    );
    await tester.pumpWidget(const SizedBox());
  });

  group('a lesson with no figures is one centered column', () {
    for (final width in [
      1024.0,
      1100.0,
      1180.0,
      1279.0,
      1280.0,
      1440.0,
      1920.0,
      2560.0,
    ]) {
      testWidgets('at $width px wide', (tester) async {
        await pump(tester, width);
        // The left outline is gone at every width.
        expect(find.byKey(const ValueKey('web-reader-outline')), findsNothing);
        expect(find.text('IN THIS LESSON'), findsNothing);
        final standard = tester.getRect(column);
        expect(standard.width, 680);
        expect(standard.center.dx, closeTo(width / 2, .01));

        await tester.tap(control);
        await tester.pumpAndSettle();
        final full = tester.getRect(column);
        expect(full.width, greaterThanOrEqualTo(680));
        expect(full.width, lessThanOrEqualTo(800));
        expect(full.left, greaterThanOrEqualTo(56));
        expect(full.center.dx, closeTo(width / 2, .01));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
