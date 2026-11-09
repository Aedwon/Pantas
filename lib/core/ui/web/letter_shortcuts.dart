import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';

/// The Settings > Accessibility > Keyboard Shortcuts switch (WCAG 2.1.4).
///
/// Every single-character shortcut (an answer letter, F, G, P, B, a digit)
/// goes through [LetterShortcuts], so this one switch turns all of them off.
/// Shortcuts with a modifier (Ctrl K), Esc, Enter, arrows, Space and Tab are
/// not character keys and never pass through here.
final letterShortcutsProvider =
    StateNotifierProvider<LetterShortcutsController, bool>((ref) {
  return LetterShortcutsController(ref.watch(appPreferencesRepositoryProvider));
});

/// Keeps the switch in the same device store as the lesson text size. It is
/// on until the learner turns it off.
class LetterShortcutsController extends StateNotifier<bool> {
  LetterShortcutsController(this._preferences) : super(true) {
    unawaited(_load());
  }

  static const _key = 'letter_shortcuts_enabled';
  final AppPreferencesRepository _preferences;
  int _revision = 0;

  Future<void> _load() async {
    final revision = _revision;
    try {
      final raw = await _preferences.deviceValue(_key);
      if (mounted && revision == _revision && raw == 'false') state = false;
    } on Exception {
      // An unavailable preference keeps the default, which is on.
    }
  }

  Future<void> setEnabled({required bool enabled}) async {
    final revision = ++_revision;
    state = enabled;
    try {
      await _preferences.setDeviceValue(_key, enabled ? 'true' : 'false');
    } on Exception {
      if (mounted && revision == _revision) state = !enabled;
      rethrow;
    }
  }
}

/// Tells the tree whether letter shortcuts are on. The app root places it
/// above the router. Without one (a bare widget in a test) they are on.
class LetterShortcutsScope extends InheritedWidget {
  const LetterShortcutsScope({
    required this.enabled,
    required super.child,
    super.key,
  });

  final bool enabled;

  static bool enabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LetterShortcutsScope>()
          ?.enabled ??
      true;

  @override
  bool updateShouldNotify(LetterShortcutsScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// Whether [text] is one letter or digit, the kind of hint that names a
/// character-key shortcut ("F", "B", "2"). "Esc", "Enter", "Ctrl K" and the
/// arrows are not.
bool isCharacterKeyHint(String text) => RegExp(r'^[A-Za-z0-9]$').hasMatch(text);

/// A control's name with its letter shortcut in brackets ("Flag (F)"). The
/// letter drops out while Keyboard Shortcuts is off.
String withLetterKey(BuildContext context, String name, String letter) =>
    LetterShortcutsScope.enabledOf(context) ? '$name ($letter)' : name;

/// Single-character shortcuts, gated by the Keyboard Shortcuts setting.
///
/// A page binds its letters here and the rest of its keys in [also], so one
/// widget holds all of its bindings. [bindings] and [once] map a lowercase
/// letter or a digit ("f", "1") to its action; a key in [once] acts a single
/// time however long it is held. When the setting is off the widget keeps
/// its place in the tree and binds only [also]. This is the only place a
/// letter or digit key may be bound; the `letter-shortcut-gate` check fails
/// any other.
class LetterShortcuts extends StatelessWidget {
  const LetterShortcuts({
    required this.child,
    this.bindings = const {},
    this.once = const {},
    this.also = const {},
    super.key,
  });

  final Widget child;
  final Map<String, VoidCallback> bindings;
  final Map<String, VoidCallback> once;

  /// Bindings that are not character keys (Esc, arrows) and so stay on.
  final Map<ShortcutActivator, VoidCallback> also;

  static const _keys = <String, LogicalKeyboardKey>{
    'a': LogicalKeyboardKey.keyA,
    'b': LogicalKeyboardKey.keyB,
    'c': LogicalKeyboardKey.keyC,
    'd': LogicalKeyboardKey.keyD,
    'e': LogicalKeyboardKey.keyE,
    'f': LogicalKeyboardKey.keyF,
    'g': LogicalKeyboardKey.keyG,
    'h': LogicalKeyboardKey.keyH,
    'i': LogicalKeyboardKey.keyI,
    'j': LogicalKeyboardKey.keyJ,
    'k': LogicalKeyboardKey.keyK,
    'l': LogicalKeyboardKey.keyL,
    'm': LogicalKeyboardKey.keyM,
    'n': LogicalKeyboardKey.keyN,
    'o': LogicalKeyboardKey.keyO,
    'p': LogicalKeyboardKey.keyP,
    'q': LogicalKeyboardKey.keyQ,
    'r': LogicalKeyboardKey.keyR,
    's': LogicalKeyboardKey.keyS,
    't': LogicalKeyboardKey.keyT,
    'u': LogicalKeyboardKey.keyU,
    'v': LogicalKeyboardKey.keyV,
    'w': LogicalKeyboardKey.keyW,
    'x': LogicalKeyboardKey.keyX,
    'y': LogicalKeyboardKey.keyY,
    'z': LogicalKeyboardKey.keyZ,
    '0': LogicalKeyboardKey.digit0,
    '1': LogicalKeyboardKey.digit1,
    '2': LogicalKeyboardKey.digit2,
    '3': LogicalKeyboardKey.digit3,
    '4': LogicalKeyboardKey.digit4,
    '5': LogicalKeyboardKey.digit5,
    '6': LogicalKeyboardKey.digit6,
    '7': LogicalKeyboardKey.digit7,
    '8': LogicalKeyboardKey.digit8,
    '9': LogicalKeyboardKey.digit9,
  };

  static SingleActivator _activator(String key, {required bool repeats}) =>
      SingleActivator(
        _keys[key] ?? (throw ArgumentError.value(key, 'key')),
        includeRepeats: repeats,
      );

  @override
  Widget build(BuildContext context) {
    final on = LetterShortcutsScope.enabledOf(context);
    return CallbackShortcuts(
      bindings: {
        ...also,
        if (on) ...{
          for (final e in bindings.entries)
            _activator(e.key, repeats: true): e.value,
          for (final e in once.entries)
            _activator(e.key, repeats: false): e.value,
        },
      },
      child: child,
    );
  }
}
