// JS entry point. Compiled with `dart compile js`; see build.sh.
//
// Exposes globalThis.pantasBuildRoadmap(inputsJson: string): string.
// The function is pure: no clock, no randomness, no I/O. The caller supplies
// `today` inside the input JSON as a local calendar date.
import 'dart:convert';
import 'dart:js_interop';

import 'package:pantas/features/roadmap/domain/build_roadmap.dart';

import 'codec.dart';

@JS('pantasBuildRoadmap')
external set _pantasBuildRoadmap(JSFunction f);

String buildRoadmapJson(String inputsJson) {
  final inputs = inputsFromJson(
    jsonDecode(inputsJson) as Map<String, Object?>,
  );
  return jsonEncode(roadmapToJson(BuildRoadmap.call(inputs)));
}

void main() {
  _pantasBuildRoadmap =
      ((JSString json) => buildRoadmapJson(json.toDart).toJS).toJS;
}
