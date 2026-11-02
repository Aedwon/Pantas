import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';

import 'databases.dart';
import 'exams.dart';

/// The lessons of each exam in the order the app's study map shows them.
///
/// This runs the app's own study map for each exam against the built content,
/// so scope and order are the app's, not a copy of its rules.
Future<Map<String, List<String>>> computeStudyOrder(
  ReviewDatabases databases,
) async {
  final out = <String, List<String>>{};
  for (final code in examCodes) {
    final app = databases.newAppDatabase();
    await AppPreferencesRepository(app).setSelectedExamId(examIdFor(code));
    final container = ProviderContainer(
      overrides: [
        contentDatabaseProvider.overrideWithValue(databases.content),
        appDatabaseProvider.overrideWithValue(app),
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AuthState.anonymous(uid: 'content-pass')),
        ),
      ],
    );
    try {
      final map = await container.read(studyMapProvider.future);
      out[code] = [
        if (map != null)
          for (final subject in map.subjects)
            for (final topic in subject.topics)
              for (final lesson in topic.lessons) lesson.id,
      ];
    } finally {
      container.dispose();
      await app.close();
    }
  }
  return out;
}
