import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_example_check_line_check.dart';
import '../../../tool/content/lesson_checks.dart';

void main() {
  const missingCheck = '''
## Core Concept

:::check
Pick one: *(a / b)*.
:::answer
*a*.
:::

## Examples

### #1: A Plain Example

Choose the correct verb: The dog *(bark / barks)* loudly.

**Solution:**

1. The subject is singular.

Correct: "The dog barks loudly."

### #2: Another Example

Choose the correct verb: The dogs *(bark / barks)* loudly.

**Solution:**

1. The subject is plural.

**Check:** Read it aloud: "The dogs bark loudly."

## Traps to Watch For

- Nothing here.
''';

  const checkOutsideAnswer = '''
## Examples

### #1: A Try Example

Choose the correct verb: The list of items *(is / are)* long.

**Solution:**

1. The head is *list*.

:::try
Which verb matches *list*?
:::answer
*Is*.
:::

**Check:** Read the head and the verb alone: "The list is long."
''';

  const good = '''
## Examples

### #1: A Plain Example

Choose the correct verb: The dog *(bark / barks)* loudly.

**Check:** "The dog barks loudly" sounds right.

### #2: A Try Example

Choose the correct verb: The list of items *(is / are)* long.

:::try
Which verb matches *list*?
:::answer
*Is*.

**Check:** Read the head and the verb alone: "The list is long."
:::

## Traps to Watch For

- Nothing here.
''';

  test('fails a ### example with no Check line, naming id, line and case', () {
    final findings = checkWalkthroughExampleCheckLines('bad', missingCheck);
    expect(findings, hasLength(1));
    expect(findings.single.where, 'bad:11');
    expect(findings.single.message, contains('#1: A Plain Example'));
    expect(findings.single.message, contains('no **Check:** line'));
  });

  test('fails a try example whose Check sits outside the answer', () {
    final findings =
        checkWalkthroughExampleCheckLines('try', checkOutsideAnswer);
    expect(findings, hasLength(1));
    expect(findings.single.where, 'try:3');
    expect(findings.single.message, contains('outside'));
    expect(findings.single.message, contains(':::answer'));
  });

  test('fails a try example with no Check anywhere', () {
    final md = checkOutsideAnswer.replaceFirst(
      RegExp(r'\*\*Check:\*\*.*\n'),
      '',
    );
    final findings = checkWalkthroughExampleCheckLines('try', md);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('no **Check:** line'));
  });

  test('passes plain and try examples that carry their Check', () {
    expect(checkWalkthroughExampleCheckLines('good', good), isEmpty);
  });

  test('skips front matter, files without ::: blocks and other headings', () {
    const noBlocks = '## Examples\n\n### #1: Old Style\n\nNo check here.\n';
    expect(checkWalkthroughExampleCheckLines('old', noBlocks), isEmpty);
    const otherSection = '''
---
title: x
---
## Core Concept

### A Heading Without Check

:::check
Q
:::answer
A
:::
''';
    expect(checkWalkthroughExampleCheckLines('other', otherSection), isEmpty);
  });

  test('all samples in docs/content/walkthrough-samples pass', () {
    final files = Directory('docs/content/walkthrough-samples')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.md'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    expect(files, hasLength(4));
    final violations = [
      for (final file in files)
        ...checkWalkthroughExampleCheckLines(
          file.path,
          file.readAsStringSync(),
        ),
    ];
    expect(violations, isEmpty);
  });

  test('registered in run_checks.dart and lesson_checks.dart', () {
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      contains('WalkthroughExampleCheckLineCheck(),'),
    );
    final root = Directory.systemTemp.createTempSync('walkthrough-checkline-');
    try {
      File('${root.path}/lessons/general/topic/part.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: lesson-topic-part\npart: 1\nkeyPoints: [One]\n---\n'
          '$missingCheck',
        );
      final messages =
          runLessonChecks(root.path).map((v) => v.message).toList();
      expect(messages, contains(contains('no **Check:** line')));
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
