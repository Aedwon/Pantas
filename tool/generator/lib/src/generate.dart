import 'dart:math';

import 'model.dart';
import 'rules/rule.dart';

const toolVersion = 1;

/// Replays the seed on refill to resume the random stream.
/// A changed rule or input that alters existing variants must get a new list.
VariantList generateVariants(
  ProblemType type, {
  required int count,
  int? seed,
  VariantList? existing,
  Map<String, Rule>? rules,
}) {
  final rule = (rules ?? ruleRegistry)[type.rule];
  if (rule == null ||
      rule.name != type.rule ||
      rule.version != type.ruleVersion) {
    throw ArgumentError(
      'Unknown rule or version: ${type.rule} ${type.ruleVersion}',
    );
  }
  if (count < 0 || (seed != null && seed < 0)) {
    throw ArgumentError('Count and seed must be nonnegative');
  }
  final actualSeed = seed ?? existing?.seed ?? 20261117;
  final previous = existing?.variants ?? const <Variant>[];
  if (existing != null &&
      (existing.problemType != type.id ||
          existing.tool != toolVersion ||
          existing.ruleVersion != type.ruleVersion ||
          existing.seed != actualSeed)) {
    throw ArgumentError('Existing list metadata does not match ${type.id}');
  }
  final length = max(count, previous.length);
  final reserved = {for (final m in type.mergedQuestions) m.index: m.id};
  if (reserved.keys.any((index) => index >= length)) {
    throw ArgumentError('Count omits a merged question index for ${type.id}');
  }
  final random = Random(actualSeed);
  final seen = <String>{};
  final variants = <Variant>[];
  for (var index = 0; index < length; index++) {
    Variant? accepted;
    for (var failed = 0; failed < 1000; failed++) {
      final candidate = rule.generate(type, random, index);
      if (candidate.index != index || candidate.source != reserved[index]) {
        throw StateError(
          '${type.id} index $index: wrong index or merged source',
        );
      }
      if (seen.add(candidate.signature)) {
        accepted = candidate;
        break;
      }
    }
    if (accepted == null) {
      throw StateError('${type.id} index $index: 1000 failed draws');
    }
    if (index < previous.length) {
      if (previous[index] != accepted) {
        throw ArgumentError(
          '${type.id} index $index: existing variant differs from replay',
        );
      }
      variants.add(previous[index]);
    } else {
      variants.add(accepted);
    }
  }
  return parseVariantList({
    'problemType': type.id,
    'generator': {
      'tool': toolVersion,
      'ruleVersion': rule.version,
      'seed': actualSeed,
    },
    'variants': variants.map((v) => v.toMap()).toList(),
  });
}
