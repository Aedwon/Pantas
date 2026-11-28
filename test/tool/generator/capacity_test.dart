// ignore_for_file: avoid_relative_lib_imports
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/bin/capacity.dart' as cli;
import '../../../tool/generator/lib/src/capacity.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'figure_check_test.dart' show asVariant, figureData, figureType;
import 'support.dart';

void main() {
  test('capacity canonicalizes rotated figures and ignored labels', () {
    signatureIgnore['generic-test'] = ['label'];
    addTearDown(() => signatureIgnore.remove('generic-test'));
    final report = measureCapacity(
      figureType(),
      ceiling: 100,
      rules: {'testFigure': EquivalentFigureRule()},
    );
    expect(report.signatures, 1);
    expect(report.ruleKeys, 1);
    expect(report.reachable, isFalse);
  });
  test('capacity enumerates only ceiling draws, without retrying duplicates',
      () {
    final type = parseProblemType({
      ...mathTypeData(),
      'params': {'max': 1},
    });
    final report = measureCapacity(
      type,
      seed: 17,
      rules: {'testAdd': AddRule()},
    );
    expect(report.ruleKeys, 1);
    expect(report.signatures, 1);
    expect(report.reachable, isFalse);
    expect(report.draws, 2000);
  });
  test('fixed seed yields deterministic capacity and reports reachability', () {
    final type = parseProblemType(mathTypeData());
    final rules = {'testAdd': AddRule()};
    final first = measureCapacity(type, ceiling: 100, seed: 17, rules: rules);
    expect(
      first.toString(),
      measureCapacity(type, ceiling: 100, seed: 17, rules: rules).toString(),
    );
    expect(first.reachable, isTrue);
    expect(first.toString(), contains('distinct ruleKeys: 100'));
    expect(first.toString(), contains('distinct signatures: 100'));
    expect(first.toString(), contains('100 reachable: yes'));
  });
  test('capacity CLI reports without creating or changing a variant list', () {
    final temp = Directory.systemTemp.createTempSync('qg-capacity-');
    addTearDown(() => temp.deleteSync(recursive: true));
    final file = File('${temp.path}/type.yaml')
      ..writeAsStringSync(jsonEncode(mathTypeData()));
    final output = <String>[];
    expect(
      cli.runCapacity(
        ['--type', file.path, '--ceiling', '100', '--seed', '17'],
        rules: {'testAdd': AddRule()},
        output: output.add,
      ),
      0,
    );
    expect(output.single, contains('100 reachable: yes'));
    expect(temp.listSync().length, 1);
    for (final args in [
      <String>[],
      ['--type', file.path, '--ceiling', '-1'],
      ['--type', file.path, '--ceiling', 'bad'],
      ['--type', file.path, '--seed', '-1'],
      ['--type', file.path, '--unknown', '1'],
    ]) {
      expect(cli.runCapacity(args, output: output.add), 1);
    }
  });
}

class EquivalentFigureRule implements Rule {
  @override
  String get name => 'testFigure';
  @override
  int get version => 1;

  @override
  RuleResult generate(ProblemType type, Random random, int index) {
    final data = figureData()
      ..['index'] = index
      ..['signature'] = 'supplied-$index';
    final vertical = index.isOdd;
    Map<String, Object?> point(int distance) => {
          'x': vertical ? 0 : distance,
          'y': vertical ? distance : 0,
          'label': 'label-$index',
        };
    data['figureSpec'] = {
      'kind': 'generic-test',
      'items': [point(1)],
    };
    final choices = (data['choices']! as List).cast<Map<String, Object?>>();
    choices[0]['figure'] = point(3);
    choices[1]['figure'] = point(2);
    return RuleResult(
      variant: asVariant(data),
      ruleParams: {'draw': index},
      cosmetics: {},
    );
  }
}
