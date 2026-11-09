// User-facing legal text must not contain drafting language.
import 'package:pantas/features/legal/domain/legal_document.dart';

import 'check.dart';

// The Nov 5 drafts also carried "Owner note" paragraphs meant only for Aedwon.
final _drafting =
    RegExp(r'\bdraft|Section 13\(a\)|\bowner note', caseSensitive: false);

class LegalTextDraftingCheck extends Check {
  const LegalTextDraftingCheck();

  @override
  String get name => 'legal-text-drafting';

  @override
  String get origin =>
      'Nov 9 2026: the in-app Notice for teens shipped drafting notes to '
      'users, such as "this draft requires specific Section 13(a) consent"';

  @override
  List<Violation> run(String root) => findDraftingText(legalDocumentFallbacks);
}

List<Violation> findDraftingText(Map<String, LegalDocument> documents) {
  final found = <Violation>[];
  void scan(String where, String text) {
    for (final match in _drafting.allMatches(text)) {
      found.add(Violation(where, match.group(0)!));
    }
  }

  for (final document in documents.values) {
    scan('${document.id}/(title)', document.title);
    for (final section in document.sections) {
      scan('${document.id}/${section.heading}', section.heading);
      scan('${document.id}/${section.heading}', section.body);
    }
  }
  return found;
}
