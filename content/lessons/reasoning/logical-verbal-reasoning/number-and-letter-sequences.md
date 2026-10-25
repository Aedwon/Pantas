---
_id: "lesson-logical-verbal-reasoning-number-and-letter-sequences"
title: "Number and Letter Sequences"
summary: "Number and letter sequences use simple rules such as repeated changes, alternating operations, interleaving, and recurrence."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **sequence** is a list of numbers or letters in an order. A sequence question asks you to find a missing or next term by spotting the intended rule.

A short list can fit more than one possible rule. In an exam question, look for a simple rule that fits every shown term and the answer choices.

Start with these common number patterns:

- **Arithmetic:** add or subtract the same amount each time, as in $2,5,8,11,\ldots$.
- **Geometric:** multiply by the same number each time, as in $3,6,12,24,\ldots$. That multiplier is called the **ratio**. Here, ratio means the number you multiply by each time.
- **Changing differences:** the amount added or subtracted changes in a simple pattern.
- **Interleaved:** odd positions follow one rule and even positions follow another.
- **Alternating operations:** the operation changes back and forth, such as multiply, then add, then multiply, then add.
- **Recurrence:** a new term is built from one or two earlier terms.

To test an interleaved pattern, label the positions $1,2,3,4,5,6,\ldots$. Read positions $1,3,5,\ldots$ as one list and positions $2,4,6,\ldots$ as another. Keep this rule only if both smaller lists have clear patterns.

To test alternating operations, write the operation between each pair of terms. If the operations repeat in a cycle, apply the next operation in that cycle.

To test a recurrence, check whether one or two earlier terms can be added, subtracted, or multiplied to make each new term. Test the same rule on more than one new term.

The **Fibonacci pattern** is a common recurrence. In $1,1,2,3,5,\ldots$, each new term is the sum of the two terms before it. To continue it, add the two most recent terms.

For letter sequences, turning letters into alphabet positions can reveal a number pattern. Use $A=1$, $B=2$, and continue through $Z=26$.

Some letter sequences use words instead of alphabet positions. The letters may be the first letters of words in a known group, or they may follow the spelling of number words. A wraparound pattern keeps moving after $Z$ by starting again at $A$.

Use the rule that fits the evidence in the question. Do not force alphabet positions when a word, spelling, or wraparound rule fits better.

## Examples

### #1: Arithmetic Pattern

Find the intended next term: $4,9,14,19,\ldots$

**Solution:**

1. Each term increases by $5$.
2. Add $5$ to the last term.

$$19+5=24$$

The next term is $24$.

### #2: Geometric Pattern

Find the intended next term: $2,6,18,54,\ldots$

**Solution:**

1. Each term is multiplied by $3$, so the ratio is $3$.
2. Apply the same multiplier again.

$$54\times3=162$$

The next term is $162$.

### #3: Changing Differences

Find the intended next term: $2,3,5,8,12,\ldots$

**Solution:**

1. The increases are $+1,+2,+3,+4$.
2. The next increase should be $+5$.

$$12+5=17$$

The next term is $17$.

### #4: Letter Positions

Find the intended next letter: $B,D,G,K,\ldots$

**Solution:**

1. Convert to positions: $2,4,7,11$.
2. The increases are $+2,+3,+4$.
3. Continue with $+5$.

$$11+5=16$$

4. The letter at position $16$ is **P**.

### #5: Interleaved Odd and Even Positions

Find the intended next term: $2,9,4,12,6,15,\ldots$

**Solution:**

1. Read the odd positions as one list: $2,4,6$. They increase by $2$.
2. Read the even positions as another list: $9,12,15$. They increase by $3$.
3. The next term is in an odd position, so continue the odd-position rule.

$$6+2=8$$

The next term is $8$.

### #6: Earlier-Term Recurrence

Find the intended next term: $1,2,2,4,8,32,\ldots$

**Solution:**

1. Starting with the third term, each term is the product of the two terms before it.
2. Check the rule again: $2\times4=8$ and $4\times8=32$.
3. Multiply the last two shown terms.

$$8\times32=256$$

The next term is $256$.

### #7: Fibonacci Recurrence

Find the intended next term: $1,1,2,3,5,8,\ldots$

**Solution:**

1. Each term after the first two is the sum of the two terms before it.
2. Add the last two shown terms.

$$5+8=13$$

The next term is $13$.

### #8: Alternating Operations

Find the intended next term: $3,6,8,16,18,36,\ldots$

**Solution:**

1. Write the moves between terms. They repeat: multiply by $2$, then add $2$.
2. The last move was multiplication by $2$, so the next move is addition by $2$.

$$36+2=38$$

The next term is $38$.

### #9: Spelling Pattern

Find the intended next letter: O, T, T, F, F, S, S, E, $\ldots$

**Solution:**

1. Read the letters as the first letters of the number words: one, two, three, four, five, six, seven, eight.
2. The next number word is nine, which starts with **N**.

The next letter is **N**.

### #10: Word-Group Pattern

Find the intended next letter: M, T, W, T, F, S, $\ldots$

**Solution:**

1. The letters are the first letters of the days from Monday through Saturday.
2. The next day is Sunday, which starts with **S**.

The next letter is **S**.

### #11: Wraparound Letter Pattern

Find the intended next letter: W, Y, A, C, $\ldots$

**Solution:**

1. Move forward by $2$ letters each time. After $Y$, moving $2$ letters passes $Z$ and starts again at $A$.
2. Apply the same move after C.

The next letter is **E**.

## Speed Tricks & Shortcuts

**Check the easy rules first.** Try the same amount added or subtracted, then the same multiplier. If neither works, test changing differences, odd and even positions, alternating operations, or a recurrence.

**Write the operations between terms.** A row such as $\times2,+2,\times2,+2$ can make an alternating rule easy to see.

**Split an interleaved sequence by position.** Read the first, third, and fifth terms as one list. Read the second, fourth, and sixth terms as another.

**For letters, use positions only when they help.** If positions do not give a clean rule, check word groups, spelling, or a wraparound cycle.

## Traps to Watch For

### #1: Assuming Only One Rule Can Exist

> A short sequence can match more than one possible rule.

Choose the simple rule that fits every term and the answer choices. Do not build a needlessly complicated rule.

### #2: Stopping After One Match

> A rule that works once may fail later.

Check every shown transition. One bad step means the rule is not the intended one.

### #3: Missing an Interleaved Pattern

> Odd and even positions may follow separate rules.

If the full list looks irregular, split it by position before giving up. Both smaller lists should follow clear rules.

### #4: Missing Alternating Operations

> The operation may switch back and forth.

Write the operation between each pair of terms. A repeating operation pattern can appear quickly.

### #5: Forgetting Earlier Terms in a Recurrence

> Some sequences use the last two terms, not only the last one.

Check whether adding or combining earlier terms creates each new term. Test the rule more than once before using it.

### #6: Forcing Letter Positions

> Not every letter pattern is a number pattern.

Use alphabet positions when they reveal a clean rule. If they do not, look for a word group, spelling pattern, or wraparound cycle instead.
