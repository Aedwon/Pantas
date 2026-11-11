import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/data/study_api.dart';

void main() {
  for (final local in [true, false]) {
    test('missing settings recovers once, local=$local', () async {
      var reads = 0;
      var recoveries = 0;
      var onboarding = false;
      final request = StudyRequest(
        api: StudyApi((name, data) async {
          reads++;
          if (reads == 1 || !local) {
            throw FirebaseFunctionsException(
              code: 'failed-precondition',
              message: 'Set your exam first.',
            );
          }
          return {'ready': true};
        }),
        uid: 'u',
        examId: 'e',
        isCurrent: () async => true,
        recoverMissingSettings: () async {
          recoveries++;
          if (!local) onboarding = true;
          return local;
        },
      );
      if (local) {
        expect(await request.read('getRoadmap'), {'ready': true});
        expect(reads, 2);
      } else {
        await expectLater(
          request.read('getRoadmap'),
          throwsA(isA<FirebaseFunctionsException>()),
        );
        expect(onboarding, isTrue);
        expect(reads, 1);
      }
      expect(recoveries, 1);
    });
  }
  test('missing settings retry cannot loop', () async {
    var reads = 0;
    var recoveries = 0;
    final request = StudyRequest(
      api: StudyApi((_, __) async {
        reads++;
        throw FirebaseFunctionsException(
          code: 'failed-precondition',
          message: 'Set your exam first.',
        );
      }),
      uid: 'u',
      examId: 'e',
      isCurrent: () async => true,
      recoverMissingSettings: () async {
        recoveries++;
        return true;
      },
    );
    await expectLater(
      request.read('getStudyInsights'),
      throwsA(isA<FirebaseFunctionsException>()),
    );
    expect(reads, 2);
    expect(recoveries, 1);
  });
  test('all new requests carry immutable original UID and explicit exam',
      () async {
    final calls = <Map<String, Object?>>[];
    final api = StudyApi((name, data) async {
      calls.add(data);
      return <String, Object?>{};
    });
    await api.request(
      'getRoadmap',
      expectedUid: 'old',
      examId: 'cse',
      payload: {'historyLimit': 5},
    );
    expect(calls.single['expectedUid'], 'old');
    expect(calls.single['examId'], 'cse');
    expect(() => calls.single['expectedUid'] = 'new', throwsUnsupportedError);
  });
  test('caller cannot replace the original UID through a payload', () async {
    var calls = 0;
    final api = StudyApi((name, data) async {
      calls++;
      return <String, Object?>{};
    });
    await expectLater(
      api.request(
        'ingestSession',
        expectedUid: 'old',
        examId: 'cse',
        payload: {'expectedUid': 'new'},
      ),
      throwsArgumentError,
    );
    expect(calls, 0);
  });
  test('original guard prevents dispatch after an owner changes', () async {
    var calls = 0;
    final api = StudyApi((name, data) async {
      calls++;
      return <String, Object?>{};
    });
    final request = StudyRequest(
      api: api,
      uid: 'old',
      examId: 'cse',
      isCurrent: () async => false,
    );
    await expectLater(request.read('getRoadmap'), throwsStateError);
    expect(calls, 0);
  });
  test('late read from a retired original owner is never published', () async {
    var alive = true;
    final api = StudyApi((name, data) async {
      alive = false;
      return {'examId': 'cse'};
    });
    final request = StudyRequest(
      api: api,
      uid: 'old',
      examId: 'cse',
      isCurrent: () async => alive,
    );
    await expectLater(request.read('getRoadmap'), throwsStateError);
  });
}
