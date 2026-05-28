import 'package:cse_cet_reviewer/features/legal/legal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
