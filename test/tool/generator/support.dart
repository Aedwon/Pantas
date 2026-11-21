// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

Map<String, Object?> mathTypeData() => {
      'id': 'qt-test-add',
      'lesson': 'lesson-test-add',
      'keyPoint': 1,
      'difficulty': 'easy',
      'exams': ['cse-pro'],
      'format': 'word-problem',
      'rule': 'testAdd',
      'ruleVersion': 1,
      'choiceCount': 4,
      'choiceKind': 'text',
      'enabled': true,
      'params': {'max': 1000000},
      'stem': r'What is ${a} + {b}$?',
      'explanation': 'Add {a} and {b} to get {answer}.',
      'mistakes': [
        {
          'id': 'subtract',
          'note': 'This subtracts the numbers. Both numbers are used, '
              'so it may look right. Check the plus sign.',
        },
        {
          'id': 'extra-one',
          'note':
              'This adds one too many. Counting can lead to this extra step. '
                  'Check the total.',
        },
        {
          'id': 'missing-one',
          'note':
              'This leaves out one. Counting can skip a step. Check the total.',
        },
      ],
      'mergedQuestions': <Object?>[],
    };

/// Params: `max` bounds both generated positive slots `a` and `b`.
/// Only test code registers this rule. No real question rule ships in Task 1.1.
class AddRule implements Rule {
  @override
  String get name => 'testAdd';
  @override
  int get version => 1;

  @override
  RuleResult generate(ProblemType t, Random r, int index) {
    final a = r.nextInt(t.params['max']! as int) + 1;
    final b = r.nextInt(t.params['max']! as int) + 1;
    final variant = parseVariants({
      'variants': [
        {
          'index': index,
          for (final merged in t.mergedQuestions)
            if (merged.index == index) 'source': merged.id,
          'slots': {'a': a, 'b': b, 'answer': a + b},
          'choices': [
            {'correct': true, 'text': '${a + b}', 'value': '${a + b}'},
            {'mistake': 'subtract', 'text': '${a - b}', 'value': '${a - b}'},
            {
              'mistake': 'extra-one',
              'text': '${a + b + 1}',
              'value': '${a + b + 1}',
            },
            {
              'mistake': 'missing-one',
              'text': '${a + b - 1}',
              'value': '${a + b - 1}',
            },
          ],
          'ruleKey': 'pending',
          'cosmetics': <String, Object?>{},
          'signature': sha256.convert(utf8.encode('$a,$b')).toString(),
        },
      ],
    }).single;
    return RuleResult(
      variant: variant,
      ruleParams: {'a': a, 'b': b},
      cosmetics: {},
    );
  }
}
