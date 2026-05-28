import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cse_cet_reviewer/features/wrapped/domain/wrapped_share_host.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase-backed [WrappedShareHost]: Cloud Storage for the PNG, Firestore
/// for the `wrapped_shares/<shareId>` record that the landing-page function
/// reads (landing-page spec §3.3).
class FirebaseWrappedShareHost implements WrappedShareHost {
  FirebaseWrappedShareHost({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static String storagePath(String uid, String shareId) =>
      'wrapped/$uid/$shareId.png';

  @override
  Future<void> publish({
    required String uid,
    required String shareId,
    required String archetypeId,
    required Uint8List pngBytes,
  }) async {
    final path = storagePath(uid, shareId);
    await _storage.ref(path).putData(
          pngBytes,
          SettableMetadata(contentType: 'image/png'),
        );
    await _firestore.collection('wrapped_shares').doc(shareId).set({
      'ownerUid': uid,
      'storagePath': path,
      'archetypeId': archetypeId,
      'createdAt': FieldValue.serverTimestamp(),
      'revoked': false,
    });
  }

  @override
  Future<void> revoke({required String uid, required String shareId}) async {
    await _firestore
        .collection('wrapped_shares')
        .doc(shareId)
        .update({'revoked': true});
    await _storage.ref(storagePath(uid, shareId)).delete();
  }
}
