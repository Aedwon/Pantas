import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// The wording of the setup acceptance that names study records.
abstract final class SetupAcceptance {
  static const version = '2026-11-09';
}

/// The acceptance the server holds for a named account.
class AccountAcceptance {
  const AccountAcceptance({required this.version, required this.acceptedAt});
  final String version;
  final DateTime acceptedAt;
}

/// Tells the server which acceptance wording a named account agreed to, and
/// reads it back.
abstract interface class SetupAcceptanceGateway {
  Future<void> record(String version);

  /// The signed-in account's own record, or null when there is none.
  Future<AccountAcceptance?> read();
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

  @override
  Future<AccountAcceptance?> read() async {
    final raw = await _client.call('getSetupAcceptance', {});
    if (raw is! Map) return null;
    final version = raw['version'];
    final at = raw['acceptedAt'];
    if (version is! String || at is! num) return null;
    return AccountAcceptance(
      version: version,
      acceptedAt: DateTime.fromMillisecondsSinceEpoch(
        at.toInt(),
        isUtc: true,
      ),
    );
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

/// The longest the Terms step waits for the account record.
final termsSkipBoundProvider =
    Provider<Duration>((ref) => const Duration(seconds: 5));

/// Lets a returning student skip Terms when the signed-in account's own record
/// covers the current wording. Returns true when it restored the acceptance on
/// this device, with the time the account first accepted. Any failure, delay,
/// missing record or other wording returns false: the student sees Terms. The
/// optional usage-sharing choice is never touched.
final termsSkipProvider = Provider<Future<bool> Function(String uid)>((ref) {
  return (uid) async {
    try {
      final record = await ref
          .read(setupAcceptanceGatewayProvider)
          .read()
          .timeout(ref.read(termsSkipBoundProvider));
      if (record == null || record.version != SetupAcceptance.version) {
        return false;
      }
      await ref
          .read(appPreferencesRepositoryProvider)
          .setSetupAcceptanceVersion(record.version);
      // The server already holds this wording for this account, so the
      // recorder has nothing to write back.
      await ref
          .read(appPreferencesRepositoryProvider)
          .setSetupAcceptanceRecordedFor('$uid|${record.version}');
      // Last, as on the Terms step: acceptance is the resume marker.
      await ref
          .read(settingsRepositoryProvider)
          .recordPolicyAcceptance(acceptedAt: record.acceptedAt);
      ref
        ..invalidate(settingsRepositoryProvider)
        ..invalidate(userSettingsProvider);
      return true;
    } on Object {
      return false;
    }
  };
});

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
