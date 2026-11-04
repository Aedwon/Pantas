import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

/// Home reads today's plan once with no screen listening to it. The provider
/// is dropped when one of its inputs changes while it is still loading, and
/// the read then failed with "disposed during loading state". That failure was
/// the first thing a student saw after finishing onboarding.
final _day = DateTime(2026, 11, 5);
final _plan = DayPlan(
  day: _day,
  lessonIds: const ['l1'],
  reviewQuestionIds: const [],
  newQuestionIds: const [],
  isMockDay: false,
  advancedIds: const {},
);
final _today = RoadmapToday(
  snapshot: DaySnapshot(
    plan: _plan,
    digest: RoadmapDigest(
      examId: 'e1',
      examDate: '',
      scopeTopicIds: const [],
      contentRevision: 'v1',
      assessmentCompleted: true,
      recordedMockCount: 0,
    ),
    topicOrderHead: const [],
  ),
  remaining: _plan,
  originalDone: false,
);

class _SlowController extends RoadmapController {
  _SlowController(super.ref, this.gate);
  final Completer<void> gate;
  @override
  Future<RoadmapToday> today(
    String examId, {
    Future<Future<bool> Function()>? originalGuard,
  }) async {
    await gate.future;
    return _today;
  }
}

ProviderContainer _container(Completer<void> gate) {
  final container = ProviderContainer(
    overrides: [
      studyUsesServerProvider.overrideWithValue(false),
      roadmapControllerProvider
          .overrideWith((ref) => _SlowController(ref, gate)),
      userSettingsProvider.overrideWith(
        (ref) async => UserSettings.defaults(),
      ),
      trackScopeProvider.overrideWith((ref, id) async => <String>{}),
      lessonScopeProvider.overrideWith((ref, id) async => <String>{}),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _tick() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('a plain read is lost when an input changes while it loads', () async {
    final gate = Completer<void>();
    final container = _container(gate);
    final read = container.read(roadmapTodayProvider('e1').future);
    final failure = expectLater(read, throwsStateError);
    await _tick();
    container.read(roadmapRevisionProvider.notifier).bump();
    await _tick();
    gate.complete();
    await failure;
  });

  test('readRoadmapToday survives an input changing while it loads', () async {
    final gate = Completer<void>();
    final container = _container(gate);
    final read = readRoadmapToday(container.read(_refProvider), 'e1');
    await _tick();
    container.read(roadmapRevisionProvider.notifier).bump();
    await _tick();
    gate.complete();
    expect((await read).snapshot.plan.day, _day);
  });
}

final _refProvider = Provider<Ref>((ref) => ref);
