import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/walkthrough_giveaway_check.dart';
import '../../../tool/content/lesson_checks.dart';

void main() {
  // Real text from history, trimmed. Each sample is the Check or try that
  // failed an audit; the lines around it are the lines that gave it away.

  // a2b132670 identities-and-like-terms, Check 1 (line 46): the key -9 is
  // printed in the stem.
  const identities = r'''
## Core Concept

### Identity Property

An **identity** is a number that keeps another number unchanged under an operation.

The **additive identity** is $0$: adding $0$ keeps any number unchanged. Add $0$ to $7$ and $-17$:

$$7+0=7$$

$$(-17)+0=-17$$

:::pair #zero-multiplication
Right: $(-17)+0=-17$ and $(-17)(1)=-17$
Wrong: $(-17)+0=-17$ and $(-17)(0)=0$
Adding $0$ keeps $-17$ unchanged, so $0$ is the additive identity.
:::

:::check
Find the value of $x$ that makes $(x+0)(1)=-9$ true.
:::answer
The answer is $-9$. Adding $0$ and multiplying by $1$ leave $-9$ unchanged.
:::
''';

  // a2b132670 decimal-and-percent-conversions, Example 2 try (line 131):
  // 0.35 and 7/20 are printed above.
  const decimals = r'''
## Core Concept

### Terminating Decimals to Fractions

Try converting $0.05$, $0.35$, and $1.25$:

$$0.35=\dfrac{35}{100}=\dfrac{35\div 5}{100\div 5}=\dfrac{7}{20}$$

## Examples

### #2: Percent to Decimal and Fraction

Express $35\%$ as a decimal and as a fraction in simplest form.

**Solution:**

1. Divide $35$ by $100$ to get the decimal, moving the point $2$ places left.

$$35\div 100=0.35$$

2. Write $35\%$ as a fraction over $100$.

$$35\%=\dfrac{35}{100}$$

:::try
Finish the last step: simplify $\dfrac{35}{100}$ to lowest terms.
:::answer
The answer is $0.35$ and $\dfrac{7}{20}$. Divide both $35$ and $100$ by $5$ to get $\dfrac{7}{20}$.

**Check:** Multiply $\dfrac{7}{20}\times \dfrac{5}{5}=\dfrac{35}{100}=0.35=35\%$.
:::
''';

  // a2b132670 digit-sums-and-six, Example 2 try (line 135): choice B 24,534 is
  // printed in a Right line.
  const digitSums = r'''
## Core Concept

### Rule for $6$

:::pair #ends-in-six-for-six
Right: $24,534$ passes $6$ because it is even and $2+4+5+3+4=18$
Wrong: $24,536$ passes $6$ because it ends in $6$
Only $2$, $5$, and $10$ depend on the last digit alone. For $6$, you must check the digit sum too.
:::

## Examples

### #2: Testing Choices for $6$

A shipping company packs exactly $6$ books per box. Which inventory count can be packed with no books left over?

- A) $24,532$
- B) $24,534$
- C) $24,536$
- D) $24,538$

**Solution:**

1. A number divisible by $6$ must pass the tests for $2$ and $3$.
2. Add the digits of each choice to test $3$.

$$2+4+5+3+4=18$$

:::try
Finish the last step: pick the choice whose digit sum is divisible by $3$.
:::answer
The answer is B, $24,534$. Only $18$ is divisible by $3$ ($18\div3=6$).
:::
''';

  // a2b132670 percentage-change, Check 2 (line 100): "Undefined" is in the
  // pair's Right line. The pair sits in an earlier section here, so only the
  // Right-line scope can catch it.
  const percentChange = r'''
## Core Concept

### Measuring Change from the Original Value

:::pair #percent-from-zero
Right: Undefined, because the starting count is $0$
Wrong: The percentage increase is $100\%$
Going from $0$ to $12$ is not $100\%$. Doubling a nonzero number gives $100\%$ growth, whereas dividing by $0$ has no value.
:::

### When the Original Value Is Zero

If the starting value is $0$, the formula tries to divide by $0$.

:::check
Weekly sales go from $0$ units to $15$ units. Can you compute an ordinary percentage increase?
:::answer
No, it is undefined. Because the starting value is $0$, dividing by $0$ is not allowed.
:::
''';

  // ecc329dd1 aspekto-at-paksa-sa-filipino, Check at line 61: only choice A
  // keeps the verb printed in the sentence.
  const aspekto = '''
## Core Concept

### Bilang ng Paksa at Anyo ng Pandiwa

:::check
Gawing maramihan ang paksa ng "Sumulat ng liham ang mag-aaral" at panatilihin ang tapos na kilos. Alin ang tama?

(A) Sumulat ng liham ang mga mag-aaral.

(B) Sumusulat ng liham ang mga mag-aaral.

(C) Susulat ng liham ang mga mag-aaral.
:::answer
Ang sagot ay **A**: "Sumulat ng liham ang mga mag-aaral." Dinagdagan lamang ng *mga* ang paksa at nanatiling tapos na ang *sumulat*.
:::
''';

  // ecc329dd1 tinutukoy-at-pagmamay-ari-sa-panghalip, try at line 111: the
  // prompt prints the series kayo, ninyo, inyo. See the known-gap test below.
  const tinutukoy = '''
## Core Concept

### Dalawang Karaniwang Ayos ng Pagmamay-ari

1. Pagkatapos ng pag-aari: anyong *ng* (*ko, mo, niya, namin, natin, ninyo, nila*), gaya sa "Ito ang aklat **ko**."
2. Nauuna ang may-ari: anyong *sa* (*akin, iyo, kaniya, amin, atin, inyo, kanila*) nang walang *sa*, gaya sa "**Akin** ang aklat na nasa mesa."

### Nagsasalita, Kausap, Pinag-uusapan, at Tayo Laban sa Kami

2. **Kausap**: *ikaw, ka, mo, iyo* (isa). Kung marami: *kayo, ninyo, inyo*. Ginagamit din ang *kayo, ninyo,* at *inyo* bilang magalang na pantawag sa iisang kausap, tulad ng "Pumasok po **kayo**."

## Examples

### #3: Linya ni Lea

Sinabi ni Lea sa kaibigan niya, "Salamat sa tulong mo." Paano niya ito sasabihin sa kaniyang guro lamang?

:::try
Tapusin ang huling hakbang: punan ang patlang ng buong magalang na anyong *ng* mula sa seryeng *kayo, ninyo, inyo*: "Salamat po sa tulong ___."
:::answer
Ang sagot ay **ninyo**: "Salamat po sa tulong ninyo." Magalang na anyo ito para sa iisang kausap.
:::
''';

  List<String> rulesOf(String id, String markdown) => [
        for (final v in checkWalkthroughGiveaways(id, markdown))
          RegExp(r'\(rule (\w)\)').firstMatch(v.message)!.group(1)!,
      ];

  test('rule c: key -9 printed in its own stem', () {
    final found = checkWalkthroughGiveaways('identities', identities);
    expect(found, hasLength(1));
    expect(found.single.where, 'identities:19');
    expect(found.single.message, contains('(rule c)'));
    expect(found.single.message, contains('-9'));
  });

  test('rule d: 0.35 printed in the same example section', () {
    final found = checkWalkthroughGiveaways('decimals', decimals);
    expect(found, hasLength(1));
    expect(found.single.where, 'decimals:25');
    expect(found.single.message, contains('(rule d)'));
    expect(found.single.message, contains('0.35'));
  });

  test('rule d: choice B 24,534 printed in a Right line', () {
    final found = checkWalkthroughGiveaways('digits', digitSums);
    expect(found, hasLength(1));
    expect(found.single.where, 'digits:29');
    expect(found.single.message, contains('(rule d)'));
    expect(found.single.message, contains('24534'));
    expect(found.single.message, contains('24,534'));
  });

  test('rule d: the word answer "undefined" printed in a Right line', () {
    final found = checkWalkthroughGiveaways('percent', percentChange);
    expect(found, hasLength(1));
    expect(found.single.where, 'percent:15');
    expect(found.single.message, contains('(rule d)'));
    expect(found.single.message, contains('undefined'));
  });

  test('rule b: only choice A keeps the verb printed in the prompt', () {
    final found = checkWalkthroughGiveaways('aspekto', aspekto);
    expect(found, hasLength(1));
    expect(found.single.where, 'aspekto:5');
    expect(found.single.message, contains('(rule b)'));
    expect(found.single.message, contains('Sumulat ng liham ang mga'));
  });

  test('known gap: the printed series in the tinutukoy try is not caught', () {
    // Round 8 flagged this try because the prompt prints kayo, ninyo, inyo and
    // names the form (ng) of the only one that fits. The lesson prints each of
    // the three forms in some list, so no rule that stays free of false alarms
    // can tell ninyo apart. Kept as a test so a later change sees the gap.
    expect(checkWalkthroughGiveaways('tinutukoy', tinutukoy), isEmpty);
  });

  test('rule a: a full choice sentence printed above, word for word', () {
    const md = '''
## Core Concept

### Plural Subjects

Right: She walks to school every day.

:::check
Which sentence is correct?

(A) She walks to school every day.

(B) She walk to school every day.
:::answer
The answer is A. The subject is singular.
:::
''';
    // The same copy also makes A the only choice with its words printed.
    expect(rulesOf('copy', md), ['a', 'b']);
  });

  test('numbers compare by value: 7,200 equals 7200, 0.40 equals 0.4', () {
    const thousands = r'''
## Core Concept

### Money

Right: The total is Php $7,200$.

:::check
A shop sells Php $3,600$ of rice and Php $3,600$ of beans. What is the total?
:::answer
The answer is Php $7200$.
:::
''';
    expect(rulesOf('t', thousands), ['d']);
    const decimal = r'''
## Core Concept

### Rates

Right: As a decimal, $0.40$.

:::check
Write $\dfrac{2}{5}$ as a decimal.
:::answer
The answer is $0.4$.
:::
''';
    expect(rulesOf('d', decimal), ['d']);
    const fraction = r'''
## Core Concept

### Fractions

Right: The result is $\frac{7}{20}$.

:::check
Simplify $\dfrac{35}{100}$.
:::answer
The answer is $\dfrac{7}{20}$.
:::
''';
    expect(rulesOf('f', fraction), ['d']);
  });

  // The two false alarms found by tuning over the 55 Math lessons at
  // a2b132670 (Nov 27). In each, the key is printed above only as a number
  // being worked on, not as a result, so a student cannot copy it.
  test('no alarm: the key is an operand in a Right line (work-rate, a2b132670)',
      () {
    const md = r'''
## Core Concept

### Turning Time Into a Work Rate

:::pair #average-work-times
Right: $\dfrac{1}{6}+\dfrac{1}{3}=\dfrac{1}{2}$ wall per hour, so $t=2$ hours
Wrong: $\dfrac{6+3}{2}=4.5$ hours
Never average solo times.
:::

:::check
Worker A can build a fence in $6$ hours, and Worker B can build the same fence in $6$ hours. What is their combined rate, and how many hours will they take together?
:::answer
The answer is $\dfrac{1}{3}$ fence per hour, and $3$ hours.
:::
''';
    expect(checkWalkthroughGiveaways('work-rate', md), isEmpty);
  });

  test(
      'no alarm: the key is a given before "of" in a Right line '
      '(percentage-base, a2b132670)', () {
    const md = r'''
## Core Concept

### Percentage Part, Rate, and Base

:::pair #wrong-percentage-base
Right: $40\%$ of a set is $72$ -> base $=180$, so $15\%$ of the set $=0.15\times180=27$
Wrong: $15\%$ of the set $=0.15\times72=10.8$
Find the base before taking another percent.
:::

## Examples

### #2: Fraction Division to Find a Rate

What percent of $\dfrac{5}{8}$ is $\dfrac{1}{4}$?

$$\text{Rate}=\dfrac{8}{20}=\dfrac{2}{5}=0.40$$

:::try
Finish the last step: change the decimal rate $0.40$ to a percent.
:::answer
The answer is $40\%$. Multiply $0.40\times100\%=40\%$.
:::
''';
    expect(checkWalkthroughGiveaways('percentage-base', md), isEmpty);
  });

  test('passes a fresh check whose key is printed nowhere above', () {
    const md = r'''
## Core Concept

### Discounts

Find the $25\%$ discount on a Php $800$ bag:

$$\text{Discount}=800\times0.25=200$$

:::check
A jacket is listed at Php $1,200$ with a $15\%$ discount. What do you pay?
:::answer
The answer is Php $1,020$. You still pay $85\%$.
:::
''';
    expect(checkWalkthroughGiveaways('fresh', md), isEmpty);
  });

  test('hidden answers and why bodies do not count as printed', () {
    const md = r'''
## Core Concept

### Discounts

:::why
Why? Because $1,020$ is what remains.
:::

:::check
A jacket is listed at Php $1,200$ with a $15\%$ discount. What do you pay?
:::answer
The answer is Php $1,020$.
:::

:::check
A coat is listed at Php $2,400$ with a $15\%$ discount. What do you pay?
:::answer
The answer is Php $2,040$. Not the first answer, Php $1,020$.
:::
''';
    expect(checkWalkthroughGiveaways('hidden', md), isEmpty);
  });

  test('a key that cannot be read is skipped', () {
    const md = r'''
## Core Concept

### Discounts

Right: The total is Php $7,200$.

:::check
Is the total Php $7,200$?
:::answer
Yes, that is correct. Add the two parts.
:::
''';
    expect(checkWalkthroughGiveaways('skip', md), isEmpty);
  });

  test('a pick-from-stem question is not a rule c giveaway', () {
    const md = r'''
## Core Concept

### Six

:::check
Which of $3,412$ and $3,414$ is divisible by $6$?
:::answer
The answer is $3,414$. Both are even.
:::
''';
    expect(checkWalkthroughGiveaways('pick', md), isEmpty);
  });

  test('registered in run_checks.dart and lesson_checks.dart', () {
    expect(
      File('tool/checks/run_checks.dart').readAsStringSync(),
      contains('WalkthroughGiveawayCheck(),'),
    );
    final root = Directory.systemTemp.createTempSync('walkthrough-giveaway-');
    try {
      File('${root.path}/lessons/general/topic/part.md')
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(
          '---\n_id: lesson-topic-part\npart: 1\nkeyPoints: [One]\n---\n'
          '$identities',
        );
      final messages =
          runLessonChecks(root.path).map((v) => v.message).toList();
      expect(messages, contains(contains('giveaway (rule c)')));
    } finally {
      root.deleteSync(recursive: true);
    }
  });
}
