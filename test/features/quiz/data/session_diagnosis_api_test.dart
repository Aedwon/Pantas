import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/quiz/data/session_diagnosis_api.dart';

void main() {
  test('Free payload keeps only the count', () {
    final result = SessionDiagnosisData.decode({
      'status': 'ok',
      'tier': 'free',
      'tracedCount': 3,
    });
    expect(result!.tracedCount, 3);
    expect(result.detail, isNull);
  });

  test('Pro payload parses traced and within-lesson detail', () {
    final result = SessionDiagnosisData.decode({
      'status': 'ok',
      'tier': 'pro',
      'tracedCount': 1,
      'traced': [
        {
          'prerequisite': 'fractions',
          'forLesson': 'percent',
          'via': 'gapTag',
          'questions': [
            {
              'questionId': 'q1',
              'position': 2,
              'mistake': 'Check the bottom.',
            },
          ],
        },
      ],
      'withinLesson': [
        {
          'lesson': 'percent',
          'questions': [
            {'questionId': 'q2', 'position': 3},
          ],
        },
      ],
    });
    expect(result!.tracedCount, 1);
    expect(result.detail!['traced'], hasLength(1));
    expect(result.detail!['withinLesson'], hasLength(1));
  });

  test('pending payload has no result', () {
    expect(SessionDiagnosisData.decode({'status': 'pending'}), isNull);
  });

  test('pending retries once after three seconds then silently stops',
      () async {
    var calls = 0;
    final waits = <Duration>[];
    final api = SessionDiagnosisApi(
      StudyRequest(
        api: StudyApi((name, data) async {
          expect(name, 'getSessionDiagnosis');
          expect(data, {
            'sessionId': 'session',
            'expectedUid': 'owner',
            'examId': 'cse',
          });
          calls++;
          return {'status': 'pending'};
        }),
        uid: 'owner',
        examId: 'cse',
        isCurrent: () async => true,
      ),
      wait: (duration) async => waits.add(duration),
    );
    expect(await api.read('session'), isNull);
    expect(calls, 2);
    expect(waits, [const Duration(seconds: 3)]);
  });

  test('Free ignores unexpected protected detail', () {
    final result = SessionDiagnosisData.decode({
      'status': 'ok',
      'tier': 'free',
      'tracedCount': 1,
      'traced': [
        {'questionId': 'private'},
      ],
      'withinLesson': [
        {'lesson': 'private'},
      ],
    });
    expect(result!.detail, isNull);
  });

  test('retry can return a completed diagnosis', () async {
    var calls = 0;
    final api = SessionDiagnosisApi(
      StudyRequest(
        api: StudyApi(
          (name, data) async => ++calls == 1
              ? {'status': 'pending'}
              : {'status': 'ok', 'tier': 'free', 'tracedCount': 2},
        ),
        uid: 'owner',
        examId: 'cse',
        isCurrent: () async => true,
      ),
      wait: (_) async {},
    );
    expect((await api.read('session'))!.tracedCount, 2);
    expect(calls, 2);
  });

  test('retired owner silently stops without making a call', () async {
    final api = SessionDiagnosisApi(
      StudyRequest(
        api: StudyApi((name, data) async => fail('Unexpected call')),
        uid: 'owner',
        examId: 'cse',
        isCurrent: () async => false,
      ),
    );
    expect(await api.read('session'), isNull);
  });

  test('native provider returns null without initializing server reads',
      () async {
    final container = ProviderContainer(
      overrides: [
        studyUsesServerProvider.overrideWithValue(false),
        studyApiProvider.overrideWith((ref) => throw StateError('Server read')),
      ],
    );
    addTearDown(container.dispose);
    expect(
      await container.read(sessionDiagnosisProvider('session').future),
      isNull,
    );
  });
}
