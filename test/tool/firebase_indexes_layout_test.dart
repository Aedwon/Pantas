import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _indexSignature(Map<String, dynamic> index) {
  final fields = (index['fields'] as List<dynamic>)
      .cast<Map<String, dynamic>>();
  final fieldSignature = fields
      .map((field) => '${field['fieldPath']}:${field['order']}')
      .join(',');

  return '${index['collectionGroup']}|${index['queryScope']}|$fieldSignature';
}

void main() {
  test('Firebase config declares the complete cleanup index contract', () {
    final firebaseConfig = jsonDecode(File('firebase.json').readAsStringSync())
        as Map<String, dynamic>;
    final firestore = firebaseConfig['firestore']! as Map<String, dynamic>;

    expect(firestore['indexes'], 'firestore.indexes.json');

    final indexesFile = File('firestore.indexes.json');
    expect(indexesFile.existsSync(), isTrue);

    final indexesConfig = jsonDecode(indexesFile.readAsStringSync())
        as Map<String, dynamic>;
    final indexes = (indexesConfig['indexes'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final expectedSignatures = <String>{
      for (final collectionGroup in [
        'quiz_attempts',
        'assessments',
        'fsrs_cards',
        'lesson_progress',
        'lesson_bookmarks',
        'question_flags',
        'mock_exam_attempts',
        'review_logs',
        'track_scope',
        'custom_blueprints',
      ])
        '$collectionGroup|COLLECTION_GROUP|deleted:ASCENDING,updatedAt:ASCENDING',
      'sync_generations|COLLECTION_GROUP|status:ASCENDING,createdAt:ASCENDING',
      'sync_generations|COLLECTION_GROUP|status:ASCENDING,retiredAt:ASCENDING',
    };

    expect(indexes, hasLength(12));
    expect(indexes.map(_indexSignature), unorderedEquals(expectedSignatures));
  });
}
