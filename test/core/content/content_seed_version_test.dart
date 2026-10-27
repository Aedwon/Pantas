import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_seed_version.dart';

void main() {
  const sourceContentSha256 =
      '8ee751ee0504bafc3645b3e40d02239c6c2371d13930ef0d71c0c594bf738a9d';

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
