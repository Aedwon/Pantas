import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

// The link preview image is the approved splash lockup with no beta mark
// (board https://claude.ai/artifact/8emGUsKPxKrkpqd1rHi2sw, E-180).
void main() {
  final html = File('web/index.html').readAsStringSync();

  test('preview tags name the logo and carry no beta wording', () {
    expect(
      html,
      contains('<meta property="og:image:alt" content="The Pantas logo">'),
    );
    final previewTags = RegExp('<meta (property="og:|name="twitter:)[^>]*>')
        .allMatches(html)
        .map((m) => m.group(0)!);
    for (final tag in previewTags) {
      expect(tag.toLowerCase(), isNot(contains('beta')), reason: tag);
    }
  });

  test('preview image is a 1200 x 630 PNG', () {
    final bytes = File('web/og-image.png').readAsBytesSync();
    final data = ByteData.sublistView(bytes);
    expect(bytes.sublist(1, 4), 'PNG'.codeUnits);
    expect(data.getUint32(16), 1200);
    expect(data.getUint32(20), 630);
  });
}
