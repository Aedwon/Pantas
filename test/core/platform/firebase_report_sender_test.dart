import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/firebase_report_sender.dart';
import 'package:pantas/core/storage/data/report_queue.dart';

QuestionReport _report({String? examId, int? version}) => QuestionReport(
      id: 'report-id-0000000001',
      accountId: 'acct-a',
      questionId: 'cse-q-1',
      message: 'Two answers look right.',
      createdAt: DateTime(2026, 11, 23),
      examId: examId,
      questionVersion: version,
    );

FirebaseReportSender _sender(
  ReportCallable callable, {
  String? account = 'acct-a',
}) =>
    FirebaseReportSender(
      callable: callable,
      currentAccount: () => account,
      build: () => '77',
    );

FirebaseFunctionsException _error(String code, [Object? details]) =>
    FirebaseFunctionsException(message: code, code: code, details: details);

void main() {
  test('the payload carries the id, question, exam, version, text and build',
      () async {
    Map<String, Object?>? sent;
    await _sender((data) async => sent = data)
        .send(_report(examId: 'cse-pro', version: 3));
    expect(sent, {
      'reportId': 'report-id-0000000001',
      'accountId': 'acct-a',
      'questionId': 'cse-q-1',
      'questionVersion': 3,
      'examId': 'cse-pro',
      'message': 'Two answers look right.',
      'build': '77',
    });
  });

  test('a report from before exam and version were kept leaves them out',
      () async {
    Map<String, Object?>? sent;
    await _sender((data) async => sent = data).send(_report());
    expect(sent!.containsKey('examId'), isFalse);
    expect(sent!.containsKey('questionVersion'), isFalse);
  });

  test('with no account nothing is called', () async {
    var called = false;
    final sender = _sender((_) async => called = true, account: null);
    await expectLater(
      sender.send(_report()),
      throwsA(isA<ReportUnavailable>()),
    );
    expect(called, isFalse);
  });

  test('a report made under another account is never called for', () async {
    var called = false;
    final sender = _sender((_) async => called = true, account: 'acct-b');
    await expectLater(
      sender.send(_report()),
      throwsA(isA<ReportUnavailable>()),
    );
    expect(called, isFalse);
  });

  test('a report with no account is never called for', () async {
    var called = false;
    final sender = _sender((_) async => called = true);
    final orphan = QuestionReport(
      id: 'report-id-0000000002',
      questionId: 'q',
      message: 'm',
      createdAt: DateTime(2026, 11, 23),
    );
    await expectLater(sender.send(orphan), throwsA(isA<ReportUnavailable>()));
    expect(called, isFalse);
  });

  test('the server saying the account differs keeps the report queued',
      () async {
    await expectLater(
      _sender(
        (_) async =>
            throw _error('failed-precondition', {'reason': 'wrong-account'}),
      ).send(_report()),
      throwsA(isA<FirebaseFunctionsException>()),
    );
  });

  test('a reused report id is a final refusal', () async {
    await expectLater(
      _sender((_) async => throw _error('already-exists')).send(_report()),
      throwsA(isA<ReportRefused>()),
    );
  });

  test('a malformed report and a full question are final refusals', () async {
    await expectLater(
      _sender((_) async => throw _error('invalid-argument')).send(_report()),
      throwsA(isA<ReportRefused>()),
    );
    await expectLater(
      _sender(
        (_) async => throw _error(
          'resource-exhausted',
          {'reason': 'question-limit'},
        ),
      ).send(_report()),
      throwsA(isA<ReportRefused>()),
    );
  });

  test('both quota refusals are final', () async {
    for (final reason in ['daily-limit', 'question-limit']) {
      await expectLater(
        _sender(
          (_) async => throw _error('resource-exhausted', {'reason': reason}),
        ).send(_report()),
        throwsA(
          isA<ReportRefused>().having((e) => e.reason, 'reason', reason),
        ),
      );
    }
  });

  test('a lost network, a server fault and a burst limit are retried later',
      () async {
    for (final error in [
      _error('resource-exhausted'),
      _error('unavailable'),
      _error('internal'),
      _error('unauthenticated'),
    ]) {
      await expectLater(
        _sender((_) async => throw error).send(_report()),
        throwsA(isA<FirebaseFunctionsException>()),
      );
    }
  });
}
