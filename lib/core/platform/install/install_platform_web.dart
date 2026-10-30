import 'dart:async';
import 'dart:js_interop';

import 'package:pantas/core/platform/install/install_platform.dart';

/// The small script in `web/pantas_pwa.js`. It starts before Flutter so it can
/// keep the browser's install event, which can fire before any Dart runs.
extension type _PantasPwa(JSObject _) implements JSObject {
  external bool hasPrompt();
  external bool wasInstalled();
  external void subscribe(JSFunction callback);
  external JSPromise<JSString> prompt();
}

@JS('pantasPwa')
external _PantasPwa? get _pwa;

extension type _MediaQuery(JSObject _) implements JSObject {
  external bool get matches;
}

@JS('matchMedia')
external _MediaQuery _matchMedia(String query);

extension type _StorageManager(JSObject _) implements JSObject {
  external JSPromise<JSBoolean> persist();
}

extension type _Navigator(JSObject _) implements JSObject {
  external String get userAgent;
  external String? get platform;
  external int? get maxTouchPoints;
  external bool? get standalone;
  external _StorageManager? get storage;
}

@JS('navigator')
external _Navigator get _navigator;

extension type _Storage(JSObject _) implements JSObject {
  external String? getItem(String key);
  external void setItem(String key, String value);
  external void removeItem(String key);
}

@JS('localStorage')
external _Storage get _localStorage;

InstallPlatform createInstallPlatform() => WebInstallPlatform();

InstallMemory createInstallMemory() => LocalStorageInstallMemory();

class WebInstallPlatform implements InstallPlatform {
  final StreamController<void> _changes = StreamController<void>.broadcast();
  bool _started = false;
  bool _persistRequested = false;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  bool get isStandalone {
    try {
      if (_navigator.standalone ?? false) return true;
      return _matchMedia('(display-mode: standalone)').matches ||
          _matchMedia('(display-mode: window-controls-overlay)').matches;
    } on Object {
      return false;
    }
  }

  @override
  bool get isIosSafari {
    try {
      final nav = _navigator;
      return isIosSafariEnvironment(
        InstallEnvironment(
          userAgent: nav.userAgent,
          platform: nav.platform ?? '',
          maxTouchPoints: nav.maxTouchPoints ?? 0,
        ),
      );
    } on Object {
      return false;
    }
  }

  @override
  bool get hasNativePrompt {
    try {
      return _pwa?.hasPrompt() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  bool get installedThisSession {
    try {
      return _pwa?.wasInstalled() ?? false;
    } on Object {
      return false;
    }
  }

  @override
  void start() {
    if (_started) return;
    _started = true;
    try {
      _pwa?.subscribe(
        (() {
          if (!_changes.isClosed) _changes.add(null);
          if (installedThisSession) unawaited(requestPersistentStorage());
        }).toJS,
      );
    } on Object {
      // Without the script the card simply never offers a native install.
    }
    // Running installed already: ask the browser to keep storage.
    if (isStandalone) unawaited(requestPersistentStorage());
  }

  @override
  Future<InstallPromptResult> promptInstall() async {
    final pwa = _pwa;
    if (pwa == null) return InstallPromptResult.unavailable;
    try {
      final outcome = (await pwa.prompt().toDart).toDart;
      return switch (outcome) {
        'accepted' => InstallPromptResult.accepted,
        'dismissed' => InstallPromptResult.dismissed,
        _ => InstallPromptResult.unavailable,
      };
    } on Object {
      return InstallPromptResult.unavailable;
    }
  }

  @override
  Future<bool> requestPersistentStorage() async {
    if (_persistRequested) return false;
    _persistRequested = true;
    try {
      final storage = _navigator.storage;
      if (storage == null) return false;
      return (await storage.persist().toDart).toDart;
    } on Object {
      return false;
    }
  }
}

class LocalStorageInstallMemory implements InstallMemory {
  static const _dismissalsKey = 'pantas.install.dismissals';
  static const _dismissedAtKey = 'pantas.install.dismissedAt';
  static const _installedKey = 'pantas.install.installed';

  String? _read(String key) {
    try {
      return _localStorage.getItem(key);
    } on Object {
      return null;
    }
  }

  void _write(String key, String? value) {
    try {
      value == null
          ? _localStorage.removeItem(key)
          : _localStorage.setItem(key, value);
    } on Object {
      // Private browsing can refuse storage. The card then shows again.
    }
  }

  @override
  int get dismissals => int.tryParse(_read(_dismissalsKey) ?? '') ?? 0;

  @override
  DateTime? get lastDismissedAt =>
      DateTime.tryParse(_read(_dismissedAtKey) ?? '');

  @override
  bool get installed => _read(_installedKey) == 'true';

  @override
  void recordDismissal(DateTime at) {
    _write(_dismissalsKey, '${dismissals + 1}');
    _write(_dismissedAtKey, at.toUtc().toIso8601String());
  }

  @override
  void recordInstalled() => _write(_installedKey, 'true');

  @override
  void clearInstalled() => _write(_installedKey, null);
}
