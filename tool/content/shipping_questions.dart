import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// A shipping question and its source, shared by all ledger tools.
class ShippingQuestion {
  ShippingQuestion(this.id, this.subject, this.file, this.question, this.meta);
  final String id;
  final String subject;
  final File file;
  final YamlMap question;
  final YamlMap meta;
}

List<ShippingQuestion> allQuestionsForApproval(String contentRoot) {
  final directory = Directory(p.join(contentRoot, 'questions'));
  if (!directory.existsSync()) {
    throw const FormatException('questions directory missing');
  }
  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.yaml'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final questions = <ShippingQuestion>[];
  final ids = <String>{};
  for (final file in files) {
    final doc =
        loadYaml(file.readAsStringSync(), sourceUrl: file.uri) as YamlMap;
    final meta = doc['meta'] as YamlMap;
    for (final raw in doc['questions'] as YamlList) {
      final question = raw as YamlMap;
      final id = question['id'] as String;
      if (!ids.add(id)) throw FormatException('duplicate question id: $id');
      questions.add(
        ShippingQuestion(
          id,
          p.split(p.relative(file.path, from: directory.path)).first,
          file,
          question,
          meta,
        ),
      );
    }
  }
  return questions;
}

/// Only the pool excludes inactive questions and pending figures.
List<ShippingQuestion> shippingQuestions(String contentRoot) =>
    allQuestionsForApproval(contentRoot).where((entry) {
      final question = entry.question;
      final figure = question['figure'];
      return question['isActive'] != false &&
          !(figure != null &&
              '$figure'.trim().isNotEmpty &&
              question['figureSpec'] == null);
    }).toList();

/// An enabled problem type with a committed variant list.
class ShippingProblemType {
  ShippingProblemType(this.file, this.variants, this.data);
  final File file;
  final File variants;
  final YamlMap data;
  String get id => data['id'] as String;
}

/// Held types live outside types/ and never enter the approval gate.
List<ShippingProblemType> activeProblemTypes(String contentRoot) {
  final directory = Directory(p.join(contentRoot, 'types'));
  if (!directory.existsSync()) return [];
  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (file) =>
            file.path.endsWith('.yaml') &&
            !file.path.endsWith('.variants.yaml'),
      )
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  final result = <ShippingProblemType>[];
  final ids = <String>{};
  for (final file in files) {
    final data =
        loadYaml(file.readAsStringSync(), sourceUrl: file.uri) as YamlMap;
    if (data['enabled'] != true) continue;
    final variants = File('${p.withoutExtension(file.path)}.variants.yaml');
    if (!variants.existsSync()) continue;
    final entry = ShippingProblemType(file, variants, data);
    if (!entry.id.startsWith('qt-') || !ids.add(entry.id)) {
      throw FormatException(
        'invalid or duplicate problem type id: ${entry.id}',
      );
    }
    result.add(entry);
  }
  return result;
}
