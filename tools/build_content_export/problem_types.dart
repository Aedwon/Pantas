import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../../tool/generator/lib/src/check/check.dart' show fillSlots;
import '../../tool/generator/lib/src/model.dart';

typedef ExportRow = Map<String, Object?>;

({
  List<ExportRow> records,
  Map<String, bool> mergedActivity,
}) exportProblemTypes(String root, Map<String, String> topicIds) {
  final records = <ExportRow>[];
  final mergedActivity = <String, bool>{};
  final ids = <String>{};
  final directory = Directory('$root/content/types');
  if (!directory.existsSync()) {
    return (records: records, mergedActivity: mergedActivity);
  }
  final files = directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where(
        (file) =>
            file.path.endsWith('.yaml') &&
            !file.path.endsWith('.variants.yaml'),
      )
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
    final type = parseProblemType(yaml);
    if (!ids.add(type.id)) {
      throw FormatException('Duplicate problem type ${type.id}');
    }
    final relative = file.path.substring(directory.path.length + 1);
    final topic = topicIds[relative.split(Platform.pathSeparator)[1]];
    if (topic == null) {
      throw FormatException('${type.id}: unknown topic');
    }
    final listFile =
        File(file.path.replaceFirst(RegExp(r'\.yaml$'), '.variants.yaml'));
    final list =
        parseVariantList(loadYaml(listFile.readAsStringSync()) as YamlMap);
    final variants = list.variants;
    if (list.problemType != type.id ||
        list.ruleVersion != type.ruleVersion ||
        variants.isEmpty) {
      throw FormatException('${type.id}: invalid variant list');
    }
    for (var index = 0; index < variants.length; index++) {
      if (variants[index].index != index) {
        throw FormatException('${type.id}: expected variantIndex $index');
      }
    }
    for (final alias in type.mergedQuestions) {
      if (alias.index >= variants.length ||
          variants[alias.index].source != alias.id ||
          mergedActivity.containsKey(alias.id)) {
        throw FormatException(
            '${type.id}: invalid merged question ${alias.id}');
      }
      mergedActivity[alias.id] = !type.enabled;
    }
    final question = <String, Object?>{
      'id': type.id,
      'lesson': type.lesson,
      'topic': topic,
      'keyPoint': type.keyPoint,
      'difficulty': type.difficulty,
      'exams': type.exams,
      'type': type.format,
      'language': yaml['language'] as String? ?? 'en',
      'questionVersion': 1,
      'isActive': type.enabled,
      'variantCount': variants.length,
      'choiceKind': type.choiceKind,
      'showQuestionFigure': yaml['showQuestionFigure'] as bool? ?? true,
      'mergedQuestions': [
        for (final alias in type.mergedQuestions)
          {'id': alias.id, 'variantIndex': alias.index},
      ],
    };
    final free = <String, Object?>{
      'id': type.id,
      'exams': type.exams,
      'variants': [
        for (final variant in variants) _renderVariant(type, variant)
      ],
    };
    final notes = {
      for (final mistake in type.mistakes) mistake.id: mistake.note
    };
    final pro = {
      'rationales': {
        for (final variant in variants)
          '${variant.index}': [
            for (final choice in variant.choices)
              if (choice.correct)
                null
              else
                fillSlots(
                  notes[choice.mistake] ??
                      (throw FormatException(
                        '${type.id}: unknown mistake ${choice.mistake}',
                      )),
                  {...variant.slots, ...choice.slots},
                ),
          ],
      },
    };
    // The uploader uses a 16-character digest. Include JSON string escaping
    // and the wrapper fields in the same size check before writing any export.
    final bytes = utf8
        .encode(jsonEncode({
          'kind': 'variants',
          'id': type.id,
          'version': '0000000000000000',
          'payload': jsonEncode(free),
        }))
        .length;
    if (bytes >= 200000) {
      throw FormatException(
          '${type.id}: Free variant document is $bytes bytes, limit 200,000');
    }
    records.add({'question': question, 'free': free, 'pro': pro});
  }
  return (records: records, mergedActivity: mergedActivity);
}

ExportRow _renderVariant(ProblemType type, Variant variant) => {
      'variantIndex': variant.index,
      'ruleKey': variant.ruleKey,
      'stem': fillSlots(type.stem, variant.slots),
      'explanation': fillSlots(type.explanation, variant.slots),
      if (variant.figureSpec case final figure?) 'figureSpec': figure,
      'choices': [
        for (final choice in variant.choices)
          {
            'text': fillSlots(choice.text, {...variant.slots, ...choice.slots}),
            'correct': choice.correct,
            if (choice.figure case final figure?) 'figure': figure,
          },
      ],
    };
