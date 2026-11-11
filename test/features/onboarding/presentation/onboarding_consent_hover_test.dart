import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  Future<GoRouter> pumpWide(WidgetTester tester, {required bool dark}) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => Scaffold(
            body: OnboardingConsentStep(onCompleted: () {}),
          ),
        ),
        GoRoute(
          path: '/legal/terms',
          builder: (_, __) => const Scaffold(body: Text('Legal terms')),
        ),
        GoRoute(
          path: '/legal/privacy',
          builder: (_, __) => const Scaffold(body: Text('Legal privacy')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          routerConfig: router,
          // One-line labels: the row is as short as the board's 52 px content,
          // so it depends on the 56 px minimum to reach the board height.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(.5)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Finder rowButton(int index) => find
      .descendant(
        of: find.byType(CheckboxRow).at(index),
        matching: find.byType(TextButton),
      )
      .first;

  for (final dark in [false, true]) {
    testWidgets('hover fills the whole row edge to edge, square (dark $dark)',
        (tester) async {
      await pumpWide(tester, dark: dark);
      final card = tester.getRect(find.byType(WebCard));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(rowButton(0)));
      await tester.pumpAndSettle();

      final first = tester.getRect(rowButton(0));
      final second = tester.getRect(rowButton(1));
      // The dark card's edge is drawn over it and takes up no room (6T-11).
      const edge = 0.0;
      expect(first.left, closeTo(card.left + edge, .01));
      expect(first.right, closeTo(card.right - edge, .01));
      expect(first.top, closeTo(card.top + edge, .01));
      expect(first.height, 56);
      // The divider is the only thing between the two rows.
      expect(second.top - first.bottom, closeTo(.5, .01));
      // The acceptance sentence names study records, so it can run to a
      // second line. A row is never shorter than the minimum.
      expect(second.height, greaterThanOrEqualTo(56));

      final button = tester.widget<TextButton>(rowButton(0));
      final shape = button.style!.shape!.resolve({WidgetState.hovered})!
          as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.zero);
      final fill =
          button.style!.backgroundColor!.resolve({WidgetState.hovered});
      final tokens =
          tester.element(find.byType(OnboardingConsentStep)).webTokens;
      expect(fill, tokens.rowHover);
    });
  }

  testWidgets('a link inside the second row opens it and does not toggle',
      (tester) async {
    await pumpWide(tester, dark: true);
    await tester.tap(find.text('Terms of Service'));
    await tester.pumpAndSettle();
    expect(find.text('Legal terms'), findsOneWidget);
  });

  testWidgets('the whole row is the tap target', (tester) async {
    await pumpWide(tester, dark: false);
    final rect = tester.getRect(rowButton(0));
    // Near the top-right of the row, clear of the label and of the card's
    // rounded corner.
    await tester.tapAt(Offset(rect.right - 30, rect.top + 3));
    await tester.pump();
    expect(
      tester.widgetList<CheckboxRow>(find.byType(CheckboxRow)).first.selected,
      isTrue,
    );
  });
}
