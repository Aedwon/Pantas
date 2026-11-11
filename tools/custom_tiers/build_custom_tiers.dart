// Builds content/exams/custom_subject_tiers.json: the price tier of each
// subject a custom exam can keep, read from the exam tags on the question sets.
//
//   dart run tools/custom_tiers/build_custom_tiers.dart [root]
//
// A subject takes the LOWEST tier among the exams tagged on its sets. A topic
// takes the HIGHEST, so a topic the table does not place in a subject can never
// lower a price. PSHS-NCE sells passes only and is not a rung of the
// subscription ladder, so it never counts toward a tier.
//
// Topic ids are minted exactly as tools/build_content_export mints them:
// `topic_upcat_` plus the topic slug with `-` turned into `_`.
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// Lowest to highest. PSHS-NCE is deliberately absent.
const customTierLadder = ['Student', 'Civil Service', 'Licensure'];
const _nce = 'PSHS-NCE';

/// One question set that holds at least one active question.
class TierSet {
  const TierSet(this.subject, this.topic, this.exams);

  /// `meta.subject`, a slug.
  final String subject;

  /// `meta.topic`, a slug.
  final String topic;

  /// `meta.exams`, tags such as `cse-pro`.
  final List<String> exams;
}

String topicIdOf(String slug) => 'topic_upcat_${slug.replaceAll('-', '_')}';

String _examIdOf(String tag) => 'exam_${tag.replaceAll('-', '_')}';

/// Builds the table. Throws [StateError] on anything that needs a ruling:
/// an unknown exam tag, a subject missing from the outline, or a subject or
/// topic whose only tags are PSHS-NCE.
Map<String, Object?> buildCustomTiers({
  required List<TierSet> sets,
  required Map<String, dynamic> outline,
  required Map<String, String> examTiers,
}) {
  final subjectsBySlug = {
    for (final raw in outline['subjects'] as List)
      (raw as Map<String, dynamic>)['slug'] as String: raw,
  };

  int? rung(String tag) {
    final tier = examTiers[_examIdOf(tag)];
    if (tier == null) throw StateError('Exam tag "$tag" is not in the catalog');
    if (tier == _nce) return null;
    final index = customTierLadder.indexOf(tier);
    if (index < 0) throw StateError('Unknown tier "$tier" for "$tag"');
    return index;
  }

  final subjectLow = <String, int>{};
  final topicHigh = <String, int>{};
  final subjectSawNce = <String>{};
  final topicSawNce = <String>{};
  final topicsWithQuestions = <String>{};
  for (final set in sets) {
    if (!subjectsBySlug.containsKey(set.subject)) {
      throw StateError('Subject "${set.subject}" is not in the outline');
    }
    topicsWithQuestions.add(set.topic);
    for (final tag in set.exams) {
      final index = rung(tag);
      if (index == null) {
        subjectSawNce.add(set.subject);
        topicSawNce.add(set.topic);
        continue;
      }
      final low = subjectLow[set.subject];
      if (low == null || index < low) subjectLow[set.subject] = index;
      final high = topicHigh[set.topic];
      if (high == null || index > high) topicHigh[set.topic] = index;
    }
  }
  for (final slug in subjectSawNce) {
    if (!subjectLow.containsKey(slug)) {
      throw StateError('Subject "$slug" is tagged only for PSHS-NCE');
    }
  }
  for (final slug in topicSawNce) {
    if (!topicHigh.containsKey(slug)) {
      throw StateError('Topic "$slug" is tagged only for PSHS-NCE');
    }
  }

  // Only topics that hold a question are listed, as the picker offers only
  // those, so an empty topic can never keep a subject alive.
  final subjects = <Map<String, Object?>>[];
  for (final subject in subjectsBySlug.values) {
    final slug = subject['slug'] as String;
    final low = subjectLow[slug];
    if (low == null) continue;
    subjects.add({
      'name': subject['name'] as String,
      'tier': customTierLadder[low],
      'topicIds': [
        for (final topic in subject['topics'] as List)
          if (topicsWithQuestions.contains(
            (topic as Map<String, dynamic>)['slug'],
          ))
            topicIdOf(topic['slug'] as String),
      ],
    });
  }
  final topicTiers = <String, Object?>{
    for (final slug in (topicHigh.keys.toList()..sort()))
      topicIdOf(slug): customTierLadder[topicHigh[slug]!],
  };
  // Topics outside the outline are still priced here, with their highest tier.
  return {'version': 1, 'subjects': subjects, 'topicTiers': topicTiers};
}

/// Reads the tree under [root] and builds the table.
Map<String, Object?> buildCustomTiersFromTree(String root) {
  final outline = jsonDecode(
    File('$root/tools/lesson_author/outline.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final catalog = jsonDecode(
    File('$root/content/exams/catalog.json').readAsStringSync(),
  ) as List<dynamic>;
  final examTiers = {
    for (final exam in catalog.cast<Map<String, dynamic>>())
      exam['id'] as String: exam['priceTier'] as String,
  };
  final sets = <TierSet>[];
  final files = Directory('$root/content/questions')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.yaml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;
    final meta = doc['meta'] as YamlMap;
    final questions = (doc['questions'] as YamlList?) ?? YamlList();
    final active = questions.any((q) => (q as YamlMap)['isActive'] != false);
    if (!active) continue;
    sets.add(
      TierSet(
        meta['subject'] as String,
        meta['topic'] as String,
        [for (final tag in meta['exams'] as YamlList? ?? YamlList()) '$tag'],
      ),
    );
  }
  return buildCustomTiers(sets: sets, outline: outline, examTiers: examTiers);
}

String renderCustomTiers(Map<String, Object?> table) =>
    '${const JsonEncoder.withIndent('  ').convert(table)}\n';

void main(List<String> args) {
  final root = args.isEmpty ? '.' : args.first;
  File('$root/content/exams/custom_subject_tiers.json')
      .writeAsStringSync(renderCustomTiers(buildCustomTiersFromTree(root)));
}
