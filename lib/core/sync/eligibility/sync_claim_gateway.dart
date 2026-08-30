import 'package:firebase_auth/firebase_auth.dart' as firebase;

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
    return result.claims?['pro'] == true;
  }
}
