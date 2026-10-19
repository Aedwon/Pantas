import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/content/repos/mock_blueprint_repo.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';

void main() {
  late Directory fixtureDirectory;
  late ContentDatabase db;
  late MockBlueprintRepo repo;
  late Map<String, Object?> exported;

  setUpAll(() async {
    fixtureDirectory = Directory.systemTemp.createTempSync('pantas_cse_bp_');
    final export = File('${fixtureDirectory.path}/export.json');
    final dbFile = File('${fixtureDirectory.path}/content.db');
    await _runDartTool([
      'run',
      'tools/build_content_export/build_content_export.dart',
      export.path,
    ]);
    exported = jsonDecode(export.readAsStringSync()) as Map<String, Object?>;
    await _runDartTool([
      'run',
      'tools/build_content_seed/seed_writer.dart',
      export.path,
      dbFile.path,
    ]);
    db = ContentDatabase(NativeDatabase(dbFile));
    repo = MockBlueprintRepo(db);
  });

  tearDownAll(() async {
    await db.close();
    fixtureDirectory.deleteSync(recursive: true);
  });

  test('the export carries the unscored personal-information items', () {
    final blueprints = {
      for (final bp in exported['mockBlueprint']! as List<Object?>)
        (bp! as Map<String, Object?>)['_id']: bp as Map<String, Object?>,
    };
    expect(blueprints['mock_blueprint_cse_pro']!['unscoredItems'], 15);
    expect(blueprints['mock_blueprint_cse_sub']!['unscoredItems'], 20);
  });

  Future<List<BlueprintSection>> sectionsOf(
    String examId, {
    required String id,
    required int minutes,
    required int? published,
  }) async {
    final blueprints = await repo.byExam(examId);
    expect(blueprints, hasLength(1));
    final bp = blueprints.single;
    expect(bp.id, id);
    expect(bp.durationMinutes, minutes);
    // One booklet with one clock: nothing may print a per-part limit.
    expect(bp.sectionalTiming, SectionalTiming.roamable);
    expect(bp.totalPublishedItems, published);
    expect(bp.source, BlueprintSource.reported);
    expect(bp.sourceNote, contains('weights'));
    return BlueprintSection.parseList(bp.sectionsJson);
  }

  void expectEvenWeights(BlueprintSection s, String exam) {
    for (final topicId in s.topicIds) {
      expect(topicId, startsWith('topic_${exam}_'));
    }
    final weights = s.topicWeights.values.toList();
    expect(weights.reduce((a, b) => a + b), closeTo(1, 1e-9));
    // Numerical Ability leans on arithmetic: the bank has only 20 CSE algebra
    // questions, and an even split would ask for 23.
    if (s.id == 'sec_cse_pro_numerical_ability') {
      expect(s.topicWeights, {
        'topic_cse_pro_arithmetic_number_sense': 0.6,
        'topic_cse_pro_algebra': 0.4,
      });
      return;
    }
    for (final w in weights) {
      expect(w, closeTo(1 / weights.length, 1e-9));
    }
  }

  test('CSE Professional uses the examinee counts and 190 minutes', () async {
    final sections = await sectionsOf(
      'exam_cse_pro',
      id: 'mock_blueprint_cse_pro',
      minutes: 190,
      published: null,
    );
    expect(
      {for (final s in sections) s.name: s.questionCount},
      {
        'General Information': 20,
        'Verbal Ability': 55,
        'Analytical Ability': 35,
        'Numerical Ability': 45,
      },
    );
    expect(sections.fold<int>(0, (n, s) => n + s.questionCount), 155);
    expect(sections.every((s) => s.sectionalMinutes == null), isTrue);
    for (final s in sections) {
      expectEvenWeights(s, 'cse_pro');
    }
    final bp = (await repo.byExam('exam_cse_pro')).single;
    expect(bp.sourceNote, contains('19 October 2026'));
    expect(bp.sourceNote, contains('Aedwon'));
  });

  test('CSE Subprofessional is an even placeholder split of 145', () async {
    final sections = await sectionsOf(
      'exam_cse_sub',
      id: 'mock_blueprint_cse_sub',
      minutes: 160,
      published: null,
    );
    expect(sections.map((s) => s.name), [
      'Verbal Ability',
      'Numerical Ability',
      'Clerical Ability',
      'General Information',
    ]);
    expect(sections.map((s) => s.questionCount), [36, 36, 36, 37]);
    expect(sections.every((s) => s.sectionalMinutes == null), isTrue);
    for (final s in sections) {
      expectEvenWeights(s, 'cse_sub');
    }
    final bp = (await repo.byExam('exam_cse_sub')).single;
    expect(bp.sourceNote, contains('Placeholder'));
    expect(bp.sourceNote, contains('2020'));
  });
}

Future<void> _runDartTool(List<String> arguments) async {
  final result = await Process.run('dart', arguments);
  expect(
    result.exitCode,
    0,
    reason: result.stdout.toString() + result.stderr.toString(),
  );
}
