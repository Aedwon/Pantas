// ignore_for_file: directives_ordering

import 'package:pantas/features/wrapped/presentation/wrapped_reveal_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> wrappedRoutes(Ref ref) => [
      GoRoute(
        path: '/wrapped/:artifactId',
        builder: (_, state) => WrappedRevealPage(
          artifactId: state.pathParameters['artifactId']!,
        ),
      ),
    ];
