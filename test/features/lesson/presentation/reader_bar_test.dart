import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/components/pantas_tap_area.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';

import '../../../helpers/hover_shape.dart';
import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    String title = 'Test Title',
    ReaderOrigin origin = ReaderOrigin.study,
    bool isBookmarked = false,
    VoidCallback? onBookmark,
    VoidCallback? onContents,
    double scrollOffset = 0,
    TextScaler textScaler = TextScaler.noScaling,
    LessonDayContext? dayContext,
    bool reduceMotion = false,
  }) async {
    await tester.pumpApp(
      MediaQuery(
        data: MediaQueryData(
          textScaler: textScaler,
          disableAnimations: reduceMotion,
        ),
        child: ReaderBar(
          title: title,
          dayContext: dayContext,
          origin: origin,
          isBookmarked: isBookmarked,
          onBookmark: onBookmark ?? () {},
          onContents: onContents ?? () {},
          scrollOffset: ValueNotifier(scrollOffset),
        ),
      ),
    );
  }

  test('reader origins preserve each originating screen', () {
    expect(
      ReaderOrigin.values.map((origin) => origin.name).toList(),
      ['study', 'home', 'bookmarks', 'search', 'plan', 'performance'],
    );
  });

  testWidgets('reader back link matches the board type and accent',
      (tester) async {
    await pumpBar(tester);
    final text = tester.widget<Text>(find.text('Study'));
    expect(text.style!.fontSize, 17);
    expect(text.style!.color, PantasColors.light.accent);
  });

  testWidgets('phone reader back takes the BackLink hover state',
      (tester) async {
    await pumpBar(tester);
    const colors = PantasColors.light;
    expect(
      tester.widget<Text>(find.text('Study')).style!.color,
      colors.accent,
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Study')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<Text>(find.text('Study')).style!.color,
      colors.accentHover,
    );
    final wash = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('Study'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (wash.decoration as BoxDecoration).color,
      colors.accent.withValues(alpha: PantasOpacity.hover),
    );
  });

  testWidgets('phone reader back is reached by Tab and Enter goes back',
      (tester) async {
    var left = 0;
    await tester.pumpApp(
      ReaderBar.ending(origin: ReaderOrigin.study, onBack: () => left++),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final focus = FocusManager.instance.primaryFocus;
    expect(focus, isNotNull);
    expect(
      find.descendant(
        of: find.byType(ReaderBar),
        matching: find.byWidgetPredicate((w) => w is FocusableActionDetector),
      ),
      findsOneWidget,
    );
    expect(
      tester.getRect(find.text('Study')).overlaps(
            tester.getRect(
              find.byWidgetPredicate((w) => w is FocusableActionDetector),
            ),
          ),
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(left, 1);
  });

  testWidgets('reader bar uses the board50px surface and44px controls',
      (tester) async {
    await pumpBar(tester);
    expect(tester.getSize(find.byType(ReaderBar)).height, 50);
    expect(
      tester
          .widget<ColoredBox>(
            find
                .descendant(
                  of: find.byType(ReaderBar),
                  matching: find.byType(ColoredBox),
                )
                .first,
          )
          .color,
      PantasColors.light.surface,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('reader-bookmark-control'))),
      const Size(44, 44),
    );
  });

  testWidgets('reader uses the approved shared23px Contents stroke',
      (tester) async {
    await pumpBar(tester);
    final glyph = tester.widget<ContentsGlyph>(find.byType(ContentsGlyph));
    expect(glyph.size, 23);
    expect(glyph.strokeWidth, 1.8);
    expect(glyph.color, PantasColors.light.iconMuted);
  });

  testWidgets('reader back shape uses24px and2.2 accent stroke',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpBar(tester);
      final back = find.descendant(
        of: find.bySemanticsLabel('Back to Study'),
        matching: find.byType(CustomPaint),
      );
      expect(tester.getSize(back), const Size(24, 24));
      expect(
        back,
        paints
          ..path(
            strokeWidth: (Paint()..strokeWidth = 2.2).strokeWidth,
            color: PantasColors.light.accent,
          ),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('reducing motion during bookmark pop shows the final frame',
      (tester) async {
    await pumpBar(tester);
    await pumpBar(tester, isBookmarked: true);
    await tester.pump(const Duration(milliseconds: 100));
    await pumpBar(tester, isBookmarked: true, reduceMotion: true);
    expect(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('reader-bookmark-pop')),
          )
          .transform
          .storage[0],
      1,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected bookmark press shrinks and cancel restores it',
      (tester) async {
    await pumpBar(tester, isBookmarked: true);
    final gesture = await tester.startGesture(
      tester.getCenter(
        find.byKey(const ValueKey('reader-bookmark-control')),
      ),
    );
    var released = false;
    try {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('reader-bookmark-pop')),
            )
            .transform
            .storage[0],
        closeTo(.82, .00001),
      );
      await gesture.cancel();
      released = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('reader-bookmark-pop')),
            )
            .transform
            .storage[0],
        1,
      );
    } finally {
      if (!released) await gesture.cancel();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    }
  });

  testWidgets('bookmark held press can unmount without a context lookup',
      (tester) async {
    await pumpBar(tester, isBookmarked: true);
    final gesture = await tester.startGesture(
      tester.getCenter(
        find.byKey(const ValueKey('reader-bookmark-control')),
      ),
    );
    try {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    } finally {
      await gesture.cancel();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(Duration.zero);
    }
  });

  testWidgets('late bookmark cancel after unmount is harmless', (tester) async {
    await pumpBar(tester);
    final gesture = tester.widget<GestureDetector>(
      find.descendant(
        of: find.byKey(const ValueKey('reader-bookmark-control')),
        matching: find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onTapCancel != null,
        ),
      ),
    );
    final cancel = gesture.onTapCancel!;
    await tester.pumpWidget(const SizedBox.shrink());
    expect(cancel, returnsNormally);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bookmark pop keeps the full outline beneath its teal fill',
      (tester) async {
    await pumpBar(tester);
    await pumpBar(tester, isBookmarked: true);
    final paints = find.descendant(
      of: find.byKey(const ValueKey('reader-bookmark-control')),
      matching: find.byType(CustomPaint),
    );
    expect(paints, findsNWidgets(2));
    final outlineScale = tester
        .widget<Transform>(
          find
              .ancestor(
                of: paints.first,
                matching: find.byType(Transform),
              )
              .first,
        )
        .transform
        .storage[0];
    expect(outlineScale, 1);
    expect(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('reader-bookmark-pop')),
          )
          .transform
          .storage[0],
      .6,
    );
  });

  testWidgets('scaled strip reserves the full scaled line box', (tester) async {
    await pumpBar(
      tester,
      title: 'Chemistry',
      scrollOffset: 90,
      textScaler: const TextScaler.linear(2),
    );
    final text = tester.widget<Text>(find.text('Chemistry'));
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey('reader-title-strip'),
            ),
          )
          .height,
      greaterThanOrEqualTo(2 * text.style!.fontSize! * text.style!.height!),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reader title strip uses Geist semibold', (tester) async {
    await pumpBar(tester, title: 'Circles', scrollOffset: 90);
    final text = tester.widget<Text>(find.text('Circles'));
    expect(text.style!.fontFamily, 'Geist');
    expect(text.style!.fontWeight, FontWeight.w600);
  });

  testWidgets('day counter uses tabular figures', (tester) async {
    await pumpBar(
      tester,
      origin: ReaderOrigin.home,
      dayContext: LessonDayContext(
        date: DateTime(2026, 10, 14),
        lessonIds: const ['l1', 'l2'],
        index: 0,
      ),
    );
    final text = tester.widget<Text>(find.text('1 of 2'));
    expect(
      text.style!.fontFeatures?.map((feature) => feature.feature),
      contains('tnum'),
    );
  });

  // 6U-3: the counter sat at the top of its 44 px box, 12 px above the Back
  // word and the bookmark.
  testWidgets('day counter is centered on the bar like Back and the bookmark',
      (tester) async {
    await pumpBar(
      tester,
      origin: ReaderOrigin.home,
      dayContext: LessonDayContext(
        date: DateTime(2026, 10, 14),
        lessonIds: const ['l1'],
        index: 0,
      ),
    );
    final counter = tester.getCenter(find.text('1 of 1')).dy;
    final bookmark = tester
        .getCenter(find.byKey(const ValueKey('reader-bookmark-control')))
        .dy;
    final back = tester.getCenter(find.text('Home')).dy;
    expect(counter, closeTo(bookmark, 1));
    expect(counter, closeTo(back, 1));
  });

  testWidgets('day counter preserves all touch targets at320 and200% text',
      (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    try {
      await pumpBar(
        tester,
        origin: ReaderOrigin.home,
        textScaler: const TextScaler.linear(2),
        dayContext: LessonDayContext(
          date: DateTime(2026, 10, 14),
          lessonIds: List.generate(12, (index) => 'l$index'),
          index: 0,
        ),
      );
      expect(tester.takeException(), isNull);
      final back = find.semantics.byLabel('Back to Home');
      expect(back.evaluate().single.rect.width, greaterThanOrEqualTo(44));
      expect(back.evaluate().single.rect.height, greaterThanOrEqualTo(44));
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('reader bookmark draws the approved teal fill', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpBar(tester, isBookmarked: true);
      expect(
        find.bySemanticsLabel('Remove lesson bookmark'),
        paints
          ..path(
            color: PantasColors.light.iconMuted,
            style: PaintingStyle.stroke,
          )
          ..path(color: PantasColors.light.accent, style: PaintingStyle.fill),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('reader bookmark uses the approved outline and22px shape',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpBar(tester);
      final paint = find.descendant(
        of: find.bySemanticsLabel('Bookmark lesson'),
        matching: find.byType(CustomPaint),
      );
      expect(tester.getSize(paint), const Size(22, 22));
      expect(
        paint,
        paints
          ..path(
            color: PantasColors.light.iconMuted,
            style: PaintingStyle.stroke,
          ),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('reader bookmark pops through the exact520ms keyframes',
      (tester) async {
    await pumpBar(tester);
    await pumpBar(tester, isBookmarked: true);
    final mark = find.byKey(const ValueKey('reader-bookmark-pop'));
    expect(mark, findsOneWidget);
    expect(tester.widget<Transform>(mark).transform.storage[0], .6);
    await tester.pump(const Duration(milliseconds: 260));
    expect(
      tester.widget<Transform>(mark).transform.storage[0],
      closeTo(1.22, .00001),
    );
    await tester.pump(const Duration(milliseconds: 260));
    expect(tester.widget<Transform>(mark).transform.storage[0], 1);
    await pumpBar(tester);
    expect(tester.widget<Transform>(mark).transform.storage[0], 1);
  });

  testWidgets('the origin word names where the reader came from',
      (tester) async {
    await pumpBar(tester);
    expect(find.text('Study'), findsOneWidget);

    await pumpBar(tester, origin: ReaderOrigin.home);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('the title is never in the bar itself', (tester) async {
    await pumpBar(tester, title: 'Balancing equations');

    expect(find.text('Balancing equations'), findsNothing);
  });

  testWidgets('the strip grows over the first ninety pixels of scroll',
      (tester) async {
    await pumpBar(tester, title: 'Balancing equations', scrollOffset: 45);
    final half =
        tester.getSize(find.byKey(const ValueKey('reader-title-strip')));

    await pumpBar(tester, title: 'Balancing equations', scrollOffset: 90);
    final full =
        tester.getSize(find.byKey(const ValueKey('reader-title-strip')));

    expect(half.height, greaterThan(0));
    expect(half.height, lessThan(30));
    expect(full.height, 30);
  });

  testWidgets('past ninety the strip does not keep growing', (tester) async {
    await pumpBar(tester, title: 'T', scrollOffset: 400);

    expect(
      tester.getSize(find.byKey(const ValueKey('reader-title-strip'))).height,
      30,
    );
  });

  testWidgets('the bookmark is the outermost trailing element', (tester) async {
    await pumpBar(tester);

    expect(
      tester
          .getCenter(find.byKey(const ValueKey('reader-bookmark-control')))
          .dx,
      greaterThan(tester.getCenter(find.byType(ContentsGlyph)).dx),
    );
  });

  testWidgets('tapping the ribbon calls back', (tester) async {
    var toggled = false;
    await pumpBar(tester, onBookmark: () => toggled = true);

    await tester.tap(find.byKey(const ValueKey('reader-bookmark-control')));
    expect(toggled, isTrue);
  });

  group('phone reader contents and bookmark are system controls', () {
    final contents = find.byType(ContentsGlyph);
    final bookmark = find.byKey(const ValueKey('reader-bookmark-control'));
    Finder areaOf(Finder inner) => inner == bookmark
        ? find.descendant(of: inner, matching: find.byType(PantasTapArea))
        : find.ancestor(of: inner, matching: find.byType(PantasTapArea));

    Future<void> tab(WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }

    bool focusIn(WidgetTester tester, Finder area) {
      final focused = FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<PantasTapArea>();
      return focused != null && area.evaluate().any((e) => e.widget == focused);
    }

    testWidgets('Tab reaches back, then contents, then bookmark',
        (tester) async {
      await pumpBar(tester);
      await tab(tester);
      expect(focusIn(tester, areaOf(find.text('Study'))), isTrue);
      await tab(tester);
      expect(focusIn(tester, areaOf(contents)), isTrue);
      await tab(tester);
      expect(focusIn(tester, areaOf(bookmark)), isTrue);
    });

    testWidgets('each shows the system focus ring when focused',
        (tester) async {
      resetWebKeyboardFocus();
      await pumpBar(tester);
      await tab(tester);
      await tab(tester);
      expect(find.byKey(const ValueKey('focus-ring')), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const ValueKey('focus-ring'))).overlaps(
              tester.getRect(contents),
            ),
        isTrue,
      );
      await tab(tester);
      expect(find.byKey(const ValueKey('focus-ring')), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const ValueKey('focus-ring'))).overlaps(
              tester.getRect(bookmark),
            ),
        isTrue,
      );
    });

    for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
      testWidgets('${key.debugName} activates contents and bookmark',
          (tester) async {
        var opened = 0;
        var toggled = 0;
        await pumpBar(
          tester,
          onContents: () => opened++,
          onBookmark: () => toggled++,
        );
        await tab(tester);
        await tab(tester);
        await tester.sendKeyEvent(key);
        await tester.pump();
        expect([opened, toggled], [1, 0]);
        await tab(tester);
        await tester.sendKeyEvent(key);
        await tester.pump();
        expect([opened, toggled], [1, 1]);
      });
    }

    testWidgets('hover washes contents and bookmark as a rounded rectangle',
        (tester) async {
      await pumpBar(tester);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      for (final target in [contents, bookmark]) {
        await mouse.moveTo(tester.getCenter(target));
        await tester.pumpAndSettle();
        expectRoundedWash(tester, areaOf(target));
        final wash = tester.widget<DecoratedBox>(
          find.descendant(
            of: areaOf(target),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  w.position == DecorationPosition.foreground,
            ),
          ),
        );
        // IconButton README: the wash is the icon's color at opacity-hover.
        expect(
          (wash.decoration as BoxDecoration).color,
          PantasColors.light.iconMuted.withValues(
            alpha: PantasOpacity.hover,
          ),
        );
      }
    });

    testWidgets('a bookmarked lesson washes the bookmark in accent',
        (tester) async {
      await pumpBar(tester, isBookmarked: true);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(bookmark));
      await tester.pumpAndSettle();
      final wash = tester.widget<DecoratedBox>(
        find.descendant(
          of: areaOf(bookmark),
          matching: find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.position == DecorationPosition.foreground,
          ),
        ),
      );
      expect(
        (wash.decoration as BoxDecoration).color,
        PantasColors.light.accent.withValues(alpha: PantasOpacity.hover),
      );
    });

    testWidgets('pressing scales each control', (tester) async {
      await pumpBar(tester);
      for (final target in [contents, bookmark]) {
        final scale = find.descendant(
          of: areaOf(target),
          matching: find.byType(PressScale),
        );
        final down = await tester.startGesture(tester.getCenter(target));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        final shrunk = tester
            .widget<Transform>(
              find
                  .descendant(of: scale, matching: find.byType(Transform))
                  .first,
            )
            .transform
            .storage[0];
        expect(shrunk, lessThan(1));
        await down.up();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('the 44 hit area holds and a tap at its corner lands',
        (tester) async {
      var opened = 0;
      var toggled = 0;
      await pumpBar(
        tester,
        onContents: () => opened++,
        onBookmark: () => toggled++,
      );
      for (final target in [contents, bookmark]) {
        final box = tester.getRect(areaOf(target));
        expect(box.width, greaterThanOrEqualTo(44));
        expect(box.height, greaterThanOrEqualTo(44));
      }
      await tester
          .tapAt(tester.getRect(areaOf(contents)).topLeft + const Offset(2, 2));
      await tester.tapAt(
        tester.getRect(areaOf(bookmark)).bottomRight - const Offset(2, 2),
      );
      expect([opened, toggled], [1, 1]);
    });
  });

  testWidgets('the contents action is labeled and at least 44dp',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpBar(tester);

    final action = find.semantics.byLabel('Contents');
    expect(action, findsOne);
    expect(action.evaluate().single.rect.size.width, greaterThanOrEqualTo(44));
    expect(action.evaluate().single.rect.size.height, greaterThanOrEqualTo(44));

    semantics.dispose();
  });

  testWidgets('the bookmark action names a lesson and is at least 44dp',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpBar(tester);

    final action = find.semantics.byLabel('Bookmark lesson');
    expect(action, findsOne);
    expect(action.evaluate().single.rect.size.width, greaterThanOrEqualTo(44));
    expect(action.evaluate().single.rect.size.height, greaterThanOrEqualTo(44));

    semantics.dispose();
  });

  testWidgets('the back action names its destination and is at least 44dp',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpBar(tester);

    final action = find.semantics.byLabel('Back to Study');
    expect(action, findsOne);
    expect(action.evaluate().single.rect.size.width, greaterThanOrEqualTo(44));
    expect(action.evaluate().single.rect.size.height, greaterThanOrEqualTo(44));

    semantics.dispose();
  });

  testWidgets('the reader bar fits at 320dp and 200% text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpBar(tester, textScaler: const TextScaler.linear(2));

    expect(tester.takeException(), isNull);
  });
}
