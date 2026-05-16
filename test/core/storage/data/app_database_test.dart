import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  test('schemaVersion is 4', () {
    expect(db.schemaVersion, equals(4));
  });

  test('inserts and reads an exam row', () async {
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_cse_pro',
            code: 'CSE_PRO',
            name: 'CSE Pro',
            shortName: 'CSE Pro',
            language: 'en',
          ),
        );
    final rows = await db.select(db.exams).get();
    expect(rows, hasLength(1));
    expect(rows.first.id, equals('exam_cse_pro'));
  });
}
