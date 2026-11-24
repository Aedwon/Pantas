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
import 'package:pantas/core/ui/figures/geometry_diagram_figure.dart';
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
    expect(half, inExclusiveRange(.2, 1));
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

  testWidgets('a plate is 288 px tall: a 260 px figure and 14 px each side',
      (tester) async {
    await pumpCircles(tester);
    final plate = find.byKey(const ValueKey('reader-figure-plate')).first;
    expect(tester.getSize(plate).height, 288);
    expect(tester.getSize(plate).width, 400);
    final figure = tester.getRect(find.byType(GeometryDiagramFigure).first);
    expect(figure.height, 260);
    expect(figure.top - tester.getTopLeft(plate).dy, 14);
  });

  testWidgets('a circle is 190 px across, as the board draws it',
      (tester) async {
    await pumpCircles(tester);
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(GeometryDiagramFigure).first,
            matching: find.byType(CustomPaint),
          ),
        )
        .painter!;
    expect(
      GeometryDiagramFigure.circleDiameter(
        const Size(360, 260),
        inPlate: true,
      ),
      190,
    );
    expect(painter, isNotNull);
  });

  testWidgets('pointing at a label in the figure underlines its words',
      (tester) async {
    await pumpCircles(tester);
    final state = tester.state<GeometryDiagramFigureState>(
      find.byType(GeometryDiagramFigure).first,
    );
    final index = state.labelRects.keys.firstWhere((l) => l == 'Tangent');
    final spot = tester.getTopLeft(find.byType(GeometryDiagramFigure).first) +
        state.labelRects[index]!.center;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(spot);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(lit(tester), 'Tangent');
    final underline = tester
        .widget<CustomPaint>(
          find.descendant(
            of: word('Tangent'),
            matching: find.byType(CustomPaint),
          ),
        )
        .foregroundPainter! as LinkUnderline;
    expect(underline.solid, isTrue);
    await mouse.moveTo(const Offset(5, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(lit(tester), isNull);
  });

  testWidgets('Show solution: the new mark draws in after the figure arrives',
      (tester) async {
    await pumpCircles(tester);
    final card = find.byKey(const ValueKey('reader-example-4'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();
    NewMarks marks() => tester
        .widgetList<NewMarks>(find.byType(NewMarks))
        .firstWhere((m) => m.labels.isNotEmpty);
    expect(marks().amount, 0);
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('reader-solution-button')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(marks().amount, 0, reason: 'the figure is still arriving');
    await tester.pump(const Duration(milliseconds: 380));
    expect(marks().amount, inExclusiveRange(0, 1.01));
    await tester.pump(const Duration(milliseconds: 300));
    expect(marks().amount, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('no label of a plate figure sits on another', (tester) async {
    await pumpCircles(tester);
    final states = tester
        .stateList<GeometryDiagramFigureState>(
          find.byType(GeometryDiagramFigure),
        )
        .toList();
    expect(states.length, greaterThan(4));
    for (final state in states) {
      final rects = state.labelRects.values.toList();
      for (var i = 0; i < rects.length; i++) {
        expect(
          const Rect.fromLTWH(0, 0, 360, 260).contains(rects[i].topLeft) &&
              const Rect.fromLTWH(0, 0, 360, 260)
                  .contains(rects[i].bottomRight),
          isTrue,
          reason:
              'label ${state.labelRects.keys.elementAt(i)} is off the plate',
        );
        for (var j = i + 1; j < rects.length; j++) {
          expect(
            rects[i].overlaps(rects[j]),
            isFalse,
            reason: '${state.labelRects.keys.elementAt(i)} overlaps '
                '${state.labelRects.keys.elementAt(j)}',
          );
        }
      }
    }
  });

  group('Example 4 (ruling 6)', () {
    Finder card() => find.byKey(const ValueKey('reader-example-4'));
    Set<String> linked(WidgetTester tester) => {
          for (final w in tester.widgetList<LinkedWord>(
            find.descendant(
              of: card(),
              matching: find.byWidgetPredicate((w) => w is LinkedWord),
            ),
          ))
            w.label,
        };

    Future<void> openSolution(WidgetTester tester) async {
      await tester.ensureVisible(card());
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: card(),
          matching: find.byKey(const ValueKey('reader-solution-button')),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('with the solution closed only BC in the problem is linked',
        (tester) async {
      await pumpCircles(tester);
      await tester.ensureVisible(card());
      await tester.pumpAndSettle();
      expect(linked(tester), {'BC'});
    });

    testWidgets('with it open, AB in the first solution line lights AB',
        (tester) async {
      await pumpCircles(tester);
      await openSolution(tester);
      expect(linked(tester), containsAll(['BC', 'AB']));
      final ab = find.descendant(
        of: card(),
        matching: find.byWidgetPredicate(
          (w) => w is LinkedWord && w.label == 'AB',
        ),
      );
      expect(ab, findsOneWidget);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(ab));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      final lit = tester
          .widgetList<LitLabel>(find.byType(LitLabel))
          .where((l) => l.label != null)
          .toList();
      expect(lit.map((l) => l.label), contains('AB'));
    });

    testWidgets('"hypotenuse" is not a linked word', (tester) async {
      await pumpCircles(tester);
      await openSolution(tester);
      expect(
        find.byWidgetPredicate(
          (w) => w is LinkedWord && w.text == 'hypotenuse',
        ),
        findsNothing,
      );
    });
  });
}
