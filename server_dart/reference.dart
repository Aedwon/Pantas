// Dart VM reference run. Reads the scenario files and runs the SAME JSON
// paths the compiled JS uses, then writes the expected files.
// Run from the repository root: dart run server_dart/reference.dart
import 'dart:convert';
import 'dart:io';

import 'package:pantas/features/roadmap/domain/build_roadmap.dart';

import 'mock_codec.dart';
import 'review_codec.dart';
import 'roadmap_codec.dart';

Map<String, Object?> _read(String name) => jsonDecode(
      File('server_dart/fixtures/$name').readAsStringSync(),
    ) as Map<String, Object?>;

void main() {
  final roadmap = <String, Object?>{
    for (final e in _read('roadmap_scenarios.json').entries)
      e.key: roadmapToJson(
        BuildRoadmap.call(inputsFromJson(e.value! as Map<String, Object?>)),
      ),
  };
  File('server_dart/fixtures/roadmap_expected.json')
      .writeAsStringSync(jsonEncode(roadmap));
  final mock = <String, Object?>{
    for (final e in _read('mock_scenarios.json').entries)
      e.key: sampleMockFromJson(e.value! as Map<String, Object?>),
  };
  File('server_dart/fixtures/mock_expected.json')
      .writeAsStringSync(jsonEncode(mock));
  final review = <String, Object?>{};
  for (final e in _read('review_scenarios.json').entries) {
    final input = e.value! as Map<String, Object?>;
    final states = scheduleReviewStates(input);
    review[e.key] = {
      'states': states,
      'due': dueReviewInputs({'now': input['now'], 'states': states}),
    };
  }
  File('server_dart/fixtures/review_expected.json')
      .writeAsStringSync(jsonEncode(review));
  stdout.writeln('wrote ${roadmap.length} roadmap and ${mock.length} mock');
}
