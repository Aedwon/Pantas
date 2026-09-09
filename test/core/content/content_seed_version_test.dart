import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_seed_version.dart';

void main() {
  const sourceContentSha256 =
      '588610f4184ff76295c17888396d81e0676c630a1fc652f9ccd3e7e818ca4cfb';

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
