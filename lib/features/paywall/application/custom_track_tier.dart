import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/data/custom_subject_tiers.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

/// The price tier of a custom exam, and the first subject that lifts it above
/// Student when one does.
@immutable
class CustomTrackTier {
  const CustomTrackTier({required this.tier, this.becauseOf});

  final PriceTier tier;

  /// The first subject above Student the exam keeps. Null at Student, or when
  /// this device cannot name the subject.
  final String? becauseOf;
}

/// A catalog-shaped entry for a custom exam, so the Pro page and the exam
/// switch treat it as a listed exam of its tier. It has no published sittings,
/// so no Season Pass is ever offered for it.
ExamCatalogEntry customCatalogEntry({
  required String examId,
  required String name,
  required PriceTier tier,
}) =>
    ExamCatalogEntry(
      id: examId,
      name: name,
      shortName: name,
      priceTier: CustomSubjectTiers.levelName(tier),
      group: 'Custom',
      comingSoon: false,
      hasContent: true,
      publishedSittings: const [],
    );

/// The tier from the client table and the topics the exam keeps. Display and
/// phone use: the server decides coverage on its own.
Future<CustomTrackTier> customTierFromTable(Ref ref, ExamId examId) async {
  final tiers = await ref.watch(customSubjectTiersProvider.future);
  final topics = await ref.watch(scopedTopicsProvider(examId).future);
  final ids = [for (final topic in topics) topic.id];
  return CustomTrackTier(
    tier: tiers.tierOf(ids),
    becauseOf: tiers.firstSubjectAboveStudent(ids),
  );
}

/// The tier the server reports for one of the student's custom exams.
Future<PriceTier> _serverTier(Ref ref, ExamId examId) async {
  final auth = await ref.watch(authStateProvider.future);
  final uid = switch (auth) {
    SignedInAuthState(:final user) => user.uid,
    AnonymousAuthState(:final uid) => uid,
    _ => null,
  };
  if (uid == null) throw StateError('No account to read the tier for');
  final reply = await ref
      .read(studyApiProvider)
      .requestAccount('getCustomTracks', expectedUid: uid);
  final tracks = reply['tracks'];
  if (tracks is! List) throw const FormatException('Bad tracks');
  final row = [for (final track in tracks) CustomTrackRow.fromJson(track)]
      .where((track) => track.examId == examId)
      .firstOrNull;
  final tier = row?.priceTier;
  if (tier == null) throw StateError('The server sent no tier');
  return PriceTier.fromCatalog(tier);
}

/// The tier of the active exam when it is a custom exam, null when it is not.
///
/// Web asks the server and phone reads the client table. While this is loading
/// or failed, the tier is unknown and no paywall may be drawn.
final activeCustomTrackTierProvider = FutureProvider<CustomTrackTier?>((
  ref,
) async {
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (exam == null || !exam.isCustom) return null;
  final local = await customTierFromTable(ref, exam.id);
  if (!ref.watch(studyUsesServerProvider)) return local;
  final server = await _serverTier(ref, exam.id);
  return CustomTrackTier(
    tier: server,
    becauseOf: server == PriceTier.student ? null : local.becauseOf,
  );
});

/// A custom exam as a switch target: its name and its tier from the client
/// table. Null when this device holds no such exam.
final customSwitchTargetProvider =
    FutureProvider.family<ExamCatalogEntry?, ExamId>((ref, examId) async {
  final name = await ref.watch(customTrackRepositoryProvider).name(examId);
  if (name == null) return null;
  final result = await customTierFromTable(ref, examId);
  return customCatalogEntry(examId: examId, name: name, tier: result.tier);
});
