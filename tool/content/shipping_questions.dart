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

List<ShippingQuestion> shippingQuestions(String contentRoot) {
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
      // Mirrors tools/build_content_export/build_content_export.dart:515-560:
      // figure-pending questions do not ship. Also honor explicit inactivity.
      final figure = question['figure'];
      if (question['isActive'] == false ||
          (figure != null &&
              '$figure'.trim().isNotEmpty &&
              question['figureSpec'] == null)) {
        continue;
      }
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
