import 'dart:async';

import 'package:pantas/core/platform/install/install_platform.dart';

class FakeInstallPlatform implements InstallPlatform {
  FakeInstallPlatform({
    this.isStandalone = false,
    this.isIosSafari = false,
    this.hasNativePrompt = false,
    this.installedThisSession = false,
    this.result = InstallPromptResult.accepted,
  });

  @override
  bool isStandalone;
  @override
  bool isIosSafari;
  @override
  bool hasNativePrompt;
  @override
  bool installedThisSession;
  InstallPromptResult result;

  int promptCalls = 0;
  int persistCalls = 0;
  int startCalls = 0;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  void emitChange() => _changes.add(null);

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<InstallPromptResult> promptInstall() async {
    promptCalls += 1;
    // The browser event works once.
    hasNativePrompt = false;
    return result;
  }

  @override
  Future<bool> requestPersistentStorage() async {
    persistCalls += 1;
    return true;
  }

  @override
  void start() => startCalls += 1;
}
