import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_repository.dart'
    show AuthGatewayException;
import 'package:pantas/core/storage/data/report_queue.dart';

/// Question reports come first in a sign-out or an account switch, before any
/// teardown (Sync stop, wipe, purchase identity change).
///
/// It sends this account's pending reports, bounded, and counts what is still
/// pending. A report left pending means the network failed, and the sign-out
/// wipe would delete it, so the sign-out or switch is refused with the
/// connection error the Account page already shows. Nothing has been touched
/// by then, so there is nothing to undo. A report the server refused for good
/// (a full question, say) is not pending: it is discarded and counted in one
/// reason-coded log line. Everything else is the wrapped gateway, unchanged.
///
/// Accepted residual: a report filed in another tab during the send window can
/// be lost with the wipe.
class ReportsFirstTransitionGateway implements AccountTransitionGateway {
  ReportsFirstTransitionGateway(
    this._inner,
    this._queue, {
    this.limit = const Duration(seconds: 2),
    void Function(String line)? log,
    bool Function(String uid)? isClosed,
    this.onRefused,
    this.onPassed,
  })  : _log = log ?? debugPrint,
        _isClosed = isClosed ?? ((_) => false);

  final AccountTransitionGateway _inner;
  final ReportQueue Function() _queue;

  /// One limit for the whole check: the send, the pending read and the
  /// refusal read together.
  final Duration limit;
  final void Function(String line) _log;

  /// True when the server has closed this account (a guardian withdrew, or it
  /// is being deleted). Its reports can never be sent.
  final bool Function(String uid) _isClosed;

  /// Runs when this check refuses, so anything sign-out cleared before it
  /// asked (a pending email-link sign-in) can be put back.
  final void Function()? onRefused;

  /// Runs when this check lets the transition go on, so what sign-out cleared
  /// is forgotten and can never come back under another account.
  final void Function()? onPassed;

  @override
  Future<void> prepareForSignOut() async {
    await _sendFirst();
    await _inner.prepareForSignOut();
  }

  @override
  Future<void> prepareForAccountSwitch() async {
    await _sendFirst();
    await _inner.prepareForAccountSwitch();
  }

  /// Deleting the account removes its reports on the server, so nothing here.
  @override
  Future<void> prepareForDeleteAccount() => _inner.prepareForDeleteAccount();

  Future<void> _sendFirst() async {
    final queue = _queue();
    final uid = queue.currentAccount;
    if (uid != null && _isClosed(uid)) {
      // A closed account's reports can never be sent. They are discarded with
      // the wipe, and main's closed-account cleanup runs without delay.
      await _logDiscarded(queue).timeout(limit, onTimeout: () {});
      onPassed?.call();
      return;
    }
    try {
      await _check(queue).timeout(limit);
    } on Object {
      // Any failure, a stall included, is a refusal: not knowing what is
      // pending is not a reason to wipe.
      onRefused?.call();
      throw const AuthGatewayException('network-request-failed');
    }
    onPassed?.call();
  }

  Future<void> _check(ReportQueue queue) async {
    try {
      // Half the limit at most: a send that never answers must still leave
      // time to read what is pending, which then decides.
      await queue.sendPending().timeout(limit ~/ 2);
    } on Object {
      // What is still pending decides, below.
    }
    final pending = await queue.pending();
    if (pending.isNotEmpty) {
      throw const AuthGatewayException('network-request-failed');
    }
    final refused = await queue.refusedReasons();
    if (refused.isNotEmpty) {
      _logCounts(refused);
    }
  }

  Future<void> _logDiscarded(ReportQueue queue) async {
    try {
      final counts = <String, int>{...await queue.refusedReasons()};
      final pending = (await queue.pending()).length;
      if (pending > 0) counts['account-closed'] = pending;
      if (counts.isNotEmpty) _logCounts(counts);
    } on Object {
      // Counting is for the log only; the closure goes on.
    }
  }

  void _logCounts(Map<String, int> counts) {
    final reasons = [
      for (final entry in counts.entries) '${entry.key}=${entry.value}',
    ].join(' ');
    _log('question reports discarded at sign-out: $reasons');
  }
}
