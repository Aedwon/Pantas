import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';

/// Lets the three state reads behind the router's onboarding redirect finish
/// before a page other than Home mounts.
///
/// The redirect lets everything through while those reads are loading. Home
/// is harmless then, but a page opened directly (a lesson, a quiz) could mount
/// and write progress before the redirect sent a new student to onboarding.
///
/// A read that fails or takes longer than [timeout] never blocks the start:
/// the router already copes with a gate it cannot read.
Future<void> settleGatesBeforeFirstPage(
  ProviderContainer container, {
  required String startLocation,
  Duration timeout = const Duration(seconds: 3),
}) async {
  if (startLocation == '/home') return;
  Future<void> settled<T>(FutureProvider<T> provider) async {
    try {
      await container.read(provider.future);
    } on Object catch (error) {
      debugPrint('Startup gate did not load: $error');
    }
  }

  try {
    await Future.wait([
      settled(passedAgeGateProvider),
      settled(activeExamFocusProvider),
      settled(onboardingCompleteProvider),
    ]).timeout(timeout);
  } on TimeoutException {
    debugPrint('Startup gates still loading; starting anyway.');
  }
}
