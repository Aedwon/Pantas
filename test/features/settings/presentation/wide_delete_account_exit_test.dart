import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';

// The wide delete dialog plays its exit before its route pops, whichever way
// it is closed.
void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<NavigatorState> pumpDialog(
    WidgetTester tester, {
    bool still = false,
    bool pushed = true,
  }) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final page = DeleteAccountPage(
      isAnonymous: false,
      entitlement: const SettingsEntitlementSnapshot.free(),
      dpoEmail: defaultLegalContact.dpoEmail,
      onDelete: () async {},
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: still),
            child: child!,
          ),
          home: pushed ? const Scaffold(body: Text('Account')) : page,
        ),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    if (pushed) {
      unawaited(
        navigator.push<void>(
          PageRouteBuilder<void>(
            pageBuilder: (_, __, ___) => page,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
      );
    }
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    return navigator;
  }

  double dialogFade(WidgetTester tester) {
    var value = 1.0;
    for (final element in find
        .ancestor(of: find.byType(Dialog), matching: find.byType(Opacity))
        .evaluate()) {
      value *= (element.widget as Opacity).opacity;
    }
    return value;
  }

  testWidgets('Keep My Account fades the dialog, then pops the route',
      (tester) async {
    final navigator = await pumpDialog(tester);
    expect(dialogFade(tester), 1);
    await tester.tap(find.text('Keep My Account'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(navigator.canPop(), isTrue);
    expect(find.byType(DeleteAccountPage), findsOneWidget);
    expect(dialogFade(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isFalse);
    expect(find.byType(DeleteAccountPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system Back plays the exit once and then pops', (tester) async {
    final navigator = await pumpDialog(tester);
    await navigator.maybePop();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(navigator.canPop(), isTrue);
    expect(dialogFade(tester), inExclusiveRange(0, 1));
    await navigator.maybePop();
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isFalse);
    expect(find.byType(DeleteAccountPage), findsNothing);
  });

  testWidgets('a page opened by address keeps its dialog and its Back',
      (tester) async {
    final navigator = await pumpDialog(tester, pushed: false);
    await tester.tap(find.text('Keep My Account'));
    await tester.pumpAndSettle();
    expect(dialogFade(tester), 1);
    expect(await navigator.maybePop(), isFalse);
    expect(find.byType(DeleteAccountPage), findsOneWidget);
  });

  testWidgets('a pop that already happened leaves nothing behind',
      (tester) async {
    final navigator = await pumpDialog(tester);
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.byType(DeleteAccountPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion pops at once', (tester) async {
    final navigator = await pumpDialog(tester, still: true);
    await tester.tap(find.text('Keep My Account'));
    await tester.pump();
    expect(navigator.canPop(), isFalse);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
