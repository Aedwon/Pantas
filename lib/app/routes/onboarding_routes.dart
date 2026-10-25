// ignore_for_file: directives_ordering

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/features/assessment/assessment.dart';
import 'package:pantas/features/onboarding/onboarding.dart';

List<RouteBase> onboardingRoutes(Ref ref) => [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/onboarding/custom/name',
        builder: (_, __) => const CustomTrackNameStep(),
      ),
      GoRoute(
        path: '/onboarding/custom/subjects',
        builder: (_, state) => CustomTrackSubjectsStep(
          name: state.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(
        path: '/assessment/:examId',
        builder: (_, state) =>
            AssessmentPage(examId: state.pathParameters['examId']!),
        routes: [
          GoRoute(
            path: 'results',
            builder: (_, state) =>
                AssessmentResultsPage(examId: state.pathParameters['examId']!),
          ),
        ],
      ),
    ];
