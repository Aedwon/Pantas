import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';

/// The wording of the setup acceptance that names study records.
abstract final class SetupAcceptance {
  static const version = '2026-11-09';
}

/// Tells the server which acceptance wording a named account agreed to.
// Single-method interface is intentional for DI in tests.
// ignore: one_member_abstracts
abstract interface class SetupAcceptanceGateway {
  Future<void> record(String version);
}

class CallableSetupAcceptanceGateway implements SetupAcceptanceGateway {
  const CallableSetupAcceptanceGateway([
    this._client = const FirebaseGuardianCallableClient(),
  ]);
  final GuardianCallableClient _client;

  @override
  Future<void> record(String version) async {
    await _client.call('recordSetupAcceptance', {'version': version});
  }
}

final setupAcceptanceGatewayProvider = Provider<SetupAcceptanceGateway>(
  (ref) => const CallableSetupAcceptanceGateway(),
);

/// Records the stored acceptance for a named account, best effort.
///
/// An anonymous account has no server record, so nothing is sent. A named
/// account is recorded once; the local marker names the account and the
/// wording. A failure leaves no marker, so the next start tries again.
class SetupAcceptanceRecorder {
  SetupAcceptanceRecorder(this._prefs, this._gateway);

  final AppPreferencesRepository _prefs;
  final SetupAcceptanceGateway _gateway;
  bool _running = false;

  Future<void> recordIfNeeded(String? uid) async {
    if (uid == null || _running) return;
    _running = true;
    try {
      final version = await _prefs.setupAcceptanceVersion();
      if (version == null) return;
      final marker = '$uid|$version';
      if (await _prefs.setupAcceptanceRecordedFor() == marker) return;
      await _gateway.record(version);
      await _prefs.setSetupAcceptanceRecordedFor(marker);
    } on Object {
      // Offline or refused: tried again on the next start.
    } finally {
      _running = false;
    }
  }
}

final setupAcceptanceRecorderProvider = Provider<SetupAcceptanceRecorder>(
  (ref) => SetupAcceptanceRecorder(
    ref.watch(appPreferencesRepositoryProvider),
    ref.watch(setupAcceptanceGatewayProvider),
  ),
);

/// Records the acceptance when the account is named: at start, and again when
/// an anonymous account becomes named. Read once at startup to keep it alive.
final setupAcceptanceSyncProvider = Provider<void>((ref) {
  final recorder = ref.watch(setupAcceptanceRecorderProvider);
  ref.listen(
    currentUserProvider,
    (_, next) {
      final user = next.valueOrNull;
      if (user != null) unawaited(recorder.recordIfNeeded(user.uid));
    },
    fireImmediately: true,
  );
});
