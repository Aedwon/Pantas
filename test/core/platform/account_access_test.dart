import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/account_access.dart';

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
}
