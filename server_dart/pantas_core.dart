// JS entry point for the server. Compiled by build.sh with `dart compile js`.
//
// Exposes two pure functions on globalThis, each taking and returning a JSON
// string. Neither reads the clock or a random source: the caller passes the
// Philippine calendar date (never a raw UTC instant) and the sampler seed.
import 'dart:convert';
import 'dart:js_interop';

import 'package:pantas/features/roadmap/domain/build_roadmap.dart';

import 'mock_codec.dart';
import 'roadmap_codec.dart';

@JS('pantasBuildRoadmap')
external set _pantasBuildRoadmap(JSFunction f);

@JS('pantasSampleMock')
external set _pantasSampleMock(JSFunction f);

String buildRoadmapJson(String inputsJson) {
  final inputs = inputsFromJson(
    jsonDecode(inputsJson) as Map<String, Object?>,
  );
  return jsonEncode(roadmapToJson(BuildRoadmap.call(inputs)));
}

String sampleMockJson(String inputJson) => jsonEncode(
      sampleMockFromJson(jsonDecode(inputJson) as Map<String, Object?>),
    );

void main() {
  _pantasBuildRoadmap =
      ((JSString json) => buildRoadmapJson(json.toDart).toJS).toJS;
  _pantasSampleMock =
      ((JSString json) => sampleMockJson(json.toDart).toJS).toJS;
}
