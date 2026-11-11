// The content the checks read: build/export.json when present, otherwise the
// content tree. Only what the checks need.
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class BlueprintRow {
  const BlueprintRow(this.id, this.examId, this.sections);

  final String id;
  final String examId;
  final List<BlueprintSectionRow> sections;
}

class BlueprintSectionRow {
  const BlueprintSectionRow(this.id, this.topicIds);

  final String id;
  final List<String> topicIds;
}

class QuestionRow {
  const QuestionRow({
    required this.id,
    required this.topicId,
    required this.examIds,
    required this.stem,
  });

  final String id;
  final String topicId;
  final Set<String> examIds;

  /// Stem text, with a bold span written as `**word**` from either source.
  final String stem;
}

class ContentSnapshot {
  const ContentSnapshot({required this.blueprints, required this.questions});

  factory ContentSnapshot.load(String root) {
    final export = File('$root/build/export.json');
    return export.existsSync()
        ? ContentSnapshot.fromExport(
            jsonDecode(export.readAsStringSync()) as Map<String, dynamic>,
          )
        : ContentSnapshot.fromTree(root);
  }

  factory ContentSnapshot.fromExport(Map<String, dynamic> export) {
    String ref(Object? value) =>
        (value! as Map<dynamic, dynamic>)['_ref'] as String;
    bool active(Map<dynamic, dynamic> row) => row['isActive'] != false;
    return ContentSnapshot(
      blueprints: [
        for (final row
            in (export['mockBlueprint'] as List).cast<Map<dynamic, dynamic>>())
          if (active(row))
            BlueprintRow(
              row['_id'] as String,
              ref(row['exam']),
              _sections(row['sections'] as List),
            ),
      ],
      questions: [
        for (final row
            in (export['question'] as List).cast<Map<dynamic, dynamic>>())
          if (active(row))
            QuestionRow(
              id: row['_id'] as String,
              topicId: ref(row['topic']),
              examIds: {for (final exam in row['examIds'] as List) ref(exam)},
              stem: _stemText(row['stem'] as List),
            ),
      ],
    );
  }

  factory ContentSnapshot.fromTree(String root) {
    final questions = <QuestionRow>[];
    for (final file in _yamlIn('$root/content/questions')) {
      final doc = loadYaml(file.readAsStringSync()) as Map<dynamic, dynamic>;
      final meta = doc['meta'] as Map<dynamic, dynamic>;
      final topic = (meta['topic'] as String).replaceAll('-', '_');
      for (final row in (doc['questions'] as List? ?? const [])
          .cast<Map<dynamic, dynamic>>()) {
        if (row['isActive'] == false) continue;
        questions.add(
          QuestionRow(
            id: row['id'] as String,
            topicId: 'topic_upcat_$topic',
            examIds: {
              for (final exam in meta['exams'] as List? ?? const [])
                'exam_${(exam as String).replaceAll('-', '_')}',
            },
            stem: row['stem'] as String? ?? '',
          ),
        );
      }
    }
    return ContentSnapshot(
      blueprints: [
        for (final file in _yamlIn('$root/content/mock'))
          ...() {
            final doc =
                loadYaml(file.readAsStringSync()) as Map<dynamic, dynamic>;
            return [
              if (doc['isActive'] != false)
                BlueprintRow(
                  doc['_id'] as String,
                  doc['exam'] as String,
                  _sections(doc['sections'] as List),
                ),
            ];
          }(),
      ],
      questions: questions,
    );
  }

  final List<BlueprintRow> blueprints;
  final List<QuestionRow> questions;

  static List<BlueprintSectionRow> _sections(List<dynamic> sections) => [
        for (final section in sections.cast<Map<dynamic, dynamic>>())
          BlueprintSectionRow(
            section['id'] as String,
            (section['topicIds'] as List).cast<String>().toList(),
          ),
      ];

  static String _stemText(List<dynamic> blocks) => [
        for (final block in blocks.cast<Map<dynamic, dynamic>>())
          [
            for (final span in (block['children'] as List? ?? const []))
              ((span as Map<dynamic, dynamic>)['marks'] as List? ?? const [])
                      .contains('strong')
                  ? '**${span['text']}**'
                  : span['text'] as String? ?? '',
          ].join(),
      ].join('\n');

  static Iterable<File> _yamlIn(String path) => Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.yaml'));
}
