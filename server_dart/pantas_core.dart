// JS entry point for the server. Compiled by build.sh with `dart compile js`.
//
// Exposes pure functions on globalThis, each taking and returning a JSON
// string. Neither reads the clock or a random source: the caller passes the
// Philippine calendar date (never a raw UTC instant) and the sampler seed.
import 'dart:convert';
import 'dart:js_interop';

import 'package:pantas/features/roadmap/domain/build_roadmap.dart';

import 'diagnosis_codec.dart';
import 'insights_codec.dart';
import 'mock_codec.dart';
import 'review_codec.dart';
import 'roadmap_codec.dart';
import 'roadmap_state_codec.dart';

@JS('pantasSessionDiagnosis')
external set _pantasSessionDiagnosis(JSFunction f);

String sessionDiagnosisJson(String json) => jsonEncode(
      sessionDiagnosisFromJson(
        (jsonDecode(json) as Map).cast<String, Object?>(),
      ),
    );

@JS('pantasRoadmapState')
external set _pantasRoadmapState(JSFunction f);

String roadmapStateJson(String json) => jsonEncode(
      roadmapStateFromJson((jsonDecode(json) as Map).cast<String, Object?>()),
    );

@JS('pantasStudyInsights')
external set _pantasStudyInsights(JSFunction f);

String studyInsightsJson(String json) => jsonEncode(
      studyInsightsFromJson((jsonDecode(json) as Map).cast<String, Object?>()),
    );

@JS('pantasBuildRoadmap')
external set _pantasBuildRoadmap(JSFunction f);

@JS('pantasSampleMock')
external set _pantasSampleMock(JSFunction f);

@JS('pantasScheduleReviews')
external set _pantasScheduleReviews(JSFunction f);
@JS('pantasDueReviews')
external set _pantasDueReviews(JSFunction f);

String scheduleReviewsJson(String json) => jsonEncode(
      scheduleReviewStates((jsonDecode(json) as Map).cast<String, Object?>()),
    );
String dueReviewsJson(String json) => jsonEncode(
      dueReviewInputs((jsonDecode(json) as Map).cast<String, Object?>()),
    );

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
  _pantasSessionDiagnosis =
      ((JSString json) => sessionDiagnosisJson(json.toDart).toJS).toJS;
  _pantasRoadmapState =
      ((JSString json) => roadmapStateJson(json.toDart).toJS).toJS;
  _pantasStudyInsights =
      ((JSString json) => studyInsightsJson(json.toDart).toJS).toJS;
  _pantasScheduleReviews =
      ((JSString json) => scheduleReviewsJson(json.toDart).toJS).toJS;
  _pantasDueReviews =
      ((JSString json) => dueReviewsJson(json.toDart).toJS).toJS;
  _pantasBuildRoadmap =
      ((JSString json) => buildRoadmapJson(json.toDart).toJS).toJS;
  _pantasSampleMock =
      ((JSString json) => sampleMockJson(json.toDart).toJS).toJS;
}
