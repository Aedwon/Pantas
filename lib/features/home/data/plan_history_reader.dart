import 'dart:convert';

import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/domain/study_models.dart';

Future<Map<String, Object?>> readPlanHistory(
  StudyRequest request, {
  required int wanted,
}) async {
  final rows = <Map<String, Object?>>[];
  final ids = <String>{};
  final cursors = <String>{};
  Map<String, Object?>? next;
  do {
    final response = await request.read(
      'getRoadmap',
      payload: {
        'historyLimit': rows.isEmpty ? 5 : 10,
        if (next != null) 'historyBefore': next,
      },
    );
    // A coverage downgrade drops paid history immediately.
    if (response['proCovered'] == false) {
      return {'changes': <Object?>[], 'next': null};
    }
    final history = studyMap(response['history']);
    for (final row in studyRows(history['changes'])) {
      if (!ids.add(studyString(row['id']))) {
        throw const FormatException('Repeated plan history');
      }
      rows.add(row);
    }
    next = history['next'] == null ? null : studyMap(history['next']);
    if (next != null && !cursors.add(jsonEncode(next))) {
      throw const FormatException('Repeated plan history cursor');
    }
  } while (next != null && rows.length < wanted);
  return {'changes': rows, 'next': next};
}
