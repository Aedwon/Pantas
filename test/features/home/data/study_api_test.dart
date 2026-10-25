import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/data/study_api.dart';

void main() {
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
