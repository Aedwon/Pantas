import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/platform/install/install_providers.dart';

import 'fake_install_platform.dart';

void main() {
  late FakeInstallPlatform platform;
  late InMemoryInstallMemory memory;
  late DateTime now;

  ProviderContainer containerFor() {
    final container = ProviderContainer(
      overrides: [
        installPlatformProvider.overrideWithValue(platform),
        installMemoryProvider.overrideWithValue(memory),
        installClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    platform = FakeInstallPlatform();
    memory = InMemoryInstallMemory();
    now = DateTime.utc(2026, 11);
  });

  test('no install path means nothing is offered', () {
    expect(
      containerFor().read(installControllerProvider),
      InstallPath.none,
    );
  });

  test('Not Now hides the offer and the answer is remembered', () {
    platform.isIosSafari = true;
    final container = containerFor();
    expect(
      container.read(installControllerProvider),
      InstallPath.iosInstructions,
    );
    container.read(installControllerProvider.notifier).notNow();
    expect(container.read(installControllerProvider), InstallPath.none);
    expect(memory.dismissals, 1);
  });

  test('the offer returns after 30 days and a second Not Now ends it', () {
    platform.isIosSafari = true;
    final first = containerFor();
    first.read(installControllerProvider.notifier).notNow();
    now = now.add(const Duration(days: 30));
    final later = containerFor();
    expect(later.read(installControllerProvider), InstallPath.iosInstructions);
    later.read(installControllerProvider.notifier).notNow();
    now = now.add(const Duration(days: 500));
    expect(
      containerFor().read(installControllerProvider),
      InstallPath.none,
    );
  });

  test('a late browser install event turns the offer on', () {
    final container = containerFor();
    expect(container.read(installControllerProvider), InstallPath.none);
    platform
      ..hasNativePrompt = true
      ..emitChange();
    return Future<void>.delayed(Duration.zero).then((_) {
      expect(container.read(installControllerProvider), InstallPath.native);
    });
  });

  test('accepting the browser dialog hides the card and keeps storage',
      () async {
    platform.hasNativePrompt = true;
    final container = containerFor();
    await container.read(installControllerProvider.notifier).install();
    expect(platform.promptCalls, 1);
    expect(platform.persistCalls, 1);
    expect(memory.installed, isTrue);
    expect(container.read(installControllerProvider), InstallPath.none);
  });

  test('closing the browser dialog counts as Not Now', () async {
    platform
      ..hasNativePrompt = true
      ..result = InstallPromptResult.dismissed;
    final container = containerFor();
    await container.read(installControllerProvider.notifier).install();
    expect(memory.dismissals, 1);
    expect(platform.persistCalls, 0);
    expect(container.read(installControllerProvider), InstallPath.none);
  });

  test('an install reported by the browser hides the card', () async {
    platform.hasNativePrompt = true;
    final container = containerFor();
    expect(container.read(installControllerProvider), InstallPath.native);
    platform
      ..hasNativePrompt = false
      ..installedThisSession = true
      ..emitChange();
    await Future<void>.delayed(Duration.zero);
    expect(memory.installed, isTrue);
    expect(container.read(installControllerProvider), InstallPath.none);
  });

  test('a new install event clears a remembered install', () {
    memory.installed = true;
    platform.hasNativePrompt = true;
    final container = containerFor();
    expect(container.read(installControllerProvider), InstallPath.native);
    expect(memory.installed, isFalse);
  });

  test('installed and running standalone is never offered', () {
    platform
      ..isStandalone = true
      ..isIosSafari = true
      ..hasNativePrompt = true;
    expect(
      containerFor().read(installControllerProvider),
      InstallPath.none,
    );
  });
}
