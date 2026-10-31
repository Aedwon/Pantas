import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/remote/content_service_providers.dart';
import 'package:pantas/core/dev/local_sample_students.dart';
import 'package:pantas/core/dev/local_student_url.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/storage/storage.dart';

/// The page address as it was when startup began. Routing rewrites the
/// address before the student can load, so startup records it first.
Uri? _startUrl;

/// Records the page address. Call first thing in startup.
void rememberLocalStudentUrl() {
  if (!localEmulators || !kIsWeb) return;
  _startUrl = Uri.base;
}

/// The sample student named by `?localStudent=<id>` in [url], or null.
SampleStudent? localStudentFromUrl(Uri url) {
  final id = url.queryParameters['localStudent'];
  return id == null ? null : SampleStudent.fromId(id);
}

/// Asks the local server to seed [student] for the account [uid], and returns
/// the parts the device keeps. Replaced in tests.
typedef LocalStudentSeed = Future<SampleStudentProfile> Function(
  String uid,
  SampleStudent student,
);

/// `POST /local-seed` on the page's own origin (`tools/local/run_web_local.py`).
/// The server runs its own handlers over the account's study records.
Future<SampleStudentProfile> seedLocalStudentOnServer(
  String uid,
  SampleStudent student,
) async {
  final reply = await Dio().post<Map<String, Object?>>(
    Uri.base.resolve('/local-seed').toString(),
    data: {'uid': uid, 'profile': student.id},
    options: Options(
      contentType: Headers.jsonContentType,
      receiveTimeout: const Duration(minutes: 4),
    ),
  );
  return SampleStudentProfile.fromJson(reply.data!);
}

/// Local runs only. When the page address carries `?localStudent=<id>`, has
/// the local server write that student's study records for the signed-in
/// account, then replaces the device's study data with the matching
/// onboarding answers and streak, and removes the parameter so a reload does
/// not do it again.
///
/// Call after sign-in. A failure is logged and the app starts as it was.
Future<void> loadLocalStudentFromUrl(
  ProviderContainer container, {
  Uri? url,
  LocalStudentSeed seed = seedLocalStudentOnServer,
  DateTime? today,
}) async {
  // Both are compile-time constants: normal builds drop everything below.
  if (!localEmulators || !kIsWeb) return;
  final student = localStudentFromUrl(url ?? _startUrl ?? Uri.base);
  if (student == null) return;
  try {
    final auth = await container.read(authStateProvider.future);
    final uid = switch (auth) {
      SignedInAuthState(:final user) => user.uid,
      AnonymousAuthState(:final uid) => uid,
      _ => null,
    };
    if (uid == null) throw StateError('Sign in before loading a student.');
    final profile = await seed(uid, student);
    await loadSampleStudentProfile(
      container.read(appDatabaseProvider),
      profile,
      today: today ?? DateTime.now(),
    );
    // Clear cached reads so every screen starts from the new records.
    for (final element in container.getAllProviderElements()) {
      element.invalidateSelf();
    }
    // The content mirror is rebuilt empty by the line above. Start it again, as
    // startup does, so question text can be fetched for the plan's reviews.
    await container.read(contentMirrorProvider).start();
  } catch (error, stack) {
    debugPrint('Local sample student did not load: $error\n$stack');
  } finally {
    removeLocalStudentFromUrl();
  }
}
