import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/paywall/paywall.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();

    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 's1',
      examId: 'e1',
      name: 'Science',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't1',
      subjectId: 's1',
      name: 'Chemistry',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l1',
      topicId: 't1',
      title: 'Lesson l1',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 10,
    );

    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('e1');
    await NotificationRationaleRepository(db).markShown();
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester, {bool readerFails = false}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          if (readerFails)
            readerContextProvider('l1')
                .overrideWith((_) => throw StateError('fixture')),
          entitlementProvider.overrideWith(
            (_) => Stream.value(const Entitlement.free()),
          ),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('/study with a topicId opens that topic', (tester) async {
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    container.read(routerProvider).go('/study?topicId=t1');
    await tester.pumpAndSettle();

    expect(find.text('Lesson l1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  });

  testWidgets('Home day extra drives the real reader counter and day rail',
      (tester) async {
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't1',
      title: 'Lesson l2',
      bodyJson: jsonEncode(<Map<String, Object?>>[]),
      estimatedMinutes: 10,
    );
    await pumpApp(tester);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(App)));
    container.read(routerProvider).go(
          '/lesson/l1?from=home',
          extra: LessonDayContext(
            date: DateTime(2026, 10, 14),
            lessonIds: const ['l1', 'l2'],
            index: 0,
          ),
        );
    await tester.pumpAndSettle();
    try {
      expect(find.text('1 of 2'), findsOneWidget);
      final fill = find.descendant(
        of: find.byType(ReaderRail),
        matching: find.byType(FractionallySizedBox),
      );
      expect(tester.widget<FractionallySizedBox>(fill).widthFactor, .5);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
      await tester.runAsync(db.close);
    }
  });

  Future<void> unmountReader(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
    await tester.runAsync(db.close);
  }

  for (final origin in ReaderOrigin.values) {
    testWidgets('deep-link ${origin.name} labels its actual fallback',
        (tester) async {
      await pumpApp(tester);
      final router = ProviderScope.containerOf(
        tester.element(find.byType(App)),
      ).read(routerProvider)
        ..go('/lesson/l1?from=${origin.name}');
      await tester.pumpAndSettle();
      try {
        expect(
          tester.widget<LessonPage>(find.byType(LessonPage)).origin,
          origin,
        );
        expect(router.canPop(), isFalse);
        final home = origin == ReaderOrigin.home ||
            origin == ReaderOrigin.plan ||
            origin == ReaderOrigin.performance;
        final label = home ? 'Home' : 'Study';
        expect(
          find.descendant(
            of: find.byType(ReaderBar),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(ReaderBar),
            matching: find.text(label),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          home ? '/home' : '/study',
        );
      } finally {
        await unmountReader(tester);
      }
    });
  }

  testWidgets('bookmark reader returns to the still-open bookmark sheet',
      (tester) async {
    await LessonBookmarksRepository(db).mark('l1');
    await pumpApp(tester);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    ).read(routerProvider)
      ..go('/study');
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.byType(BookmarksSheet), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(BookmarksSheet),
        matching: find.text('Lesson l1'),
      ),
    );
    await tester.pumpAndSettle();
    try {
      expect(find.byType(ReaderBar), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(BookmarksSheet), findsOneWidget);
      expect(tester.widget<PantasSheet>(find.byType(PantasSheet)).open, isTrue);
    } finally {
      await unmountReader(tester);
    }
  });

  testWidgets('missing reader names its real Home fallback', (tester) async {
    await pumpApp(tester);
    final router = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    ).read(routerProvider)
      ..go('/lesson/missing?from=performance');
    await tester.pumpAndSettle();
    try {
      expect(find.text('Lesson not found.'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/home');
    } finally {
      await unmountReader(tester);
    }
  });

  testWidgets('failed bookmark reader names and returns to its real origin',
      (tester) async {
    await LessonBookmarksRepository(db).mark('l1');
    await pumpApp(tester, readerFails: true);
    ProviderScope.containerOf(
      tester.element(find.byType(App)),
    ).read(routerProvider).go('/study');
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BookmarksSheet),
        matching: find.text('Lesson l1'),
      ),
    );
    await tester.pumpAndSettle();
    try {
      expect(find.text('Could not load this lesson.'), findsOneWidget);
      expect(find.text('Bookmarks'), findsOneWidget);
      await tester.tap(find.text('Bookmarks'));
      await tester.pumpAndSettle();
      expect(find.byType(BookmarksSheet), findsOneWidget);
      expect(tester.widget<PantasSheet>(find.byType(PantasSheet)).open, isTrue);
    } finally {
      await unmountReader(tester);
    }
  });

  testWidgets('topic Contents uses the shared reader sheet', (tester) async {
    await pumpApp(tester);
    ProviderScope.containerOf(
      tester.element(find.byType(App)),
    ).read(routerProvider).go('/lesson/l1?from=study');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ContentsGlyph));
    await tester.pumpAndSettle();
    try {
      expect(find.byType(PantasSheet), findsOneWidget);
      expect(
        tester.widget<PantasSheet>(find.byType(PantasSheet)).readerContents,
        isTrue,
      );
      expect(find.text('Chemistry'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
    } finally {
      await unmountReader(tester);
    }
  });

  testWidgets(
      'day Contents follows real cross-topic order and preserves context',
      (tester) async {
    await seedContentSubject(
      contentDb,
      subjectId: 's2',
      examId: 'e1',
      name: 'Biology',
    );
    await seedContentTopic(
      contentDb,
      topicId: 't2',
      subjectId: 's2',
      name: 'Cells',
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'l2',
      topicId: 't2',
      title: 'Lesson l2',
      bodyJson: '[]',
      estimatedMinutes: 12,
    );
    await pumpApp(tester);
    ProviderScope.containerOf(
      tester.element(find.byType(App)),
    ).read(routerProvider).go(
          '/lesson/l1?from=home',
          extra: LessonDayContext(
            date: DateTime.now(),
            lessonIds: const ['l2', 'l1'],
            index: 1,
          ),
        );
    await tester.pumpAndSettle();
    await tester.tap(find.text('2 of 2'));
    await tester.pumpAndSettle();
    try {
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Cells'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      final sheet = find.byKey(const ValueKey('lesson-contents'));
      expect(
        tester
            .getTopLeft(
              find.descendant(of: sheet, matching: find.text('Lesson l2')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.descendant(of: sheet, matching: find.text('Lesson l1')),
              )
              .dy,
        ),
      );
      await tester
          .tap(find.descendant(of: sheet, matching: find.text('Lesson l2')));
      await tester.pumpAndSettle();
      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(tester.widget<ReaderBar>(find.byType(ReaderBar)).lessonId, 'l2');
      expect(find.text('Reading'), findsNothing);
    } finally {
      await unmountReader(tester);
    }
  });

  testWidgets('/study/topic/t1 is no longer a route', (tester) async {
    await pumpApp(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(App)),
    );
    container.read(routerProvider).go('/study/topic/t1');
    await tester.pumpAndSettle();

    expect(find.textContaining('no routes for location'), findsOneWidget);
  });
}
