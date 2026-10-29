// ignore_for_file: directives_ordering

import 'package:pantas/core/ui/reader_transition.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> studyRoutes(Ref ref) => [
      GoRoute(
        path: '/study',
        builder: (context, state) => StudyTabHome(
          openTopicId: state.uri.queryParameters['topicId'],
          searchOnOpen: state.uri.queryParameters['search'] == '1',
          onSearchCancelled: state.uri.queryParameters['search'] == '1'
              ? () {
                  final query =
                      Map<String, String>.of(state.uri.queryParameters)
                        ..remove('search');
                  context
                      .go(state.uri.replace(queryParameters: query).toString());
                }
              : null,
        ),
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        pageBuilder: (_, state) => readerPage(
          key: state.pageKey,
          entry: state.uri.queryParameters['via'] == 'pull'
              ? ReaderEntry.advance
              : ReaderEntry.forward,
          child: LessonPage(
            lessonId: state.pathParameters['lessonId']!,
            resume: state.uri.queryParameters['resume'] == 'true',
            dayContext: state.extra is LessonDayContext
                ? state.extra! as LessonDayContext
                : null,
            origin: ReaderOrigin.fromQuery(state.uri.queryParameters['from']),
          ),
        ),
      ),
      GoRoute(
        path: '/study/ending/:topicId',
        builder: (_, state) => TopicEndingPage(
          topicId: state.pathParameters['topicId']!,
        ),
      ),
    ];
