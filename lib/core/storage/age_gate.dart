import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';

final passedAgeGateProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasPassedAgeGate();
});

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).hasCompletedOnboarding();
});

/// The age group on this device. [AgeGroup.unset] when none was recorded.
final ageGroupProvider = FutureProvider<AgeGroup>((ref) async {
  return ref.watch(appPreferencesRepositoryProvider).readAgeGroup();
});

/// Privacy-sensitive controls stay closed while the age is loading or failed.
final resolvedAgeGroupProvider = Provider<AgeGroup>((ref) {
  final age = ref.watch(ageGroupProvider);
  return age.isLoading || age.hasError
      ? AgeGroup.unrecognized
      : age.requireValue;
});
