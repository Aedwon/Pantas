import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/features/legal/domain/legal_contact.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';

final legalContactProvider = Provider<LegalContact>(
  (ref) => defaultLegalContact,
);

final legalDocumentProvider =
    Provider.autoDispose.family<LegalDocument?, String>((ref, id) {
  final document = legalDocumentFallbacks[id];
  if (id != 'child-notice-kids' || document == null) return document;
  if (ref.watch(_kidsNoticeSiblingAccessProvider).asData?.value != true) {
    return document;
  }

  return LegalDocument(
    id: document.id,
    title: document.title,
    updatedAt: document.updatedAt,
    sections: [
      for (final section in document.sections)
        if (section.heading == 'Who can see it')
          LegalSection(
            heading: section.heading,
            body: section.body.replaceFirst(
              childNoticeKidsProviderCopy,
              '$childNoticeKidsSiblingCopy $childNoticeKidsProviderCopy',
            ),
          )
        else
          section,
    ],
  );
});

final _kidsNoticeSiblingAccessProvider = FutureProvider.autoDispose<bool>(
  (ref) async {
    if (!ref.watch(resolvedAgeGroupProvider).isChild) return false;
    final state = ref.watch(authStateProvider).asData?.value;
    if (state is! SignedInAuthState) return false;
    final auth = ref.watch(authRepositoryProvider);
    final result = await auth.listChildren();
    return result.children.any(
      (child) => child.uid == state.user.uid && child.siblingOpenWithoutCode,
    );
  },
);

/// True while the student has not finished onboarding. The legal pages then
/// open outside the app's main navigation, and Back returns to the step that
/// linked to them. Unknown counts as finished, as the Settings route did.
final legalInOnboardingProvider = Provider<bool>(
  (ref) => ref.watch(onboardingCompleteProvider).valueOrNull == false,
);
