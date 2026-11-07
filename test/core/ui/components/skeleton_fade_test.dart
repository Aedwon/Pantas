import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/skeleton_fade.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// The approved splash hand-off (Splash Hand-off canvas, Web_B_Still and
// Phone_B_Fade): when the data arrives the content fades in over the loading
// shapes while they fade out underneath. Shapes 1 to 0 over 200 ms, content
// 0 to 1 over 300 ms starting at 60 ms, shapes kept until the fade ends, and
// no movement.
void main() {
  const loadedKey = ValueKey('loaded');

  Widget host({
    required bool loading,
    bool fade = true,
    bool reduceMotion = false,
  }) =>
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SkeletonFade(
                    loading: loading,
                    fade: fade,
                    skeleton: const SkeletonPulse(
                      child: SkeletonBlock(width: 120, height: 300),
                    ),
                    content: const SizedBox(
                      key: loadedKey,
                      height: 200,
                      child: Text('Loaded plan'),
                    ),
                  ),
                  const Text('After'),
                ],
              ),
            ),
          ),
        ),
      );

  double opacityOf(WidgetTester tester, Key key) =>
      tester.widget<FadeTransition>(find.byKey(key)).opacity.value;

  testWidgets('while loading only the shapes are drawn', (tester) async {
    await tester.pumpWidget(host(loading: true));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SkeletonBlock), findsOneWidget);
    expect(find.text('Loaded plan'), findsNothing);
  });

  testWidgets('content that was never behind shapes appears with no fade',
      (tester) async {
    await tester.pumpWidget(host(loading: false));
    expect(find.text('Loaded plan'), findsOneWidget);
    expect(find.byType(SkeletonBlock), findsNothing);
    expect(opacityOf(tester, SkeletonFade.contentFadeKey), 1);
  });

  testWidgets('data arriving fades the content in over the shapes',
      (tester) async {
    await tester.pumpWidget(host(loading: true));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(host(loading: false));
    // The page takes the content's size at once and keeps it for the fade.
    final topBefore = tester.getTopLeft(find.text('After'));
    // Frame zero: both are in the tree, content invisible, shapes fully shown.
    expect(find.byType(SkeletonBlock), findsOneWidget);
    expect(find.text('Loaded plan'), findsOneWidget);
    expect(opacityOf(tester, SkeletonFade.contentFadeKey), 0);
    expect(opacityOf(tester, SkeletonFade.shapesFadeKey), 1);

    // 30 ms: the shapes are going, the content has not started (60 ms).
    await tester.pump(const Duration(milliseconds: 30));
    expect(opacityOf(tester, SkeletonFade.shapesFadeKey), lessThan(1));
    expect(opacityOf(tester, SkeletonFade.shapesFadeKey), greaterThan(0));
    expect(opacityOf(tester, SkeletonFade.contentFadeKey), 0);

    // 100 ms: both are part way. Both are still in the tree.
    await tester.pump(const Duration(milliseconds: 70));
    final shapes = opacityOf(tester, SkeletonFade.shapesFadeKey);
    final content = opacityOf(tester, SkeletonFade.contentFadeKey);
    expect(shapes, inExclusiveRange(0, 1));
    expect(content, inExclusiveRange(0, 1));
    expect(find.byType(SkeletonBlock), findsOneWidget);
    expect(find.text('Loaded plan'), findsOneWidget);

    // 210 ms: the shapes have finished (200 ms) but stay until the fade ends.
    await tester.pump(const Duration(milliseconds: 110));
    expect(opacityOf(tester, SkeletonFade.shapesFadeKey), 0);
    expect(find.byType(SkeletonBlock), findsOneWidget);
    expect(opacityOf(tester, SkeletonFade.contentFadeKey), lessThan(1));

    // Nothing moved at any point: the text below keeps its place.
    expect(tester.getTopLeft(find.text('After')), topBefore);

    // 360 ms: the content is whole and the shapes leave the tree.
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();
    expect(find.byType(SkeletonBlock), findsNothing);
    expect(opacityOf(tester, SkeletonFade.contentFadeKey), 1);
    expect(tester.getTopLeft(find.text('After')), topBefore);
  });

  testWidgets('the fade applies no slide, scale or other transform',
      (tester) async {
    await tester.pumpWidget(host(loading: true));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(host(loading: false));
    await tester.pump(const Duration(milliseconds: 100));

    final fade = find.byType(SkeletonFade);
    for (final moving in [
      SlideTransition,
      ScaleTransition,
      RotationTransition,
      SizeTransition,
      Transform,
      AnimatedPositioned,
    ]) {
      expect(
        find.descendant(of: fade, matching: find.byType(moving)),
        findsNothing,
        reason: '$moving would move the content',
      );
    }
    final loaded = tester.getTopLeft(find.byKey(loadedKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(find.byKey(loadedKey)), loaded);
  });

  testWidgets('the shapes keep their pulse state through the fade',
      (tester) async {
    await tester.pumpWidget(host(loading: true));
    await tester.pump(const Duration(milliseconds: 400));
    final before = tester.state(find.byType(SkeletonPulse));

    await tester.pumpWidget(host(loading: false));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.state(find.byType(SkeletonPulse)), same(before));
  });

  testWidgets('reduced motion swaps at once', (tester) async {
    await tester.pumpWidget(host(loading: true, reduceMotion: true));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(host(loading: false, reduceMotion: true));
    await tester.pump();

    expect(find.byType(SkeletonBlock), findsNothing);
    expect(find.text('Loaded plan'), findsOneWidget);
    expect(opacityOf(tester, SkeletonFade.contentFadeKey), 1);
  });

  testWidgets('a result that is not data (an error) swaps at once',
      (tester) async {
    await tester.pumpWidget(host(loading: true));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(host(loading: false, fade: false));
    await tester.pump();

    expect(find.byType(SkeletonBlock), findsNothing);
    expect(opacityOf(tester, SkeletonFade.contentFadeKey), 1);
  });

  testWidgets('going back to loading shows only the shapes again',
      (tester) async {
    await tester.pumpWidget(host(loading: true));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(host(loading: false));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(host(loading: true));
    await tester.pump();

    expect(find.text('Loaded plan'), findsNothing);
    expect(find.byType(SkeletonBlock), findsOneWidget);
  });
}
