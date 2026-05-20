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
