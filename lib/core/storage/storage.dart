import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/database_opener.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/attempts_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/content_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/review_state_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/streak_repository.dart';
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(
    'Override appDatabaseProvider in main bootstrap or tests',
  ),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(appDatabaseProvider)),
);

final attemptsRepositoryProvider = Provider<AttemptsRepository>(
  (ref) => AttemptsRepository(ref.watch(appDatabaseProvider)),
);

final reviewStateRepositoryProvider = Provider<ReviewStateRepository>(
  (ref) => ReviewStateRepository(ref.watch(appDatabaseProvider)),
);

final streakRepositoryProvider = Provider<StreakRepository>(
  (ref) => StreakRepository(ref.watch(appDatabaseProvider)),
);

final seederProvider = Provider<Seeder>(
  (ref) => Seeder(ref.watch(appDatabaseProvider), bundle: rootBundle),
);

/// Opens the encrypted DB and returns a ProviderContainer override list.
/// Call from main bootstrap.
Future<List<Override>> bootstrapStorageOverrides() async {
  final db = await openEncryptedDatabase();
  return [appDatabaseProvider.overrideWithValue(db)];
}
