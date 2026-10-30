import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';

import '../../integration_test/release/support/firebase_emulator_harness.dart';

void main() {
  group('Firebase Release E2E runner contract', () {
    test('emulator Pro setup satisfies the current expiring claim contract',
        () {
      final now = DateTime.utc(2026, 10, 30);
      final claims = firebaseEmulatorProClaims(now);
      expect(hasLiveProClaim(claims, at: now), isTrue);
      expect(
        hasLiveProClaim(claims, at: now.add(const Duration(hours: 1))),
        isFalse,
      );
    });

    test('accepts only runner-shaped demo project and loopback endpoints', () {
      final config = FirebaseEmulatorConfig.parse(
        projectId: 'demo-pantas-release-e2e-contract',
        authHost: '127.0.0.1:19099',
        firestoreHost: '127.0.0.1:18080',
      );

      expect(config.projectId, 'demo-pantas-release-e2e-contract');
      expect(config.authEndpoint.host, '127.0.0.1');
      expect(config.authEndpoint.port, 19099);
      expect(config.firestoreEndpoint.host, '127.0.0.1');
      expect(config.firestoreEndpoint.port, 18080);
      expect(config.androidHost, '10.0.2.2');
      expect(
        config.authAdminUri('accounts:update').toString(),
        'http://10.0.2.2:19099/identitytoolkit.googleapis.com/v1/projects/'
        'demo-pantas-release-e2e-contract/accounts:update',
      );
    });

    test('rejects missing runner values', () {
      expect(
        () => FirebaseEmulatorConfig.parse(
          projectId: null,
          authHost: '127.0.0.1:19099',
          firestoreHost: '127.0.0.1:18080',
        ),
        throwsA(isA<StateError>()),
      );
      expect(
        () => FirebaseEmulatorConfig.parse(
          projectId: 'demo-contract',
          authHost: '',
          firestoreHost: '127.0.0.1:18080',
        ),
        throwsA(isA<StateError>()),
      );
      expect(
        () => FirebaseEmulatorConfig.parse(
          projectId: 'demo-contract',
          authHost: '127.0.0.1:19099',
          firestoreHost: null,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects production or non-demo project identifiers', () {
      for (final projectId in <String>[
        'pantas-prod',
        'pantas-staging',
        'production-project',
        'demo-',
        'demo-contract/path',
        'demo-contract project',
        '',
      ]) {
        expect(
          () => FirebaseEmulatorConfig.parse(
            projectId: projectId,
            authHost: '127.0.0.1:19099',
            firestoreHost: '127.0.0.1:18080',
          ),
          throwsA(isA<StateError>()),
          reason: projectId,
        );
      }
    });

    test('rejects non-loopback and malformed emulator endpoints', () {
      for (final badAuthHost in <String>[
        'firebase.google.com:9099',
        '10.0.2.2:9099',
        'localhost:9099',
        '127.0.0.1',
        '127.0.0.1:not-a-port',
        '127.0.0.1:0',
        '127.0.0.1:65536',
      ]) {
        expect(
          () => FirebaseEmulatorConfig.parse(
            projectId: 'demo-contract',
            authHost: badAuthHost,
            firestoreHost: '127.0.0.1:18080',
          ),
          throwsA(isA<StateError>()),
          reason: badAuthHost,
        );
      }
    });

    test('rejects overlapping Auth and Firestore ports', () {
      expect(
        () => FirebaseEmulatorConfig.parse(
          projectId: 'demo-contract',
          authHost: '127.0.0.1:18080',
          firestoreHost: '127.0.0.1:18080',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  test('Firebase harness does not import or claim excluded service surfaces',
      () {
    final source = File(
      'integration_test/release/support/firebase_emulator_harness.dart',
    ).readAsStringSync();

    const forbidden = <String>[
      'package:cloud_functions/',
      'FirebaseFunctions',
      'package:firebase_app_check/',
      'FirebaseAppCheck',
      'package:google_sign_in/',
      'GoogleSignIn',
      'package:purchases_flutter/',
      'RevenueCat',
    ];

    for (final token in forbidden) {
      expect(source, isNot(contains(token)), reason: token);
    }
  });
}
