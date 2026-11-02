import 'package:flutter_test/flutter_test.dart';

import '../../tools/content_pass/app/mock_topics.dart';

void main() {
  test('blueprint topics map to the seed topics', () {
    expect(
      seedTopicId('topic_cse_pro_code_of_conduct_ra_6713'),
      'topic_upcat_code_of_conduct_ra_6713',
    );
    expect(seedTopicId('topic_cse_sub_vocabulary'), 'topic_upcat_vocabulary');
  });

  test('other topic ids pass through', () {
    expect(seedTopicId('topic_upcat_algebra'), 'topic_upcat_algebra');
    expect(seedTopicId('topic_cse_vocab'), 'topic_cse_vocab');
  });
}
