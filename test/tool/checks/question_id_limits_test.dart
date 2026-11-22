import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/telemetry/telemetry.dart';

import '../../../tool/checks/content_snapshot.dart';
import '../../../tool/checks/question_id_limits.dart';

QuestionRow row(String id) =>
    QuestionRow(id: id, topicId: 't', examIds: const {}, stem: '');

void main() {
  test('the limit is the app analytics limit', () {
    expect(maxQuestionIdLength, kMaxPropertyIdentifierLength);
  });

  test('an id past the limit, or with other characters, fails', () {
    for (final bad in ['q-${'x' * 99}', 'q-algebra-0001.v2', 'q algebra']) {
      expect(findQuestionIdsPastLimits([row(bad)]), hasLength(1), reason: bad);
    }
  });

  test('prod ids that broke the save on Nov 22 2026 now pass', () {
    expect(
      findQuestionIdsPastLimits([
        row(
          'q-data-interpretation-rates-ratios-and-percentages-in-context-0001',
        ),
        row(
          'q-environment-management-disaster-risk-reduction-and-management-'
          '0001',
        ),
        row('q-${'x' * 98}'),
      ]),
      isEmpty,
    );
  });
}
