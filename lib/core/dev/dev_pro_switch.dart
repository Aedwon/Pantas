import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A debug-only switch between Free and Pro, driven from outside the app.
///
/// Aedwon tests the paywall constantly and asked for a switch that is not a
/// control in the UI: a real student must never find one, and a debug row in
/// Settings is a row somebody has to remember to strip.
///
/// It is a Dart VM service extension instead, so `tools/pro` flips it over
/// adb while the app keeps running. **It is persisted**, because a hot
/// restart lands after every change shipped to the device and an unpersisted
/// switch would fall back to Free each time.
///
/// Null means no override: the real entitlement from the store decides.
const String devProOverrideKey = 'dev.pro_override';

/// The live value. Null until [registerDevProSwitch] reads what was stored.
final ValueNotifier<bool?> devProOverride = ValueNotifier<bool?>(null);

/// Rebuilds whenever the switch is flipped, so the entitlement follows and
/// the screen changes without a restart.
///
/// Synchronous on purpose. As a `StreamProvider` this spends its first frame
/// in a loading state, and the entitlement that watches it never settled.
final devProOverrideProvider = Provider<bool?>((ref) {
  void onFlip() => ref.invalidateSelf();
  devProOverride.addListener(onFlip);
  ref.onDispose(() => devProOverride.removeListener(onFlip));
  return devProOverride.value;
});

/// Restores the stored value and opens `ext.pantas.pro` to the VM service.
///
/// Does nothing in a release build, where neither the extension nor the
/// stored key is read.
Future<void> registerDevProSwitch(ProviderContainer container) async {
  if (!kDebugMode) return;

  final db = container.read(appDatabaseProvider);
  devProOverride.value = await _read(db);

  developer.registerExtension('ext.pantas.pro', (method, parameters) async {
    final requested = _resolve(parameters['value']);
    if (requested != _Requested.report) {
      devProOverride.value = switch (requested) {
        _Requested.pro => true,
        _Requested.free => false,
        _Requested.clear => null,
        _Requested.toggle => !(devProOverride.value ?? false),
        _Requested.report => devProOverride.value,
      };
      await _write(db, devProOverride.value);
    }
    return developer.ServiceExtensionResponse.result(
      jsonEncode({'pro': devProOverride.value}),
    );
  });
}

enum _Requested { pro, free, clear, toggle, report }

_Requested _resolve(String? value) => switch (value) {
      'true' || 'pro' => _Requested.pro,
      'false' || 'free' => _Requested.free,
      'clear' || 'null' => _Requested.clear,
      'toggle' => _Requested.toggle,
      _ => _Requested.report,
    };

Future<bool?> _read(AppDatabase db) async {
  final row = await (db.select(db.accountPrefs)
        ..where((t) => t.key.equals(devProOverrideKey)))
      .getSingleOrNull();
  return switch (row?.value) {
    'true' => true,
    'false' => false,
    _ => null,
  };
}

Future<void> _write(AppDatabase db, bool? value) async {
  if (value == null) {
    await (db.delete(db.accountPrefs)
          ..where((t) => t.key.equals(devProOverrideKey)))
        .go();
    return;
  }
  await db.into(db.accountPrefs).insertOnConflictUpdate(
        AccountPrefsCompanion.insert(
          key: devProOverrideKey,
          value: '$value',
        ),
      );
}
