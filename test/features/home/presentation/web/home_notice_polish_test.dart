import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/presentation/widgets/home_notice_strip.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import '../../../../helpers/in_memory_database.dart';

// QA 4N: the wide Home notice against the board (HomeD).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  setUp(() {
    debugWebPlatformOverride = true;
    resetWebKeyboardFocus();
  });
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    bool dark = false,
    double width = 1080,
  }) async {
    tester.view.physicalSize = Size(width + 360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: Column(mainAxisSize: MainAxisSize.min, children: [child]),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    testWidgets('buttons take the board padding, dark=$dark (4N-3)',
        (tester) async {
      await mount(
        tester,
        HomeWebNotice(
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          expanded: true,
          onClose: () {},
          onToggle: () {},
          primaryLabel: 'Add Exam Date',
          onPrimary: () {},
          secondaryLabel: 'Later',
          onSecondary: () {},
        ),
        dark: dark,
      );
      final add =
          tester.getRect(find.widgetWithText(WebButton, 'Add Exam Date'));
      final later = tester.getRect(find.widgetWithText(WebButton, 'Later'));
      // Board `.btn2` is 20 px at the sides and `.btn3` 16 px.
      expect(add.width, tester.getSize(find.text('Add Exam Date')).width + 40);
      expect(later.width, tester.getSize(find.text('Later')).width + 32);
      expect(add.width, closeTo(156, 1.5));
      // 16 px of Later's padding and the 12 px gap: 28 from its text.
      expect(
        tester.getTopLeft(find.widgetWithText(WebButton, 'Add Exam Date')).dx -
            tester.getTopRight(find.text('Later')).dx,
        closeTo(28, .01),
      );
    });

    testWidgets('the header ring is whole and closed, dark=$dark (4N-7)',
        (tester) async {
      await mount(
        tester,
        HomeWebNotice(
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          onClose: () {},
          onToggle: () {},
          primaryLabel: 'Add Exam Date',
          onPrimary: () {},
        ),
        dark: dark,
      );
      final card = tester.getRect(find.byType(HomeWebNotice));
      final header = find.ancestor(
        of: find.text('Add your exam date'),
        matching: find.byType(TextButton),
      );
      // The header sits one pixel inside the card's own rule, so the 2 px ring
      // is not half under it, and the card keeps its 52 px header.
      expect(tester.getTopLeft(header).dx, card.left + 1);
      expect(tester.getTopLeft(header).dy, card.top + 1);
      expect(tester.getSize(header).height, 50);
      expect(tester.getSize(find.byType(HomeWebNotice)).height, 52);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final material = tester.widget<Material>(
        find.descendant(of: header, matching: find.byType(Material)).first,
      );
      final shape = material.shape! as RoundedRectangleBorder;
      expect(shape.side.width, 2);
      // Rounded on the right too, where the dismiss button begins.
      final radius = shape.borderRadius as BorderRadius;
      expect(radius.topRight, const Radius.circular(10));
      expect(radius.bottomRight, const Radius.circular(10));
    });
  }

  Future<void> mountStrip(WidgetTester tester, double window) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    tester.view.physicalSize = Size(window, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const notice = HomeNotice(
      kind: HomeNoticeKind.monthOnly,
      title: 'Do you know the day of your CSE Pro?',
      detail: 'Until then, your plan is paced to the end of November.',
      dismissalToken: '2026-11-01',
      primaryLabel: 'Pick the Day',
      secondaryLabel: 'Not Yet',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          nowProvider.overrideWithValue(() => DateTime(2026, 11, 5)),
          homeNoticeProvider.overrideWith((ref) async => notice),
        ],
        child: MaterialApp(
          theme: buildDarkTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(window, 900),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.fromLTRB(274, 28, 44, 0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: HomeNoticeStrip(
                      onDate: (_) {},
                      onRoute: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Do you know the day of your CSE Pro?'));
    await tester.pumpAndSettle();
  }

  for (final window in [1440.0, 1280.0]) {
    testWidgets(
        'month-only chips are whole and inside the 18 px padding at $window '
        '(4N-4, 5Q-1)', (tester) async {
      await mountStrip(tester, window);
      final card = tester.getRect(find.byType(HomeWebNotice));
      // Same left and right edges as the text and the buttons, and no chip is
      // cut: every chip is whole inside them (5Q-1).
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('notice-day-5'))).dx,
        card.left + 18,
      );
      final chips = find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('notice-day-'),
      );
      expect(chips, findsWidgets);
      for (final element in chips.evaluate()) {
        final rect = tester.getRect(find.byWidget(element.widget));
        expect(rect.right, lessThanOrEqualTo(card.right - 18));
        expect(rect.left, greaterThanOrEqualTo(card.left + 18));
      }
      // The row wraps instead of scrolling or clipping.
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('notice-day-5')),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });
  }
}
