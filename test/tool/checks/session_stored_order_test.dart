import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/session_stored_order.dart';

void main() {
  test('storing the order from before grouping fails', () {
    const retakeShape = 'await _sessions.create(sessionId: session.sessionId,'
        ' questionIds: picked.map((question) => question.id).toList());';
    for (final bad in <String>[
      // The Nov 22 2026 shape, from StartRetake.
      retakeShape,
      'await sessions.createGuarded(questionIds: ids);',
      'await _sessions.create(questionIds: questions.map((q) => q.id));',
    ]) {
      expect(
        findUnsafeSessionCreates('lib/a.dart', bad),
        hasLength(1),
        reason: bad,
      );
    }
  });

  test('storing the built session order passes', () {
    expect(
      findUnsafeSessionCreates('lib/a.dart', '''
await _sessions.create(
  sessionId: session.sessionId,
  questionIds: session.questions.map((question) => question.id).toList(),
);
await _reviewRepo.upsert(next);
'''),
      isEmpty,
    );
  });
}
