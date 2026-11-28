// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:yaml/yaml.dart';

import '../lib/src/generate.dart';
import '../lib/src/model.dart';
import '../lib/src/rules/rule.dart';

void main(List<String> args) {
  exitCode = runGenerate(args);
}

/// Returns a process status; injectable registry keeps example rules test-only.
int runGenerate(List<String> args, {Map<String, Rule>? rules}) {
  try {
    final options = <String, String>{};
    for (var i = 0; i < args.length; i++) {
      final key = args[i];
      if (!['--type', '--count', '--seed'].contains(key) ||
          options.containsKey(key) ||
          i + 1 >= args.length) {
        throw const FormatException(
          'Expected --type <path> --count <n> [--seed <n>]',
        );
      }
      options[key] = args[++i];
    }
    final path = options['--type'];
    final count = int.tryParse(options['--count'] ?? '');
    final seed =
        options.containsKey('--seed') ? int.tryParse(options['--seed']!) : null;
    if (path == null ||
        !path.endsWith('.yaml') ||
        count == null ||
        count < 0 ||
        (options.containsKey('--seed') && seed == null)) {
      throw const FormatException(
        'Expected YAML type, nonnegative count and integer seed',
      );
    }
    final type = parseProblemType(_yamlMap(File(path).readAsStringSync()));
    final output = File('${path.substring(0, path.length - 5)}.variants.yaml');
    final before = output.existsSync() ? output.readAsStringSync() : null;
    final doc = generateVariants(
      type,
      count: count,
      seed: seed,
      rules: rules,
      existing: before == null ? null : parseVariantList(_yamlMap(before)),
    );
    final text = writeVariantList(doc);
    // Never rewrite existing bytes, including human formatting, during refill.
    final previous = before == null ? null : parseVariantList(_yamlMap(before));
    if (previous != null && previous.variants.length == doc.variants.length) {
      return 0;
    }
    var result = text;
    if (before != null && previous!.variants.isNotEmpty) {
      final oldCanonical = writeVariantList(previous);
      result = before +
          (before.endsWith('\n') ? '' : '\n') +
          text.substring(oldCanonical.length);
    }
    if (parseVariantList(_yamlMap(result)) != doc) {
      throw const FormatException(
        'Refill requires the generated block-list format',
      );
    }
    final staging = output.parent.createTempSync('.generator-');
    final temporary = File('${staging.path}/variants.yaml');
    try {
      temporary
        ..writeAsStringSync(result, flush: true)
        ..renameSync(output.path);
    } finally {
      staging.deleteSync(recursive: true);
    }
    return 0;
  } on Object catch (error) {
    stderr.writeln('Generation failed: $error');
    return 1;
  }
}

Map<Object?, Object?> _yamlMap(String text) {
  final value = loadYaml(text);
  if (value is! Map) throw const FormatException('Expected YAML map');
  return value.cast<Object?, Object?>();
}
