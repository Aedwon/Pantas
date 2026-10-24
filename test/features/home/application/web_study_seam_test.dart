import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';
import 'package:pantas/features/home/domain/study_models.dart';

import '../../../helpers/pump_app.dart';

Map<String, Object?> insights({bool pro = true}) => {
      'examId': 'e',
      'serverNow': 100,
      'accessRecheckAt': null,
      'proCovered': pro,
      'revision': 'r1',
      'trialEndsAt': 1790834400000,
      'performance': {
        'overall': {'correct': 2, 'answered': 4},
        'subjects': [
          {
            'id': 's',
            'title': 'Science',
            'correct': 2,
            'answered': 4,
            'topicCount': 1,
          },
        ],
        'topics': [
          {
            'id': 't',
            'parentId': 's',
            'title': 'Cells',
            'correct': 2,
            'answered': 4,
          },
        ],
        'lessons': [
          {
            'id': 'l',
            'parentId': 't',
            'title': 'Cell division',
            'correct': 2,
            'answered': 4,
          },
        ],
        'lessonLevelAvailable': true,
      },
    };

void main() {
  ProviderContainer container({bool pro = true}) => ProviderContainer(
        overrides: [
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          serverStudyInsightsProvider('e').overrideWith(
            (_) => Stream.value(
              StudyInsights.decode(insights(pro: pro), examId: 'e'),
            ),
          ),
        ],
      );

  test('web performance uses authoritative counts and authored parent names',
      () async {
    final scope = container();
    addTearDown(scope.dispose);
    final result = await scope.read(webPerformanceViewProvider.future);
    expect(result.subjects.single.answered, 4);
    expect(result.topics.single.subtext, 'Science');
    expect(result.lessons.single.subtext, 'Cells');
    expect(result.parentSubjectIds, {'t': 's', 'l': 's'});
    expect(result.subjectCounts, {'s': 1});
  });

  test('Free web performance cannot publish topic or lesson depth', () async {
    final scope = container(pro: false);
    addTearDown(scope.dispose);
    final result = await scope.read(webPerformanceViewProvider.future);
    expect(result.subjects.single.correct, 2);
    expect(result.topics, isEmpty);
    expect(result.lessons, isEmpty);
  });

  test('web trial end comes from actual server metadata', () async {
    final scope = container();
    addTearDown(scope.dispose);
    expect(
      (await scope.read(webTrialEndsAtProvider.future))?.millisecondsSinceEpoch,
      1790834400000,
    );
  });
}
