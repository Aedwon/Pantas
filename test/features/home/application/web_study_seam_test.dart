import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
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
        'topicDetails': [
          {
            'id': 't',
            'title': 'Cells',
            'subject': 'Science',
            'correct': 2,
            'answered': 4,
            'lessons': [
              {'id': 'l', 'title': 'Cell division', 'read': true},
              {'id': 'l2', 'title': 'Unread lesson', 'read': false},
            ],
          },
        ],
        'lessonLevelAvailable': true,
      },
    };

void main() {
  test('fresh coverage replaces a restored public performance snapshot',
      () async {
    final events = StreamController<StudyInsights>();
    addTearDown(events.close);
    final scope = ProviderContainer(
      overrides: [
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        serverStudyInsightsProvider('e').overrideWith((_) => events.stream),
      ],
    );
    addTearDown(scope.dispose);
    final subscription = scope.listen(webPerformanceViewProvider, (_, __) {});
    addTearDown(subscription.close);
    final first = scope.read(webPerformanceViewProvider.future);
    events.add(StudyInsights.decode(insights(pro: false), examId: 'e'));
    expect((await first).topics, isEmpty);
    events.add(StudyInsights.decode(insights(), examId: 'e'));
    await scope.pump();
    expect(
      (await scope.read(webPerformanceViewProvider.future)).topics,
      hasLength(1),
    );
  });

  ProviderContainer container({bool pro = true}) => ProviderContainer(
        overrides: [
          todayLessonIdsProvider('e').overrideWith((_) async => {'l2'}),
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

  test('web topic detail uses stored reads and actual Today membership',
      () async {
    final scope = container();
    addTearDown(scope.dispose);
    final detail = await scope.read(webTopicDetailProvider('t').future);
    expect(detail.name, 'Cells');
    expect(detail.subject, 'Science');
    expect(detail.lessonsRead, 1);
    expect(detail.lessons.map((l) => l.read), [true, false]);
    expect(detail.lessons.map((l) => l.today), [false, true]);
    expect(detail.answered, 4);
  });

  test('Free topic detail refuses paid reads', () async {
    final scope = container(pro: false);
    addTearDown(scope.dispose);
    await expectLater(
      scope.read(webTopicDetailProvider('t').future),
      throwsStateError,
    );
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
