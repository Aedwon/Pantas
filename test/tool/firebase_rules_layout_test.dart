import 'dart:convert';
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

  test('firestore.rules defines generation-based Sync layout', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('function isProOwner(uid)'));
    expect(rules, contains('function activeGenerationId(uid)'));
    expect(rules, contains('function isActiveGeneration(uid, generationId)'));
    expect(rules, contains('function isStagingGeneration(uid, generationId)'));
    expect(rules, contains('match /sync_state/{stateId}'));
    expect(rules, contains('match /sync_generations/{generationId}'));

    for (final collection in [
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
    ]) {
      expect(rules, contains('match /$collection/{rowId}'));
    }
  });

  test('firestore.rules freezes Sync row metadata requirements', () {
    final rules = File('firestore.rules').readAsStringSync();

    expect(rules, contains('request.resource.data.updatedAt == request.time'));
    expect(rules, contains('request.resource.data.originDeviceId.size() > 0'));
    expect(rules, contains('request.resource.data.mutationId.size() > 0'));
    expect(rules, contains('request.resource.data.schemaVersion == 1'));
    expect(rules, contains('request.resource.data.deleted is bool'));
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
    // Read as JSON, not as text. `flutterfire configure` rewrites this file
    // minified, and the old string match wanted the spacing a human editor
    // leaves behind. It failed on 12 August against a correct config.
    final config = jsonDecode(File('firebase.json').readAsStringSync())
        as Map<String, dynamic>;

    final firestore = config['firestore']! as Map<String, dynamic>;
    expect(firestore['rules'], 'firestore.rules');

    final storage = config['storage']! as Map<String, dynamic>;
    expect(storage['rules'], 'storage.rules');

    final emulators = config['emulators']! as Map<String, dynamic>;
    expect(emulators.keys, containsAll(['firestore', 'auth', 'functions']));
    expect(emulators.containsKey('storage'), isTrue);
  });
}
