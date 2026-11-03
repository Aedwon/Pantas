// ignore_for_file: directives_ordering

import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/ui/reader_transition.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/pages/topic_ending_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The lesson's path, named because the router lifts it out of the web shell.
const lessonRoutePath = '/lesson/:lessonId';

/// [web] is true when the lesson sits above the web shell instead of inside it.
/// It then brings its own shell wrapper, which is the one it always had.
List<RouteBase> studyRoutes(Ref ref, {bool web = false}) => [
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
        path: lessonRoutePath,
        pageBuilder: (_, state) {
          final lesson = LessonPage(
            lessonId: state.pathParameters['lessonId']!,
            resume: state.uri.queryParameters['resume'] == 'true',
            dayContext: state.extra is LessonDayContext
                ? state.extra! as LessonDayContext
                : null,
            origin: ReaderOrigin.fromQuery(state.uri.queryParameters['from']),
          );
          return readerPage(
            key: state.pageKey,
            entry: state.uri.queryParameters['via'] == 'pull'
                ? ReaderEntry.advance
                : ReaderEntry.forward,
            child: web
                ? WebRouteShell(path: state.uri.path, child: lesson)
                : lesson,
          );
        },
      ),
      GoRoute(
        path: '/study/ending/:topicId',
        builder: (_, state) => TopicEndingPage(
          topicId: state.pathParameters['topicId']!,
        ),
      ),
    ];
