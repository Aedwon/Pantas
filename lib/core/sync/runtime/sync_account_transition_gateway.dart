import 'dart:async';

import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_repository.dart'
    show AuthGatewayException;
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

class SyncAccountTransitionGateway implements AccountTransitionGateway {
  const SyncAccountTransitionGateway(
    this._runtime, {
    this.signOutFlushLimit = const Duration(seconds: 2),
    this.flushReports,
    this.flushNow,
    this.hasUnsentData,
  });

  /// Sends what Sync holds without stopping it, so a sign-out that is then
  /// refused leaves Sync running.
  final Future<void> Function()? flushNow;

  /// True when study changes or question reports are still unsent. The wipe
  /// that follows would delete them, so sign-out and an account switch stop.
  final Future<bool> Function()? hasUnsentData;

  /// Sends the signed-in account's queued question reports. Run while that
  /// account is still signed in, because the wipe that follows removes them.
  final Future<void> Function()? flushReports;

  /// Read at each call: the app installs the configured runtime after the
  /// auth repository is built.
  final SyncRuntimeLifecycle Function() _runtime;

  /// The longest Sign Out waits for the upload.
  final Duration signOutFlushLimit;

  /// Sends the changes and reports still waiting, so the sign-out wipe does
  /// not erase them. The sends are best effort and bounded by
  /// [signOutFlushLimit]. If anything is still unsent after them (offline,
  /// slow or failing), sign-out stops before Sync is stopped and before the
  /// wipe, with the connection error the Account page already shows.
  @override
  Future<void> prepareForSignOut() async {
    await _sendEverything();
    try {
      await _runtime()
          .quiesce(flush: true)
          .timeout(signOutFlushLimit, onTimeout: () {});
    } on Object {
      // Nothing more to do: the check above already found nothing unsent.
    }
  }

  Future<void> _sendEverything() async {
    await _bounded(flushNow);
    await _sendReports();
    await _refuseIfUnsent();
  }

  Future<void> _bounded(Future<void> Function()? send) async {
    if (send == null) return;
    try {
      await send().timeout(signOutFlushLimit, onTimeout: () {});
    } on Object {
      // Never stops Sign Out by itself; the check that follows decides.
    }
  }

  Future<void> _refuseIfUnsent() async {
    final check = hasUnsentData;
    if (check == null) return;
    bool unsent;
    try {
      unsent = await check();
    } on Object {
      // Not knowing is not a reason to delete.
      unsent = true;
    }
    if (unsent) throw const AuthGatewayException('network-request-failed');
  }

  /// Best effort and bounded, like the upload: the reports not sent in time
  /// are removed by the wipe.
  Future<void> _sendReports() => _bounded(flushReports);

  /// Sync is left running: it wipes another account's data when the new
  /// account arrives, before anything runs for it. Stopping it now would leave
  /// it off for the current account if the switch is then cancelled. What is
  /// unsent is sent while the old account is still signed in, and the switch
  /// stops if any of it cannot be.
  @override
  Future<void> prepareForAccountSwitch() => _sendEverything();

  /// Nothing here, as before this gateway was wired: stopping Sync now would
  /// leave it off for the account if the deletion then fails.
  @override
  Future<void> prepareForDeleteAccount() async {}
}
