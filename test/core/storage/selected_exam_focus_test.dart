import 'package:cse_cet_reviewer/core/content/content.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = inMemoryDatabase();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> insertExam(String id, String name) async {
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: id,
            code: id.toUpperCase(),
            name: name,
            shortName: id.toUpperCase(),
            language: 'en',
          ),
        );
  }

  test('uses persisted selected exam when valid', () async {
    await insertExam('cse', 'Civil Service Exam');
    await insertExam('upcat', 'UPCAT');
    await AppPreferencesRepository(db).setSelectedExamId('cse');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam?.id, equals('cse'));
    expect(focus.needsSelection, isFalse);
  });

  test('uses only exam as fallback when one exam exists', () async {
    await insertExam('cse', 'Civil Service Exam');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam?.id, equals('cse'));
    expect(focus.needsSelection, isFalse);
  });

  test('needs selection when multiple exams exist and none selected', () async {
    await insertExam('cse', 'Civil Service Exam');
    await insertExam('upcat', 'UPCAT');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam, isNull);
    expect(focus.needsSelection, isTrue);
  });

  test('needs selection when persisted exam is invalid', () async {
    await insertExam('cse', 'Civil Service Exam');
    await insertExam('upcat', 'UPCAT');
    await AppPreferencesRepository(db).setSelectedExamId('removed');

    final focus = await container.read(activeExamFocusProvider.future);

    expect(focus.exam, isNull);
    expect(focus.needsSelection, isTrue);
  });
}
