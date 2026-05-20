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
}
