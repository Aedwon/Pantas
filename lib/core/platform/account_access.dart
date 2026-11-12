import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Remembers final account refusals, including ones received during bootstrap.
class AccountAccess {
  AccountAccess({this.refreshToken});

  /// Forces a new sign-in token for the account. True when the same
  /// account is still signed in and its token was renewed.
  final Future<bool> Function(String uid)? refreshToken;

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
      return await _attempt(uid, action);
    } on FirebaseFunctionsException catch (error) {
      if (uid == null || error.code != 'unauthenticated') rethrow;
      // A tab that sat in the background can send a call with an expired
      // token before the browser's refresh timer runs. Renew it and retry
      // once. The retry is outside this catch, so a second refusal surfaces.
      if (!await _renew(uid) || isClosed(uid)) rethrow;
    }
    return _attempt(uid, action);
  }

  Future<T> _attempt<T>(String? uid, Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseFunctionsException catch (error) {
      if (uid != null && isAccountClosedError(error)) close(uid);
      rethrow;
    }
  }

  Future<bool> _renew(String uid) async {
    try {
      return await (refreshToken ?? _forceRefresh)(uid);
    } on Object {
      return false;
    }
  }

  Future<void> dispose() => _events.close();
}

/// Only the server's structured terminal reason closes an account.
bool isAccountClosedError(Object error) {
  if (error is! FirebaseFunctionsException ||
      error.code != 'permission-denied') {
    return false;
  }
  final details = error.details;
  return details is Map && details['reason'] == 'account-closed';
}

FirebaseFunctionsException _closedError() => FirebaseFunctionsException(
      message: 'This account is being deleted.',
      code: 'permission-denied',
      details: const {'reason': 'account-closed'},
    );

Future<bool> _forceRefresh(String uid) async {
  if (Firebase.apps.isEmpty) return false;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.uid != uid) return false;
  await user.getIdToken(true);
  return FirebaseAuth.instance.currentUser?.uid == uid;
}

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
