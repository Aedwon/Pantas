import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';

class SyncCloudProgressGateway implements CloudProgressGateway {
  SyncCloudProgressGateway(this._gateway);

  final FirestoreGateway _gateway;

  static const _meaningfulCollections = [
    'quiz_attempts',
    'assessments',
    'fsrs_cards',
    'lesson_progress',
    'lesson_bookmarks',
    'question_flags',
    'mock_exam_attempts',
  ];

  @override
  Future<bool> hasMeaningfulProgress(String uid) async {
    for (final collection in _meaningfulCollections) {
      final rows = await _gateway.readCollection('users/$uid/$collection');
      if (rows.isNotEmpty) return true;
    }
    return false;
  }
}
