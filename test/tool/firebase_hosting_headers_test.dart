import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Files that must always be fresh for browsers are still cached at Google's
/// edge until the next deploy, which clears that cache. On Nov 7 every
/// `no-cache` file missed the Manila edge and some took 0.7 s more.
const _fresh = 'public, max-age=0, must-revalidate, s-maxage=31536000';

void main() {
  late List<Map<String, Object?>> rules;

  setUpAll(() {
    final config = jsonDecode(File('firebase.json').readAsStringSync())
        as Map<String, Object?>;
    final hosting = (config['hosting']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((site) => site['target'] == 'app');
    rules = (hosting['headers']! as List<Object?>).cast<Map<String, Object?>>();
  });

  String cacheControlFor(String source) {
    final rule = rules.singleWhere((r) => r['source'] == source);
    final headers =
        (rule['headers']! as List<Object?>).cast<Map<String, Object?>>();
    return headers.singleWhere((h) => h['key'] == 'Cache-Control')['value']!
        as String;
  }

  test('always-fresh files revalidate in the browser and stay at the edge', () {
    for (final source in [
      '/index.html',
      '/',
      '/*.js',
      '/manifest.json',
      '/version.json',
      '/flutter_service_worker.js',
    ]) {
      expect(cacheControlFor(source), _fresh, reason: source);
    }
  });

  test('hashed files stay immutable for a year', () {
    expect(
      cacheControlFor(
        '**/*.????????.@(js|css|wasm|png|jpg|jpeg|webp|svg|woff|woff2|ttf|otf)',
      ),
      'public, max-age=31536000, immutable',
    );
  });

  test('no rule is plain no-cache any more', () {
    for (final rule in rules) {
      final headers =
          (rule['headers']! as List<Object?>).cast<Map<String, Object?>>();
      for (final header in headers) {
        expect(header['value'], isNot('no-cache'), reason: '${rule['source']}');
      }
    }
  });
}
