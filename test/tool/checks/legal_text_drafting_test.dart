import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';

import '../../../tool/checks/legal_text_drafting.dart';

Map<String, LegalDocument> docs(String body, {String title = 'Title'}) => {
      'd': LegalDocument(
        id: 'd',
        title: title,
        updatedAt: DateTime.utc(2026),
        sections: [LegalSection(heading: 'H', body: body)],
      ),
    };

void main() {
  test('drafting language fails on both patterns', () {
    final found = findDraftingText(
      docs('this draft requires specific Section 13(a) consent'),
    );
    expect(found.map((v) => v.message), ['draft', 'Section 13(a)']);
    expect(found.first.where, 'd/H');
  });

  test('clean text passes', () {
    expect(findDraftingText(docs('We keep your answers.')), isEmpty);
  });

  test('case and word forms are caught, titles included', () {
    expect(findDraftingText(docs('Drafted')), hasLength(1));
    expect(findDraftingText(docs('SECTION 13(A)')), hasLength(1));
    expect(findDraftingText(docs('ok', title: 'Drafts')), hasLength(1));
  });

  test('notes meant for the owner fail', () {
    expect(
      findDraftingText(docs('Owner note: confirm the inbox first.')),
      hasLength(1),
    );
  });
}
