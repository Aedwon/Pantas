import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

void main() {
  test('privacy fallback includes RA 10173 rights and delete account route',
      () {
    final document = legalDocumentFallbacks['privacy'];

    expect(document, isNotNull);
    expect(document!.title, 'Privacy Policy');
    expect(
      document.sections.map((section) => section.body).join('\n'),
      allOf([
        contains('RA 10173'),
        contains('export'),
        contains('correction'),
        contains('/settings/account'),
      ]),
    );
  });

  test('terms fallback has stable title and last updated date', () {
    final document = legalDocumentFallbacks['terms'];

    expect(document, isNotNull);
    expect(document!.title, 'Terms of Service');
    expect(document.updatedAt, DateTime.utc(2026, 7, 18));
  });

  test('terms fallback includes intellectual property clause', () {
    final document = legalDocumentFallbacks['terms'];

    expect(
      document!.sections.map((section) => section.body).join('\n'),
      allOf([
        contains('protected by copyright'),
        contains('machine-learning'),
        contains('written permission'),
      ]),
    );
  });

  test('legal contact uses non-example DPO email and physical address', () {
    expect(defaultLegalContact.dpoEmail, isNot(contains('example.com')));
    expect(defaultLegalContact.dpoEmail, contains('@'));
    expect(defaultLegalContact.physicalAddress, contains('Philippines'));
  });
}
