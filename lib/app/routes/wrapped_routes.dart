// ignore_for_file: directives_ordering

import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/features/wrapped/presentation/wrapped_reveal_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> wrappedRoutes(Ref ref) => [
      GoRoute(
        path: '/wrapped/:artifactId',
        redirect: (_, __) async {
          try {
            await ref.read(ageGroupProvider.future);
          } on Object {
            return '/record';
          }
          return ref.read(resolvedAgeGroupProvider).hasChildLimits
              ? '/record'
              : null;
        },
        builder: (_, state) => WrappedRevealPage(
          artifactId: state.pathParameters['artifactId']!,
        ),
      ),
    ];
