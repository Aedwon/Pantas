import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_consent_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_welcome_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

/// A step slides in under `ExcludeFocus` for its first frames, as the
/// onboarding page builds it: it cannot take focus when it is built, so the
/// `autofocus` of the step is dropped. Keys must still work once it has
/// settled, with no click and no Tab.
class _Sliding extends StatefulWidget {
  const _Sliding({required this.child});
  final Widget child;
  @override
  State<_Sliding> createState() => _SlidingState();
}

class _SlidingState extends State<_Sliding>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) =>
            ExcludeFocus(excluding: _controller.value == 0, child: child!),
      );
}

void main() {
  late AppDatabase db;
  setUp(() {
    db = inMemoryDatabase();
    debugWebPlatformOverride = true;
  });
  tearDown(() {
    debugWebPlatformOverride = null;
    return db.close();
  });

  Future<void> pump(WidgetTester tester, Widget step) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWithValue(
            DriftSettingsRepository(db),
          ),
        ],
        child: MaterialApp(
          theme: buildDarkTheme(web: true),
          home: Scaffold(body: _Sliding(child: step)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> mouseClick(WidgetTester tester, Finder at) async {
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    final point = tester.getCenter(at);
    await mouse.addPointer(location: point);
    await mouse.down(point);
    await mouse.up();
    await tester.pumpAndSettle();
  }

  FocusNode fieldFocus(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).focusNode!;

  testWidgets('Welcome: Enter works the moment the step has settled',
      (tester) async {
    var advances = 0;
    await pump(tester, OnboardingWelcomeStep(onAdvance: () => advances++));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(advances, 1);
  });

  testWidgets('Terms: a mouse click on the box, then Enter, continues',
      (tester) async {
    var done = 0;
    await pump(tester, OnboardingConsentStep(onCompleted: () => done++));
    await mouseClick(tester, find.text('I agree to the '));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(done, 1);
  });

  testWidgets('Name: the field the board draws as active holds focus',
      (tester) async {
    await pump(tester, OnboardingNameStep(onCompleted: () {}));
    expect(fieldFocus(tester).hasPrimaryFocus, isTrue);
    await tester.enterText(find.byType(TextField), 'Ana');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Ana',
    );
  });

  testWidgets('Name: a click on bare page returns focus to the field',
      (tester) async {
    await pump(tester, OnboardingNameStep(onCompleted: () {}));
    // The field's own tap-outside handling drops its focus to the page.
    await mouseClick(tester, find.text('What should we call you?'));
    await tester.pump();
    await tester.pump();
    expect(fieldFocus(tester).hasPrimaryFocus, isTrue);
  });

  testWidgets('Year: the field holds focus with no click', (tester) async {
    await pump(
      tester,
      OnboardingAgeGateStep(currentYear: 2026, onAgeGatePassed: () {}),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasPrimaryFocus, isTrue);
  });
}
