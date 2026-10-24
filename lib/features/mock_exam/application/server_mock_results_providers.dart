import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_results.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';

final mockUsesServerProvider = Provider<bool>((ref) => kIsWeb);

/// Auth events invalidate the request even after an A-to-B-to-A transition.
final serverMockIdentityProvider = Provider<String?>((ref) {
  final state = ref.watch(authStateProvider);
  if (state.isLoading ||
      state.hasError ||
      state.valueOrNull is! SignedInAuthState) {
    return null;
  }
  return ref.watch(serverMockActorProvider)();
});

Future<T> guardedMockRead<T>(
  Ref ref,
  Future<T> Function(ServerMockApi, void Function()) read,
) async {
  final uid = ref.watch(serverMockIdentityProvider);
  if (uid == null) throw const ServerMockException(code: 'unauthenticated');
  ref.watch(entitlementProvider);
  final actor = ref.watch(serverMockActorProvider);
  var disposed = false;
  ref.onDispose(() => disposed = true);
  void check() {
    if (disposed || actor() != uid) {
      throw const ServerMockException(code: 'cancelled');
    }
  }

  check();
  final result = await read(ref.watch(serverMockApiProvider), check);
  check();
  return result;
}

/// Browsers store timer delays as signed 32-bit milliseconds. Re-read at a
/// safe segment boundary. Server time and monotonic elapsed time own expiry.
void _scheduleServerMockRefresh(
  Ref ref, {
  required int serverNow,
  required Iterable<int?> deadlines,
  required Duration requestElapsed,
}) {
  final future =
      deadlines.whereType<int>().where((at) => at > serverNow).toList();
  if (future.isEmpty) return;
  final next = future.reduce((a, b) => a < b ? a : b);
  final remaining = Duration(milliseconds: next - serverNow) - requestElapsed;
  final timer = Timer(
    Duration(milliseconds: remaining.inMilliseconds.clamp(1, 0x7fffffff)),
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);
}

final serverMockResultProvider =
    FutureProvider.family<ServerMockResult, String>((ref, id) async {
  final elapsed = ref.watch(serverMockElapsedProvider);
  final began = elapsed();
  final result = await guardedMockRead(ref, (api, check) => api.results(id));
  _scheduleServerMockRefresh(
    ref,
    serverNow: result.serverNow,
    deadlines: [
      if (result.canReview) result.reviewUntil,
      result.accessRecheckAt,
    ],
    requestElapsed: elapsed() - began,
  );
  return result;
});

final serverMockHistoryProvider = FutureProvider<List<ServerMockResult>>(
  (ref) => guardedMockRead(ref, (api, check) async {
    final entries = <ServerMockResult>[];
    final seen = <String>{};
    final cursors = <String>{};
    Map<String, Object?>? before;
    do {
      check();
      final page = await api.history(before: before);
      check();
      for (final result in page.items) {
        if (!seen.add(result.mockId)) {
          throw const ServerMockFormatException('Repeated history result');
        }
        entries.add(result);
      }
      before = page.next;
      if (before != null &&
          !cursors.add('${before['submittedAt']}/${before['mockId']}')) {
        throw const ServerMockFormatException('Repeated history cursor');
      }
    } while (before != null);
    return List.unmodifiable(entries);
  }),
);

final serverMockAvailabilityProvider =
    FutureProvider.family<Map<String, Object?>, String>(
  (ref, examId) {
    final elapsed = ref.watch(serverMockElapsedProvider);
    final began = elapsed();
    return guardedMockRead(ref, (api, check) async {
      final reply = await api.availability(examId);
      if (reply['examId'] != examId ||
          !['in-progress', 'cooldown', 'available', 'no-blueprint']
              .contains(reply['status']) ||
          reply['proCovered'] is! bool) {
        throw const ServerMockFormatException('Invalid availability');
      }
      serverMockWhole(reply['serverNow']);
      if (reply['nextEligibleAt'] != null) {
        serverMockWhole(reply['nextEligibleAt']);
      }
      final serverNow = serverMockWhole(reply['serverNow']);
      final access = reply['accessRecheckAt'];
      _scheduleServerMockRefresh(
        ref,
        serverNow: serverNow,
        deadlines: [
          if (reply['status'] == 'cooldown')
            serverMockWhole(reply['nextEligibleAt']),
          if (access != null) serverMockWhole(access),
        ],
        requestElapsed: elapsed() - began,
      );
      return reply;
    });
  },
);

final serverMockSetupCountProvider = FutureProvider.family<int, String>(
  (ref, examId) => guardedMockRead(ref, (api, check) async {
    final reply = await api.availability(examId, includeSetup: true);
    check();
    if (reply['examId'] != examId || reply['status'] != 'available') {
      throw const ServerMockException(code: 'failed-precondition');
    }
    final setup = serverMockObject(reply['setup']);
    final count = serverMockWhole(setup['questionCount']);
    serverMockWhole(setup['expectedQuestionCount']);
    if (count > ServerMockPaper.maxAnswers) {
      throw const ServerMockFormatException('Setup preview is too large');
    }
    return count;
  }),
);
