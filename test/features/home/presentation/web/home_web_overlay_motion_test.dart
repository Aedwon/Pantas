import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';

const _drawer = ValueKey('home-web-drawer');
const _dialog = ValueKey('home-web-dialog');

// ignore: avoid_positional_boolean_parameters
late void Function(bool) _set;

/// Mounts a wide Home overlay. Like the Home screens, the parent stops
/// passing content once it closes.
Future<void> _mount(
  WidgetTester tester, {
  required bool drawer,
  bool open = false,
  bool still = false,
}) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (still) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  var isOpen = open;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: true),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, update) {
            _set = (value) => update(() => isOpen = value);
            return HomeWebOverlay(
              page: const Text('Page'),
              open: isOpen,
              label: 'Reviews',
              drawer: drawer,
              onDismiss: () => _set(false),
              child: isOpen
                  ? const SizedBox(height: 300, child: Text('Body'))
                  : const SizedBox.shrink(),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _frames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

double _opacityOf(WidgetTester tester, Key key) => tester
    .widget<Opacity>(
      find.ancestor(of: find.byKey(key), matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  testWidgets('a drawer slides in from the right and out again',
      (tester) async {
    await _mount(tester, drawer: true);
    _set(true);
    await _frames(tester);
    await tester.pump(const Duration(milliseconds: 100));
    final middle = tester.getTopLeft(find.byKey(_drawer)).dx;
    expect(middle, greaterThan(1000));
    expect(middle, lessThan(1440));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(_drawer)).dx, 1000);

    await tester.tapAt(const Offset(100, 100));
    await _frames(tester);
    await tester.pump(const Duration(milliseconds: 100));
    // It is still mounted, still shows its content and is part way out.
    expect(find.text('Body'), findsOneWidget);
    expect(tester.getTopLeft(find.byKey(_drawer)).dx, greaterThan(1000));
    await tester.pumpAndSettle();
    expect(find.byKey(_drawer), findsNothing);
    expect(find.text('Body'), findsNothing);
  });

  testWidgets('opening again while it closes turns it round', (tester) async {
    await _mount(tester, drawer: true, open: true);
    _set(false);
    await _frames(tester);
    await tester.pump(const Duration(milliseconds: 150));
    final closing = tester.getTopLeft(find.byKey(_drawer)).dx;
    expect(closing, greaterThan(1000));
    _set(true);
    await _frames(tester);
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getTopLeft(find.byKey(_drawer)).dx, lessThan(closing));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(_drawer)).dx, 1000);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('a dialog fades and rises, then fades out', (tester) async {
    await _mount(tester, drawer: false);
    _set(true);
    await _frames(tester);
    await tester.pump(const Duration(milliseconds: 60));
    final fade = _opacityOf(tester, _dialog);
    expect(fade, inExclusiveRange(0, 1));
    final rising = tester.getTopLeft(find.byKey(_dialog)).dy;
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, _dialog), 1);
    expect(tester.getTopLeft(find.byKey(_dialog)).dy, lessThan(rising));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _frames(tester);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byKey(_dialog), findsOneWidget);
    expect(_opacityOf(tester, _dialog), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(find.byKey(_dialog), findsNothing);
  });

  testWidgets('reduced motion opens and closes at once', (tester) async {
    await _mount(tester, drawer: true, still: true);
    _set(true);
    await _frames(tester);
    expect(tester.getTopLeft(find.byKey(_drawer)).dx, 1000);
    _set(false);
    await _frames(tester);
    expect(find.byKey(_drawer), findsNothing);
  });

  group('notice detail', () {
    Future<void> mountNotice(
      WidgetTester tester, {
      required bool expanded,
      bool still = false,
    }) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      if (still) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                child: HomeWebNotice(
                  title: 'Add your exam date',
                  detail: 'It sharpens the plan.',
                  expanded: expanded,
                  onClose: () {},
                  onToggle: () {},
                ),
              ),
            ),
          ),
        ),
      );
    }

    // The detail's own box: it grows from nothing as the notice opens.
    double height(WidgetTester tester) {
      final detail = find.ancestor(
        of: find.text('It sharpens the plan.'),
        matching: find.byType(ClipRect),
      );
      return detail.evaluate().isEmpty
          ? 0
          : tester.getSize(detail.first).height;
    }

    testWidgets('opens and closes over 350 ms with one turning chevron',
        (tester) async {
      await mountNotice(tester, expanded: false);
      await tester.pumpAndSettle();
      final folded = height(tester);
      expect(find.text('It sharpens the plan.'), findsNothing);

      await mountNotice(tester, expanded: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final middle = height(tester);
      expect(middle, greaterThan(folded));
      expect(find.text('It sharpens the plan.'), findsOneWidget);
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        .5,
      );
      expect(find.byIcon(Icons.expand_less), findsNothing);
      await tester.pumpAndSettle();
      expect(height(tester), greaterThan(middle));

      await mountNotice(tester, expanded: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('It sharpens the plan.'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('It sharpens the plan.'), findsNothing);
      expect(height(tester), folded);
    });

    testWidgets('the header hover tint keeps the card corner and reaches the X',
        (tester) async {
      await mountNotice(tester, expanded: true);
      await tester.pumpAndSettle();
      final header = find.byType(TextButton);
      // The tint is the button's own shape: it follows the card's top-left
      // corner (16 px, less the 1 px rule it sits inside) and is rounded like
      // a row on the side of the dismiss button (4N-7).
      final shape = tester
          .widget<Material>(
            find.descendant(of: header, matching: find.byType(Material)).first,
          )
          .shape! as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      );
      // It reaches the card's rule, which is drawn over its outer pixel.
      expect(
        tester.getTopLeft(header).dy,
        tester.getTopLeft(find.byType(HomeWebNotice)).dy + 1,
      );
      final close = find.byTooltip('Dismiss');
      expect(
        tester.getTopRight(header).dx,
        tester
            .getTopLeft(
              find.ancestor(of: close, matching: find.byType(Padding)).first,
            )
            .dx,
      );
    });

    testWidgets(
        'the notice that opens low on the page scrolls clear of the edge',
        (tester) async {
      // 3K-2: the card used to stop against the window bottom, 44 px short of
      // the margin the end of the page has.
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      var expanded = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: context.webPageBottomInset),
                  child: Column(
                    children: [
                      const SizedBox(height: 780),
                      HomeWebNotice(
                        title: 'Add your exam date',
                        detail: 'It sharpens the plan.',
                        expanded: expanded,
                        onClose: () {},
                        onToggle: () {},
                        primaryLabel: 'Pick the Day',
                        onPrimary: () {},
                      ),
                      const SizedBox(height: 400),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      update(() => expanded = true);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.byType(HomeWebNotice)).dy,
        closeTo(900 - 44, .5),
      );
    });

    testWidgets('a compact density does not shave the header (3K-3)',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true)
              .copyWith(visualDensity: VisualDensity.compact),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                child: HomeWebNotice(
                  title: 'Add your exam date',
                  detail: 'It sharpens the plan.',
                  expanded: true,
                  onClose: () {},
                  onToggle: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final header = find.byType(TextButton);
      // 52 px of header: the button's 50 between the card's 1 px rules.
      expect(tester.getSize(header).height, 50);
      expect(
        tester.getTopLeft(header).dy,
        tester.getTopLeft(find.byType(HomeWebNotice)).dy + 1,
      );
    });

    testWidgets('reduced motion shows the detail at once', (tester) async {
      await mountNotice(tester, expanded: false, still: true);
      await tester.pumpAndSettle();
      final folded = height(tester);
      await mountNotice(tester, expanded: true, still: true);
      await tester.pump();
      await tester.pump();
      expect(find.text('It sharpens the plan.'), findsOneWidget);
      expect(height(tester), greaterThan(folded));
    });
  });
}
