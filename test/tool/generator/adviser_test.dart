// ignore_for_file: avoid_relative_lib_imports
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import 'check_support.dart';
import 'check_test.dart' show fixture;
import 'figure_check_test.dart' show asVariant, figureData, figureType;
import 'support.dart';

void main() {
  setUp(registerTestSolvers);
  tearDown(() {
    mathSolvers.clear();
    figureSolvers.clear();
    mistakeSolvers.clear();
  });
  test('figure stem with text choices passes independent checking', () {
    final type =
        parseProblemType(figureType().toMap()..['choiceKind'] = 'text');
    final data = figureData();
    for (final choice
        in (data['choices']! as List).cast<Map<String, Object?>>()) {
      choice.remove('figure');
    }
    figureSolvers['testFigure'] = TextFigureSolver('Three right');
    mistakeSolvers[('testFigure', 'short')] =
        (type, variant) => <String, Object?>{'text': 'Two right'};
    expect(checkVariants(type, [asVariant(data)]), isEmpty);
    figureSolvers['alternate'] = TextFigureSolver('Two right');
    expect(
      checkVariants(type, [asVariant(data)]).any(
        (f) => f.check == 'correctness' && f.reason.contains('library'),
      ),
      isTrue,
    );
  });
  test('choiceKind is required and limited to figure or text', () {
    for (final kind in [null, 'mixed', 1]) {
      final data = mathTypeData()..['choiceKind'] = kind;
      expect(() => parseProblemType(data), throwsFormatException);
    }
    expect(parseProblemType(mathTypeData()).choiceKind, 'text');
    expect(figureType().choiceKind, 'figure');
  });
  test('generation owns the canonical parameter hash and cosmetics', () {
    final type = parseProblemType(mathTypeData());
    final doc = generateVariants(
      type,
      count: 2,
      seed: 17,
      rules: {'testAdd': AddRule()},
    );
    final first = doc.variants.first;
    final params = TestMathSolver().ruleParams(type, first);
    expect(
      first.ruleKey,
      sha256.convert(utf8.encode(dataKey(params))).toString(),
    );
    expect(first.cosmetics, isEmpty);
    expect(
      writeVariantList(doc),
      writeVariantList(
        generateVariants(
          type,
          count: 2,
          seed: 17,
          rules: {'testAdd': AddRule()},
        ),
      ),
    );
    expect(AddRule().generate(type, Random(17), 0).ruleParams, params);
  });
  test('planted ruleKey mismatch fails independently', () {
    final failures =
        checkVariants(parseProblemType(mathTypeData()), fixture('rule-key'));
    expect(failures.any((f) => f.check == 'ruleKey'), isTrue);
  });
  test('planted text choice with a figure fails', () {
    expect(
      checkVariants(
        parseProblemType(mathTypeData()),
        fixture('text-choice-figure'),
      ).any((f) => f.check == 'choiceKind'),
      isTrue,
    );
  });
  test('planted figure choice without a figure fails', () {
    expect(
      checkVariants(figureType(), fixture('figure-choice-missing'))
          .any((f) => f.check == 'choiceKind'),
      isTrue,
    );
  });
  test('planted inconsistent cosmetics fails', () {
    expect(
      checkVariants(figureType(), fixture('cosmetics'))
          .any((f) => f.check == 'cosmetics'),
      isTrue,
    );
  });
  test('cosmetics round-trip and differ only between variants', () {
    final data = figureData()..['cosmetics'] = {'fill': 'white'};
    final shown = data['figureSpec']! as Map<String, Object?>;
    shown['items'] = [
      {'x': 1, 'y': 0, 'fill': 'white'},
    ];
    final choices = (data['choices']! as List).cast<Map<String, Object?>>();
    for (final choice in choices) {
      choice['figure'] = <String, Object?>{
        ...choice['figure']! as Map<String, Object?>,
        'fill': 'white',
      };
    }
    final variant = asVariant(data);
    expect(asVariant(variant.toMap()).cosmetics, {'fill': 'white'});
    expect(
      TestFigureSolver(3).validateCosmetics(figureType(), variant),
      isEmpty,
    );
  });
  test('rule metadata is required and cosmetics are deeply immutable', () {
    for (final key in ['ruleKey', 'cosmetics']) {
      final data = figureData()..remove(key);
      expect(() => asVariant(data), throwsFormatException);
    }
    final variant = asVariant(figureData()..['cosmetics'] = {'fill': 'white'});
    expect(() => variant.cosmetics['fill'] = 'black', throwsUnsupportedError);
  });
  test('figure choice requires a nonblank description', () {
    expect(
      checkVariants(figureType(), fixture('figure-choice-blank'))
          .any((f) => f.check == 'choiceKind'),
      isTrue,
    );
  });
  test('checker uses the registered per-kind ignore list', () {
    final first = figureData();
    final second = figureData()
      ..['index'] = 1
      ..['signature'] = 'other';
    (first['figureSpec']! as Map<String, Object?>)['label'] = 'A';
    (second['figureSpec']! as Map<String, Object?>)['label'] = 'B';
    signatureIgnore['generic-test'] = ['label'];
    addTearDown(() => signatureIgnore.remove('generic-test'));
    expect(
      checkVariants(figureType(), [asVariant(first), asVariant(second)])
          .any((f) => f.check == 'signature'),
      isTrue,
    );
  });
  test('per-kind signature ignore list removes nested label permutations', () {
    final first = figureData();
    final second = figureData();
    (first['figureSpec']! as Map<String, Object?>)['label'] = 'A';
    (second['figureSpec']! as Map<String, Object?>)['label'] = 'B';
    expect(
      canonicalSignature(asVariant(first)),
      isNot(canonicalSignature(asVariant(second))),
    );
    const ignored = {
      'generic-test': ['label'],
    };
    expect(
      canonicalSignature(asVariant(first), ignore: ignored),
      canonicalSignature(asVariant(second), ignore: ignored),
    );
  });
}

class TextFigureSolver extends TestFigureSolver {
  TextFigureSolver(this.text) : super(3);
  final String text;

  @override
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  ) =>
      candidate['text'] == text;
}
