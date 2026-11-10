import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';

const _rangeMessage = 'Enter an age from 5 to 100.';
const _tip = 'Hold + or − to go faster.';

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  final minus = find.byKey(const ValueKey('age-minus'));
  final plus = find.byKey(const ValueKey('age-plus'));

  Widget step({VoidCallback? passed, VoidCallback? guardian}) => ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: OnboardingAgeGateStep(
          onAgeGatePassed: passed ?? () {},
          onGuardianNeeded: guardian,
          onBack: () {},
        ),
      );

  Future<void> pumpPhone(
    WidgetTester tester, {
    bool disableAnimations = true,
    Widget? child,
  }) =>
      pumpAccessibilitySurface(
        tester,
        child ?? step(),
        viewportSize: const Size(390, 844),
        disableAnimations: disableAnimations,
      );

  Future<void> pumpWide(
    WidgetTester tester, {
    bool disableAnimations = true,
  }) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    const size = Size(1440, 900);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            disableAnimations: disableAnimations,
          ),
          child: Scaffold(body: _FrameHost(child: step())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String age(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;
  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
  }

  Widget continueButton() => find
      .widgetWithText(PantasButton, 'Continue')
      .evaluate()
      .map((e) => e.widget)
      .followedBy(
        find
            .widgetWithText(WebButton, 'Continue')
            .evaluate()
            .map((e) => e.widget),
      )
      .single;
  VoidCallback? continueAction() {
    final button = continueButton();
    return button is PantasButton
        ? button.onPressed
        : (button as WebButton).onPressed;
  }

  final layouts =
      <String, Future<void> Function(WidgetTester, {bool disableAnimations})>{
    'phone': pumpPhone,
    'wide': pumpWide,
  };

  for (final layout in layouts.entries) {
    group('${layout.key}:', () {
      testWidgets('asks "How old are you?" with the privacy line, from 17',
          (tester) async {
        await layout.value(tester);
        expect(find.text('How old are you?'), findsOneWidget);
        expect(
          find.text('We only ask this once and never keep it.'),
          findsOneWidget,
        );
        expect(age(tester), '17');
        expect(continueAction(), isNotNull);
      });

      testWidgets('a tap on minus or plus changes the age by one',
          (tester) async {
        await layout.value(tester);
        await tester.tap(plus);
        await tester.pump();
        expect(age(tester), '18');
        await tester.tap(minus);
        await tester.tap(minus);
        await tester.pump();
        expect(age(tester), '16');
      });

      testWidgets('activating a step button without a pointer steps once',
          (tester) async {
        await layout.value(tester);
        final handle = tester.ensureSemantics();
        tester.semantics.tap(find.semantics.byLabel('1 year older'));
        await tester.pump();
        expect(age(tester), '18');
        handle.dispose();
      });

      testWidgets('the age takes digits only, at most three', (tester) async {
        await layout.value(tester);
        await type(tester, 'a1b2c34');
        expect(age(tester), '123');
      });

      testWidgets(
          'an age outside 5 to 100 shows the error and turns Continue off',
          (tester) async {
        await layout.value(tester);
        for (final text in ['4', '101', '999', '0']) {
          await type(tester, text);
          final message = find.text(_rangeMessage);
          expect(message, findsOneWidget, reason: text);
          final color = tester.widget<Text>(message).style!.color;
          final theme = Theme.of(tester.element(message));
          final colors = theme.brightness == Brightness.dark
              ? PantasColors.dark
              : PantasColors.light;
          expect(color, colors.dangerText, reason: text);
          expect(continueAction(), isNull, reason: text);
        }
        await type(tester, '5');
        expect(find.text(_rangeMessage), findsNothing);
        expect(continueAction(), isNotNull);
        await type(tester, '100');
        expect(find.text(_rangeMessage), findsNothing);
        await type(tester, '');
        expect(find.text(_rangeMessage), findsNothing);
        expect(continueAction(), isNull);
      });

      testWidgets('Continue keeps its place when the message comes and goes',
          (tester) async {
        await layout.value(tester);
        final steady = tester.getTopLeft(find.text('Continue')).dy;
        for (final text in ['4', '300', '40', '', '3']) {
          await type(tester, text);
          expect(
            tester.getTopLeft(find.text('Continue')).dy,
            steady,
            reason: text,
          );
        }
      });

      testWidgets(
          'keys: arrows by 1, page keys by 10, Home and End to the ends',
          (tester) async {
        await layout.value(tester);
        await tester.tap(find.byType(TextField));
        await tester.pump();
        Future<void> key(LogicalKeyboardKey k) async {
          await tester.sendKeyEvent(k);
          await tester.pump();
        }

        await key(LogicalKeyboardKey.arrowUp);
        expect(age(tester), '18');
        await key(LogicalKeyboardKey.arrowDown);
        await key(LogicalKeyboardKey.arrowDown);
        expect(age(tester), '16');
        await key(LogicalKeyboardKey.pageUp);
        expect(age(tester), '26');
        await key(LogicalKeyboardKey.pageDown);
        expect(age(tester), '16');
        await key(LogicalKeyboardKey.pageDown);
        expect(age(tester), '6');
        await key(LogicalKeyboardKey.pageDown);
        expect(age(tester), '5');
        await key(LogicalKeyboardKey.end);
        expect(age(tester), '100');
        await key(LogicalKeyboardKey.pageUp);
        expect(age(tester), '100');
        await key(LogicalKeyboardKey.home);
        expect(age(tester), '5');
      });

      testWidgets('the number is named Age and carries its range',
          (tester) async {
        await layout.value(tester);
        final handle = tester.ensureSemantics();
        final data =
            tester.getSemantics(find.byType(TextField)).getSemanticsData();
        expect(data.label, 'Age');
        expect(data.value, '17');
        expect(data.minValue, '5');
        expect(data.maxValue, '100');
        expect(data.flagsCollection.isTextField, isTrue);
        await tester.tap(plus);
        await tester.pump();
        expect(
          tester.getSemantics(find.byType(TextField)).getSemanticsData().value,
          '18',
        );
        handle.dispose();
      });

      testWidgets('the step buttons are named for a screen reader',
          (tester) async {
        await layout.value(tester);
        final handle = tester.ensureSemantics();
        await tester.pump();
        expect(find.bySemanticsLabel('1 year younger'), findsOneWidget);
        expect(find.bySemanticsLabel('1 year older'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('three quick taps show the tip and a hold clears it',
          (tester) async {
        await layout.value(tester);
        expect(find.text(_tip), findsNothing);
        for (var i = 0; i < 2; i++) {
          await tester.tap(plus);
          await tester.pump(const Duration(milliseconds: 200));
        }
        expect(find.text(_tip), findsNothing);
        await tester.tap(plus);
        await tester.pump();
        expect(find.text(_tip), findsOneWidget);
        final hold = await tester.startGesture(tester.getCenter(plus));
        await tester.pump(const Duration(milliseconds: 450));
        await hold.up();
        await tester.pump();
        expect(find.text(_tip), findsNothing);
      });

      testWidgets('taps more than 1.5 s apart do not count together',
          (tester) async {
        await layout.value(tester);
        for (var i = 0; i < 3; i++) {
          await tester.tap(plus);
          await tester.pump(const Duration(milliseconds: 1600));
        }
        expect(find.text(_tip), findsNothing);
      });

      testWidgets('a hold repeats, speeds up, and stops at 100 and at 5',
          (tester) async {
        await layout.value(tester);
        final up = await tester.startGesture(tester.getCenter(plus));
        await tester.pump();
        expect(age(tester), '18');
        await tester.pump(const Duration(milliseconds: 399));
        expect(age(tester), '18');
        await tester.pump(const Duration(milliseconds: 1));
        expect(age(tester), '19');
        await tester.pump(const Duration(milliseconds: 140));
        expect(age(tester), '20');
        await tester.pump(const Duration(seconds: 12));
        expect(age(tester), '100');
        await up.up();
        await tester.pump();
        expect(age(tester), '100');
        final down = await tester.startGesture(tester.getCenter(minus));
        await tester.pump(const Duration(seconds: 12));
        expect(age(tester), '5');
        await down.up();
        await tester.pump();
        expect(age(tester), '5');
      });

      testWidgets('a hold stops on release', (tester) async {
        await layout.value(tester);
        final up = await tester.startGesture(tester.getCenter(plus));
        await tester.pump(const Duration(milliseconds: 540));
        await up.up();
        final held = age(tester);
        await tester.pump(const Duration(seconds: 2));
        expect(age(tester), held);
      });

      testWidgets('the number rolls in from the side it came from and fades',
          (tester) async {
        await layout.value(tester, disableAnimations: false);
        final roll = find.byKey(const ValueKey('age-roll'));
        FractionalTranslation slide() => tester.widget<FractionalTranslation>(
              find.descendant(
                of: roll,
                matching: find.byType(FractionalTranslation),
              ),
            );
        double opacity() => tester
            .widget<Opacity>(
              find.descendant(of: roll, matching: find.byType(Opacity)),
            )
            .opacity;
        await tester.tap(plus);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        expect(slide().translation.dy, greaterThan(0));
        expect(slide().translation.dy, lessThanOrEqualTo(.45));
        expect(opacity(), lessThan(1));
        await tester.pumpAndSettle();
        expect(slide().translation.dy, 0);
        expect(opacity(), 1);
        await tester.tap(minus);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        expect(slide().translation.dy, lessThan(0));
        await tester.pumpAndSettle();
      });

      testWidgets('under reduced motion the number only fades', (tester) async {
        await layout.value(tester);
        final roll = find.byKey(const ValueKey('age-roll'));
        await tester.tap(plus);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        final slide = tester.widget<FractionalTranslation>(
          find.descendant(
            of: roll,
            matching: find.byType(FractionalTranslation),
          ),
        );
        expect(slide.translation, Offset.zero);
        final fade = tester.widget<Opacity>(
          find.descendant(of: roll, matching: find.byType(Opacity)),
        );
        expect(fade.opacity, lessThan(1));
        await tester.pumpAndSettle();
      });

      testWidgets('12 is blocked and the block persists', (tester) async {
        await layout.value(tester);
        await type(tester, '12');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text("Pantas isn't available yet"), findsOneWidget);
        expect(
          find.text("Sorry, this app isn't available for users under 13."),
          findsOneWidget,
        );
        final repo = AppPreferencesRepository(db);
        expect(await repo.blockedMinimumAge(), 13);
        expect(await repo.hasPassedAgeGate(), isFalse);
        await layout.value(tester);
        await tester.pumpAndSettle();
        expect(find.text("Pantas isn't available yet"), findsOneWidget);
      });

      for (final minor in ['13', '17']) {
        testWidgets('$minor goes to the guardian flow and saves "minor"',
            (tester) async {
          var passed = 0;
          var guardian = 0;
          await layout.value(tester);
          // Rebuild with callbacks.
          await _pumpWith(
            tester,
            layout.key == 'wide',
            db,
            passed: () => passed++,
            guardian: () => guardian++,
          );
          await type(tester, minor);
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          expect(passed, 0);
          expect(guardian, 1);
          final repo = AppPreferencesRepository(db);
          expect(await repo.ageGroup(), 'minor');
          expect(await repo.hasPassedAgeGate(), isFalse);
        });
      }

      testWidgets('18 saves "adult" and passes', (tester) async {
        var passed = 0;
        await _pumpWith(
          tester,
          layout.key == 'wide',
          db,
          passed: () => passed++,
          guardian: () => fail('an adult needs no guardian'),
        );
        await type(tester, '18');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(passed, 1);
        final repo = AppPreferencesRepository(db);
        expect(await repo.ageGroup(), 'adult');
        expect(await repo.hasPassedAgeGate(), isTrue);
      });

      testWidgets('Enter on a valid age continues', (tester) async {
        var passed = 0;
        await _pumpWith(
          tester,
          layout.key == 'wide',
          db,
          passed: () => passed++,
        );
        await type(tester, '30');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(passed, 1);
      });
    });
  }

  testWidgets('wide: the hint names the arrow keys with key hints',
      (tester) async {
    await pumpWide(tester);
    expect(find.text('Type it, or use'), findsOneWidget);
    expect(find.widgetWithText(WebKeyHint, '↑'), findsOneWidget);
    expect(find.widgetWithText(WebKeyHint, '↓'), findsOneWidget);
    expect(find.text('Back'), findsWidgets);
  });

  testWidgets('wide: the age field has focus as the step opens',
      (tester) async {
    await pumpWide(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
  });

  testWidgets('phone: the two step buttons share the row, 12 apart',
      (tester) async {
    await pumpPhone(tester);
    final left = tester.getRect(minus);
    final right = tester.getRect(plus);
    expect(left.height, 52);
    expect(right.height, 52);
    expect(left.width, right.width);
    expect(right.left - left.right, 12);
    expect(tester.getCenter(minus).dy, tester.getCenter(plus).dy);
  });

  testWidgets('wide: the control is one row, minus then number then plus',
      (tester) async {
    await pumpWide(tester);
    final m = tester.getCenter(minus);
    final n = tester.getCenter(find.byType(TextField));
    final p = tester.getCenter(plus);
    expect(m.dx, lessThan(n.dx));
    expect(n.dx, lessThan(p.dx));
    expect((m.dy - n.dy).abs(), lessThan(1));
    expect(tester.getSize(minus), const Size(44, 44));
  });

  testWidgets('save failure keeps the age and Retry works', (tester) async {
    var passed = 0;
    await pumpPhone(
      tester,
      child: ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appPreferencesRepositoryProvider
              .overrideWithValue(_FailingAgePreferences(db)),
        ],
        child: OnboardingAgeGateStep(onAgeGatePassed: () => passed++),
      ),
    );
    await type(tester, '42');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(passed, 0);
    expect(age(tester), '42');
    await tester.ensureVisible(find.text('Try Again'));
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(passed, 1);
  });

  testWidgets('Back from the next step shows the same age', (tester) async {
    final shown = ValueNotifier<bool>(true);
    addTearDown(shown.dispose);
    await pumpPhone(
      tester,
      child: ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: ValueListenableBuilder<bool>(
          valueListenable: shown,
          builder: (_, on, __) => on
              ? OnboardingAgeGateStep(onAgeGatePassed: () {})
              : const SizedBox(),
        ),
      ),
    );
    await type(tester, '29');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    shown.value = false;
    await tester.pump();
    shown.value = true;
    await tester.pump();
    expect(age(tester), '29');
  });

  for (final cell in [
    for (final width in [390.0, 320.0, 1440.0])
      for (final dark in [false, true])
        for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
  ]) {
    testWidgets('matrix: no overflow ($cell)', (tester) async {
      // The setup steps list in the frame overflows by itself at 200% text
      // (its own gap, shared by every step); the step is checked around it.
      final original = FlutterError.onError;
      addTearDown(() => FlutterError.onError = original);
      FlutterError.onError = (details) {
        final railOverflow = cell.width >= 1024 &&
            details.exceptionAsString().contains('overflowed') &&
            details
                .toDiagnosticsNode()
                .toStringDeep()
                .contains('OnboardingRail');
        if (!railOverflow) original?.call(details);
      };
      await pumpDs(
        tester,
        cell,
        cell.width >= 1024 ? _FrameHost(child: step()) : step(),
        scroll: false,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(TextField), findsOneWidget);
      await type(tester, '300');
      expect(find.text(_rangeMessage), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(plus);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _pumpWith(
  WidgetTester tester,
  bool wide,
  AppDatabase db, {
  VoidCallback? passed,
  VoidCallback? guardian,
}) async {
  final child = ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: OnboardingAgeGateStep(
      onAgeGatePassed: passed ?? () {},
      onGuardianNeeded: guardian,
      onBack: () {},
    ),
  );
  if (!wide) {
    await pumpAccessibilitySurface(
      tester,
      child,
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );
    return;
  }
  debugWebPlatformOverride = true;
  addTearDown(() => debugWebPlatformOverride = null);
  const size = Size(1440, 900);
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: true),
      home: MediaQuery(
        data: const MediaQueryData(size: size, disableAnimations: true),
        child: Scaffold(body: _FrameHost(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FrameHost extends StatefulWidget {
  const _FrameHost({required this.child});
  final Widget child;
  @override
  State<_FrameHost> createState() => _FrameHostState();
}

class _FrameHostState extends State<_FrameHost> {
  final _controller = OnboardingFrameController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingFrame(
        controller: _controller,
        enabled: true,
        resetToken: 'age',
        child: widget.child,
      );
}

class _FailingAgePreferences extends AppPreferencesRepository {
  _FailingAgePreferences(super.db);
  bool fail = true;
  @override
  Future<void> setPassedAgeGate({required bool value}) async {
    if (fail) {
      fail = false;
      throw StateError('private details');
    }
    await super.setPassedAgeGate(value: value);
  }
}
