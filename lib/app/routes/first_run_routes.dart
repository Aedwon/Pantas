import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/features/first_run/presentation/first_run_page.dart';

/// `/try`: the one page that holds the whole first run. It reports as
/// `other` in screen views (plan ruling 19).
List<RouteBase> firstRunRoutes(Ref ref) => [
      GoRoute(
        path: firstRunPath,
        builder: (context, state) => const FirstRunPage(),
      ),
    ];

const firstRunPath = '/try';
