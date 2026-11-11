import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/local_sample_students.dart';
import 'package:pantas/core/dev/local_study_reset.dart';
import 'package:pantas/core/storage/storage.dart';

/// A debug-only service extension that allows the `tools/demo` bash script
/// to reset the database and load the Steady sample student.
Future<void> registerDevDemoSwitch(ProviderContainer container) async {
  if (!kDebugMode) return;

  final db = container.read(appDatabaseProvider);
  final contentDb = container.read(contentDatabaseProvider);

  developer.registerExtension('ext.pantas.demo', (method, parameters) async {
    final action = parameters['action'];
    if (action == 'reset') {
      await resetLocalStudyData(db);
    } else if (action == 'populate') {
      await loadSampleStudent(
        db,
        contentDb,
        SampleStudent.steady,
        today: DateTime.now(),
      );
    }

    // Invalidate all providers so memory caches clear immediately
    for (final element in container.getAllProviderElements()) {
      element.invalidateSelf();
    }

    return developer.ServiceExtensionResponse.result(
      jsonEncode({'status': 'ok', 'action': action}),
    );
  });
}
