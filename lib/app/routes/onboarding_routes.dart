// ignore_for_file: directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
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
            // The last question dissolves into the results, which then play
            // their own entrance. No slide, no blank screen between them.
            pageBuilder: (_, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 240),
              reverseTransitionDuration: const Duration(milliseconds: 240),
              transitionsBuilder: (context, animation, _, child) =>
                  MediaQuery.disableAnimationsOf(context)
                      ? child
                      : FadeTransition(
                          opacity: animation
                              .drive(CurveTween(curve: PantasCurves.ease)),
                          child: child,
                        ),
              child: AssessmentResultsPage(
                examId: state.pathParameters['examId']!,
              ),
            ),
          ),
        ],
      ),
    ];
