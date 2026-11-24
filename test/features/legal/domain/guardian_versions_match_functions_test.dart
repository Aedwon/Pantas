import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/legal/legal.dart';

void main() {
  test('app and functions publish the same guardian document versions', () {
    final source = File('functions/src/guardianConsent.ts').readAsStringSync();
    final block = RegExp(
      r'GUARDIAN_DOCUMENT_VERSIONS\s*=\s*\{([^}]*)\}',
    ).firstMatch(source);
    expect(block, isNotNull);
    // The functions side keeps the date in one constant the map refers to.
    final constants = {
      for (final m in RegExp(r"const (\w+) = '([^']+)';").allMatches(source))
        m.group(1)!: m.group(2)!,
    };
    final functionsVersions = {
      for (final m in RegExp(r"(\w+):\s*(?:'([^']+)'|(\w+))")
          .allMatches(block!.group(1)!))
        m.group(1)!: m.group(2) ?? constants[m.group(3)!]!,
    };
    expect(functionsVersions, guardianDocumentVersions);
    expect(guardianDocumentVersions.length, 3);
  });
}
