// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/bin/generate.dart' as cli;
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'support.dart';

void main() {
  late Directory temp;
  late File type;
  late File variants;
  setUp(() {
    temp = Directory.systemTemp.createTempSync('qg-cli-');
    type = File('${temp.path}/qt-test-add.yaml')..writeAsStringSync(_typeYaml);
    variants = File('${temp.path}/qt-test-add.variants.yaml');
  });
  tearDown(() => temp.deleteSync(recursive: true));

  test('CLI writes a list next to the type and refill appends without changes',
      () {
    final rules = <String, Rule>{'testAdd': AddRule()};
    expect(
      cli.runGenerate(
        ['--type', type.path, '--count', '100', '--seed', '17'],
        rules: rules,
      ),
      0,
    );
    final first = variants.readAsStringSync();
    expect(
      cli.runGenerate(['--type', type.path, '--count', '120'], rules: rules),
      0,
    );
    expect(variants.readAsStringSync().startsWith(first), isTrue);
    final doc = parseVariantList(loadYaml(variants.readAsStringSync()) as Map);
    expect(doc.variants, hasLength(120));
    expect(doc.seed, 17);
    expect(doc.tool, 1);
    expect(doc.ruleVersion, 1);
  });

  test('refill refuses a flow-list edit without corrupting the saved file', () {
    final rules = <String, Rule>{'testAdd': AddRule()};
    expect(
      cli.runGenerate(['--type', type.path, '--count', '2'], rules: rules),
      0,
    );
    final doc = parseVariantList(loadYaml(variants.readAsStringSync()) as Map);
    final edited = jsonEncode(doc.toMap());
    variants.writeAsStringSync(edited);
    expect(
      cli.runGenerate(['--type', type.path, '--count', '3'], rules: rules),
      isNot(0),
    );
    expect(variants.readAsStringSync(), edited);
  });

  test('CLI failure leaves existing list untouched', () {
    final rules = <String, Rule>{'testAdd': AddRule()};
    expect(
      cli.runGenerate(['--type', type.path, '--count', '2'], rules: rules),
      0,
    );
    final before = variants.readAsBytesSync();
    expect(
      cli.runGenerate(
        ['--type', type.path, '--count', '3', '--seed', '999'],
        rules: rules,
      ),
      isNot(0),
    );
    expect(variants.readAsBytesSync(), before);
  });

  test('invalid arguments and unknown rules fail without creating output', () {
    for (final args in [
      <String>[],
      ['--type', type.path, '--count', '-1'],
      ['--type', type.path, '--count', '1', '--unknown'],
      ['--type', type.path, '--count', '1', '--count', '2'],
      ['--type', type.path, '--count', '1'],
    ]) {
      expect(cli.runGenerate(args, rules: <String, Rule>{}), isNot(0));
      expect(variants.existsSync(), isFalse);
    }
  });
}

const _typeYaml = '''
id: qt-test-add
lesson: lesson-test-add
keyPoint: 1
difficulty: easy
exams: [cse-pro]
format: word-problem
rule: testAdd
ruleVersion: 1
choiceCount: 4
choiceKind: text
enabled: true
params: {max: 1000000}
stem: What is {a} + {b}?
explanation: Add {a} and {b} to get {answer}.
mistakes: []
mergedQuestions: []
''';
