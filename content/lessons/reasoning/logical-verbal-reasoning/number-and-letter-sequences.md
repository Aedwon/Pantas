---
_id: "lesson-logical-verbal-reasoning-number-and-letter-sequences"
title: "Number and Letter Sequences"
summary: "Number and letter sequences use repeated changes, alternating operations, separate position rules, and earlier terms."
subject: "subject-reasoning"
topic: "topic-logical-verbal-reasoning"
estimatedMinutes: 15
isActive: true
---

## Core Concept

A **sequence** is a list of numbers or letters in an order. Each item is a **term**. A sequence question asks you to find a missing or next term by spotting the intended rule.

A short list can fit more than one rule. Look for a simple rule that fits every shown term and the answer choices.

### Repeated and Changing Moves

An **arithmetic pattern** adds or subtracts the same amount each time. In $2,5,8,11,\ldots$, each move adds $3$.

A **geometric pattern** multiplies by the same number each time. That multiplier is called the **ratio**. In $3,6,12,24,\ldots$, the ratio is $2$.

With **changing differences**, the amount added or subtracted follows its own pattern. Find each difference by subtracting a term from the term after it. Then check how those differences change.

### Separate Rules by Position

In an **interleaved pattern**, odd positions follow one rule and even positions follow another. Odd and even describe the positions, not the values of the terms.

Label the positions $1,2,3,4,5,6,\ldots$. Read positions $1,3,5,\ldots$ as one list and positions $2,4,6,\ldots$ as another. Keep this rule only if both smaller lists have clear patterns.

Next, find which list contains the missing position. Use that list's rule to find the missing term. This approach helps when the moves between neighboring terms do not form a clear pattern.

### Alternating Operations

With **alternating operations**, the move switches back and forth. For example, a rule may multiply by $2$, then add $2$, and repeat.

Write the operation between each pair of terms. Check that the same cycle works through the whole list. Then apply the next operation in the cycle.

Unlike an interleaved pattern, this rule works directly from each term to the next. Try it when neighboring terms show a repeating set of moves.

### Rules Using Earlier Terms

A **recurrence** builds a new term from earlier terms. For example, each new term might be the product of the two terms before it. A product is the result of multiplication.

Check the rule from the first place where enough earlier terms are given. Test it on every later term before using it to continue the list. Do not accept a rule just because it works once.

The **Fibonacci pattern** is a recurrence that adds the two terms before each new term. In $1,1,2,3,5,\ldots$, the sum of $1$ and $1$ gives $2$. Then $1+2=3$, and $2+3=5$.

To continue this pattern, add the two most recent terms. A list can use this same addition rule with different starting terms.

### Letter Patterns

For letter sequences, alphabet positions can reveal a number pattern. Use $A=1$, $B=2$, and continue through $Z=26$. Find the next position, then turn it back into a letter.

Some letter sequences use words instead of alphabet positions. The letters may start words in a known group, such as the days of the week. They may also start number words in order.

A **wraparound pattern** keeps moving after $Z$ by starting again at $A$. Use the rule that fits every term. Do not force alphabet positions when a word or spelling rule fits better.

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

1. Subtract each term from the next to find the increases.

$$3-2=1,\quad 5-3=2$$

$$8-5=3,\quad 12-8=4$$

2. The increases go up by $1$ each time. Use $+5$ next.

$$12+5=17$$

The next term is $17$.

### #4: Letter Positions

Find the intended next letter: B, D, G, K, $\ldots$

**Solution:**

1. Convert each letter to its alphabet position.

$$B=2,\quad D=4$$

$$G=7,\quad K=11$$

2. Find the increases between positions.

$$4-2=2,\quad 7-4=3$$

$$11-7=4$$

3. The increases are $2,3,4$, so continue with $+5$.

$$11+5=16$$

4. The letter at position $16$ is P. The next letter is P.

### #5: Interleaved Odd and Even Positions

Find the intended next term: $2,9,4,12,6,15,\ldots$

**Solution:**

1. Read the odd positions as one list: $2,4,6$. They increase by $2$.
2. Read the even positions as another list: $9,12,15$. They increase by $3$.
3. The missing term is at position $7$. This is an odd position, so continue the odd-position list.

$$6+2=8$$

The next term is $8$. Adding $3$ to $15$ would continue the even-position list, but the missing position is odd.

### #6: Earlier-Term Recurrence

Find the intended next term: $1,2,2,4,8,32,\ldots$

**Solution:**

1. Test whether each term is the product of the two terms before it. Start at the third term.

$$1\times2=2,\quad 2\times2=4$$

2. Check the remaining shown terms.

$$2\times4=8,\quad 4\times8=32$$

3. The rule works throughout. Multiply the last two shown terms.

$$8\times32=256$$

The next term is $256$.

### #7: Fibonacci Recurrence

Find the intended next term: $1,1,2,3,5,8,\ldots$

**Solution:**

1. Each term after the first two is the sum of the two terms before it. Check the later terms.

$$2+3=5,\quad 3+5=8$$

2. Add the last two shown terms.

$$5+8=13$$

The next term is $13$.

### #8: Alternating Operations

Find the intended next term: $3,6,8,16,18,36,\ldots$

**Solution:**

1. Check the moves from the start.

$$3\times2=6,\quad 6+2=8$$

$$8\times2=16,\quad 16+2=18$$

$$18\times2=36$$

2. The moves repeat: multiply by $2$, then add $2$. The last move was multiplication, so add next.

$$36+2=38$$

The next term is $38$.

### #9: Spelling Pattern

Find the intended next letter: O, T, T, F, F, S, S, E, $\ldots$

**Solution:**

1. Read the letters as the first letters of the number words: one, two, three, four, five, six, seven, eight.
2. The next number word is nine, which starts with N.

The next letter is N.

### #10: Word-Group Pattern

Find the intended next letter: M, T, W, T, F, S, $\ldots$

**Solution:**

1. The letters are the first letters of the days from Monday through Saturday.
2. The next day is Sunday, which starts with S.

The next letter is S.

### #11: Wraparound Letter Pattern

Find the intended next letter: W, Y, A, C, $\ldots$

**Solution:**

1. Move forward by $2$ letters each time. From Y, count Z, then A. This follows the same rule as W to Y and A to C.
2. From C, count D, then E.

The next letter is E.

## Traps to Watch For

### #1: Assuming Only One Rule Can Exist

> A short sequence can match more than one rule.

Choose a simple rule that fits every term and the answer choices. A rule that needs a new exception for each term is a poor fit.

### #2: Stopping After One Match

> A rule that works once may fail later.

Check every shown move where the rule applies. In a recurrence, start where enough earlier terms are available. One failed check means you need another rule.

### #3: Splitting by Value Instead of Position

> Odd and even positions are different from odd and even numbers.

In $2,9,4,12,6,15,\ldots$, the odd-position list is $2,4,6$. Grouping the odd values together would give the wrong lists. Label positions before splitting.

### #4: Repeating the Wrong Operation

> An alternating rule needs the correct next move.

After a multiplication step, the cycle may call for addition. Repeating the last operation in Example #8 would give $72$. Track the full cycle before continuing.

### #5: Using Only the Last Term

> A recurrence may need the last two terms.

Adding the most recent difference may fail when each new term comes from two earlier terms. Check the same earlier-term rule throughout the list.

### #6: Forcing Letter Positions

> Not every letter pattern is a number pattern.

Use alphabet positions when they reveal a clear rule. If they do not, check word groups, number spelling, or wraparound. Test the whole list before choosing a letter.
