import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/features/home/data/study_api.dart';

void main() {
  late AccountAccess access;
  setUp(() => access = AccountAccess());
  tearDown(() => access.dispose());

  test('structured terminal refusal closes the request owner before rethrowing',
      () async {
    final events = <String>[];
    final sub = access.closures.listen(events.add);
    addTearDown(sub.cancel);
    final error = FirebaseFunctionsException(
      message: 'This account is being deleted.',
      code: 'permission-denied',
      details: const {'reason': 'account-closed'},
    );
    await expectLater(
      access.run('student', () async => throw error),
      throwsA(same(error)),
    );
    expect(events, ['student']);
    expect(access.isClosed('student'), isTrue);
  });

  test('a closed owner never dispatches another request', () async {
    access.close('student');
    var sent = false;
    await expectLater(
      access.run('student', () async {
        sent = true;
        return 1;
      }),
      throwsA(isA<FirebaseFunctionsException>()),
    );
    expect(sent, isFalse);
  });

  test('closure remembered before a listener attaches; duplicates emit once',
      () async {
    access.close('student');
    final events = <String>[];
    final sub = access.closures.listen(events.add);
    addTearDown(sub.cancel);
    expect(access.isClosed('student'), isTrue);
    access.close('student');
    expect(events, isEmpty);
  });

  test(
      'ordinary permission errors and offline failures do not close an account',
      () async {
    for (final code in ['permission-denied', 'unavailable']) {
      final error = FirebaseFunctionsException(
        message: 'This account is being deleted.',
        code: code,
      );
      await expectLater(
        access.run('student', () async => throw error),
        throwsA(same(error)),
      );
      expect(access.isClosed('student'), isFalse);
    }
    expect(await access.run('other', () async => 7), 7);
  });

  group('expired sign-in token', () {
    FirebaseFunctionsException unauth() => FirebaseFunctionsException(
          message: 'Expired token',
          code: 'unauthenticated',
        );

    test('one refusal renews the token and retries once to success', () async {
      var refreshed = 0;
      final a = AccountAccess(
        refreshToken: (uid) async => ++refreshed > 0,
      );
      addTearDown(a.dispose);
      var sent = 0;
      final result = await a.run('student', () async {
        sent++;
        if (sent == 1) throw unauth();
        return 'plan';
      });
      expect(result, 'plan');
      expect(sent, 2);
      expect(refreshed, 1);
    });

    test('a second refusal after the retry surfaces, with no loop', () async {
      var refreshed = 0;
      final a = AccountAccess(
        refreshToken: (uid) async => ++refreshed > 0,
      );
      addTearDown(a.dispose);
      var sent = 0;
      await expectLater(
        a.run('student', () async {
          sent++;
          throw unauth();
        }),
        throwsA(
          isA<FirebaseFunctionsException>()
              .having((e) => e.code, 'code', 'unauthenticated'),
        ),
      );
      expect(sent, 2);
      expect(refreshed, 1);
    });

    test('a closed-account refusal is never retried', () async {
      var refreshed = 0;
      final a = AccountAccess(
        refreshToken: (uid) async => ++refreshed > 0,
      );
      addTearDown(a.dispose);
      var sent = 0;
      await expectLater(
        a.run('student', () async {
          sent++;
          throw FirebaseFunctionsException(
            message: 'This account is being deleted.',
            code: 'permission-denied',
            details: const {'reason': 'account-closed'},
          );
        }),
        throwsA(isA<FirebaseFunctionsException>()),
      );
      expect(sent, 1);
      expect(refreshed, 0);
      expect(a.isClosed('student'), isTrue);
    });

    test('signed out never renews or retries', () async {
      var refreshed = 0;
      final a = AccountAccess(
        refreshToken: (uid) async => ++refreshed > 0,
      );
      addTearDown(a.dispose);
      var sent = 0;
      await expectLater(
        a.run<void>(null, () async {
          sent++;
          throw unauth();
        }),
        throwsA(isA<FirebaseFunctionsException>()),
      );
      expect(sent, 1);
      expect(refreshed, 0);
    });

    test('no retry when the account changed during renewal', () async {
      final a = AccountAccess(refreshToken: (uid) async => false);
      addTearDown(a.dispose);
      var sent = 0;
      await expectLater(
        a.run<void>('student', () async {
          sent++;
          throw unauth();
        }),
        throwsA(isA<FirebaseFunctionsException>()),
      );
      expect(sent, 1);
    });

    test('Home plan read after a resume with an expired token ends with data',
        () async {
      final a = AccountAccess(refreshToken: (uid) async => true);
      addTearDown(a.dispose);
      var tokenFresh = false;
      final api = StudyApi(
        (name, data) => a.run('student', () async {
          if (!tokenFresh) {
            tokenFresh = true; // the renewal lands right after the refusal
            throw unauth();
          }
          return <String, Object?>{'days': 3};
        }),
      );
      final request = StudyRequest(
        api: api,
        uid: 'student',
        examId: 'exam',
        isCurrent: () async => true,
      );
      expect(await request.read('getRoadmap'), {'days': 3});
    });
  });
}
