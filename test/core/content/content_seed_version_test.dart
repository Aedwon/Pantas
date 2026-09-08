import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_seed_version.dart';

void main() {
  const sourceContentSha256 =
      'eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45';

  test('the recorded seed version is the logical source digest prefix', () {
    expect(sourceContentSha256, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(
      contentSeedVersion,
      sourceContentSha256.substring(0, 16),
      reason:
          'contentSeedVersion is derived from the approved plaintext source '
          'digest. Randomized protected payload bytes are not '
          'version authority.',
    );
  });
}
