import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';

void main() {
  test('AC-10 a named Pro claim needs a future numeric expiry', () {
    final at = DateTime.utc(2026, 10, 10);
    expect(hasLiveProClaim({'pro': true}, at: at), isFalse);
    expect(
      hasLiveProClaim(
        {'pro': true, 'proUntil': at.millisecondsSinceEpoch},
        at: at,
      ),
      isFalse,
    );
    expect(
      hasLiveProClaim(
        {
          'pro': true,
          'proUntil': at.add(const Duration(days: 1)).millisecondsSinceEpoch,
        },
        at: at,
      ),
      isTrue,
    );
  });
  test('AC-3 permission-denied refreshes once and retries sync once', () async {
    var calls = 0;
    var refreshes = 0;
    final result = await refreshOnceAfterPermissionDenied(
      () async {
        calls++;
        if (calls == 1) {
          throw FirebaseException(plugin: 'test', code: 'permission-denied');
        }
        return 'confirmed-row';
      },
      refresh: () async {
        refreshes++;
      },
    );
    expect(result, 'confirmed-row');
    expect(calls, 2);
    expect(refreshes, 1);
  });
  test('account-closed never refreshes or retries under another identity',
      () async {
    var uid = 'student';
    final dispatched = <String>[];
    final refusal = FirebaseFunctionsException(
      code: 'permission-denied',
      message: 'This account is being deleted.',
      details: const {'reason': 'account-closed'},
    );
    await expectLater(
      refreshOnceAfterPermissionDenied(
        () async {
          dispatched.add(uid);
          if (uid == 'student') throw refusal;
          return 'activated';
        },
        refresh: () async {
          uid = 'other-student';
        },
      ),
      throwsA(same(refusal)),
    );
    expect(uid, 'student', reason: 'no credential refresh after closure');
    expect(dispatched, ['student']);
  });

  test('AC-3 claim changes refresh once and stop on another account', () async {
    final changes = StreamController<Object?>.broadcast();
    var refreshed = 0;
    final binding = ClaimsChangeBinding(
      watchChanges: (_) => changes.stream,
      refresh: (_) async {
        refreshed++;
      },
    );
    await binding.associate('test-account');
    changes
      ..add(null)
      ..add(1)
      ..add(1)
      ..add(2);
    await pumpEventQueue();
    expect(refreshed, 2);
    await binding.associate(null);
    changes.add(3);
    await pumpEventQueue();
    expect(refreshed, 2);
    await changes.close();
  });
}
