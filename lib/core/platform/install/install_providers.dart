import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/platform/install/install_platform_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/platform/install/install_platform_web.dart'
    as impl;

final installPlatformProvider =
    Provider<InstallPlatform>((ref) => impl.createInstallPlatform());

final installMemoryProvider =
    Provider<InstallMemory>((ref) => impl.createInstallMemory());

final installClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// What the browser lets Pantas offer, after the learner's own answers.
/// It says nothing about timing: Home adds the "after the first finished
/// lesson" rule.
class InstallController extends Notifier<InstallPath> {
  StreamSubscription<void>? _subscription;

  @override
  InstallPath build() {
    final platform = ref.watch(installPlatformProvider);
    _subscription = platform.changes.listen((_) => _refresh());
    ref.onDispose(() => unawaited(_subscription?.cancel()));
    // The install event only fires when Pantas is not installed, so a fresh
    // one means any remembered install is out of date.
    if (platform.hasNativePrompt) {
      ref.read(installMemoryProvider).clearInstalled();
    }
    return _current();
  }

  InstallPath _current() {
    final platform = ref.read(installPlatformProvider);
    final memory = ref.read(installMemoryProvider);
    final path = installPathFor(platform, memory);
    if (path == InstallPath.none) return path;
    final snoozed = installPromptSnoozed(
      dismissals: memory.dismissals,
      lastDismissedAt: memory.lastDismissedAt,
      now: ref.read(installClockProvider)(),
    );
    return snoozed ? InstallPath.none : path;
  }

  void _refresh() {
    final platform = ref.read(installPlatformProvider);
    final memory = ref.read(installMemoryProvider);
    if (platform.installedThisSession) {
      memory.recordInstalled();
    } else if (platform.hasNativePrompt) {
      memory.clearInstalled();
    }
    state = _current();
  }

  /// Opens the browser's install dialog. Hides the card either way.
  Future<void> install() async {
    final platform = ref.read(installPlatformProvider);
    final memory = ref.read(installMemoryProvider);
    final result = await platform.promptInstall();
    switch (result) {
      case InstallPromptResult.accepted:
        memory.recordInstalled();
        unawaited(platform.requestPersistentStorage());
      case InstallPromptResult.dismissed:
        memory.recordDismissal(ref.read(installClockProvider)());
      case InstallPromptResult.unavailable:
        break;
    }
    state = _current();
  }

  /// "Not Now": hides the card for 30 days. A second one stops it.
  void notNow() {
    ref
        .read(installMemoryProvider)
        .recordDismissal(ref.read(installClockProvider)());
    state = _current();
  }
}

final installControllerProvider =
    NotifierProvider<InstallController, InstallPath>(InstallController.new);
