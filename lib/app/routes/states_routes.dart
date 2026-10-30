import 'package:pantas/core/platform/first_screen_ready.dart';
// ignore_for_file: directives_ordering

import 'package:pantas/features/shell/presentation/update_required_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> statesRoutes(Ref ref) => [
      GoRoute(
        path: '/update-required',
        builder: (_, __) => const FirstScreenReady(child: UpdateRequiredPage()),
      ),
    ];
