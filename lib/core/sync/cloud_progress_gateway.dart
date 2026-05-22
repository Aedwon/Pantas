import 'package:cse_cet_reviewer/core/auth/auth_repository.dart';
import 'package:cse_cet_reviewer/core/sync/firestore/firestore_gateway.dart';

class SyncCloudProgressGateway implements CloudProgressGateway {
  SyncCloudProgressGateway(this._gateway);

  final FirestoreGateway _gateway;

  static const _meaningfulCollections = [
    'quiz_attempts',
    'lesson_progress',
    'fsrs_cards',
  ];

  @override
  Future<bool> hasMeaningfulProgress(String uid) async {
    if (uid.startsWith('anon-')) {
      throw ArgumentError.value(uid, 'uid', 'anonymous users do not sync');
    }

    for (final collection in _meaningfulCollections) {
      final rows = await _gateway.readCollection('users/$uid/$collection');
      if (rows.isNotEmpty) return true;
    }
    return false;
  }
}
