import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/seeder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Seeder seeder;

  setUp(() {
    db = inMemoryDatabase();
    seeder = Seeder(db, bundle: rootBundle);
  });
  tearDown(() => db.close());

  // Counts are deliberately not asserted as literals: the seed asset is
  // regenerated whenever content is authored, and pinning the numbers here made
  // every content commit a failing test. What matters is that each table is
  // populated and that seeding twice does not duplicate rows.
  test(
      'maybeSeed populates exams/subjects/topics/questions/lessons on empty DB',
      () async {
    await seeder.maybeSeed();

    expect(await db.select(db.exams).get(), isNotEmpty);
    expect(await db.select(db.subjects).get(), isNotEmpty);
    expect(await db.select(db.topics).get(), isNotEmpty);
    expect(await db.select(db.questions).get(), isNotEmpty);
    expect(await db.select(db.lessons).get(), isNotEmpty);
  });

  test('maybeSeed is idempotent (running twice does not duplicate rows)',
      () async {
    await seeder.maybeSeed();
    final afterFirst = [
      (await db.select(db.exams).get()).length,
      (await db.select(db.subjects).get()).length,
      (await db.select(db.topics).get()).length,
      (await db.select(db.questions).get()).length,
      (await db.select(db.lessons).get()).length,
    ];

    await seeder.maybeSeed();
    final afterSecond = [
      (await db.select(db.exams).get()).length,
      (await db.select(db.subjects).get()).length,
      (await db.select(db.topics).get()).length,
      (await db.select(db.questions).get()).length,
      (await db.select(db.lessons).get()).length,
    ];

    expect(afterSecond, equals(afterFirst));
  });
}
