import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/install/install_platform.dart';

import 'fake_install_platform.dart';

const _iphoneSafari =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 '
    '(KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1';
const _iphoneChrome =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 '
    '(KHTML, like Gecko) CriOS/130.0.0.0 Mobile/15E148 Safari/604.1';
const _iphoneFirefox =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 '
    '(KHTML, like Gecko) FxiOS/130.0 Mobile/15E148 Safari/605.1.15';
const _iphoneInApp =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 '
    '(KHTML, like Gecko) Mobile/15E148';
const _macSafari =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 '
    '(KHTML, like Gecko) Version/18.0 Safari/605.1.15';
const _androidChrome =
    'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/130.0.0.0 Mobile Safari/537.36';

void main() {
  group('isIosSafariEnvironment', () {
    bool check(String ua, {String platform = '', int touch = 0}) =>
        isIosSafariEnvironment(
          InstallEnvironment(
            userAgent: ua,
            platform: platform,
            maxTouchPoints: touch,
          ),
        );

    test('iPhone Safari counts', () {
      expect(check(_iphoneSafari, platform: 'iPhone', touch: 5), isTrue);
    });

    test('iPadOS reports a Mac, so a touch screen makes it an iPad', () {
      expect(check(_macSafari, platform: 'MacIntel', touch: 5), isTrue);
    });

    test('a real Mac without touch does not count', () {
      expect(check(_macSafari, platform: 'MacIntel'), isFalse);
    });

    test('other iOS browsers and in-app browsers do not count', () {
      expect(check(_iphoneChrome), isFalse);
      expect(check(_iphoneFirefox), isFalse);
      expect(check(_iphoneInApp), isFalse);
    });

    test('Android Chrome does not count', () {
      expect(
        check(_androidChrome, platform: 'Linux armv81', touch: 5),
        isFalse,
      );
    });
  });

  group('installPathFor', () {
    test('the browser install event gives the native path', () {
      final path = installPathFor(
        FakeInstallPlatform(hasNativePrompt: true),
        InMemoryInstallMemory(),
      );
      expect(path, InstallPath.native);
    });

    test('iPhone Safari gives the instructions path', () {
      final path = installPathFor(
        FakeInstallPlatform(isIosSafari: true),
        InMemoryInstallMemory(),
      );
      expect(path, InstallPath.iosInstructions);
    });

    test('a browser with no install path gives none', () {
      expect(
        installPathFor(FakeInstallPlatform(), InMemoryInstallMemory()),
        InstallPath.none,
      );
    });

    test('running installed gives none, even with an event or iOS', () {
      expect(
        installPathFor(
          FakeInstallPlatform(isStandalone: true, hasNativePrompt: true),
          InMemoryInstallMemory(),
        ),
        InstallPath.none,
      );
      expect(
        installPathFor(
          FakeInstallPlatform(isStandalone: true, isIosSafari: true),
          InMemoryInstallMemory(),
        ),
        InstallPath.none,
      );
    });

    test('an install remembered in this browser gives none', () {
      expect(
        installPathFor(
          FakeInstallPlatform(isIosSafari: true),
          InMemoryInstallMemory(installed: true),
        ),
        InstallPath.none,
      );
    });

    test('a fresh install event beats a remembered install', () {
      expect(
        installPathFor(
          FakeInstallPlatform(hasNativePrompt: true),
          InMemoryInstallMemory(installed: true),
        ),
        InstallPath.native,
      );
    });
  });

  group('installPromptSnoozed', () {
    final day = DateTime.utc(2026, 11);

    test('never dismissed is not snoozed', () {
      expect(
        installPromptSnoozed(dismissals: 0, lastDismissedAt: null, now: day),
        isFalse,
      );
    });

    test('one Not Now hides it for 30 days, then it returns', () {
      expect(
        installPromptSnoozed(
          dismissals: 1,
          lastDismissedAt: day,
          now: day.add(const Duration(days: 29)),
        ),
        isTrue,
      );
      expect(
        installPromptSnoozed(
          dismissals: 1,
          lastDismissedAt: day,
          now: day.add(const Duration(days: 30)),
        ),
        isFalse,
      );
    });

    test('a second Not Now stops it for good', () {
      expect(
        installPromptSnoozed(
          dismissals: 2,
          lastDismissedAt: day,
          now: day.add(const Duration(days: 400)),
        ),
        isTrue,
      );
    });
  });

  test('InMemoryInstallMemory counts dismissals', () {
    final memory = InMemoryInstallMemory();
    final at = DateTime.utc(2026, 11);
    memory.recordDismissal(at);
    expect(memory.dismissals, 1);
    expect(memory.lastDismissedAt, at);
    memory
      ..recordInstalled()
      ..clearInstalled();
    expect(memory.installed, isFalse);
  });

  test('the unsupported platform offers nothing', () async {
    const platform = UnsupportedInstallPlatform();
    expect(platform.hasNativePrompt, isFalse);
    expect(platform.isStandalone, isFalse);
    expect(platform.isIosSafari, isFalse);
    expect(await platform.promptInstall(), InstallPromptResult.unavailable);
    expect(await platform.requestPersistentStorage(), isFalse);
  });
}
