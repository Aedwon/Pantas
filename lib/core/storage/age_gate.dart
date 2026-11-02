import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';

final passedAgeGateProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasPassedAgeGate();
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasCompletedOnboarding();
});

/// `minor`, `adult`, or null when no age was recorded on this device.
final ageGroupProvider = FutureProvider<String?>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).ageGroup();
});
