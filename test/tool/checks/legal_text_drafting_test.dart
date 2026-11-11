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
  test('the Nov 9 leak still fails on its drafting word', () {
    final found = findDraftingText(
      docs('this draft requires specific Section 13(a) consent'),
    );
    expect(found.map((v) => v.message), ['draft']);
    expect(found.first.where, 'd/H');
  });

  test('clean text passes, including a cited section of the law', () {
    expect(findDraftingText(docs('We keep your answers.')), isEmpty);
    expect(
      findDraftingText(docs('your specific permission (Section 13(a))')),
      isEmpty,
    );
  });

  test('case and word forms are caught, titles included', () {
    expect(findDraftingText(docs('Drafted')), hasLength(1));
    expect(findDraftingText(docs('ok', title: 'Drafts')), hasLength(1));
  });

  test('notes meant for the owner fail', () {
    expect(
      findDraftingText(docs('Owner note: confirm the inbox first.')),
      hasLength(1),
    );
  });
}
