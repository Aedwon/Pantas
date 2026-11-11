import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/public_id_provider.dart';

void main() {
  test('R-5 Dart check digit matches the shared vectors', () {
    final vectors = jsonDecode(
      File('test/fixtures/public_id_vectors.json').readAsStringSync(),
    ) as List<dynamic>;
    for (final item in vectors) {
      final vector = item as Map<String, dynamic>;
      expect(
        isValidPublicId(vector['digits'] as String),
        vector['valid'] as bool,
        reason: vector['digits'] as String,
      );
    }
  });

  test('R-5 named account waits for a valid server ID and clears on switch',
      () async {
    final auth = StreamController<AuthState>();
    final first = StreamController<String?>();
    final second = StreamController<String?>();
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => auth.stream),
        publicIdReaderProvider.overrideWithValue(
          (uid) => uid == 'first' ? first.stream : second.stream,
        ),
      ],
    );
    final listener = container.listen(publicIdProvider, (_, __) {});
    addTearDown(() async {
      listener.close();
      container.dispose();
      await auth.close();
      await first.close();
      await second.close();
    });
    auth.add(
      const AuthState.signedIn(
        user: AuthUser(uid: 'first', email: '', displayName: ''),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      await container.read(publicIdProvider.future),
      const PublicIdState.notReady(),
    );
    first.add('123456783');
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(publicIdProvider).requireValue,
      const PublicIdState.notReady(),
    );
    first.add('123456782');
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(publicIdProvider).requireValue,
      const PublicIdState.ready('123456782'),
    );
    auth.add(
      const AuthState.signedIn(
        user: AuthUser(uid: 'second', email: '', displayName: ''),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      await container.read(publicIdProvider.future),
      const PublicIdState.notReady(),
    );
    first.add('999999998');
    second.add('876543216');
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(publicIdProvider).requireValue,
      const PublicIdState.ready('876543216'),
    );
    auth.add(const AuthState.anonymous(uid: 'anon'));
    await Future<void>.delayed(Duration.zero);
    expect(
      await container.read(publicIdProvider.future),
      const PublicIdState.notSignedIn(),
    );
    auth.add(const AuthState.signedOut());
    await Future<void>.delayed(Duration.zero);
    expect(
      await container.read(publicIdProvider.future),
      const PublicIdState.notSignedIn(),
    );
  });
}
