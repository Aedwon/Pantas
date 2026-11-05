import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/content_snapshot.dart';
import '../../../tool/checks/mock_blueprint_topics.dart';

ContentSnapshot content(List<String> topicIds) => ContentSnapshot(
      blueprints: [
        BlueprintRow('bp', 'exam_cse_pro', [
          BlueprintSectionRow('sec', topicIds),
        ]),
      ],
      questions: const [
        QuestionRow(
          id: 'q1',
          topicId: 'topic_upcat_algebra',
          examIds: {'exam_cse_pro'},
          stem: '',
        ),
        QuestionRow(
          id: 'q2',
          topicId: 'topic_upcat_physics',
          examIds: {'exam_upcat'},
          stem: '',
        ),
      ],
    );

void main() {
  test('an id the code cannot map to a pool fails', () {
    final found = findUnresolvedTopics(content(['topic_cse_pro_geometry']));
    expect(found.single.message, contains('topic_cse_pro_geometry'));
  });

  test('a topic whose questions are all for another exam fails', () {
    expect(
      findUnresolvedTopics(content(['topic_upcat_physics'])),
      hasLength(1),
    );
  });

  test('an exam-specific id that maps to a shared pool passes', () {
    expect(findUnresolvedTopics(content(['topic_cse_pro_algebra'])), isEmpty);
    expect(findUnresolvedTopics(content(['topic_upcat_algebra'])), isEmpty);
  });
}
