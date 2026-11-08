import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/font_licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registry yields every bundled font notice in full', () async {
    LicenseRegistry.reset();
    addTearDown(LicenseRegistry.reset);
    registerBundledFontLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    for (final notice in {
      'Geist': 'assets/fonts/OFL-Geist.txt',
      'Source Serif 4': 'assets/fonts/OFL-SourceSerif4.txt',
      'Phosphor': 'assets/fonts/phosphor/LICENSE',
    }.entries) {
      final matches = entries.where(
        (entry) => entry.packages.contains(notice.key),
      );
      expect(matches, hasLength(1), reason: notice.key);
      final text = matches.single.paragraphs.map((p) => p.text).join('\n');
      expect(
        _normalize(text),
        _normalize(File(notice.value).readAsStringSync()),
        reason: notice.key,
      );
    }
  });
}

String _normalize(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();
