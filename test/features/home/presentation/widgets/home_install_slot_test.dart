import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/platform/install/install_providers.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_install_offer.dart';
import 'package:pantas/features/home/presentation/widgets/home_install_slot.dart';

import '../../../../core/platform/install/fake_install_platform.dart';

class _Harness {
  _Harness({
    FakeInstallPlatform? platform,
    InMemoryInstallMemory? memory,
    this.finished = true,
    this.brightness = Brightness.light,
  })  : platform = platform ?? FakeInstallPlatform(),
        memory = memory ?? InMemoryInstallMemory();

  final FakeInstallPlatform platform;
  final InMemoryInstallMemory memory;
  final bool finished;
  final Brightness brightness;
  DateTime now = DateTime.utc(2026, 11);

  Widget build() => ProviderScope(
        overrides: [
          installPlatformProvider.overrideWithValue(platform),
          installMemoryProvider.overrideWithValue(memory),
          installClockProvider.overrideWithValue(() => now),
          homeFirstLessonFinishedProvider.overrideWith((ref) async => finished),
        ],
        child: MaterialApp(
          theme: brightness == Brightness.dark
              ? buildDarkTheme(web: true)
              : buildLightTheme(web: true),
          home: const Scaffold(
            body: SingleChildScrollView(child: HomeInstallSlot()),
          ),
        ),
      );
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized();
    view.platformDispatcher.views.first.physicalSize = const Size(390, 1200);
    view.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized();
    view.platformDispatcher.views.first.resetPhysicalSize();
    view.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('never shows at first open, before a finished lesson',
      (tester) async {
    final h = _Harness(
      platform: FakeInstallPlatform(hasNativePrompt: true),
      finished: false,
    );
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('Install Pantas'), findsNothing);
  });

  testWidgets('shows after the first finished lesson', (tester) async {
    final h = _Harness(platform: FakeInstallPlatform(hasNativePrompt: true));
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('Install Pantas'), findsOneWidget);
    expect(find.text('Not Now'), findsOneWidget);
  });

  testWidgets('is hidden when the app already runs installed', (tester) async {
    final h = _Harness(
      platform: FakeInstallPlatform(isStandalone: true, hasNativePrompt: true),
    );
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('Install Pantas'), findsNothing);
  });

  testWidgets('is hidden when the browser offers no install path',
      (tester) async {
    await tester.pumpWidget(_Harness().build());
    await tester.pumpAndSettle();
    expect(find.text('Install Pantas'), findsNothing);
    expect(find.text('Show Me How'), findsNothing);
  });

  testWidgets('Not Now hides the card and remembers it', (tester) async {
    final h = _Harness(platform: FakeInstallPlatform(hasNativePrompt: true));
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not Now'));
    await tester.pumpAndSettle();
    expect(find.text('Install Pantas'), findsNothing);
    expect(h.memory.dismissals, 1);
  });

  testWidgets('a remembered Not Now keeps it hidden on the next visit',
      (tester) async {
    final h = _Harness(
      platform: FakeInstallPlatform(hasNativePrompt: true),
      memory: InMemoryInstallMemory(
        dismissals: 1,
        lastDismissedAt: DateTime.utc(2026, 10, 20),
      ),
    );
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    expect(find.text('Install Pantas'), findsNothing);
  });

  testWidgets('Install Pantas opens the browser dialog', (tester) async {
    final h = _Harness(platform: FakeInstallPlatform(hasNativePrompt: true));
    await tester.pumpWidget(h.build());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Install Pantas'));
    await tester.pumpAndSettle();
    expect(h.platform.promptCalls, 1);
    expect(find.text('Install Pantas'), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('iPhone Show Me How opens the steps sheet, ${brightness.name}',
        (tester) async {
      final h = _Harness(
        platform: FakeInstallPlatform(isIosSafari: true),
        brightness: brightness,
      );
      await tester.pumpWidget(h.build());
      await tester.pumpAndSettle();
      expect(find.text('Install Pantas'), findsNothing);
      await tester.tap(find.text('Show Me How'));
      await tester.pumpAndSettle();
      expect(h.platform.promptCalls, 0);
      expect(find.text('Add Pantas to your Home Screen'), findsOneWidget);
      expect(find.text('Tap Add to Home Screen'), findsOneWidget);
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();
      expect(find.text('Add Pantas to your Home Screen'), findsNothing);
      // Closing the sheet does not dismiss the card.
      expect(find.text('Show Me How'), findsOneWidget);
    });
  }
}
