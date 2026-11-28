// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../lib/src/capacity.dart';
import '../lib/src/model.dart';
import '../lib/src/rules/rule.dart';

void main(List<String> args) {
  exitCode = runCapacity(args);
}

int runCapacity(
  List<String> args, {
  Map<String, Rule>? rules,
  void Function(String)? output,
}) {
  try {
    final options = <String, String>{};
    for (var i = 0; i < args.length; i++) {
      final key = args[i];
      if (!['--type', '--ceiling', '--seed'].contains(key) ||
          options.containsKey(key) ||
          i + 1 >= args.length) {
        throw const FormatException(
          'Expected --type <path> [--ceiling 2000] [--seed <n>]',
        );
      }
      options[key] = args[++i];
    }
    final path = options['--type'];
    final ceiling = int.tryParse(options['--ceiling'] ?? '2000');
    final seed = int.tryParse(options['--seed'] ?? '20261117');
    if (path == null ||
        !path.endsWith('.yaml') ||
        ceiling == null ||
        seed == null ||
        ceiling < 0 ||
        seed < 0) {
      throw const FormatException(
        'Expected YAML type and nonnegative integers',
      );
    }
    final data = loadYaml(File(path).readAsStringSync());
    if (data is! Map) throw const FormatException('Expected YAML map');
    final report = measureCapacity(
      parseProblemType(data),
      ceiling: ceiling,
      seed: seed,
      rules: rules,
    );
    if (output == null) {
      stdout.writeln(report);
    } else {
      output(report.toString());
    }
    return 0;
  } on Object catch (error) {
    stderr.writeln('Capacity failed: $error');
    return 1;
  }
}
