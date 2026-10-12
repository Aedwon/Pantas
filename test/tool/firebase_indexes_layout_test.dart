import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _indexSignature(Map<String, dynamic> index) {
  final fields =
      (index['fields'] as List<dynamic>).cast<Map<String, dynamic>>();
  final fieldSignature = fields
      .map((field) => '${field['fieldPath']}:${field['order']}')
      .join(',');

  return '${index['collectionGroup']}|${index['queryScope']}|$fieldSignature';
}

void main() {
  test('Firebase config declares cleanup and claims repair indexes', () {
    final firebaseConfig = jsonDecode(File('firebase.json').readAsStringSync())
        as Map<String, dynamic>;
    final firestore = firebaseConfig['firestore']! as Map<String, dynamic>;

    expect(firestore['indexes'], 'firestore.indexes.json');

    final indexesFile = File('firestore.indexes.json');
    expect(indexesFile.existsSync(), isTrue);

    final indexesConfig =
        jsonDecode(indexesFile.readAsStringSync()) as Map<String, dynamic>;
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
        [
          collectionGroup,
          'COLLECTION_GROUP',
          'deleted:ASCENDING,updatedAt:ASCENDING',
        ].join('|'),
      'sync_generations|COLLECTION_GROUP|status:ASCENDING,createdAt:ASCENDING',
      'sync_generations|COLLECTION_GROUP|status:ASCENDING,retiredAt:ASCENDING',
    };

    expect(indexes, hasLength(12));
    expect(indexes.map(_indexSignature), unorderedEquals(expectedSignatures));
  });

  test('Firebase config declares single-field claims repair overrides', () {
    final config = jsonDecode(File('firestore.indexes.json').readAsStringSync())
        as Map<String, dynamic>;
    final overrides = (config['fieldOverrides'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(overrides, hasLength(4));
    for (final field in ['claimsPending', 'updatedAt']) {
      final matches = overrides.where(
        (entry) =>
            entry['collectionGroup'] == 'server' && entry['fieldPath'] == field,
      );
      expect(matches, hasLength(1), reason: field);
      expect(matches.single, {
        'collectionGroup': 'server',
        'fieldPath': field,
        'indexes': [
          {'order': 'ASCENDING', 'queryScope': 'COLLECTION'},
          {'order': 'ASCENDING', 'queryScope': 'COLLECTION_GROUP'},
        ],
      });
    }
  });

  test('Firebase config keeps both expiry TTL overrides without indexes', () {
    final config = jsonDecode(File('firestore.indexes.json').readAsStringSync())
        as Map<String, dynamic>;
    final overrides = (config['fieldOverrides'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final group in ['users', 'webhookRateLimits']) {
      final matches = overrides.where(
        (entry) =>
            entry['collectionGroup'] == group &&
            entry['fieldPath'] == 'expireAt',
      );
      expect(matches, hasLength(1), reason: group);
      expect(matches.single, {
        'collectionGroup': group,
        'fieldPath': 'expireAt',
        'ttl': true,
        'indexes': <dynamic>[],
      });
    }
  });

  test('expiry guard rejects direct and aliased top-level account writes', () {
    for (final source in [
      r'db.doc(`users/${uid}`).set({expireAt: timestamp});',
      "db.collection('users').doc(uid).update({'expireAt': timestamp});",
      "db.collection('users').doc(uid).set({'expireAt': timestamp});",
      r'const event = db.doc(`users/${uid}`); '
          'transaction.set(event, {expireAt: timestamp});',
      r'const event = db.doc(`webhookEvents/${eventId}/users/${uid}`); '
          r'{ let event = db.doc(`users/${uid}`); '
          'transaction.set(event, {expireAt: timestamp}); }',
      'const payload = {expireAt: timestamp}; '
          r'db.doc(`users/${uid}`).set(payload);',
    ]) {
      expect(_hasUnreviewedExpiry(source), isTrue, reason: source);
    }
    expect(
      _hasUnreviewedExpiry(
        r'const event = db.doc(`webhookEvents/${eventId}/users/${uid}`); '
        'transaction.set(event, {expireAt: timestamp});',
      ),
      isFalse,
    );
    expect(
      _hasUnreviewedExpiry(
        r'const rate = deps.db.doc(`webhookRateLimits/${uid}_${bucket}`); '
        'transaction.set(rate, {expireAt: timestamp});',
      ),
      isFalse,
    );
  });

  test('source never writes expiry to a top-level account document', () {
    final violations = <String>[];
    for (final root in ['functions/src', 'lib']) {
      for (final file
          in Directory(root).listSync(recursive: true).whereType<File>()) {
        if (_hasUnreviewedExpiry(file.readAsStringSync())) {
          violations.add(file.path);
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'Account documents must never receive the TTL field.',
    );
  });
}

// Fail closed: only the reviewed dedupe and rate-limit writes may use TTL.
// New write forms or destinations need review before extending this guard.
bool _hasUnreviewedExpiry(String source) {
  final references = RegExp(
    r'const\s+(\w+)\s*=\s*[\w.]+\.doc\(`'
    r'(webhookEvents/\$\{[^}]+\}/users/\$\{[^}]+\}|'
    r'webhookRateLimits/[^`]+)`\);',
  );
  var remaining = source;
  for (final reference in references.allMatches(source)) {
    final name = RegExp.escape(reference.group(1)!);
    // A repeated binding could refer to an account in another scope.
    if (RegExp('(?:const|let|var|final)\\s+$name\\b')
            .allMatches(source)
            .length !=
        1) {
      continue;
    }
    remaining = remaining.replaceAll(
      RegExp('transaction\\.set\\(\\s*$name\\s*,\\s*'
          r'\{[^{}]*\bexpireAt\s*:[^{}]*\}\s*\)'),
      '',
    );
  }
  return RegExp(r'\bexpireAt\b').hasMatch(remaining);
}
