import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/domain/study_models.dart';

void main() {
  Map<String, Object?> reply({bool pro = false}) => {
        'examId': 'cse',
        'serverNow': 123,
        'accessRecheckAt': null,
        'proCovered': pro,
        'revision': 'v1',
        'profile': {'id': 'nightOwl'},
        'performance': {
          'overall': {'correct': 2, 'answered': 3},
          'subjects': [
            {
              'id': 's',
              'title': 'Math',
              'correct': 2,
              'answered': 3,
              'topicCount': 1,
            }
          ],
          'lessonLevelAvailable': true,
        },
      };
  test('Free retains measured subject summary and allowed profile only', () {
    final r = reply();
    r['tendencies'] = {
      'pressure': {'value': 42},
    };
    r['performance'] = (r['performance']! as Map<String, Object?>)
      ..['topics'] = [
        {'id': 'secret'},
      ];
    final model = StudyInsights.decode(r, examId: 'cse');
    expect(model.correct, 2);
    expect(model.answered, 3);
    expect(model.profileId, 'nightOwl');
    expect(model.topics, isEmpty);
    expect(model.tendencies, isNull);
  });
  test('invalid or other-exam summary fails rather than showing invented zero',
      () {
    expect(
      () => StudyInsights.decode(reply(), examId: 'other'),
      throwsFormatException,
    );
    final r = reply();
    (r['performance']! as Map<String, Object?>)['overall'] = {
      'correct': 4,
      'answered': 3,
    };
    expect(() => StudyInsights.decode(r, examId: 'cse'), throwsFormatException);
  });
  test('roadmap reads exact stored membership and unknown days stay unknown',
      () {
    final plan = {
      'day': '2026-10-24',
      'lessonIds': ['l1'],
      'reviewQuestionIds': ['q1'],
      'newQuestionIds': <String>[],
      'isMockDay': false,
      'isRestDay': false,
      'advancedIds': <String>[],
    };
    final r = <String, Object?>{
      'examId': 'cse',
      'serverNow': 123,
      'accessRecheckAt': null,
      'proCovered': false,
      'revision': 'v1',
      'state': 'planning',
      'today': plan,
      'remaining': plan,
      'originalDone': false,
      'canAdvance': false,
      'todayTopicOrder': ['t'],
      'weekDays': [
        {'day': '2026-10-23', 'state': 'unknown'},
      ],
    };
    final model = StudyRoadmap.decode(r, examId: 'cse');
    expect(model.today.lessonIds, ['l1']);
    expect(model.remaining.reviewQuestionIds, ['q1']);
    expect(model.weekDays.single['state'], 'unknown');
    expect(model.comingUp, isNull);
  });
}
