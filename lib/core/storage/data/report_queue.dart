import 'dart:async';
import 'dart:convert';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:uuid/uuid.dart';

/// Where a report is in its life on this device.
enum ReportState {
  /// Not yet accepted by the server. Kept, with its message, until it is.
  pending,

  /// The server accepted it. Only the question and the day are kept, for the
  /// limits. The message is gone from the device.
  sent,

  /// The server refused it for good (over its limit for the question, or a
  /// message it cannot take). Never retried. Kept for the limits only.
  refused,
}

class QuestionReport {
  const QuestionReport({
    required this.id,
    required this.questionId,
    required this.message,
    required this.createdAt,
    this.accountId,
    this.examId,
    this.questionVersion,
    this.state = ReportState.pending,
  });

  /// Made on this device when the report is queued. The server stores one
  /// report per id, so a retry never duplicates it.
  final String id;
  final String questionId;
  final String message;
  final DateTime createdAt;

  /// The account that made the report. Only that account sends it. Null for a
  /// report queued before accounts were recorded, until an account claims it.
  final String? accountId;

  /// Null for a report queued before the app recorded them.
  final String? examId;
  final int? questionVersion;
  final ReportState state;
}

/// Sends one report to the server. Returns when the server has accepted it.
/// Throws [ReportRefused] when the server will never accept it,
/// [ReportUnavailable] when nothing can be sent right now (no signed-in
/// account), and anything else for a failure worth retrying.
// Single-method interface is intentional: tests and the app swap senders.
// ignore: one_member_abstracts
abstract interface class ReportSender {
  Future<void> send(QuestionReport report);
}

/// The server refused the report for good. Retrying cannot help.
class ReportRefused implements Exception {
  const ReportRefused(this.reason);
  final String reason;
  @override
  String toString() => 'ReportRefused($reason)';
}

/// Nothing can be sent now, and trying again at once would not change that.
class ReportUnavailable implements Exception {
  const ReportUnavailable();
}

enum ReportResult { queued, empty, questionLimit, dailyLimit }

/// What the student is told once a report is saved.
enum ReportDelivery {
  /// The server has it.
  sent,

  /// It is on this device and goes out when the app can reach the server.
  saved,
}

/// Device-local, atomic limits, and the sender that moves reports to the
/// server. A report stays on the device until the server accepts it. Sent
/// reports keep only their question and day, which preserves the per-question
/// lifetime count and the daily count.
class ReportQueue {
  ReportQueue(
    this._db, {
    ReportSender? sender,
    String? Function()? account,
    this.maxAttempts = 3,
    Future<void> Function(Duration)? wait,
    String Function()? newId,
    this.retryEvery,
  })  : _sender = sender,
        _account = account ?? (() => null),
        _wait = wait ?? Future<void>.delayed,
        _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final ReportSender? _sender;

  /// The account signed in now, or null.
  final String? Function() _account;
  final Future<void> Function(Duration) _wait;
  final String Function() _newId;

  /// How many times one report is tried in one pass.
  final int maxAttempts;

  /// When set, a pass that failed on a network error tries again after this
  /// long. Null in tests.
  final Duration? retryEvery;

  /// The device-preference key that holds the list. Sign-out and an account
  /// switch wipe it (SyncLocalStateWiper), because it holds student text.
  static const storageKey = 'quiz_question_reports';
  static const _key = storageKey;

  /// The longest message the server takes. The form stops typing at this.
  static const maxMessageLength = 1000;

  Future<void> _tail = Future<void>.value();
  Timer? _retry;

  /// Reports the server has not accepted, oldest first.
  Future<List<QuestionReport>> pending() async => [
        for (final r in await history())
          if (r.state == ReportState.pending) r,
      ];

  /// Every report ever made on this device, sent or not.
  Future<List<QuestionReport>> history() async {
    final rows = await _rows();
    return [for (final row in rows) _parse(row)];
  }

  Future<ReportResult?> limit(String questionId, DateTime now) async {
    final reports = await history();
    if (reports.where((r) => r.questionId == questionId).length >= 3) {
      return ReportResult.questionLimit;
    }
    if (reports.where((r) => _sameDay(r.createdAt, now)).length >= 20) {
      return ReportResult.dailyLimit;
    }
    return null;
  }

  Future<ReportResult> add(
    String questionId,
    String message,
    DateTime now, {
    String? examId,
    int? questionVersion,
  }) async {
    final trimmed = _cut(message.trim());
    if (trimmed.isEmpty) return ReportResult.empty;
    // Read before the transaction opens: the first read can start work (a
    // provider's stream) that must not run inside the transaction's zone.
    final account = _account();
    return _db.transaction(() async {
      final blocked = await limit(questionId, now);
      if (blocked != null) return blocked;
      final rows = await _rows();
      rows.add({
        'id': _newId(),
        'questionId': questionId,
        'message': trimmed,
        'createdAt': now.toIso8601String(),
        if (account != null) 'accountId': account,
        if (examId != null) 'examId': examId,
        if (questionVersion != null) 'questionVersion': questionVersion,
      });
      await _write(rows);
      return ReportResult.queued;
    });
  }

  /// Sends every pending report, oldest first, and returns how many are still
  /// pending. A report leaves the device only after the server accepts it. A
  /// failure keeps it, and ends the pass, so one outage is not hit once per
  /// report. Passes run one after another, never together.
  Future<int> sendPending() {
    final pass = _tail.then((_) => _pass());
    _tail = pass.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return pass;
  }

  /// Stops a scheduled retry. The queue is not used again after this.
  void dispose() {
    _retry?.cancel();
    _retry = null;
  }

  Future<int> _pass() async {
    final sender = _sender;
    final account = _account();
    final all = await pending();
    // Only the account that made a report sends it. A report of another
    // account stays, untouched, until that account is signed in again or the
    // sign-out wipe removes it.
    final queued = [
      for (final r in all)
        if (r.accountId == account) r,
    ];
    var remaining = queued.length;
    if (account == null) return all.length;
    if (sender == null || remaining == 0) return remaining;
    var networkFailure = false;
    for (final report in queued) {
      final outcome = await _deliver(sender, report);
      if (outcome == _Outcome.failed) {
        networkFailure = true;
        break;
      }
      if (outcome == _Outcome.unavailable) break;
      await _settle(
        report.id,
        outcome == _Outcome.sent ? ReportState.sent : ReportState.refused,
      );
      remaining--;
    }
    if (networkFailure && retryEvery != null) {
      _retry?.cancel();
      _retry = Timer(retryEvery!, () => unawaited(_retryPass()));
    }
    return remaining;
  }

  Future<void> _retryPass() async {
    try {
      await sendPending();
    } on Object {
      // The next start or return to the app tries again.
    }
  }

  Future<_Outcome> _deliver(ReportSender sender, QuestionReport report) async {
    final toSend = QuestionReport(
      id: report.id,
      questionId: report.questionId,
      message: _cut(report.message),
      createdAt: report.createdAt,
      accountId: report.accountId,
      examId: report.examId,
      questionVersion: report.questionVersion,
    );
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await sender.send(toSend);
        return _Outcome.sent;
      } on ReportRefused {
        return _Outcome.refused;
      } on ReportUnavailable {
        return _Outcome.unavailable;
      } on Object {
        if (attempt == maxAttempts) return _Outcome.failed;
        await _wait(Duration(seconds: attempt * attempt * 2));
      }
    }
    return _Outcome.failed;
  }

  /// Marks one report done and drops its message. Reads the list again, so a
  /// report added during the pass is kept.
  Future<void> _settle(String id, ReportState state) =>
      _db.transaction(() async {
        final rows = await _rows();
        for (final row in rows) {
          if (row['id'] != id) continue;
          row
            ..['state'] = state.name
            ..['message'] = '';
        }
        await _write(rows);
      });

  /// The stored list. A list written before reports had ids gets them here and
  /// is saved at once, so an id never changes between tries.
  Future<List<Map<String, Object?>>> _rows() async {
    final account = _account();
    bool whole(Map<String, Object?> row) =>
        row['id'] is String && (row['accountId'] is String || account == null);
    final stored = await _read();
    if (stored.every(whole)) return stored;
    return _db.transaction(() async {
      final rows = await _read();
      var changed = false;
      for (final row in rows) {
        if (row['id'] is! String) {
          row['id'] = _newId();
          changed = true;
        }
        // A report from before accounts were recorded belongs to the account
        // signed in at the first read after the upgrade.
        if (row['accountId'] is! String && account != null) {
          row['accountId'] = account;
          changed = true;
        }
      }
      if (changed) await _write(rows);
      return rows;
    });
  }

  Future<List<Map<String, Object?>>> _read() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(_key)))
        .getSingleOrNull();
    if (row == null) return [];
    final data = jsonDecode(row.value) as List<dynamic>;
    return [
      for (final item in data) Map<String, Object?>.from(item as Map),
    ];
  }

  Future<void> _write(List<Map<String, Object?>> rows) =>
      _db.into(_db.devicePrefs).insertOnConflictUpdate(
            DevicePrefsCompanion.insert(key: _key, value: jsonEncode(rows)),
          );

  QuestionReport _parse(Map<String, Object?> row) => QuestionReport(
        id: row['id']! as String,
        questionId: row['questionId']! as String,
        message: (row['message'] as String?) ?? '',
        createdAt: DateTime.parse(row['createdAt']! as String),
        accountId: row['accountId'] as String?,
        examId: row['examId'] as String?,
        questionVersion: row['questionVersion'] as int?,
        state: ReportState.values.firstWhere(
          (s) => s.name == row['state'],
          orElse: () => ReportState.pending,
        ),
      );

  /// At most [maxMessageLength] UTF-16 units, never ending inside a pair.
  static String _cut(String message) {
    if (message.length <= maxMessageLength) return message;
    var end = maxMessageLength;
    final last = message.codeUnitAt(end - 1);
    if (last >= 0xD800 && last <= 0xDBFF) end--;
    return message.substring(0, end);
  }

  bool _sameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }
}

enum _Outcome { sent, refused, unavailable, failed }
