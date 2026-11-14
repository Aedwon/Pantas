import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';

import '../golden_harness.dart';

const _window = Size(760, 460);

final _router = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, __) => const SizedBox())],
);

const _recent = [
  StudyLesson(
    id: 'l1',
    title: 'Adding fractions',
    estimatedMinutes: 6,
    isRead: true,
    isBookmarked: false,
  ),
  StudyLesson(
    id: 'l2',
    title: 'Comparing halves and thirds',
    estimatedMinutes: 4,
    isRead: false,
    isBookmarked: false,
  ),
  StudyLesson(
    id: 'l3',
    title: 'Ratios in recipes',
    estimatedMinutes: 8,
    isRead: false,
    isBookmarked: false,
  ),
];

Widget _search({List<StudyLesson>? recent}) => ProviderScope(
      overrides: [
        studyMapProvider.overrideWith((ref) async => null),
        searchResultsProvider.overrideWith((ref) async => const []),
        recentlyOpenedLessonsProvider.overrideWith(
          (ref) => recent == null
              ? Completer<List<StudyLesson>>().future
              : Future.value(recent),
        ),
      ],
      child: InheritedGoRouter(
        goRouter: _router,
        child: const WebLessonSearch(),
      ),
    );

void main() {
  goldenSheet(
    'search_overlay',
    [
      GoldenState(
        'Recently opened',
        (_) => _search(recent: _recent),
        window: _window,
      ),
      GoldenState(
        'Row hover',
        (_) => _search(recent: _recent),
        action: GoldenAction.hover,
        at: const Alignment(0, 0.22),
        window: _window,
      ),
      GoldenState('Loading', (_) => _search(), window: _window),
      GoldenState(
        'Nothing opened yet',
        (_) => _search(recent: const []),
        window: _window,
      ),
    ],
    columns: 2,
    web: true,
  );
}
