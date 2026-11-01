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

  test('history reuses the first page and fetches only later pages', () async {
    final calls = <Object?>[];
    final request = StudyRequest(
      uid: 'u',
      examId: 'e',
      isCurrent: () async => true,
      api: StudyApi((name, body) async {
        calls.add(body['historyBefore']);
        return {
          'history': {
            'changes': [
              {'id': 'b'},
            ],
            'next': null,
          },
        };
      }),
    );
    final first = <String, Object?>{
      'history': {
        'changes': [
          {'id': 'a'},
        ],
        'next': {'occurredAt': 1, 'id': 'a'},
      },
    };
    final one = await readPlanHistory(request, wanted: 1, first: first);
    expect(calls, isEmpty);
    expect((one['changes']! as List).length, 1);
    final two = await readPlanHistory(request, wanted: 2, first: first);
    expect(calls, hasLength(1));
    expect((two['changes']! as List).length, 2);
  });
}
