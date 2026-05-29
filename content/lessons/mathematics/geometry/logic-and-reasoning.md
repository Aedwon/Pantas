---
_id: "lesson-geometry-logic-and-reasoning"
title: "Logic and Reasoning (Conditional Statements, Converses, Inverses, Contrapositives)"
summary: "This lesson teaches you how to rewrite if-then statements and tell which versions must be true."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A **conditional statement** is an if-then sentence: "If $p$, then $q$."

The **hypothesis** ($p$) is the "if" part. The **conclusion** ($q$) is the "then" part.

From one conditional, you can build three new statements:

- **Converse**: swap the parts. "If $q$, then $p$."
- **Inverse**: negate both parts. "If not $p$, then not $q$."
- **Contrapositive**: swap AND negate. "If not $q$, then not $p$."

Here is the most important fact in this lesson. A conditional and its **contrapositive** always have the SAME truth value. They are **logically equivalent**. The converse and the inverse are also equivalent to each other, but NOT to the original.

To prove a statement FALSE, you need a **counterexample**: one case where the hypothesis is true but the conclusion is false. One counterexample kills a statement.

A **biconditional** uses "if and only if". It means the conditional AND its converse are both true.

CETs test this two ways: "write the contrapositive of..." and "which statement is logically equivalent to...". Both become easy with one memory trick below.

## Mnemonics & Memory Aids

To build the contrapositive, remember:

> Flip and negate.

The converse only flips. The inverse only negates. The contrapositive does BOTH, and doing both is what keeps the truth value safe.

## Examples

### #1: Naming the Parts

Identify the hypothesis and conclusion: "If a number is divisible by $6$, then it is divisible by $3$."

**Solution:**
The hypothesis follows "if". The conclusion follows "then".

1. Hypothesis: a number is divisible by $6$.
2. Conclusion: it is divisible by $3$.
3. This conditional is true: every multiple of $6$ (like $6$, $12$, $18$) is also a multiple of $3$.

### #2: Writing All Three Forms

Write the converse, inverse, and contrapositive of: "If it is raining, then the ground is wet."

**Solution:**
Let $p$ be "it is raining" and $q$ be "the ground is wet".

1. Converse (flip): "If the ground is wet, then it is raining."
2. Inverse (negate): "If it is not raining, then the ground is not wet."
3. Contrapositive (flip and negate): "If the ground is not wet, then it is not raining."
4. Only the contrapositive must match the original. If rain always wets the ground, then dry ground truly means no rain.

### #3: Finding a Counterexample

Is the converse in Example $2$ true: "If the ground is wet, then it is raining"?

**Solution:**
Look for one case with a wet ground but no rain.

1. A janitor mops the floor. The ground is wet, but it is not raining.
2. The hypothesis (wet ground) is true, but the conclusion (raining) is false.
3. That single counterexample makes the converse FALSE.
4. Lesson: a true statement can have a false converse. Never assume the converse for free.

### #4: Picking the Equivalent Statement

Which statement is logically equivalent to: "If a figure is a square, then it has four sides"?

**Solution:**
"Logically equivalent" means it is true and false in exactly the same situations. Only the contrapositive qualifies.

1. Flip and negate the original.
2. Contrapositive: "If a figure does not have four sides, then it is not a square."
3. That is the answer. The converse ("If a figure has four sides, then it is a square") is among the choices, and it is false: a rectangle has four sides but is not necessarily a square.

### #5: Chaining Statements (Deductive Reasoning)

Given: "If a student passes the UPCAT, then the student enrolls at UP." and "If a student enrolls at UP, then the student moves to Diliman." Rico passes the UPCAT. What can you conclude?

**Solution:**
Chain the conditionals like dominoes.

1. From the first statement, Rico passing means Rico enrolls at UP.
2. From the second statement, enrolling at UP means Rico moves to Diliman.
3. Conclusion: Rico moves to Diliman.
4. This chain is called the **Law of Syllogism**: if $p$ leads to $q$ and $q$ leads to $r$, then $p$ leads to $r$. Using one true statement plus a matching fact is the **Law of Detachment**.

## Speed Tricks & Shortcuts

For "which is equivalent" questions, do not test each choice with stories. Just build the contrapositive mechanically (flip and negate) and find it among the choices. It is always the answer.

Truth pairs to memorize: the original and contrapositive always match, and the converse and inverse always match. So if a question says the converse is true, the inverse is automatically true too, and you get that answer for free.

To check any "always true" claim, hunt for a counterexample first. Finding one weird case is much faster than proving all cases.

## Traps to Watch For

### #1: Believing the Converse

> A true statement does NOT make its converse true.

"All squares have four sides" is true, but "all four-sided figures are squares" is false. Test-makers state a true conditional and offer the converse as a conclusion. Refuse it unless the problem says "if and only if".

### #2: Mixing Up Inverse and Contrapositive

> The inverse only negates. The contrapositive negates AND swaps.

Students negate both parts, forget to swap them, and pick the inverse thinking it is the contrapositive. The inverse is NOT equivalent to the original. Always do both moves: flip and negate.

### #3: A Bad Counterexample

> A counterexample needs a TRUE hypothesis and a FALSE conclusion.

To disprove "If a number is prime, then it is odd", the counterexample is $2$: prime (hypothesis true) but even (conclusion false). The number $9$ is not a counterexample; it is odd but not prime, so its hypothesis is false and it proves nothing.
