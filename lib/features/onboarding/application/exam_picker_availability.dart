import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/storage.dart';

enum ExamPickerAvailability {
  hidden,
  ageRestricted,
  comingSoon,
  selectable;

  String? get reason => switch (this) {
        ageRestricted => 'For ages 13 and up',
        comingSoon => 'Coming soon',
        hidden || selectable => null,
      };
}

class ExamPickerPolicy {
  const ExamPickerPolicy({
    required this.ageGroup,
    this.isWeb = kIsWeb,
    this.platform = TargetPlatform.iOS,
    this.pshsForChildren =
        const bool.fromEnvironment('PANTAS_PSHS_FOR_CHILDREN'),
  });

  final AgeGroup ageGroup;
  final bool isWeb;
  final TargetPlatform platform;
  final bool pshsForChildren;

  bool get allowsCustomExams => !ageGroup.hasChildLimits;

  ExamPickerAvailability availability(
    ExamCatalogEntry entry, {
    bool cseOnly = false,
  }) {
    final pshs = entry.id == 'exam_pshs_nce';
    if (pshs && !isWeb && platform == TargetPlatform.android) {
      return ExamPickerAvailability.hidden;
    }
    if (ageGroup.hasChildLimits && !pshs) {
      return ExamPickerAvailability.ageRestricted;
    }
    if (pshs && ageGroup.isChild && isWeb && pshsForChildren) {
      return ExamPickerAvailability.selectable;
    }
    if (!entry.isSelectable ||
        (cseOnly &&
            !ageGroup.isChild &&
            entry.id != 'exam_cse_pro' &&
            entry.id != 'exam_cse_sub') ||
        ageGroup == AgeGroup.unrecognized) {
      return ExamPickerAvailability.comingSoon;
    }
    return ExamPickerAvailability.selectable;
  }

  /// Whether a tap on [entry] first asks "Is this for a child under 13?"
  /// (under-13 board 3A): an adult or teen account tapping PSHS-NCE where the
  /// exam is shown. While PSHS-NCE is still coming soon, the question opens
  /// only on a build with [pshsForChildren] on, so the path can be tested.
  /// A child, an unset and an unrecognized group never see it.
  bool asksChildQuestion(ExamCatalogEntry entry, {bool cseOnly = false}) {
    if (entry.id != 'exam_pshs_nce') return false;
    if (ageGroup != AgeGroup.adult && ageGroup != AgeGroup.minor) return false;
    return switch (availability(entry, cseOnly: cseOnly)) {
      ExamPickerAvailability.selectable => true,
      ExamPickerAvailability.comingSoon => pshsForChildren,
      ExamPickerAvailability.hidden ||
      ExamPickerAvailability.ageRestricted =>
        false,
    };
  }
}

final examPickerPolicyProvider = Provider<ExamPickerPolicy>((ref) {
  return ExamPickerPolicy(
    ageGroup: ref.watch(resolvedAgeGroupProvider),
    platform: defaultTargetPlatform,
  );
});
