import 'dart:async';

import 'package:pantas/core/auth/auth_repository.dart'
    show AuthGatewayException;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/report_queue.dart';

/// True while this device holds study changes the server has not accepted: a
/// queued change, a recorded local change not yet promoted, or a first full
/// upload that has not run. A pull in waiting is not unsent data. The reads
/// share one transaction, so they see one consistent state.
Future<bool> hasUnsentSyncData(AppDatabase db) => db.transaction(() async {
      final queued = await (db.select(db.pendingSync)..limit(1)).get();
      if (queued.isNotEmpty) return true;
      final rows = await db
          .customSelect('select 1 as unsent from sync_local_mutations limit 1')
          .get();
      if (rows.isNotEmpty) return true;
      final markers = await db
          .customSelect(
            'select 1 as unsent from sync_meta where key = '
            "'pending_full_push' and value = '1' limit 1",
          )
          .get();
      return markers.isNotEmpty;
    });

/// What a sign-out would delete that the server does not have, counting only
/// work this account can still upload: its Pro study backup when Pro sync is
/// active for it, and its own pending question reports. A Free or guest
/// account's study writes can never upload, so they never block.
Future<bool> hasUnsentForSignOut(
  AppDatabase db, {
  required bool canUploadStudyData,
  required ReportQueue reports,
}) =>
    db.transaction(() async {
      if (canUploadStudyData && await hasUnsentSyncData(db)) return true;
      return (await reports.pending()).isNotEmpty;
    });

/// Runs [wipe] only if nothing is unsent, checking and wiping in one
/// transaction so no write can land between them. A check that stalls past
/// [limit] counts as unsent. Refusal is the connection error the Account page
/// already shows.
Future<void> wipeUnlessUnsent(
  AppDatabase db, {
  required Future<bool> Function() hasUnsent,
  required Future<void> Function() wipe,
  Duration limit = const Duration(seconds: 5),
}) =>
    db.transaction(() async {
      // Not knowing (an error, or no answer in time) is not a reason to delete.
      final unsent = await hasUnsent()
          .then<bool>((value) => value, onError: (Object _) => true)
          .timeout(limit, onTimeout: () => true);
      if (unsent) throw const AuthGatewayException('network-request-failed');
      await wipe();
    });
