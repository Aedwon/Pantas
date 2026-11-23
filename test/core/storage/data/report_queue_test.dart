import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/report_queue.dart';

import '../../../helpers/in_memory_database.dart';

const _key = 'quiz_question_reports';

/// Records every report it is given and fails on demand.
class _Sender implements ReportSender {
  final sent = <QuestionReport>[];
  final script =
      <Exception?>[]; // one entry per call: null = accept, else throw
  int calls = 0;

  @override
  Future<void> send(QuestionReport report) async {
    calls++;
    final next = script.isEmpty ? null : script.removeAt(0);
    if (next != null) throw next;
    sent.add(report);
  }
}

ReportQueue _queue(
  AppDatabase db,
  ReportSender? sender, {
  String? Function()? account,
  int attempts = 3,
  List<Duration>? waits,
  String Function()? newId,
}) {
  var n = 0;
  return ReportQueue(
    db,
    sender: sender,
    account: account ?? () => 'acct-a',
    maxAttempts: attempts,
    wait: (d) async => waits?.add(d),
    newId: newId ?? () => 'report-id-${n++}'.padRight(20, '0'),
  );
}

Future<void> _storeRaw(AppDatabase db, List<Map<String, Object?>> rows) =>
    db.into(db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion(
            key: const Value(_key),
            value: Value(jsonEncode(rows)),
          ),
        );

Future<List<dynamic>> _readRaw(AppDatabase db) async {
  final row = await (db.select(db.devicePrefs)
        ..where((p) => p.key.equals(_key)))
      .getSingle();
  return jsonDecode(row.value) as List<dynamic>;
}

void main() {
  test('reports survive reopening and the fourth for a question is refused',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = _queue(db, null);
    final now = DateTime(2026, 10, 12, 23);
    for (var i = 0; i < 3; i++) {
      expect(await queue.add('q', '  Concern $i  ', now), ReportResult.queued);
    }
    expect(await queue.add('q', 'Fourth', now), ReportResult.questionLimit);
    final reopened = _queue(db, null);
    final reports = await reopened.pending();
    expect(reports, hasLength(3));
    expect(reports.first.message, 'Concern 0');
    expect(await reopened.sendPending(), 3);
    expect(await reopened.pending(), hasLength(3));
  });

  test('twenty per local day, reset at midnight, blank does not use a slot',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = _queue(db, null);
    final now = DateTime(2026, 10, 12, 23, 59);
    expect(await queue.add('q', '   ', now), ReportResult.empty);
    await Future.wait([
      for (var i = 0; i < 20; i++) queue.add('q$i', 'Concern', now),
    ]);
    expect(await queue.add('new', 'Concern', now), ReportResult.dailyLimit);
    expect(
      await queue.add('new', 'Concern', DateTime(2026, 10, 13)),
      ReportResult.queued,
    );
    expect(await queue.pending(), hasLength(21));
  });

  test('each report gets its own stable id, kept with exam and version',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = _queue(db, null);
    await queue.add(
      'q1',
      'One',
      DateTime(2026, 11, 23),
      examId: 'cse-pro',
      questionVersion: 4,
    );
    await queue.add('q2', 'Two', DateTime(2026, 11, 23));
    final first = await queue.pending();
    final again = await queue.pending();
    expect(first.map((r) => r.id).toSet(), hasLength(2));
    expect(again.map((r) => r.id), first.map((r) => r.id));
    expect(first.first.examId, 'cse-pro');
    expect(first.first.questionVersion, 4);
    expect(first.last.examId, isNull);
  });

  test('a message longer than the maximum is cut, never refused', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = _queue(db, null);
    expect(ReportQueue.maxMessageLength, 1000);
    await queue.add('q', 'm' * 1200, DateTime(2026, 11, 23));
    expect((await queue.pending()).single.message, hasLength(1000));
  });

  test('sendPending sends in order and keeps only a count of each sent report',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender();
    final queue = _queue(db, sender);
    final now = DateTime(2026, 11, 23, 10);
    await queue.add('q1', 'One', now, examId: 'cse-pro', questionVersion: 2);
    await queue.add('q2', 'Two', now);
    expect(await queue.sendPending(), 0);
    expect(sender.sent.map((r) => r.message), ['One', 'Two']);
    expect(sender.sent.first.examId, 'cse-pro');
    expect(sender.sent.first.questionVersion, 2);
    expect(await queue.pending(), isEmpty);
    // The message is gone from the device; the count is not.
    final stored = await _readRaw(db);
    expect(stored, hasLength(2));
    expect(jsonEncode(stored), isNot(contains('One')));
    expect(await queue.sendPending(), 0);
    expect(sender.calls, 2, reason: 'a sent report is never sent again');
  });

  test('sent reports keep counting toward both limits', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final queue = _queue(db, _Sender());
    final now = DateTime(2026, 11, 23, 10);
    for (var i = 0; i < 3; i++) {
      expect(await queue.add('q', 'C$i', now), ReportResult.queued);
    }
    await queue.sendPending();
    expect(await queue.pending(), isEmpty);
    expect(await queue.add('q', 'again', now), ReportResult.questionLimit);
    expect(await queue.history(), hasLength(3));
    for (var i = 0; i < 17; i++) {
      expect(await queue.add('r$i', 'C', now), ReportResult.queued);
    }
    await queue.sendPending();
    expect(await queue.add('new', 'C', now), ReportResult.dailyLimit);
    expect(
      await queue.add('new', 'C', DateTime(2026, 11, 24)),
      ReportResult.queued,
    );
  });

  test('a failure keeps the report, retries with a wait, then stops the pass',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender()
      ..script.addAll([
        Exception('offline'),
        Exception('offline'),
        Exception('offline'),
      ]);
    final waits = <Duration>[];
    final queue = _queue(db, sender, waits: waits);
    final now = DateTime(2026, 11, 23, 10);
    await queue.add('q1', 'One', now);
    await queue.add('q2', 'Two', now);
    expect(await queue.sendPending(), 2);
    expect(sender.calls, 3, reason: 'three tries for the first, none for more');
    expect(waits, hasLength(2));
    expect(waits.last, greaterThan(waits.first));
    expect((await queue.pending()).map((r) => r.message), ['One', 'Two']);
  });

  test('a retry that works sends the report once and carries on', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender()..script.add(Exception('blip'));
    final queue = _queue(db, sender);
    final now = DateTime(2026, 11, 23, 10);
    await queue.add('q1', 'One', now);
    await queue.add('q2', 'Two', now);
    expect(await queue.sendPending(), 0);
    expect(sender.sent.map((r) => r.message), ['One', 'Two']);
  });

  test('the same id is sent on every try of one report', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final ids = <String>[];
    final queue = _queue(
      db,
      _Retrying(ids),
    );
    await queue.add('q1', 'One', DateTime(2026, 11, 23, 10));
    await queue.sendPending();
    expect(ids, hasLength(2));
    expect(ids.toSet(), hasLength(1));
  });

  test('a report the server refuses for good is dropped but still counted',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender()..script.add(const ReportRefused('question-limit'));
    final queue = _queue(db, sender);
    final now = DateTime(2026, 11, 23, 10);
    await queue.add('q1', 'One', now);
    await queue.add('q2', 'Two', now);
    expect(await queue.sendPending(), 0);
    expect(sender.sent.map((r) => r.message), ['Two']);
    expect(sender.calls, 2, reason: 'a refusal is not retried');
    expect(await queue.pending(), isEmpty);
    expect(await queue.history(), hasLength(2));
    expect(jsonEncode(await _readRaw(db)), isNot(contains('One')));
  });

  test('when no account can send, the report stays and nothing is retried',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender()..script.add(const ReportUnavailable());
    final waits = <Duration>[];
    final queue = _queue(db, sender, waits: waits);
    await queue.add('q1', 'One', DateTime(2026, 11, 23, 10));
    expect(await queue.sendPending(), 1);
    expect(sender.calls, 1);
    expect(waits, isEmpty);
    expect(await queue.pending(), hasLength(1));
  });

  test('two passes at once never send a report twice', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final sender = _Sender();
    final queue = _queue(db, sender);
    await queue.add('q1', 'One', DateTime(2026, 11, 23, 10));
    await Future.wait([
      queue.sendPending(),
      queue.sendPending(),
      queue.sendPending(),
    ]);
    expect(sender.calls, 1);
  });

  test('a report added while another is sending is kept', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gate = Completer<void>();
    final queue = _queue(db, _Slow(gate.future));
    final now = DateTime(2026, 11, 23, 10);
    await queue.add('q1', 'One', now);
    final pass = queue.sendPending();
    await Future<void>.delayed(Duration.zero);
    await queue.add('q2', 'Two', now);
    gate.complete();
    await pass;
    expect((await queue.pending()).map((r) => r.message), ['Two']);
    expect(await queue.history(), hasLength(2));
  });

  group('accounts', () {
    test('what account A queued is never sent as account B', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sender = _Sender();
      String? who = 'acct-a';
      final queue = _queue(db, sender, account: () => who);
      await queue.add('q1', 'From A', DateTime(2026, 11, 23, 10));
      who = 'acct-b';
      expect(await queue.sendPending(), 0);
      expect(sender.calls, 0);
      await queue.add('q2', 'From B', DateTime(2026, 11, 23, 10));
      expect(await queue.sendPending(), 0);
      expect(sender.sent.map((r) => r.message), ['From B']);
      expect((await queue.pending()).map((r) => r.message), ['From A']);
      who = 'acct-a';
      expect(await queue.sendPending(), 0);
      expect(sender.sent.map((r) => r.message), ['From B', 'From A']);
    });

    test('each report carries the account that made it', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final queue = _queue(db, null, account: () => 'acct-a');
      await queue.add('q1', 'One', DateTime(2026, 11, 23, 10));
      expect((await queue.pending()).single.accountId, 'acct-a');
    });

    test('with nobody signed in nothing is sent', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sender = _Sender();
      final queue = _queue(db, sender, account: () => null);
      await queue.add('q1', 'One', DateTime(2026, 11, 23, 10));
      expect(await queue.sendPending(), 1);
      expect(sender.calls, 0);
    });
  });

  group('reports queued before this change', () {
    final old = [
      {
        'questionId': 'q1',
        'message': 'Old one',
        'createdAt': DateTime(2026, 11, 20, 9).toIso8601String(),
      },
      {
        'questionId': 'q1',
        'message': 'Old two',
        'createdAt': DateTime(2026, 11, 20, 10).toIso8601String(),
      },
    ];

    test('they read, get ids that stay, and count as pending', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await _storeRaw(db, old);
      final queue = _queue(db, null);
      final first = await queue.pending();
      expect(first.map((r) => r.message), ['Old one', 'Old two']);
      expect(first.map((r) => r.id).toSet(), hasLength(2));
      expect(first.every((r) => r.examId == null), isTrue);
      expect(first.every((r) => r.questionVersion == null), isTrue);
      // A second queue on the same data sees the same ids: they were stored.
      final again = await _queue(db, null).pending();
      expect(again.map((r) => r.id), first.map((r) => r.id));
      expect(
        (await _readRaw(db)).every((r) => (r as Map).containsKey('id')),
        isTrue,
      );
    });

    test('they belong to the account signed in at the first read', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await _storeRaw(db, old);
      final sender = _Sender();
      String? who = 'acct-a';
      final queue = _queue(db, sender, account: () => who);
      expect((await queue.pending()).map((r) => r.accountId), [
        'acct-a',
        'acct-a',
      ]);
      who = 'acct-b';
      expect(await queue.sendPending(), 0);
      expect(sender.calls, 0);
      who = 'acct-a';
      expect(await queue.sendPending(), 0);
      expect(sender.sent, hasLength(2));
    });

    test('with nobody signed in at first read they wait for an account',
        () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await _storeRaw(db, old);
      String? who;
      final sender = _Sender();
      final queue = _queue(db, sender, account: () => who);
      expect((await queue.pending()).map((r) => r.accountId), [null, null]);
      expect(await queue.sendPending(), 2);
      who = 'acct-b';
      expect(await queue.sendPending(), 0);
      expect(sender.sent, hasLength(2));
    });

    test('they send, once, then keep counting', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await _storeRaw(db, old);
      final sender = _Sender();
      final queue = _queue(db, sender);
      expect(await queue.sendPending(), 0);
      expect(sender.sent.map((r) => r.message), ['Old one', 'Old two']);
      expect(sender.sent.first.examId, isNull);
      final at = DateTime(2026, 11, 20, 11);
      expect(await queue.add('q1', 'new', at), ReportResult.queued);
      expect(await queue.add('q1', 'new', at), ReportResult.questionLimit);
    });

    test('an old message over the maximum is cut when it is sent', () async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await _storeRaw(db, [
        {
          'questionId': 'q1',
          'message': 'x' * 3000,
          'createdAt': DateTime(2026, 11, 20, 9).toIso8601String(),
        },
      ]);
      final sender = _Sender();
      await _queue(db, sender).sendPending();
      expect(sender.sent.single.message, hasLength(1000));
    });
  });
}

class _Retrying implements ReportSender {
  _Retrying(this.ids);
  final List<String> ids;
  @override
  Future<void> send(QuestionReport report) async {
    ids.add(report.id);
    if (ids.length == 1) throw Exception('blip');
  }
}

class _Slow implements ReportSender {
  _Slow(this.gate);
  final Future<void> gate;
  @override
  Future<void> send(QuestionReport report) => gate;
}
