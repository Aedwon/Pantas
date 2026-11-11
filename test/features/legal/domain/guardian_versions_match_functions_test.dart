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
    final functionsVersions = {
      for (final m
          in RegExp(r"(\w+):\s*'([^']+)'").allMatches(block!.group(1)!))
        m.group(1)!: m.group(2)!,
    };
    expect(functionsVersions, guardianDocumentVersions);
    expect(guardianDocumentVersions.length, 3);
  });
}
