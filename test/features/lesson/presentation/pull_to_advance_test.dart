import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';

import '../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpPull(
    WidgetTester tester, {
    String? nextTitle = 'Next Lesson',
    VoidCallback? onAdvance,
    bool isAtEnd = true,
    String lessonId = 'l1',
    bool disableAnimations = false,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    await tester.pumpApp(
      MediaQuery(
        data: MediaQueryData(
          disableAnimations: disableAnimations,
          textScaler: textScaler,
        ),
        child: Scaffold(
          body: PullToAdvance(
            lessonId: lessonId,
            isAtEnd: ValueNotifier(isAtEnd),
            nextTitle: nextTitle,
            onAdvance: onAdvance ?? () {},
            child: const ColoredBox(
              color: Colors.white,
              child: Center(child: Text('Current Content')),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('the handle names the next lesson', (tester) async {
    await pumpPull(tester, nextTitle: 'Real and Imaginary Number Systems');

    expect(
      find.textContaining('Real and Imaginary Number Systems'),
      findsNWidgets(2),
    );
  });

  testWidgets('both bodies move together at the 480ms transition midpoint',
      (tester) async {
    var advances = 0;
    await tester.pumpApp(
      PullToAdvance(
        lessonId: 'l1',
        destinationKey: 'l2',
        nextTitle: 'Lesson 2',
        onAdvance: () => advances++,
        isAtEnd: ValueNotifier(true),
        incomingChild: const Center(child: Text('Incoming body')),
        child: const Center(child: Text('Outgoing body')),
      ),
    );
    final semantics = tester.ensureSemantics();
    tester.semantics.tap(find.semantics.byLabel('Next lesson: Lesson 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 240));
    final height = tester.getSize(find.byType(PullToAdvance)).height;
    final fraction = PantasCurves.slideA.transform(.5);
    final outgoing =
        tester.widget<Transform>(find.byKey(const ValueKey('pull-outgoing')));
    final incoming =
        tester.widget<Transform>(find.byKey(const ValueKey('pull-incoming')));
    expect(outgoing.transform.storage[13], closeTo(-height * fraction, .01));
    expect(
      incoming.transform.storage[13],
      closeTo(height * (1 - fraction), .01),
    );
    expect(advances, 0);
    expect(find.bySemanticsLabel('Incoming body'), findsNothing);
    await tester.pump(const Duration(milliseconds: 240));
    expect(advances, 1);
    semantics.dispose();
  });

  testWidgets('revealing the footer never changes the measured scroll extent',
      (tester) async {
    final atEnd = ValueNotifier(false);
    final controller = ScrollController();
    await tester.pumpApp(
      PullToAdvance(
        lessonId: 'l1',
        nextTitle: 'Next',
        onAdvance: () {},
        isAtEnd: atEnd,
        contentBuilder: (footer) => SingleChildScrollView(
          controller: controller,
          child: Column(children: [const SizedBox(height: 1200), footer]),
        ),
      ),
    );
    final extent = controller.position.maxScrollExtent;
    atEnd.value = true;
    await tester.pumpAndSettle();
    expect(controller.position.maxScrollExtent, extent);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    atEnd.dispose();
  });

  testWidgets('dragging past a real scroll surface end commits',
      (tester) async {
    var advances = 0;
    final controller = ScrollController();
    await tester.pumpApp(
      PullToAdvance(
        lessonId: 'l1',
        nextTitle: 'Next',
        isAtEnd: ValueNotifier(true),
        onAdvance: () => advances++,
        contentBuilder: (footer) => SingleChildScrollView(
          controller: controller,
          physics: const ClampingScrollPhysics(),
          child: Column(children: [const SizedBox(height: 1200), footer]),
        ),
      ),
    );
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(PullToAdvance)));
    await gesture.moveBy(const Offset(0, -20));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -140));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(advances, 1);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets(
      'a released drag moves both bodies the same full viewport distance',
      (tester) async {
    var advances = 0;
    await tester.pumpApp(
      PullToAdvance(
        lessonId: 'l1',
        nextTitle: 'Next',
        isAtEnd: ValueNotifier(true),
        onAdvance: () => advances++,
        incomingChild: const Center(child: Text('Incoming real body')),
        child: const Center(child: Text('Outgoing real body')),
      ),
    );
    final viewport = tester.getSize(find.byType(PullToAdvance)).height;
    final rest = tester.getTopLeft(find.text('Outgoing real body')).dy;
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(PullToAdvance)));
    await gesture.moveBy(const Offset(0, -130));
    await tester.pump();
    final outgoingStart = tester.getTopLeft(find.text('Outgoing real body')).dy;
    expect(outgoingStart, lessThan(rest));
    await gesture.up();
    await tester.pump();
    final incomingStart = tester.getTopLeft(find.text('Incoming real body')).dy;
    await tester.pump(const Duration(milliseconds: 240));
    final outgoingMid = tester.getTopLeft(find.text('Outgoing real body')).dy;
    final incomingMid = tester.getTopLeft(find.text('Incoming real body')).dy;
    expect(
      outgoingMid - outgoingStart,
      closeTo(incomingMid - incomingStart, .01),
    );
    expect(advances, 0);
    await tester.pump(const Duration(milliseconds: 240));
    expect(
      tester.getTopLeft(find.text('Outgoing real body')).dy - outgoingStart,
      closeTo(-viewport, .01),
    );
    expect(
      tester.getTopLeft(find.text('Incoming real body')).dy - incomingStart,
      closeTo(-viewport, .01),
    );
    expect(advances, 1);
  });

  testWidgets('the drawn pull control uses a 44px filling circle',
      (tester) async {
    await pumpPull(tester);
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('pull-handle'))),
      const Size(44, 44),
    );
  });

  testWidgets('a long next title stays complete at 320dp and 200% text',
      (tester) async {
    tester.view
      ..physicalSize = const Size(320, 640)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPull(
      tester,
      nextTitle: 'Real and Imaginary Number Systems and Their Applications',
      textScaler: const TextScaler.linear(2),
    );

    expect(tester.takeException(), isNull);
    for (final footerText in tester.widgetList<Text>(
      find.text('Real and Imaginary Number Systems and Their Applications'),
    )) {
      expect(footerText.maxLines, isNull);
      expect(footerText.overflow, isNot(TextOverflow.ellipsis));
    }
  });

  testWidgets('no next lesson draws no handle', (tester) async {
    await pumpPull(tester, nextTitle: null);

    expect(find.byKey(const ValueKey('pull-handle')), findsNothing);
  });

  testWidgets('a drag short of the threshold settles back', (tester) async {
    var advanced = false;
    await pumpPull(tester, onAdvance: () => advanced = true);

    await tester.drag(find.byType(PullToAdvance), const Offset(0, -60));
    await tester.pumpAndSettle();

    expect(advanced, isFalse);
  });

  testWidgets('the circle advances on a physical tap without dragging',
      (tester) async {
    var advances = 0;
    await pumpPull(tester, onAdvance: () => advances++);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pull-handle')));
    await tester.pumpAndSettle();
    expect(advances, 1);
  });

  testWidgets('an armed pull says Let go and cancellation resets it',
      (tester) async {
    var advances = 0;
    await pumpPull(tester, onAdvance: () => advances++);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PullToAdvance)),
    );
    await gesture.moveBy(const Offset(0, -130));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.text('Let go for'),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity,
      1,
    );
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(advances, 0);
    expect(
      tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.text('Pull up for'),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity,
      1,
    );
  });

  testWidgets('release uses the drawn 480ms transition before advancing',
      (tester) async {
    var advances = 0;
    await pumpPull(tester, onAdvance: () => advances++);
    final semantics = tester.ensureSemantics();
    tester.semantics.tap(find.semantics.byLabel('Next lesson: Next Lesson'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 479));
    expect(advances, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(advances, 1);
    semantics.dispose();
  });

  testWidgets('a drag past the threshold commits', (tester) async {
    var advanced = false;
    await pumpPull(tester, onAdvance: () => advanced = true);

    await tester.drag(find.byType(PullToAdvance), const Offset(0, -120));
    await tester.pumpAndSettle();

    expect(advanced, isTrue);
  });

  testWidgets('the next lesson semantic action commits without a drag',
      (tester) async {
    final semantics = tester.ensureSemantics();
    var advanced = false;
    await pumpPull(
      tester,
      nextTitle: 'Real and Imaginary Number Systems',
      onAdvance: () => advanced = true,
    );

    final action = find.semantics.byLabel(
      'Next lesson: Real and Imaginary Number Systems',
    );
    expect(action, findsOne);

    tester.semantics.tap(action);
    await tester.pumpAndSettle();

    expect(advanced, isTrue);
    semantics.dispose();
  });

  testWidgets('reduced motion advances without a transition', (tester) async {
    final semantics = tester.ensureSemantics();
    var advanced = false;
    await pumpPull(
      tester,
      disableAnimations: true,
      onAdvance: () => advanced = true,
    );

    expect(find.byType(AnimatedSize), findsNothing);
    expect(
      tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .every((widget) => widget.duration == Duration.zero),
      isTrue,
    );

    tester.semantics.tap(find.semantics.byLabel('Next lesson: Next Lesson'));
    await tester.pump();

    expect(advanced, isTrue);
    semantics.dispose();
  });

  testWidgets('the handle arms past the threshold', (tester) async {
    await pumpPull(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PullToAdvance)),
    );
    await gesture.moveBy(const Offset(0, -130));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      tester.getSize(find.byKey(const ValueKey('pull-handle'))).width,
      44,
    );

    await gesture.up();
  });

  testWidgets('the handle stays away until the end of the lesson',
      (tester) async {
    // It used to sit under every lesson from the first line, offering the
    // next topic to someone who had not read a word of this one.
    await pumpPull(tester, isAtEnd: false);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('pull-handle')).hitTestable(),
      findsNothing,
    );
    expect(find.textContaining('Pull up for').hitTestable(), findsNothing);
  });

  testWidgets('the handle arrives once the end is reached', (tester) async {
    await pumpPull(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('pull-handle')), findsOneWidget);
  });

  testWidgets('a pulled sheet is clipped, so nothing escapes upward',
      (tester) async {
    // Aedwon: the body text "can go up and obstruct even the topmost part of
    // the screen" instead of disappearing under the bar the way scrolling
    // makes it.
    await pumpPull(tester);
    await tester.pumpAndSettle();

    final box = tester.getRect(find.byType(PullToAdvance));
    final gesture = await tester.startGesture(box.center);
    await gesture.moveBy(const Offset(0, -120));
    await tester.pump();

    final content = tester.getRect(find.text('Current Content'));
    // The clip keeps the lifted content inside the widget it belongs to.
    expect(find.byType(ClipRect), findsWidgets);
    expect(content.top, greaterThanOrEqualTo(box.top - 0.5));

    await gesture.up();
  });

  testWidgets('advancing moves the body and never the chrome', (tester) async {
    // Aedwon: "when pulling up, the entire page is animated including the top
    // navbar (where the < Study lives). this is not elegant". Advancing is no
    // longer a navigation, so nothing above the body can travel with it.
    var advanced = false;
    await tester.pumpApp(
      Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 40, child: Text('Reader chrome')),
            Expanded(
              child: PullToAdvance(
                lessonId: 'l1',
                isAtEnd: ValueNotifier(true),
                nextTitle: 'Next Lesson',
                onAdvance: () => advanced = true,
                child: const Center(child: Text('Current Content')),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chromeBefore = tester.getRect(find.text('Reader chrome'));

    final gesture = await tester.startGesture(
      tester.getRect(find.byType(PullToAdvance)).center,
    );
    await gesture.moveBy(const Offset(0, -120));
    await tester.pump();

    expect(
      tester.getRect(find.text('Reader chrome')),
      chromeBefore,
      reason: 'the chrome must not move while the body is pulled',
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(advanced, isTrue);
    expect(tester.getRect(find.text('Reader chrome')), chromeBefore);
  });
}
