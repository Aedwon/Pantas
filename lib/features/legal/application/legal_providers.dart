import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/features/legal/domain/legal_contact.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';

final legalContactProvider = Provider<LegalContact>(
  (ref) => defaultLegalContact,
);

final legalDocumentProvider = Provider.family<LegalDocument?, String>(
  (ref, id) => legalDocumentFallbacks[id],
);

/// True while the student has not finished onboarding. The legal pages then
/// open outside the app's main navigation, and Back returns to the step that
/// linked to them. Unknown counts as finished, as the Settings route did.
final legalInOnboardingProvider = Provider<bool>(
  (ref) => ref.watch(onboardingCompleteProvider).valueOrNull == false,
);
