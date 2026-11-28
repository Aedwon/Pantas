import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';

// Aedwon's Nov 28 recording: on the wide Study map, hovering one topic row lit
// two rows, in a darker gray, and the light stayed after the pointer left.
// One row lights, in `surface-hover`, and it clears on exit.

StudyTopic _topic(String id) => StudyTopic(
      id: id,
      name: 'Topic $id',
      lessons: [
        StudyLesson(
          id: 'l$id',
          title: 'Lesson $id',
          isRead: false,
          isBookmarked: false,
        ),
      ],
      readCount: 0,
      hasBookmark: false,
    );

StudyMap _map() => StudyMap(
      examShortName: 'CSE',
      subjects: [
        StudySubject(
          id: 's1',
          name: 'Verbal Ability',
          topics: [_topic('a'), _topic('b'), _topic('c'), _topic('d')],
        ),
        StudySubject(
          id: 's2',
          name: 'Numerical Ability',
          topics: [_topic('e'), _topic('f')],
        ),
      ],
      readCount: 0,
      totalCount: 6,
    );

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pump(WidgetTester tester, {String? open}) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: WebStudyMap(
              map: _map(),
              openTopicId: open,
              onTopic: (_) {},
              onBookmark: (_) {},
              onLesson: (_, {required resume}) {},
              onBookmarks: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder rowOf(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(ReaderTap));

  /// The names of the topic rows whose painted fill is not transparent, with
  /// the fill. Read from the boxes the row draws, so a fade shows its current
  /// in-between color, not where it is heading.
  Map<String, Color> lit(WidgetTester tester) {
    final out = <String, Color>{};
    for (final id in ['a', 'b', 'c', 'd', 'e', 'f']) {
      final name = 'Topic $id';
      final row = rowOf(name);
      if (row.evaluate().isEmpty) continue;
      for (final box in tester.widgetList<DecoratedBox>(
        find.descendant(of: row.first, matching: find.byType(DecoratedBox)),
      )) {
        final color = (box.decoration as BoxDecoration?)?.color;
        if (color != null && color.a > 0) out[name] = color;
      }
    }
    return out;
  }

  testWidgets('hovering one topic row lights only that row, then clears',
      (tester) async {
    await pump(tester);
    final hover = tester.element(find.byType(WebStudyMap)).colors.surfaceHover;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);

    for (final name in ['Topic b', 'Topic c', 'Topic a', 'Topic e']) {
      await mouse.moveTo(tester.getCenter(find.text(name)));
      await tester.pumpAndSettle();
      expect(lit(tester), {name: hover}, reason: 'hovering $name');
    }

    await mouse.moveTo(const Offset(1400, 880));
    await tester.pumpAndSettle();
    expect(lit(tester), isEmpty);
  });

  // The cause in the recording: the fill faded from `Colors.transparent`, which
  // is transparent black, so half-way it was a half-alpha dark gray (about
  // #7B7B7C at 50%). The rows a quick pointer crossed were all mid-fade at
  // once, two rows read dark, and the fade-out looked like a light left
  // behind. Every in-between fill must be the hover color itself, only less
  // opaque, so nothing on the way is darker than the page or the hover.
  testWidgets('the hover fade never passes through a darker gray',
      (tester) async {
    await pump(tester);
    final hover = tester.element(find.byType(WebStudyMap)).colors.surfaceHover;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);

    void expectOnlyHoverHue(String moment) {
      lit(tester).forEach((name, color) {
        final why = '$name at $moment is $color, not $hover at some alpha';
        // The blend multiplies each channel, so allow float rounding only.
        expect(color.r, closeTo(hover.r, 1e-6), reason: why);
        expect(color.g, closeTo(hover.g, 1e-6), reason: why);
        expect(color.b, closeTo(hover.b, 1e-6), reason: why);
      });
    }

    await mouse.moveTo(tester.getCenter(find.text('Topic b')));
    for (var ms = 0; ms <= 150; ms += 25) {
      await tester.pump(const Duration(milliseconds: 25));
      expectOnlyHoverHue('fade in +$ms ms');
    }
    // Over to the next row: one fades out while the other fades in.
    await mouse.moveTo(tester.getCenter(find.text('Topic c')));
    for (var ms = 0; ms <= 150; ms += 25) {
      await tester.pump(const Duration(milliseconds: 25));
      expectOnlyHoverHue('cross fade +$ms ms');
    }
    await tester.pumpAndSettle();
    expect(lit(tester), {'Topic c': hover});
    // Off the list: it clears, and the way out is no darker either.
    await mouse.moveTo(const Offset(1400, 880));
    for (var ms = 0; ms <= 150; ms += 25) {
      await tester.pump(const Duration(milliseconds: 25));
      expectOnlyHoverHue('fade out +$ms ms');
    }
    await tester.pumpAndSettle();
    expect(lit(tester), isEmpty);
  });

  testWidgets('with a topic open, hover still lights one row and clears',
      (tester) async {
    await pump(tester, open: 'f');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    final selected = lit(tester);
    expect(selected.keys, ['Topic f']);

    for (final name in ['Topic c', 'Topic d', 'Topic a']) {
      await mouse.moveTo(tester.getCenter(find.text(name)));
      await tester.pumpAndSettle();
      expect(lit(tester).keys.toSet(), {name, 'Topic f'}, reason: name);
    }
    await mouse.moveTo(const Offset(1400, 880));
    await tester.pumpAndSettle();
    expect(lit(tester), selected);
  });
}
