import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('firestore.rules denies audit_logs client access', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('match /audit_logs/{logId}'));
    expect(rules, contains('allow read, write: if false;'));
  });

  test('firestore.rules rejects anonymous users by sign_in_provider', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(
      rules,
      contains("request.auth.token.firebase.sign_in_provider != 'anonymous'"),
    );
  });

  test('firestore.rules includes all synced user-data subcollections', () {
    final rules = File('firestore.rules').readAsStringSync();

    for (final path in [
      'lesson_progress/{lessonId}',
      'quiz_attempts/{attemptId}',
      'fsrs_cards/{cardId}',
      'assessments/{assessmentId}',
      'study_plan/{docId}',
      'mock_exam_attempts/{attemptId}',
    ]) {
      expect(rules, contains('match /$path'));
    }
  });

  test('firestore.rules limits root user updates to allowed keys', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('affectedKeys().hasOnly'));
    expect(rules, contains("'preferences'"));
    expect(rules, isNot(contains("'pro'")));
  });

  test('firestore.rules deny users root delete', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('match /users/{uid}'));
    expect(rules, contains('allow delete: if false;'));
  });

  test('firestore.rules gates Pro paths with the pro custom claim', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('function isProUser()'));
    expect(rules, contains('request.auth.token.pro == true'));
    expect(rules, contains('match /proDossiers/{dossierId}'));
    expect(
      rules,
      contains('match /examTracks/{trackId}/proContent/{contentId}'),
    );
  });

  test('firebase.json points at firestore.rules and local emulators', () {
    final config = File('firebase.json').readAsStringSync();

    expect(config, contains('"rules": "firestore.rules"'));
    expect(config, contains('"emulators"'));
    expect(config, contains('"firestore"'));
    expect(config, contains('"auth"'));
    expect(config, contains('"functions"'));
    expect(config, contains('"storage"'));
  });
}
