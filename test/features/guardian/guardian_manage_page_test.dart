import 'dart:async';
import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/presentation/guardian_manage_page.dart';

import 'fake_guardian_gateway.dart';

class _Sink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

const _title = 'Manage permission';
const _lead =
    "You confirmed your child's Pantas account. You can change this at any "
    'time.';
const _sharing = 'Allow optional usage sharing';
const _help =
    'Helps us improve Pantas. Your child can turn it off at any time.';
const _withdraw = 'Withdraw Permission';
const _dialogTitle = 'Withdraw permission?';
const _dialogBody =
    'Your child is signed out, and their account and study records are '
    'deleted. This cannot be undone. It does not cancel an app store '
    'subscription.';
// Board MS_States draws a Notice with a title and a text. The page shows the
// confirm page's existing retry line with both texts until the lead rules.
const _failedTitle = 'Your change was not saved. Check your connection, then '
    'try again.';

void main() {
  late FakeGuardianGateway gateway;
  late _Sink sink;
  setUp(() {
    gateway = FakeGuardianGateway();
    sink = _Sink();
  });

  Future<void> pump(
    WidgetTester tester, {
    String? token = 'm1',
    Brightness brightness = Brightness.light,
    Size size = const Size(390, 844),
    bool web = false,
    double scale = 1,
  }) async {
    if (web) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
    }
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          guardianGatewayProvider.overrideWithValue(gateway),
          telemetryProvider.overrideWithValue(sink),
        ],
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: MaterialApp(
            theme: brightness == Brightness.dark
                ? buildDarkTheme(web: web)
                : buildLightTheme(web: web),
            home: GuardianManagePage(token: token),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool switchValue(WidgetTester tester) =>
      tester.widget<PantasSwitch>(find.byType(PantasSwitch)).value;

  Future<void> tapSwitch(WidgetTester tester) async {
    await tester.tap(find.byType(PantasSwitch));
    await tester.pump();
  }

  Future<void> openWithdraw(WidgetTester tester) async {
    await tester.ensureVisible(find.text(_withdraw));
    await tester.tap(find.text(_withdraw));
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    for (final entry in {
      'phone': (const Size(390, 844), false),
      'wide web': (const Size(1440, 900), true),
    }.entries) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
            'the active page says the approved copy: ${entry.key} '
            '$brightness $scale', (tester) async {
          await pump(
            tester,
            brightness: brightness,
            size: entry.value.$1,
            web: entry.value.$2,
            scale: scale,
          );
          expect(find.text(_title), findsOneWidget);
          expect(find.text(_lead), findsOneWidget);
          expect(find.text(_sharing), findsOneWidget);
          expect(find.text(_help), findsOneWidget);
          expect(find.text(_withdraw), findsOneWidget);
          expect(find.byType(PantasSwitch), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  for (final web in [false, true]) {
    for (final allowed in [false, true]) {
      testWidgets(
          'the sharing row tells assistive tools it is a switch that is '
          '${allowed ? 'on' : 'off'}, web $web', (tester) async {
        final handle = tester.ensureSemantics();
        gateway.manage = GuardianManageActive(sharingAllowed: allowed);
        await pump(
          tester,
          web: web,
          size: web ? const Size(1440, 900) : const Size(390, 844),
        );
        final node = tester.getSemantics(find.text(_sharing));
        final toggled = node.flagsCollection.isToggled;
        final canTap = node.getSemanticsData().hasAction(SemanticsAction.tap);
        handle.dispose();
        expect(toggled, allowed ? Tristate.isTrue : Tristate.isFalse);
        expect(canTap, isTrue);
      });
    }
  }

  for (final web in [false, true]) {
    testWidgets('the help line wraps instead of being cut off, web $web',
        (tester) async {
      await pump(
        tester,
        web: web,
        size: web ? const Size(1440, 900) : const Size(390, 844),
      );
      final help = tester.widget<Text>(find.text(_help));
      expect(help.maxLines, isNull);
      expect(help.overflow, isNot(TextOverflow.ellipsis));
    });
  }

  testWidgets('opening the page reads and changes nothing', (tester) async {
    await pump(tester);
    expect(gateway.sharingCalls, isEmpty);
    expect(gateway.withdrawCalls, isEmpty);
  });

  testWidgets('the switch starts off when the guardian has not allowed sharing',
      (tester) async {
    await pump(tester);
    expect(switchValue(tester), isFalse);
  });

  testWidgets('the switch starts on when the guardian allowed sharing',
      (tester) async {
    gateway.manage = const GuardianManageActive(sharingAllowed: true);
    await pump(tester);
    expect(switchValue(tester), isTrue);
  });

  testWidgets('turning the switch on applies at once and calls the server',
      (tester) async {
    final gate = gateway.sharingGate = Completer<void>();
    await pump(tester, token: 'tok');
    await tapSwitch(tester);
    // The call is still out, and the switch already shows the new value.
    expect(switchValue(tester), isTrue);
    expect(gateway.sharingCalls.single, (token: 'tok', allowed: true));
    gate.complete();
    await tester.pumpAndSettle();
    expect(switchValue(tester), isTrue);
    expect(find.text(_failedTitle), findsNothing);
  });

  testWidgets('turning the switch off sends allowed false', (tester) async {
    gateway.manage = const GuardianManageActive(sharingAllowed: true);
    await pump(tester, token: 'tok');
    await tapSwitch(tester);
    await tester.pumpAndSettle();
    expect(gateway.sharingCalls.single, (token: 'tok', allowed: false));
    expect(switchValue(tester), isFalse);
  });

  testWidgets('a failed change returns the switch to its old value and says so',
      (tester) async {
    gateway.sharingFailure = const GuardianGatewayException('unavailable');
    await pump(tester);
    await tapSwitch(tester);
    await tester.pumpAndSettle();
    expect(switchValue(tester), isFalse);
    expect(find.text(_failedTitle), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(sink.errors, hasLength(1));
  });

  testWidgets('a failed change off returns the switch to on', (tester) async {
    gateway
      ..manage = const GuardianManageActive(sharingAllowed: true)
      ..sharingFailure = const GuardianGatewayException('unavailable');
    await pump(tester);
    await tapSwitch(tester);
    await tester.pumpAndSettle();
    expect(switchValue(tester), isTrue);
    expect(find.text(_failedTitle), findsOneWidget);
  });

  testWidgets('Try Again repeats the change and clears the notice',
      (tester) async {
    gateway.sharingFailure = const GuardianGatewayException('unavailable');
    await pump(tester, token: 'tok');
    await tapSwitch(tester);
    await tester.pumpAndSettle();
    gateway.sharingFailure = null;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(gateway.sharingCalls, [
      (token: 'tok', allowed: true),
      (token: 'tok', allowed: true),
    ]);
    expect(switchValue(tester), isTrue);
    expect(find.text(_failedTitle), findsNothing);
  });

  testWidgets('the server closing the link mid-change shows the closed link',
      (tester) async {
    gateway.sharingResult = const GuardianManageClosed();
    await pump(tester);
    await tapSwitch(tester);
    await tester.pumpAndSettle();
    expect(find.text('This link no longer works'), findsOneWidget);
    expect(find.byType(PantasSwitch), findsNothing);
  });

  group('withdraw', () {
    testWidgets('opens one destructive dialog and calls nothing yet',
        (tester) async {
      await pump(tester);
      await openWithdraw(tester);
      final dialog = tester.widget<CenteredDialog>(find.byType(CenteredDialog));
      expect(dialog.destructive, isTrue);
      expect(dialog.title, _dialogTitle);
      expect(dialog.message, _dialogBody);
      expect(dialog.secondaryLabel, 'Cancel');
      expect(dialog.primaryLabel, 'Withdraw');
      expect(gateway.withdrawCalls, isEmpty);
    });

    for (final web in [false, true]) {
      testWidgets('the safe choice comes first and Withdraw last, web $web',
          (tester) async {
        await pump(
          tester,
          web: web,
          size: web ? const Size(1440, 900) : const Size(390, 844),
        );
        await openWithdraw(tester);
        final cancel = tester.getCenter(
          find.descendant(
            of: find.byType(CenteredDialog),
            matching: find.text('Cancel'),
          ),
        );
        final withdraw = tester.getCenter(
          find.descendant(
            of: find.byType(CenteredDialog),
            matching: find.text('Withdraw'),
          ),
        );
        expect(cancel.dx, lessThan(withdraw.dx));
      });
    }

    testWidgets('a tap outside the dialog does not close it', (tester) async {
      await pump(tester);
      await openWithdraw(tester);
      await tester.tapAt(const Offset(2, 2));
      await tester.pumpAndSettle();
      expect(find.byType(CenteredDialog), findsOneWidget);
    });

    testWidgets('Cancel closes the dialog and withdraws nothing',
        (tester) async {
      await pump(tester);
      await openWithdraw(tester);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(CenteredDialog), findsNothing);
      expect(gateway.withdrawCalls, isEmpty);
      expect(find.text(_title), findsOneWidget);
    });

    testWidgets('Withdraw calls the server and shows the withdrawn page',
        (tester) async {
      await pump(tester, token: 'tok');
      await openWithdraw(tester);
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(gateway.withdrawCalls, ['tok']);
      expect(find.text('Permission withdrawn'), findsOneWidget);
      expect(
        find.text(
          "Your child's account is closed and is being deleted. You can "
          'close this page.',
        ),
        findsOneWidget,
      );
      expect(find.byType(PantasSwitch), findsNothing);
      expect(find.text(_withdraw), findsNothing);
    });

    testWidgets('a failed withdrawal keeps the page and offers Try Again',
        (tester) async {
      gateway.withdrawFailure = const GuardianGatewayException('unavailable');
      await pump(tester);
      await openWithdraw(tester);
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(find.byType(CenteredDialog), findsNothing);
      expect(find.text(_title), findsOneWidget);
      expect(find.text(_failedTitle), findsOneWidget);
      expect(sink.errors, hasLength(1));
      // Try Again asks again before anything is deleted.
      gateway.withdrawFailure = null;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.byType(CenteredDialog), findsOneWidget);
      expect(gateway.withdrawCalls, hasLength(1));
    });

    testWidgets('a link that stopped working shows the closed link',
        (tester) async {
      gateway.withdrawTo = GuardianWithdrawal.closed;
      await pump(tester);
      await openWithdraw(tester);
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(find.text('This link no longer works'), findsOneWidget);
    });

    testWidgets('a guardian who has not confirmed sees the confirm-first page',
        (tester) async {
      gateway.withdrawTo = GuardianWithdrawal.notConfirmed;
      await pump(tester);
      await openWithdraw(tester);
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm the account first'), findsOneWidget);
    });
  });

  group('other states', () {
    testWidgets('a link that no longer works', (tester) async {
      gateway.manage = const GuardianManageClosed();
      await pump(tester);
      expect(find.text('This link no longer works'), findsOneWidget);
      expect(
        find.text('The account was closed, or a newer link replaced this one.'),
        findsOneWidget,
      );
      expect(find.byType(PantasSwitch), findsNothing);
      expect(find.text(_withdraw), findsNothing);
    });

    testWidgets('a missing token shows the closed link without calling out',
        (tester) async {
      gateway.manageFailure =
          const GuardianGatewayException('must-not-be-called');
      await pump(tester, token: null);
      expect(find.text('This link no longer works'), findsOneWidget);
    });

    testWidgets('the guardian has not confirmed yet', (tester) async {
      gateway.manage = const GuardianManageNotConfirmed();
      await pump(tester);
      expect(find.text('Confirm the account first'), findsOneWidget);
      expect(
        find.text(
          'Use the Review and Confirm link in the same email. After that, '
          'this page lets you manage permission.',
        ),
        findsOneWidget,
      );
      expect(find.byType(PantasSwitch), findsNothing);
    });

    testWidgets('loading shows no page text and then the page', (tester) async {
      final gate = Completer<void>();
      final slow = _SlowGateway(gateway, gate.future);
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guardianGatewayProvider.overrideWithValue(slow),
            telemetryProvider.overrideWithValue(sink),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const GuardianManagePage(token: 'm1'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(_title), findsNothing);
      expect(find.text('This link no longer works'), findsNothing);
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text(_title), findsOneWidget);
    });

    testWidgets('a failed load shows a retry that loads the page',
        (tester) async {
      gateway.manageFailure = const GuardianGatewayException('unavailable');
      await pump(tester);
      expect(find.text('Try Again'), findsOneWidget);
      expect(sink.errors, hasLength(1));
      gateway.manageFailure = null;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text(_title), findsOneWidget);
    });
  });
}

/// Delegates to the fake but waits on its gate before reading the manage page.
class _SlowGateway extends FakeGuardianGateway {
  _SlowGateway(this._inner, this._gate);
  final FakeGuardianGateway _inner;
  final Future<void> _gate;
  @override
  Future<GuardianManageView> readManage(String token) async {
    await _gate;
    return _inner.readManage(token);
  }
}
