import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

/// Which price tier each subject sits in, for showing a custom exam's tier.
///
/// The table is generated from the question sets' exam tags
/// (`tools/custom_tiers/build_custom_tiers.dart`). This reader is display
/// only: the server works out the real tier itself and decides coverage. The
/// rules match the server's `customTier`.
@immutable
class CustomSubjectTiers {
  const CustomSubjectTiers._(this._subjects, this._topicTiers);

  factory CustomSubjectTiers.fromJson(Map<String, dynamic> json) {
    final subjects = <(PriceTier, Set<String>, String)>[
      for (final raw
          in (json['subjects'] as List<dynamic>).cast<Map<String, dynamic>>())
        (
          PriceTier.fromCatalog(raw['tier'] as String),
          (raw['topicIds'] as List<dynamic>).cast<String>().toSet(),
          raw['name'] as String? ?? '',
        ),
    ];
    final loose = <String, PriceTier>{
      for (final entry
          in (json['topicTiers'] as Map<String, dynamic>? ?? const {}).entries)
        entry.key: PriceTier.fromCatalog(entry.value as String),
    };
    final placed = {for (final subject in subjects) ...subject.$2};
    loose.removeWhere((id, _) => placed.contains(id));
    return CustomSubjectTiers._(subjects, loose);
  }

  final List<(PriceTier, Set<String>, String)> _subjects;

  /// Topics the table places in no subject, at their own tier.
  final Map<String, PriceTier> _topicTiers;

  /// The highest tier among the subjects that keep at least one of
  /// [includedTopicIds]. Fail closed, like the server: a kept topic the table
  /// places in no subject and gives no tier (new content before the table is
  /// rebuilt) raises the tier to the top, so it can never under-price. Student
  /// when nothing is kept.
  PriceTier tierOf(Iterable<String> includedTopicIds) {
    final included = includedTopicIds.toSet();
    var top = PriceTier.student;
    void raise(PriceTier tier) {
      if (tier.index > top.index) top = tier;
    }

    final placed = <String>{};
    for (final (tier, topics, _) in _subjects) {
      placed.addAll(topics);
      if (topics.any(included.contains)) raise(tier);
    }
    for (final id in included) {
      final tier = _topicTiers[id];
      if (tier != null) {
        raise(tier);
      } else if (!placed.contains(id)) {
        raise(PriceTier.licensure);
      }
    }
    return top;
  }

  /// The first subject above Student that keeps at least one of
  /// [includedTopicIds], in the table's order. Null when there is none.
  String? firstSubjectAboveStudent(Iterable<String> includedTopicIds) {
    final included = includedTopicIds.toSet();
    for (final (tier, topics, name) in _subjects) {
      if (tier != PriceTier.student &&
          name.isNotEmpty &&
          topics.any(included.contains)) {
        return name;
      }
    }
    return null;
  }

  /// The tier as the catalog spells it, for the "-level" wording.
  static String levelName(PriceTier tier) => switch (tier) {
        PriceTier.student => 'Student',
        PriceTier.civilService => 'Civil Service',
        PriceTier.licensure => 'Licensure',
        PriceTier.nce => 'PSHS-NCE',
      };

  /// "Civil Service-level".
  static String levelLabel(PriceTier tier) => '${levelName(tier)}-level';
}

const customSubjectTiersAsset = 'content/exams/custom_subject_tiers.json';

final customSubjectTiersProvider = FutureProvider<CustomSubjectTiers>(
  (ref) async => CustomSubjectTiers.fromJson(
    jsonDecode(await rootBundle.loadString(customSubjectTiersAsset))
        as Map<String, dynamic>,
  ),
);
