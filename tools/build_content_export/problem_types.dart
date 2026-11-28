// ignore_for_file: avoid_relative_lib_imports
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../../tool/generator/lib/src/check/check.dart' show fillSlots;
import '../../tool/generator/lib/src/model.dart';

typedef ExportRow = Map<String, Object?>;

/// The exam that D-P1 reserves: type rows serve its practice and review but
/// stay out of its mock until the PSHS-NCE content lane confirms the format.
/// Flipping this one set changes the mock rule everywhere it is read.
const mockReservedExams = {'pshs-nce'};

/// The exam tag the export adds to a type whose lesson has PSHS-NCE questions.
const pshsExam = 'pshs-nce';

/// What the question files say, read once per export.
class SourceTags {
  const SourceTags({required this.examsById, required this.pshsLessons});

  /// File-level `meta.exams` of the file holding each question id.
  final Map<String, List<String>> examsById;

  /// Lessons that have at least one served question in a [pshsExam] file.
  final Set<String> pshsLessons;
}

/// Reads the question files under `content/questions`.
SourceTags readSourceTags(String root) {
  final examsById = <String, List<String>>{};
  final pshsLessons = <String>{};
  final directory = Directory('$root/content/questions');
  final files = directory.existsSync()
      ? (directory
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith('.yaml'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path)))
      : <File>[];
  for (final file in files) {
    final doc = loadYaml(file.readAsStringSync());
    if (doc is! YamlMap || doc['meta'] is! YamlMap) continue;
    final meta = doc['meta'] as YamlMap;
    final exams = [
      for (final code in meta['exams'] as YamlList? ?? []) '$code',
    ];
    final questions = doc['questions'];
    if (questions is! YamlList) continue;
    for (final raw in questions) {
      if (raw is! YamlMap) continue;
      final id = raw['id'] as String;
      examsById[id] = exams;
      // The export holds back a question whose picture is not drawn yet.
      final figure = raw['figure'];
      final pending = figure != null &&
          '$figure'.trim().isNotEmpty &&
          raw['figureSpec'] == null;
      if (exams.contains(pshsExam) && !pending) {
        pshsLessons.add(
          raw['lesson'] as String? ??
              'lesson-${meta['topic']}-${meta['subtopic']}',
        );
      }
    }
  }
  return SourceTags(examsById: examsById, pshsLessons: pshsLessons);
}

/// The one place D-P1 lives. A type takes the current file-level exams of the
/// files that hold its merged source questions, in first-seen order, plus
/// [pshsExam] when its lesson has PSHS-NCE questions. A type with no merged
/// source keeps the exams written in its own file.
List<String> problemTypeExams(ProblemType type, SourceTags tags) {
  final exams = <String>[];
  for (final alias in type.mergedQuestions) {
    final fileExams = tags.examsById[alias.id];
    if (fileExams == null) {
      throw FormatException(
        '${type.id}: merged question ${alias.id} is not in content/questions',
      );
    }
    for (final code in fileExams) {
      if (!exams.contains(code)) exams.add(code);
    }
  }
  if (exams.isEmpty) exams.addAll(type.exams);
  if (tags.pshsLessons.contains(type.lesson) && !exams.contains(pshsExam)) {
    exams.add(pshsExam);
  }
  return exams;
}

/// The exams whose mock papers may hold this type row.
List<String> problemTypeMockExams(List<String> exams) => [
      for (final code in exams)
        if (!mockReservedExams.contains(code)) code,
    ];

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
  final tags = readSourceTags(root);
  for (final file in files) {
    final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
    final type = parseProblemType(yaml);
    final exams = problemTypeExams(type, tags);
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
          '${type.id}: invalid merged question ${alias.id}',
        );
      }
      mergedActivity[alias.id] = !type.enabled;
    }
    final question = <String, Object?>{
      'id': type.id,
      'lesson': type.lesson,
      'topic': topic,
      'keyPoint': type.keyPoint,
      'difficulty': type.difficulty,
      'exams': exams,
      'mockExams': problemTypeMockExams(exams),
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
      'exams': exams,
      'variants': [
        for (final variant in variants) _renderVariant(type, variant),
      ],
    };
    final notes = {
      for (final mistake in type.mistakes) mistake.id: mistake.note,
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
        .encode(
          jsonEncode({
            'kind': 'variants',
            'id': type.id,
            'version': '0000000000000000',
            'payload': jsonEncode(free),
          }),
        )
        .length;
    if (bytes >= 200000) {
      throw FormatException(
        '${type.id}: Free variant document is $bytes bytes, limit 200,000',
      );
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
