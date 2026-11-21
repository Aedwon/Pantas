import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/domain/age_group.dart';
import 'package:pantas/features/legal/legal.dart';

import '../../../helpers/child_setup_harness.dart';

void main() {
  test('unknown legal document id returns null', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(legalDocumentProvider('missing')), isNull);
  });

  test('privacy and terms documents are available from provider', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(legalDocumentProvider('privacy'))?.title,
      'Privacy Policy',
    );
    expect(
      container.read(legalDocumentProvider('terms'))?.title,
      'Terms of Service',
    );
  });

  for (final open in [false, true]) {
    test('kids notice reflects the current child sibling setting ($open)',
        () async {
      final auth = MockAuthRepository();
      when(auth.listChildren).thenAnswer(
        (_) async => (
          children: [
            (uid: 'child', nickname: null, siblingOpenWithoutCode: open),
            (uid: 'sibling', nickname: null, siblingOpenWithoutCode: !open),
          ],
          maskedHolderEmail: null,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          authStateProvider.overrideWith(
            (_) => Stream.value(
              AuthState.fromSession(const AuthSession(uid: 'child')),
            ),
          ),
          resolvedAgeGroupProvider.overrideWithValue(AgeGroup.child),
        ],
      );
      addTearDown(container.dispose);
      final provider = legalDocumentProvider('child-notice-kids');
      final sub = container.listen(provider, (_, __) {});
      addTearDown(sub.close);
      await container.read(authStateProvider.future);
      await container.pump();
      await container.pump();

      final body = sub
          .read()!
          .sections
          .singleWhere((s) => s.heading == 'Who can see it');
      expect(body.body.contains('They can study as you.'), open);
    });
  }
}
