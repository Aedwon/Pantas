import 'dart:async';

import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

/// What sign-out and an account switch do first: send what is waiting, bounded.
/// Stopping Sync and the guarded wipe that follow belong to the repository,
/// which restarts Sync if any step refuses.
class SyncAccountTransitionGateway implements AccountTransitionGateway {
  const SyncAccountTransitionGateway(
    this._runtime, {
    this.signOutFlushLimit = const Duration(seconds: 2),
    this.flushReports,
    this.flushNow,
    this.hasUnsentData,
  });

  /// True while something is still unsent. Only used to know when to stop
  /// sending: a flush returns before its upload has finished, so the send
  /// repeats until nothing is left or the limit passes. The refusal is the
  /// repository's guarded check, not this.
  final Future<bool> Function()? hasUnsentData;

  /// Read at each call: the app installs the configured runtime after the
  /// auth repository is built.
  // ignore: unused_field
  final SyncRuntimeLifecycle Function() _runtime;

  /// The longest each send waits.
  final Duration signOutFlushLimit;

  /// Sends the signed-in account's queued question reports, while that account
  /// is still signed in.
  final Future<void> Function()? flushReports;

  /// Sends what Sync holds, without stopping it, so a refused sign-out leaves
  /// Sync running.
  final Future<void> Function()? flushNow;

  /// Best effort: offline or failing, sign-out goes on to the guarded check,
  /// which refuses if anything is still unsent.
  @override
  Future<void> prepareForSignOut() => _sendEverything();

  /// Sync is left running here, as is the new account's start: the repository
  /// stops Sync and wipes under a guard before it signs in to the new account.
  @override
  Future<void> prepareForAccountSwitch() => _sendEverything();

  /// Nothing here, as before this gateway was wired: stopping Sync now would
  /// leave it off for the account if the deletion then fails.
  @override
  Future<void> prepareForDeleteAccount() async {}

  Future<void> _sendEverything() async {
    final deadline = DateTime.now().add(signOutFlushLimit);
    while (true) {
      await _bounded(flushNow);
      await _bounded(flushReports);
      if (!await _stillUnsent() || !DateTime.now().isBefore(deadline)) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<bool> _stillUnsent() async {
    final check = hasUnsentData;
    if (check == null) return false;
    try {
      return await check().timeout(signOutFlushLimit, onTimeout: () => false);
    } on Object {
      return false;
    }
  }

  Future<void> _bounded(Future<void> Function()? send) async {
    if (send == null) return;
    try {
      await send().timeout(signOutFlushLimit, onTimeout: () {});
    } on Object {
      // Never stops a sign-out by itself; the guarded check decides.
    }
  }
}
