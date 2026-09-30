import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/features/roadmap/data/topic_prerequisites.dart';

import '../../../../tools/build_content_seed/seed_writer.dart';

void main() {
  late Set<String> shippedTopicIds;

  setUpAll(() async {
    final buildDirectory = Directory('build')..createSync(recursive: true);
    final fixtureDirectory =
        buildDirectory.createTempSync('roadmap_prerequisites_');
    addTearDown(() => fixtureDirectory.deleteSync(recursive: true));
    final export = File('${fixtureDirectory.path}/export.json');
    final seed = File('${fixtureDirectory.path}/content.db');

    final result = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      export.path,
    ]);
    expect(
      result.exitCode,
      0,
      reason: '${result.stdout}${result.stderr}',
    );
    await writeContentSeed(inputJson: export, outputDb: seed);

    final db = ContentDatabase(NativeDatabase(seed));
    try {
      final topics = await db.select(db.contentTopics).get();
      shippedTopicIds = topics.map((topic) => topic.id).toSet();
      expect(shippedTopicIds, isNotEmpty);
    } finally {
      await db.close();
    }
  });

  test('the app prerequisite map contains only valid acyclic links', () {
    _validatePrerequisites(topicPrerequisites, shippedTopicIds);
  });

  test('an empty prerequisite map passes', () {
    _validatePrerequisites(const {}, shippedTopicIds);
  });

  test('an unknown topic key fails with its id', () {
    expect(
      () => _validatePrerequisites(
        const {'topic_unknown': <String>[]},
        shippedTopicIds,
      ),
      throwsA(
        isA<TestFailure>().having(
          (failure) => failure.message,
          'message',
          contains('Unknown topic: topic_unknown'),
        ),
      ),
    );
  });

  test('an unknown prerequisite value fails with its id', () {
    expect(
      () => _validatePrerequisites(
        const {
          'topic_upcat_algebra': ['topic_unknown'],
        },
        shippedTopicIds,
      ),
      throwsA(
        isA<TestFailure>().having(
          (failure) => failure.message,
          'message',
          contains('Unknown prerequisite: topic_unknown'),
        ),
      ),
    );
  });

  test('a self link fails with the topic id', () {
    expect(
      () => _validatePrerequisites(
        const {
          'topic_upcat_algebra': ['topic_upcat_algebra'],
        },
        shippedTopicIds,
      ),
      throwsA(
        isA<TestFailure>().having(
          (failure) => failure.message,
          'message',
          contains('Self link: topic_upcat_algebra'),
        ),
      ),
    );
  });

  test('a cycle fails with the complete cycle path', () {
    expect(
      () => _validatePrerequisites(
        const {
          'topic_upcat_algebra': ['topic_upcat_geometry'],
          'topic_upcat_geometry': ['topic_upcat_trigonometry'],
          'topic_upcat_trigonometry': ['topic_upcat_algebra'],
        },
        shippedTopicIds,
      ),
      throwsA(
        isA<TestFailure>().having(
          (failure) => failure.message,
          'message',
          contains(
            'Prerequisite cycle: topic_upcat_algebra -> '
            'topic_upcat_geometry -> '
            'topic_upcat_trigonometry -> topic_upcat_algebra',
          ),
        ),
      ),
    );
  });

  test('shared prerequisites and disconnected topics pass', () {
    _validatePrerequisites(
      const {
        'topic_upcat_geometry': ['topic_upcat_algebra'],
        'topic_upcat_trigonometry': ['topic_upcat_algebra'],
        'topic_upcat_biology': <String>[],
      },
      shippedTopicIds,
    );
  });
}

void _validatePrerequisites(
  Map<String, List<String>> prerequisites,
  Set<String> shippedTopicIds,
) {
  for (final entry in prerequisites.entries) {
    expect(
      shippedTopicIds,
      contains(entry.key),
      reason: 'Unknown topic: ${entry.key}',
    );
    for (final prerequisite in entry.value) {
      expect(
        shippedTopicIds,
        contains(prerequisite),
        reason: 'Unknown prerequisite: $prerequisite for ${entry.key}',
      );
      expect(
        prerequisite,
        isNot(entry.key),
        reason: 'Self link: ${entry.key}',
      );
    }
  }

  final visiting = <String>{};
  final visited = <String>{};
  final path = <String>[];

  void visit(String topicId) {
    if (visiting.contains(topicId)) {
      final cycle = [...path.sublist(path.indexOf(topicId)), topicId];
      fail('Prerequisite cycle: ${cycle.join(' -> ')}');
    }
    if (visited.contains(topicId)) return;

    visiting.add(topicId);
    path.add(topicId);
    for (final prerequisite in prerequisites[topicId] ?? const <String>[]) {
      visit(prerequisite);
    }
    path.removeLast();
    visiting.remove(topicId);
    visited.add(topicId);
  }

  for (final topicId in prerequisites.keys) {
    visit(topicId);
  }
}
