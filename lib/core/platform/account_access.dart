import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Remembers final account refusals, including ones received during bootstrap.
class AccountAccess {
  final _events = StreamController<String>.broadcast(sync: true);
  final _closed = <String>{};

  Stream<String> get closures => _events.stream;
  bool isClosed(String uid) => _closed.contains(uid);

  void close(String uid) {
    if (_closed.add(uid)) _events.add(uid);
  }

  Future<T> run<T>(String? uid, Future<T> Function() action) async {
    if (uid != null && isClosed(uid)) throw _closedError();
    try {
      return await action();
    } on FirebaseFunctionsException catch (error) {
      final details = error.details;
      if (uid != null &&
          error.code == 'permission-denied' &&
          details is Map &&
          details['reason'] == 'account-closed') {
        close(uid);
      }
      rethrow;
    }
  }

  Future<void> dispose() => _events.close();
}

FirebaseFunctionsException _closedError() => FirebaseFunctionsException(
      message: 'This account is being deleted.',
      code: 'permission-denied',
      details: const {'reason': 'account-closed'},
    );

final accountAccess = AccountAccess();

/// Captures the authenticated owner before dispatch. A late refusal must never
/// sign out a different account that signed in while this call was in flight.
extension AccountCallable on HttpsCallable {
  Future<HttpsCallableResult<T>> callForAccount<T>([Object? data]) {
    final uid =
        Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser?.uid;
    return accountAccess.run(uid, () => call<T>(data));
  }
}
