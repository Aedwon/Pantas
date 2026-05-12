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

  test(
      'maybeSeed populates exams/subjects/topics/questions/lessons on empty DB',
      () async {
    await seeder.maybeSeed();

    expect(await db.select(db.exams).get(), hasLength(2));
    expect(await db.select(db.subjects).get(), hasLength(2));
    expect(await db.select(db.topics).get(), hasLength(2));
    expect(await db.select(db.questions).get(), hasLength(4));
    expect(await db.select(db.lessons).get(), hasLength(1));
  });

  test('maybeSeed is idempotent (running twice does not duplicate rows)',
      () async {
    await seeder.maybeSeed();
    await seeder.maybeSeed();
    expect(await db.select(db.exams).get(), hasLength(2));
    expect(await db.select(db.questions).get(), hasLength(4));
  });
}
