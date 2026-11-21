import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Chooses an index by rule coverage, index coverage, then least recent use.
/// The seeded permutation also breaks ties in the last-served timestamps.
int? chooseVariant({
  required String uid,
  required String typeId,
  required List<String> ruleKeysByIndex,
  required Map<int, DateTime> served,
}) {
  if (ruleKeysByIndex.isEmpty) return null;
  final seed = sha256.convert(utf8.encode(uid + typeId));
  // Sort by full digest strings so the order is identical in Dart VM and JS.
  final ranks = [
    for (var i = 0; i < ruleKeysByIndex.length; i++)
      sha256.convert(utf8.encode('$seed#$i')).toString(),
  ];
  final order = List<int>.generate(ranks.length, (index) => index)
    ..sort((a, b) => ranks[a].compareTo(ranks[b]));

  final servedRules = {
    for (final index in served.keys)
      if (index >= 0 && index < ruleKeysByIndex.length) ruleKeysByIndex[index],
  };
  int? unserved;
  int? oldest;
  for (final index in order) {
    final time = served[index];
    if (time == null) {
      if (!servedRules.contains(ruleKeysByIndex[index])) return index;
      unserved ??= index;
    } else if (oldest == null || time.isBefore(served[oldest]!)) {
      oldest = index;
    }
  }
  return unserved ?? oldest;
}
