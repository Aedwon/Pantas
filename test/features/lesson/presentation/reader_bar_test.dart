import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';

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
    expect(glyph.color, const Color(0xFF8E8E93));
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
        matching: find.byType(GestureDetector),
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
          ..path(color: const Color(0xFF8E8E93), style: PaintingStyle.stroke)
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
            color: const Color(0xFF8E8E93),
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
