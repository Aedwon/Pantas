import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_fresh_instance_check.dart';
import '../../../tool/content/lesson_checks.dart';

void main() {
  const reusedSentence = '''
## Core Concept

### Present Verbs

With a singular subject, add *-s* to the verb.

- The dog barks every morning.
- The dogs bark every morning.

:::check
Choose the correct verb: The dog *(bark / barks)* every morning.
:::answer
*Barks*. One dog is singular, so add *-s*.
:::
''';

  const freshSentence = '''
## Core Concept

### Present Verbs

With a singular subject, add *-s* to the verb.

- The dog barks every morning.
- The dogs bark every morning.

:::check
Choose the correct verb: My sister *(teach / teaches)* in Cebu.
:::answer
*Teaches*. One person is singular, so add *-es*.
:::
''';

  test('fails when a check stem repeats an example sentence', () {
    final findings = checkWalkthroughFreshInstances('bad', reusedSentence);
    expect(findings, hasLength(1));
    expect(findings.single.where, 'bad:10');
    expect(findings.single.message, contains('the dog barks every morning'));
  });

  test('passes on a fresh instance of the taught rule', () {
    expect(checkWalkthroughFreshInstances('good', freshSentence), isEmpty);
  });

  test('fails when a long stem run repeats earlier prose or a Right line', () {
    const md = '''
## Core Concept

### Agreement

:::pair #head
Right: The basket of apples is heavy today.
Wrong: The basket of apples are heavy today.
The head is *basket*.
:::

:::check
Pick the verb: The basket of apples *(is / are)* heavy today.
:::answer
*Is*.
:::
''';
    final findings = checkWalkthroughFreshInstances('pair', md);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('the basket of apples'));
  });

  test('fails when a check repeats a worked number set, passes when fresh', () {
    const bad = r'''
## Core Concept

### Negative Values

Let's substitute $x=-2$ into $5x-2x^2+10$:

$$5x-2x^2+10=5(-2)-2(-2)^2+10=-8$$

:::check
Find the value of $5x-2x^2+10$ when $x=-2$.
:::answer
The answer is $-8$.
:::
''';
    final findings = checkWalkthroughFreshInstances('math', bad);
    expect(findings, hasLength(1));
    expect(findings.single.message, contains('5x-2x^2+10'));

    final good = bad.replaceFirst(
      r'Find the value of $5x-2x^2+10$ when $x=-2$.',
      r'If $x=-5$, what is the value of $2x-3$?',
    );
    expect(checkWalkthroughFreshInstances('math', good), isEmpty);
  });

  test('a try that finishes the worked chain is not a repeat', () {
    const md = r'''
## Examples

### #1: Two Values

If $a=-3$ and $b=-1$, evaluate $2a^2-ab+b^3$.

**Solution:**

1. Put each answer back.

$$2a^2-ab+b^3=18-3+(-1)$$

:::try
Finish the last step: $18-3+(-1)$.
:::answer
The answer is $14$.
:::
''';
    expect(checkWalkthroughFreshInstances('try', md), isEmpty);
  });

  test('flags a try that reuses a sentence worked in another section', () {
    const md = '''
## Examples

### #1: Verbs

- The list of items on the shelf is long.

### #2: Verbs again

:::try
Choose the verb: The list of items on the shelf *(is / are)* long.
:::answer
*Is*.
:::
''';
    expect(checkWalkthroughFreshInstances('try', md), hasLength(1));
  });

  test('ignores answer text, retired lessons and non walk-through files', () {
    const md = '''
## Core Concept

:::check
Choose the correct verb: My sister *(teach / teaches)* in Cebu.
:::answer
My sister teaches in Cebu. The dog barks every morning.
:::

:::check
Choose the correct verb: The members *(agree / agrees)* on the plan today.
:::answer
Agree.
:::
''';
    expect(checkWalkthroughFreshInstances('ok', md), isEmpty);
    expect(
      checkWalkthroughFreshInstances(
        'plain',
        '## Core Concept\n\n- The dog barks every morning.\n\n'
        'The dog barks every morning.\n',
      ),
      isEmpty,
    );
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
        ...checkWalkthroughFreshInstances(file.path, file.readAsStringSync()),
    ];
    expect(violations, isEmpty);
  });

  test('registered in run_checks.dart and lesson_checks.dart', () {
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      contains('WalkthroughFreshInstanceCheck(),'),
    );
    final root = Directory.systemTemp.createTempSync('walkthrough-fresh-');
    try {
      File('${root.path}/lessons/general/topic/part.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: lesson-topic-part\npart: 1\nkeyPoints: [One]\n---\n'
          '$reusedSentence',
        );
      final messages =
          runLessonChecks(root.path).map((v) => v.message).toList();
      expect(messages, contains(contains('the dog barks every morning')));
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
