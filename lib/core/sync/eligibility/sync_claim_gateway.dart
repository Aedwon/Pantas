import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';

// ignore: one_member_abstracts
abstract interface class SyncClaimGateway {
  Future<bool> refreshProClaim({required String uid});
}

class FirebaseSyncClaimGateway implements SyncClaimGateway {
  FirebaseSyncClaimGateway({firebase.FirebaseAuth? auth})
      : _auth = auth ?? firebase.FirebaseAuth.instance;

  final firebase.FirebaseAuth _auth;

  @override
  Future<bool> refreshProClaim({required String uid}) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous || user.uid != uid) {
      return false;
    }
    final result = await user.getIdTokenResult(true);
    return hasLiveProClaim(result.claims ?? {});
  }
}

bool hasLiveProClaim(Map<String, Object?> claims, {DateTime? at}) {
  final end = claims['proUntil'];
  return claims['pro'] == true &&
      end is num &&
      end.isFinite &&
      end > (at ?? DateTime.now()).millisecondsSinceEpoch;
}

Future<void> refreshPaymentClaimToken(String? expectedUid) async {
  final user = firebase.FirebaseAuth.instance.currentUser;
  if (user != null && user.uid == expectedUid) {
    await user.getIdTokenResult(true);
  }
}

class ClaimsChangeBinding {
  ClaimsChangeBinding({
    required Stream<Object?> Function(String uid) watchChanges,
    required Future<void> Function(String uid) refresh,
  })  : _watchChanges = watchChanges,
        _refresh = refresh;
  final Stream<Object?> Function(String uid) _watchChanges;
  final Future<void> Function(String uid) _refresh;
  StreamSubscription<Object?>? _subscription;
  String? _uid;
  Object? _last;

  Future<void> associate(String? uid) async {
    if (_uid == uid) return;
    _uid = uid;
    await _subscription?.cancel();
    _subscription = null;
    _last = null;
    if (uid == null) return;
    _subscription = _watchChanges(uid).listen(
      (value) {
        if (_uid != uid || value == null || value == _last) return;
        _last = value;
        unawaited(_refresh(uid).catchError((Object _) {}));
      },
      onError: (Object _) {},
    );
  }

  Future<void> dispose() => associate(null);
}

Future<void> refreshCurrentClaimToken() async {
  final user = firebase.FirebaseAuth.instance.currentUser;
  if (user != null) await user.getIdTokenResult(true);
}

Future<T> refreshOnceAfterPermissionDenied<T>(
  Future<T> Function() action, {
  Future<void> Function()? refresh,
}) async {
  try {
    return await action();
  } on FirebaseException catch (error, stack) {
    if (error.code != 'permission-denied') rethrow;
    try {
      await (refresh ?? refreshCurrentClaimToken)();
    } catch (_) {
      Error.throwWithStackTrace(error, stack);
    }
    return action();
  }
}
