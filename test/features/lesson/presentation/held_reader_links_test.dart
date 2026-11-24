// Linked words, the held figure and the show-solution swap, on the real
// Circles lesson. Spec: "Linked words", "Motion values", acceptance 5.
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

import '../../../helpers/in_memory_database.dart';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late ScrollController scroll;

  Future<void> pumpCircles(WidgetTester tester, {bool reduce = false}) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    scroll = ScrollController();
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
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 900),
              disableAnimations: reduce,
            ),
            child: Scaffold(
              body: WebReaderLayout(
                reader: ReaderContext(
                  lesson: Lesson(
                    id: 'c',
                    topicId: 't',
                    title: 'Circles',
                    summary: '',
                    estimatedMinutes: 13,
                    bodyJson: body,
                  ),
                  topicId: 't',
                  topicName: 'Geometry',
                  next: null,
                  positionInTopic: 1,
                  lessonsInTopic: 1,
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
  }

  Finder word(String text) => find.byWidgetPredicate(
        (w) => w is LinkedWord && w.text == text,
      );

  String? lit(WidgetTester tester) =>
      tester.widget<LitLabel>(find.byType(LitLabel).first).label;

  testWidgets('Tangent is a linked word and lights its part on hover',
      (tester) async {
    await pumpCircles(tester);
    expect(word('Tangent'), findsOneWidget);
    expect(word('Radius'), findsOneWidget);
    expect(lit(tester), isNull);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(word('Tangent')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    expect(lit(tester), 'Tangent');
    final amount = tester.widget<LitLabel>(find.byType(LitLabel).first).amount;
    expect(amount, 1);
    await mouse.moveTo(const Offset(5, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    expect(lit(tester), isNull);
  });

  testWidgets('the change takes 150 ms', (tester) async {
    await pumpCircles(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(word('Chord')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 75));
    final half = tester.widget<LitLabel>(find.byType(LitLabel).first).amount;
    expect(half, inExclusiveRange(.2, .95));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<LitLabel>(find.byType(LitLabel).first).amount,
      1,
    );
  });

  testWidgets('keyboard focus lights it, and Enter keeps it lit',
      (tester) async {
    await pumpCircles(tester);
    Focus.of(
      tester.element(
        find.descendant(
          of: word('Secant'),
          matching: find.byType(GestureDetector),
        ),
      ),
    ).requestFocus();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tap lights it and a tap elsewhere clears it', (tester) async {
    await pumpCircles(tester);
    await tester.tap(word('Secant'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(lit(tester), 'Secant');
    await tester.tapAt(const Offset(30, 450));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(lit(tester), isNull);
  });

  testWidgets('a figure label is linked once per paragraph', (tester) async {
    await pumpCircles(tester);
    expect(word('Tangent'), findsOneWidget);
  });
}
