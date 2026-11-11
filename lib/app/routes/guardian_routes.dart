import 'package:pantas/features/guardian/presentation/guardian_screen.dart';
// ignore_for_file: directives_ordering

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/features/guardian/guardian.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_guardian_step.dart';

List<RouteBase> guardianRoutes(Ref ref) => [
      // The emailed link. Reachable signed out and before onboarding.
      GoRoute(
        path: '/guardian',
        builder: (_, state) =>
            GuardianConfirmPage(token: state.uri.queryParameters['token']),
      ),
      // The manage link, from the same email and from the Thank you page.
      // Reachable signed out.
      GoRoute(
        path: '/guardian/manage',
        builder: (_, state) =>
            GuardianManagePage(token: state.uri.queryParameters['token']),
      ),
      GoRoute(
        path: '/guardian/withdrawn',
        builder: (_, __) => const GuardianWithdrawnPage(),
      ),
      GoRoute(
        path: '/guardian/waiting',
        builder: (_, __) => const GuardianWaitingPage(),
      ),
      // Change Email: the same form as onboarding.
      GoRoute(
        path: '/guardian/contact',
        builder: (context, __) => OnboardingGuardianStep(
          onBack: () => context.pop(),
          onSent: () => context.go('/guardian/waiting'),
        ),
      ),
    ];
