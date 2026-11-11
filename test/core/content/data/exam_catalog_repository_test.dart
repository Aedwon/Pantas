import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';

class _CatalogBundle extends CachingAssetBundle {
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    loads++;
    final bytes = Uint8List.fromList(
      utf8.encode(
        jsonEncode([
          {
            'id': 'exam_cse_pro',
            'name': 'Civil Service Examination: Professional',
            'shortName': 'CSE Pro',
            'priceTier': 'Civil Service',
            'group': 'Civil service',
            'comingSoon': false,
            'publishedSittings': [
              {
                'firstDay': '2027-08-08',
                'lastDay': '2027-08-08',
                'sourceUrl': 'https://www.csc.gov.ph/announcement',
              },
              {
                'firstDay': '2027-03-14',
                'lastDay': '2027-03-14',
                'sourceUrl': 'https://www.csc.gov.ph/announcement',
              },
            ],
          },
          {
            'id': 'exam_upcat',
            'name': 'UP College Admission Test',
            'shortName': 'UPCAT',
            'priceTier': 'Student',
            'group': 'College entrance',
            'comingSoon': false,
            'publishedSittings': <Object?>[],
          },
          {
            'id': 'exam_let',
            'name': 'Licensure Examination for Teachers',
            'shortName': 'LET',
            'priceTier': 'Licensure',
            'group': 'Licensure',
            'comingSoon': true,
            'publishedSittings': <Object?>[],
          },
        ]),
      ),
    );
    return ByteData.sublistView(bytes);
  }
}

void main() {
  late ContentDatabase db;
  late _CatalogBundle bundle;
  late ExamCatalogRepository repository;

  setUp(() {
    db = ContentDatabase(NativeDatabase.memory());
    bundle = _CatalogBundle();
    repository = ExamCatalogRepository(db, assetBundle: bundle);
  });
  tearDown(() => db.close());

  Future<void> addExam(String id) => db.into(db.contentExams).insert(
        ContentExamsCompanion.insert(
          id: id,
          schemaVersion: 1,
          updatedAt: DateTime.utc(2026),
          code: id,
          name: id,
          shortName: id,
          language: 'en',
          ordering: 1,
        ),
      );

  test('catalog keeps file order and orders published sittings by date',
      () async {
    final entries = await repository.watchAll().first;
    expect(
      entries.map((e) => e.id),
      ['exam_cse_pro', 'exam_upcat', 'exam_let'],
    );
    expect(
      entries.first.publishedSittings.map((s) => s.firstDay),
      [DateTime.utc(2027, 3, 14), DateTime.utc(2027, 8, 8)],
    );
    expect(
      entries.first.publishedSittings.first.sourceUrl,
      'https://www.csc.gov.ph/announcement',
    );
  });

  test('an exam without sittings keeps an empty list and asset loads once',
      () async {
    expect((await repository.entry('exam_upcat')).publishedSittings, isEmpty);
    await repository.watchAll().first;
    expect(bundle.loads, 1);
  });

  test('selectability follows the database row and Coming soon flag', () async {
    final before = await repository.entry('exam_upcat');
    expect(before.hasContent, isFalse);
    expect(before.isSelectable, isFalse);
    await addExam('exam_upcat');
    final after = await repository.entry('exam_upcat');
    expect(after.hasContent, isTrue);
    expect(after.isSelectable, isTrue);
    await addExam('exam_let');
    expect((await repository.entry('exam_let')).isSelectable, isFalse);
  });

  test('watchAll updates hasContent when an exam row arrives', () async {
    final updates = StreamIterator(repository.watchAll());
    addTearDown(updates.cancel);
    expect(await updates.moveNext(), isTrue);
    expect(updates.current[1].hasContent, isFalse);
    await addExam('exam_upcat');
    expect(await updates.moveNext(), isTrue);
    expect(updates.current[1].hasContent, isTrue);
  });
}
