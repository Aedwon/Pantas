import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/features/home/application/server_today.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

void main() {
  test('week strip uses observed server states and leaves unknown days plain',
      () {
    expect(
        serverWeekStates([
          {'state': 'done'},
          {'state': 'partial'},
          {'state': 'missed'},
          {'state': 'rest'},
          {'state': 'today'},
          {'state': 'unknown'},
          {'state': 'unknown'},
        ]),
        [
          WeekDayState.done,
          WeekDayState.partial,
          WeekDayState.missed,
          WeekDayState.dayOff,
          WeekDayState.today,
          WeekDayState.plain,
          WeekDayState.plain,
        ]);
  });

  test('server Today preserves original, remaining and advance membership',
      () async {
    Map<String, Object?> plan(List<String> lessons) => {
          'day': '2026-10-24',
          'lessonIds': lessons,
          'reviewQuestionIds': <String>[],
          'newQuestionIds': <String>[],
          'advancedIds': ['l2'],
          'isMockDay': false,
          'isRestDay': false,
        };
    final remote = StudyRoadmap.decode(
      {
        'examId': 'e',
        'serverNow': 100,
        'accessRecheckAt': null,
        'proCovered': false,
        'revision': 'r',
        'state': 'planning',
        'today': plan(['l1', 'l2']),
        'remaining': plan(['l2']),
        'originalDone': true,
        'canAdvance': false,
        'todayTopicOrder': ['t'],
        'weekDays': [
          for (var i = 0; i < 7; i++) {'state': i == 6 ? 'today' : 'unknown'},
        ],
      },
      examId: 'e',
    );
    final today = serverToday(remote, examDate: '2026-11-11:day');
    expect(today.snapshot.plan.lessonIds, ['l1', 'l2']);
    expect(today.remaining.lessonIds, ['l2']);
    expect(today.originalDone, isTrue);
    expect(today.snapshot.topicOrder, ['t']);
    expect(today.snapshot.digest.examDate, '2026-11-11:day');
    final scope = ProviderContainer(
      overrides: [
        studyUsesServerProvider.overrideWithValue(true),
        userSettingsProvider.overrideWith((_) async => UserSettings.defaults()),
        serverStudyRoadmapProvider('e')
            .overrideWith((_) => Stream.value(remote)),
      ],
    );
    addTearDown(scope.dispose);
    final week = await scope.read(weekStripProvider('e').future);
    expect(week.todayFraction, 1);
  });
}
