import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

/// The account, exam and Sync core a Home plan was built for: the same owner
/// and core the launch guard captures, readable at once. Home stamps the plan
/// it shows with this and drops the plan the moment it moves.
@immutable
class HomeBoundary {
  const HomeBoundary({required this.owner, required this.core});

  /// Account, database, exam and account lifetime, compared by value. Null
  /// while the account is still being read.
  final Object? owner;

  /// The active Sync core token, or null until its first read finishes.
  final String? core;

  /// True when the owner differs from an owner already read, or the core
  /// differs from a core already read. Something still unread is not a move:
  /// the first read only names it, and a change inside that wait is caught by
  /// the launch guard.
  bool movedFrom(HomeBoundary before) =>
      (before.owner != null && owner != before.owner) ||
      (before.core != null && core != before.core);
}

/// The active Sync core token. It changes with no event the account or exam
/// providers hear of, so it follows the Sync table itself.
final homeCoreTokenProvider = StreamProvider.autoDispose<String>((ref) async* {
  final db = ref.watch(appDatabaseProvider);
  final store = SyncActiveContextStore(db);
  Future<String> read() async =>
      (await store.readSnapshot())?.token ?? 'uninitialized';
  var last = await read();
  yield last;
  await for (final _
      in db.tableUpdates(TableUpdateQuery.onTable(db.syncMeta))) {
    final next = await read();
    if (next == last) continue;
    last = next;
    yield next;
  }
});

final homeBoundaryProvider = Provider.autoDispose<HomeBoundary>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final preparer = ref.watch(todayQuizPreparerProvider);
  final auth = ref.watch(authStateProvider).unwrapPrevious().asData?.value;
  final examId = ref
      .watch(activeExamFocusProvider)
      .unwrapPrevious()
      .asData
      ?.value
      .exam
      ?.id;
  return HomeBoundary(
    owner: auth == null
        ? null
        : (db, preparer, preparer.accountLifetimeToken, auth, examId),
    core: ref.watch(homeCoreTokenProvider).valueOrNull,
  );
});
