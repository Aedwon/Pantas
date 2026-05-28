import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CONTRIBUTING documents flutterfire configure', () {
    final docs = File('CONTRIBUTING.md').readAsStringSync();

    expect(docs, contains('flutterfire configure'));
    expect(docs, contains('lib/firebase_options_dev.dart'));
    expect(docs, contains('lib/firebase_options_prod.dart'));
  });

  test('CONTRIBUTING documents App Check debug token registration', () {
    final docs = File('CONTRIBUTING.md').readAsStringSync();

    expect(docs, contains('App Check'));
    expect(docs, contains('debug token'));
  });

  test('CONTRIBUTING documents Play Integrity as prod-only Android setup', () {
    final docs = File('CONTRIBUTING.md').readAsStringSync();

    expect(docs, contains('Play Integrity'));
    expect(docs, contains('prod'));
  });

  test('OPERATIONS documents Firebase sync setup', () {
    final docs = File('docs/OPERATIONS.md').readAsStringSync();

    expect(docs, contains('resetCloudUserData'));
    expect(docs, contains('App Check enforcement'));
    expect(docs, contains('firestore.rules'));
    expect(docs, contains('real-device'));
    expect(docs, contains('content.db'));
    expect(docs, contains('out of user-data sync scope'));
  });

  test('firebase setup docs mention legal callable manual validation', () {
    final docs = File(
      'docs/superpowers/specs/2026-05-23-legal-ra10173-implementation-notes.md',
    ).readAsStringSync();

    expect(docs, contains('deleteAccount'));
    expect(docs, contains('App Check'));
    expect(docs, contains('asia-southeast1'));
    expect(docs, contains('throwaway account'));
  });
}
