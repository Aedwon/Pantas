import 'dart:async';

import 'package:pantas/core/platform/remote_flags.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 3),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
  });

  group('RemoteFlags.parse', () {
    test('parses minimum build and non-empty service message', () {
      final flags = RemoteFlags.parse(10, 'Maintenance tonight');
      expect(flags.minimumSupportedBuild, equals(10));
      expect(flags.serviceMessage, equals('Maintenance tonight'));
    });

    test('parses missing minimum as 0', () {
      final flags = RemoteFlags.parse(null, 'Hello');
      expect(flags.minimumSupportedBuild, equals(0));
    });

    test('parses empty service message string as null', () {
      final flags1 = RemoteFlags.parse(5, '');
      expect(flags1.serviceMessage, isNull);

      final flags2 = RemoteFlags.parse(5, '   ');
      expect(flags2.serviceMessage, isNull);

      final flags3 = RemoteFlags.parse(5, null);
      expect(flags3.serviceMessage, isNull);
    });

    test('fallback has 0 minimum build and null service message', () {
      expect(RemoteFlags.fallback.minimumSupportedBuild, equals(0));
      expect(RemoteFlags.fallback.serviceMessage, isNull);
    });
  });

  group('fetchRemoteFlags', () {
    late MockFirebaseRemoteConfig mockConfig;

    setUp(() {
      mockConfig = MockFirebaseRemoteConfig();
      when(() => mockConfig.setConfigSettings(any())).thenAnswer((_) async {});
      when(() => mockConfig.setDefaults(any())).thenAnswer((_) async {});
      when(() => mockConfig.fetchAndActivate()).thenAnswer((_) async => true);
    });

    test('returns parsed flags on successful fetch', () async {
      when(() => mockConfig.getInt('minimum_supported_build')).thenReturn(12);
      when(() => mockConfig.getString('service_message'))
          .thenReturn('Update available');

      final flags = await fetchRemoteFlags(remoteConfig: mockConfig);

      expect(flags.minimumSupportedBuild, equals(12));
      expect(flags.serviceMessage, equals('Update available'));
    });

    test('returns fallback when fetch throws', () async {
      when(() => mockConfig.fetchAndActivate())
          .thenThrow(Exception('Network error'));

      final flags = await fetchRemoteFlags(remoteConfig: mockConfig);

      expect(flags, equals(RemoteFlags.fallback));
    });

    test('returns fallback when fetch times out', () async {
      final completer = Completer<bool>();
      when(() => mockConfig.fetchAndActivate())
          .thenAnswer((_) => completer.future);

      final flags = await fetchRemoteFlags(
        remoteConfig: mockConfig,
        timeout: const Duration(milliseconds: 50),
      );

      expect(flags, equals(RemoteFlags.fallback));
    });

    test('returns defaults when keys are missing in config', () async {
      when(() => mockConfig.getInt('minimum_supported_build')).thenReturn(0);
      when(() => mockConfig.getString('service_message')).thenReturn('');

      final flags = await fetchRemoteFlags(remoteConfig: mockConfig);

      expect(flags.minimumSupportedBuild, equals(0));
      expect(flags.serviceMessage, isNull);
    });
  });
}
