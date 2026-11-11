import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';

/// Lets the state reads behind the router's onboarding redirect finish
/// before the first page mounts.
///
/// The redirect lets everything through while those reads are loading. A page
/// opened directly (a lesson, a quiz) could mount and write progress before
/// the redirect sent a new student to onboarding. Home is no exception: it
/// mounted, drew its "Choose your exam" card under the fading splash, and
/// then the redirect slid onboarding over it (4P-2). With the reads settled
/// the redirect runs first, so the first page is the right one.
///
/// A read that fails or takes longer than [timeout] never blocks the start:
/// the router holds private pages on a neutral route until the guardian gate
/// settles.
Future<void> settleGatesBeforeFirstPage(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  Future<void> settled<T>(FutureProvider<T> provider) async {
    try {
      await container.read(provider.future);
    } on Object catch (error) {
      debugPrint('Startup gate did not load: $error');
    }
  }

  try {
    await Future.wait([
      settled(guardianGateProvider),
      settled(passedAgeGateProvider),
      settled(activeExamFocusProvider),
      settled(onboardingCompleteProvider),
    ]).timeout(timeout);
  } on TimeoutException {
    debugPrint('Startup gates still loading; starting anyway.');
  }
}
