import 'package:pantas/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passedAgeGateProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasPassedAgeGate();
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasCompletedOnboarding();
});
