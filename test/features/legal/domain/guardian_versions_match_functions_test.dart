import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/child_setup/domain/child_setup.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';

void main() {
  test('published legal versions match the server', () {
    final guardian =
        File('functions/src/guardianConsent.ts').readAsStringSync();
    final documents = RegExp(
      r'GUARDIAN_DOCUMENT_VERSIONS = \{([^}]+)\}',
    ).firstMatch(guardian)!.group(1)!;
    final published = <String, String>{
      for (final match in RegExp(r"(\w+): '([^']+)'").allMatches(documents))
        match.group(1)!: match.group(2)!,
      'child': _version(guardian, 'CHILD_NOTICE_VERSION'),
    };
    expect(guardianDocumentVersions, published);
    expect(
      guardianNoticeWordingVersion,
      _version(guardian, 'GUARDIAN_NOTICE_WORDING_VERSION'),
    );
    expect(ChildSetupVersions.childNotice, published['child']);
    expect(
      guardian,
      contains(
        'GUARDIAN_TICK_TEXT_VERSIONS = '
        "{tick1: '${ChildSetupVersions.tick1}', "
        "tick2: '${ChildSetupVersions.tick2}'}",
      ),
    );
    final checkout =
        File('functions/src/paymongoCheckout.ts').readAsStringSync();
    final sibling = File('functions/src/childActions.ts').readAsStringSync();
    expect(
      checkoutBoxTextVersion,
      _version(checkout, 'CHECKOUT_BOX_TEXT_VERSION'),
    );
    expect(
      ChildSetupVersions.siblingNotice,
      _version(sibling, 'SIBLING_NOTICE_VERSION'),
    );
    final versions = [
      ...published.values,
      guardianNoticeWordingVersion,
      checkoutBoxTextVersion,
      ChildSetupVersions.siblingNotice,
      ChildSetupVersions.tick1,
      ChildSetupVersions.tick2,
    ];
    expect(versions.toSet(), {ChildSetupVersions.childNotice});
    for (final id in [
      'privacy',
      'terms',
      'teens',
      'child-notice',
      'child-notice-kids',
    ]) {
      expect(
        legalDocumentFallbacks[id]
            ?.updatedAt
            .toIso8601String()
            .split('T')
            .first,
        ChildSetupVersions.childNotice,
        reason: id,
      );
    }
  });
}

String _version(String source, String constant) =>
    RegExp("$constant = '([^']+)'").firstMatch(source)!.group(1)!;
