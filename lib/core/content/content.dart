import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/content_database_opener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'content_database.dart';

final contentDatabaseProvider = Provider<ContentDatabase>(
  (ref) => throw UnimplementedError(
    'Override contentDatabaseProvider in main bootstrap or tests',
  ),
);

Future<List<Override>> bootstrapContentOverrides({
  Future<ContentDatabase> Function() open = openContentDatabase,
}) async {
  final db = await open();
  return [contentDatabaseProvider.overrideWithValue(db)];
}
