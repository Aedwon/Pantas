import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pantas/features/wrapped/domain/wrapped_share_host.dart';

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

  /// How long a shared card stays up. The server rules accept at most 90 days
  /// from their own clock, so this keeps a margin for a fast device clock.
  static const shareLifetime = Duration(days: 89);

  /// The `wrapped_shares/<shareId>` document. `expireAt` is the field the
  /// Firestore TTL policy deletes by.
  static Map<String, Object?> shareRecord({
    required String uid,
    required String shareId,
    required String archetypeId,
    required DateTime now,
  }) =>
      {
        'ownerUid': uid,
        'storagePath': storagePath(uid, shareId),
        'archetypeId': archetypeId,
        'createdAt': FieldValue.serverTimestamp(),
        'revoked': false,
        'expireAt': Timestamp.fromDate(now.add(shareLifetime)),
      };

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
    await _firestore.collection('wrapped_shares').doc(shareId).set(
          shareRecord(
            uid: uid,
            shareId: shareId,
            archetypeId: archetypeId,
            now: DateTime.now(),
          ),
        );
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
