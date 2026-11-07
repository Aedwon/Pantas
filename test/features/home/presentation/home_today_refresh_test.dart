import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/server_today.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';

// Home builds its plan once per plan change (spec S6): the cached copy and the
// network copy of the same plan are one build, a changed plan rebuilds without
// a skeleton flash, and a failure after data keeps today's handling.

const _exam = Exam(
  id: 'e1',
  code: 'UPCAT',
  name: 'UP College Admissions Test',
  shortName: 'UPCAT',
  language: 'en',
  isActive: true,
  subjects: [],
);

StudyRoadmap roadmap(
  String revision, {
  List<String> lessons = const ['l1'],
  int serverNow = 100,
}) {
  final plan = <String, Object?>{
    'day': '2026-10-24',
    'lessonIds': lessons,
    'reviewQuestionIds': <String>[],
    'newQuestionIds': <String>[],
    'advancedIds': <String>[],
    'isMockDay': false,
    'isRestDay': false,
  };
  return StudyRoadmap.decode(
    {
      'examId': 'e1',
      'serverNow': serverNow,
      'proCovered': false,
      'revision': revision,
      'state': 'planning',
      'today': plan,
      'remaining': plan,
      'weekDays': <Object?>[],
      'originalDone': false,
      'canAdvance': false,
      'todayTopicOrder': <String>[],
    },
    examId: 'e1',
  );
}

HomeTodayData built(StudyRoadmap from) => HomeTodayData(
      today: serverToday(from, examDate: ''),
      lessons: [
        for (final id in from.today.lessonIds)
          HomeTodayLesson(
            id: id,
            title: 'Lesson $id (${from.revision})',
            subject: 'Mathematics',
            minutes: 8,
            read: false,
          ),
      ],
      questionWork: null,
      canAdvance: from.canAdvance,
      examName: _exam.name,
      examShortName: _exam.shortName,
    );

class _Launcher extends TodayQuestionLauncher {
  _Launcher(Ref ref, this.ownerStillSame) : super(ref, () => true);
  final bool Function() ownerStillSame;
  @override
  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async =>
      () async => isAlive() && ownerStillSame();
}

class _Harness {
  final roadmaps = StreamController<StudyRoadmap>();
  final loads = <Completer<HomeTodayData>>[];
  bool ownerStillSame = true;
  StudyRoadmap latest = roadmap('r1');

  /// A load that stays open until the test finishes it.
  Completer<HomeTodayData> get lastLoad => loads.last;

  Future<void> pump(WidgetTester tester) async {
    addTearDown(roadmaps.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyUsesServerProvider.overrideWithValue(true),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(_exam),
          ),
          serverStudyRoadmapProvider('e1')
              .overrideWith((ref) => roadmaps.stream),
          homeTodayLoaderProvider.overrideWith(
            (ref) => (examId, guard) {
              final load = Completer<HomeTodayData>();
              loads.add(load);
              return load.future;
            },
          ),
          todayQuestionLauncherProvider
              .overrideWith((ref) => _Launcher(ref, () => ownerStillSame)),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: HomeTodayScreen(
            examId: 'e1',
            pageBuilder: (today, _) => Scaffold(body: today),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> emit(WidgetTester tester, StudyRoadmap value) async {
    latest = value;
    roadmaps.add(value);
    await tester.pump();
  }
}

void main() {
  testWidgets('the cached copy and the network copy of one plan build once',
      (tester) async {
    final home = _Harness();
    await home.pump(tester);
    expect(home.loads, hasLength(1));

    // The cached copy arrives while the first build runs, then the network
    // copy of the same plan (a later server time only).
    await home.emit(tester, roadmap('r1'));
    await home.emit(tester, roadmap('r1', serverNow: 900));
    expect(home.loads, hasLength(1), reason: 'no rebuild for the same plan');

    home.lastLoad.complete(built(roadmap('r1')));
    await tester.pumpAndSettle();

    expect(home.loads, hasLength(1));
    expect(find.text('Lesson l1 (r1)'), findsOneWidget);
    await home.emit(tester, roadmap('r1', serverNow: 1500));
    expect(home.loads, hasLength(1), reason: 'same plan on screen, no rebuild');
  });

  testWidgets('a plan that changed while the first build ran is rebuilt once',
      (tester) async {
    final home = _Harness();
    await home.pump(tester);

    await home.emit(tester, roadmap('r1'));
    await home.emit(tester, roadmap('r2', lessons: ['l1', 'l2']));
    expect(home.loads, hasLength(1), reason: 'the first build is still open');

    // The open build used the cached plan.
    home.lastLoad.complete(built(roadmap('r1')));
    await tester.pump();
    await tester.pump();

    expect(home.loads, hasLength(2), reason: 'rebuilt for the newer plan');
    home.lastLoad.complete(built(roadmap('r2', lessons: ['l1', 'l2'])));
    await tester.pumpAndSettle();
    expect(home.loads, hasLength(2));
    expect(find.text('Lesson l2 (r2)'), findsOneWidget);
  });

  testWidgets('a changed plan rebuilds and the old plan stays on screen',
      (tester) async {
    final home = _Harness();
    await home.pump(tester);
    home.lastLoad.complete(built(roadmap('r1')));
    await tester.pumpAndSettle();
    expect(find.text('Lesson l1 (r1)'), findsOneWidget);

    await home.emit(tester, roadmap('r2', lessons: ['l1', 'l2']));
    await tester.pump();

    expect(home.loads, hasLength(2), reason: 'a different plan rebuilds');
    expect(find.byType(HomeTodaySkeleton), findsNothing);
    expect(find.text('Lesson l1 (r1)'), findsOneWidget, reason: 'kept on show');

    home.lastLoad.complete(built(roadmap('r2', lessons: ['l1', 'l2'])));
    await tester.pumpAndSettle();
    expect(find.byType(HomeTodaySkeleton), findsNothing);
    expect(find.text('Lesson l2 (r2)'), findsOneWidget);
  });

  testWidgets('a build that fails after a plan copy arrived builds again',
      (tester) async {
    final home = _Harness();
    await home.pump(tester);
    await home.emit(tester, roadmap('r1'));

    home.lastLoad
        .completeError(StateError('Planned lesson content unavailable'));
    await tester.pump();
    await tester.pump();

    expect(home.loads, hasLength(2), reason: 'the plan arrived mid-failure');
    home.lastLoad.complete(built(roadmap('r1')));
    await tester.pumpAndSettle();
    expect(find.text('Lesson l1 (r1)'), findsOneWidget);
  });

  testWidgets('a rebuild that fails shows the error, not the old plan',
      (tester) async {
    final home = _Harness();
    await home.pump(tester);
    home.lastLoad.complete(built(roadmap('r1')));
    await tester.pumpAndSettle();

    await home.emit(tester, roadmap('r2'));
    home.lastLoad
        .completeError(StateError('Planned lesson content unavailable'));
    await tester.pumpAndSettle();

    expect(find.text('Could not load your plan.'), findsOneWidget);
    expect(find.text('Lesson l1 (r1)'), findsNothing);
  });

  testWidgets('a rebuild after the owner changed shows no old plan',
      (tester) async {
    final home = _Harness();
    await home.pump(tester);
    home.lastLoad.complete(built(roadmap('r1')));
    await tester.pumpAndSettle();

    home.ownerStillSame = false;
    await home.emit(tester, roadmap('r2'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Lesson l1 (r1)'), findsNothing);
    expect(find.byType(HomeTodaySkeleton), findsOneWidget);
  });
}
