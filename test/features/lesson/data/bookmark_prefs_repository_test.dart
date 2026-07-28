import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/lesson/data/repos/bookmark_prefs_repository.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/bookmark_order.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late BookmarkPrefsRepository repo;

  setUp(() {
    db = inMemoryDatabase();
    repo = BookmarkPrefsRepository(db);
  });

  tearDown(() => db.close());

  test('an untouched install reads the default order', () async {
    expect(await repo.readOrder(), BookmarkOrder.recent);
  });

  test('a chosen order round-trips', () async {
    await repo.saveOrder(BookmarkOrder.custom);

    expect(await repo.readOrder(), BookmarkOrder.custom);
  });

  test('a stored value nobody recognises falls back rather than throwing',
      () async {
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: BookmarkPrefsRepository.orderKey,
            value: 'sideways',
          ),
        );

    expect(await repo.readOrder(), BookmarkOrder.recent);
  });
}
