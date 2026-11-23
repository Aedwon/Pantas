import 'dart:async';

import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

class SyncAccountTransitionGateway implements AccountTransitionGateway {
  const SyncAccountTransitionGateway(
    this._runtime, {
    this.signOutFlushLimit = const Duration(seconds: 2),
    this.flushReports,
  });

  /// Sends the signed-in account's queued question reports. Run while that
  /// account is still signed in, because the wipe that follows removes them.
  final Future<void> Function()? flushReports;

  /// Read at each call: the app installs the configured runtime after the
  /// auth repository is built.
  final SyncRuntimeLifecycle Function() _runtime;

  /// The longest Sign Out waits for the upload.
  final Duration signOutFlushLimit;

  /// Uploads the changes still waiting (the engine holds a change a few
  /// seconds before it sends it), so the sign-out wipe does not erase them.
  /// Best effort: offline, slow or failing, Sign Out goes on after
  /// [signOutFlushLimit], and what was not sent is lost with the wipe, as
  /// before this upload existed.
  @override
  Future<void> prepareForSignOut() async {
    try {
      await _runtime()
          .quiesce(flush: true)
          .timeout(signOutFlushLimit, onTimeout: () {});
    } on Object {
      // A backup problem never stops Sign Out.
    }
    await _sendReports();
  }

  /// Best effort and bounded, like the upload: the reports not sent in time
  /// are removed by the wipe.
  Future<void> _sendReports() async {
    final send = flushReports;
    if (send == null) return;
    try {
      await send().timeout(signOutFlushLimit, onTimeout: () {});
    } on Object {
      // Never stops Sign Out or a switch.
    }
  }

  /// Sync is left running: it wipes another account's data when the new
  /// account arrives, before anything runs for it. Stopping it now would leave
  /// it off for the current account if the switch is then cancelled. Only the
  /// queued reports are sent, while the old account is still signed in.
  @override
  Future<void> prepareForAccountSwitch() => _sendReports();

  /// Nothing here, as before this gateway was wired: stopping Sync now would
  /// leave it off for the account if the deletion then fails.
  @override
  Future<void> prepareForDeleteAccount() async {}
}
