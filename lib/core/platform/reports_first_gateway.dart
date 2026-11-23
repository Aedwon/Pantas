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
  }) : _log = log ?? debugPrint;

  final AccountTransitionGateway _inner;
  final ReportQueue Function() _queue;

  /// The longest the send waits.
  final Duration limit;
  final void Function(String line) _log;

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
    try {
      await queue.sendPending().timeout(limit);
    } on Object {
      // Slow or failing: what is still pending decides, below.
    }
    // Not knowing what is pending is not a reason to wipe.
    final List<QuestionReport> pending;
    final Map<String, int> refused;
    try {
      pending = await queue.pending();
      refused = await queue.refusedReasons();
    } on Object {
      throw const AuthGatewayException('network-request-failed');
    }
    if (pending.isNotEmpty) {
      throw const AuthGatewayException('network-request-failed');
    }
    if (refused.isNotEmpty) {
      final reasons = [
        for (final entry in refused.entries) '${entry.key}=${entry.value}',
      ].join(' ');
      _log('question reports discarded at sign-out: $reasons');
    }
  }
}
