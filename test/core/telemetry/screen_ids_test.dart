import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/screen_ids.dart';

import '../../../tool/list_routes.dart' as routes;

String _sample(String template) => template.replaceAllMapped(
      RegExp(':[A-Za-z]+'),
      (_) => 'abc123',
    );

void main() {
  group('screenIdFor', () {
    test('maps a route to its screen id', () {
      expect(screenIdFor('/home'), 'home');
      expect(screenIdFor('/study'), 'study');
      expect(screenIdFor('/lesson/abc'), 'lesson');
      expect(screenIdFor('/settings/pro'), 'pro');
      expect(screenIdFor('/pro'), 'pro');
      expect(screenIdFor('/quiz/practice/cse'), 'quiz_practice');
      expect(screenIdFor('/quiz/practice/cse/run'), 'quiz_practice_run');
      expect(screenIdFor('/assessment/cse/results'), 'assessment_results');
    });

    test('never returns a concrete id, a query or free text', () {
      expect(screenIdFor('/lesson/secret-lesson-42?from=x#y'), 'lesson');
      expect(screenIdFor('/legal/privacy'), 'legal');
      expect(screenIdFor('/plan/day/2026-11-14'), 'plan_day');
      expect(screenIdFor('/home/'), 'home');
    });

    test('an unknown route is other', () {
      expect(screenIdFor('/nope'), 'other');
      expect(screenIdFor('/home/extra/segments'), 'other');
      expect(screenIdFor(''), 'other');
      expect(screenIdFor('home'), 'home');
    });

    test('debug-only screens are other', () {
      expect(screenIdFor('/settings/_debug'), 'other');
      expect(screenIdFor('/settings/_gallery'), 'other');
    });

    test('the startup screen is not a screen a person opens', () {
      expect(screenIdFor('/startup'), 'startup');
      expect(trackedScreenIds, isNot(contains('startup')));
    });
  });

  group('the closed set', () {
    test('every id is snake_case, short and used once', () {
      final ids = screenIdSet;
      for (final id in ids) {
        expect(
          RegExp(r'^[a-z][a-z0-9_]{0,39}$').hasMatch(id),
          isTrue,
          reason: id,
        );
      }
      expect(ids, contains('other'));
    });

    test('every declared route maps to a known screen', () {
      final listed = routes.listRoutes(Directory('lib/app'));
      expect(listed, isNotEmpty);
      for (final route in listed) {
        final id = screenIdFor(_sample(route.path));
        expect(id, isNot('other'), reason: route.path);
        expect(screenIdSet, contains(id));
      }
    });

    test('the server accepts exactly the ids the app can send', () {
      final source = File('functions/src/_screenIds.ts').readAsStringSync();
      final block = RegExp(r'SCREEN_IDS = \[(.*?)\] as const', dotAll: true)
          .firstMatch(source)!
          .group(1)!;
      final server = RegExp("'([a-z0-9_]+)'")
          .allMatches(block)
          .map((m) => m.group(1)!)
          .toSet();
      expect(
        server,
        trackedScreenIds.toSet(),
        reason: 'client and server screen lists have drifted',
      );
    });
  });
}
