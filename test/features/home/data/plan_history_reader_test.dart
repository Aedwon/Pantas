import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/data/plan_history_reader.dart';
import 'package:pantas/features/home/data/study_api.dart';

void main() {
  test('history follows stable server cursor beyond one hundred rows',
      () async {
    final cursors = <Object?>[];
    final request = StudyRequest(
      uid: 'u',
      examId: 'e',
      isCurrent: () async => true,
      api: StudyApi((name, body) async {
        expect(name, 'getRoadmap');
        cursors.add(body['historyBefore']);
        final start = body['historyBefore'] == null
            ? 0
            : (body['historyBefore']! as Map)['occurredAt']! as int;
        return {
          'history': {
            'changes': [
              for (var i = start; i < start + 10; i++) {'id': 'h$i'},
            ],
            'next': start >= 110
                ? null
                : {'occurredAt': start + 10, 'id': 'cursor$start'},
          },
        };
      }),
    );
    final history = await readPlanHistory(request, wanted: 115);
    expect((history['changes']! as List).length, 120);
    expect(cursors.length, 12);
    expect(history['next'], isNull);
  });
}
