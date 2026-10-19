// Dart VM reference run. Reads fixtures/scenarios.json, runs the SAME
// buildRoadmapJson path the JS build uses, writes fixtures/expected.json.
// Run: dart run spike/roadmap_js/expected.dart
import 'dart:convert';
import 'dart:io';

import 'package:pantas/features/roadmap/domain/build_roadmap.dart';

import 'codec.dart';

void main() {
  final scenarios = jsonDecode(
    File('spike/roadmap_js/fixtures/scenarios.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final out = <String, Object?>{};
  for (final e in scenarios.entries) {
    final inputs = inputsFromJson(e.value! as Map<String, Object?>);
    out[e.key] = roadmapToJson(BuildRoadmap.call(inputs));
  }
  // Compact, key order preserved: the Node test compares parsed JSON and the
  // exact serialized string.
  File('spike/roadmap_js/fixtures/expected.json')
      .writeAsStringSync(jsonEncode(out));
  stdout.writeln('wrote expected for ${out.length} scenarios');
}
