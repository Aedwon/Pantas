---
_id: "lesson-geometry-logic-and-reasoning"
title: "Logic and Reasoning (Conditional Statements, Converses, Inverses, Contrapositives)"
summary: "How to rewrite if-then statements, test claims, and draw valid conclusions."
subject: "subject-mathematics"
topic: "topic-geometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A **conditional statement** is an if-then sentence: "If $p$, then $q$." The letters stand for statements that can be true or false.

The **hypothesis** ($p$) is the "if" part. The **conclusion** ($q$) is the "then" part. A conditional rules out a true hypothesis with a false conclusion.

To **negate** a statement means to say that it is not true. From one conditional, you can build three new statements:

- **Converse**: swap the parts. "If $q$, then $p$."
- **Inverse**: negate both parts. "If not $p$, then not $q$."
- **Contrapositive**: swap and negate. "If not $q$, then not $p$."

A conditional and its contrapositive always have the same **truth value**: they are true or false together. They are **logically equivalent**, which means they agree in every possible case.

The converse and inverse are also equivalent to each other. They need not match the original conditional. A converse may be true, but the original alone does not prove it.

A **counterexample** is one case with a true hypothesis and a false conclusion. It proves that an "always true" conditional is false. A case with a false hypothesis does not disprove the conditional.

### Biconditionals

A **biconditional** uses "if and only if." The statement "$p$ if and only if $q$" means both "If $p$, then $q$" and "If $q$, then $p$."

To prove a biconditional, check both directions. Proving only one direction is not enough. You can join a conditional and its converse this way only when both are true.

### Drawing Conclusions

For these rules, accept the given statements as true. A **deduction** is a conclusion that must follow from them.

The **Law of Detachment** needs a true conditional and its true hypothesis:

$$p \Rightarrow q,\quad p\quad\therefore q$$

The arrow ($\Rightarrow$) means "if ... then." The symbol $\therefore$ means "therefore." If "If $p$, then $q$" is true and $p$ is true, you may conclude $q$.

Knowing only that $q$ is true does not let you conclude $p$. There may be another reason for $q$ to be true.

The **Law of Syllogism**, also called hypothetical syllogism, joins two true conditionals:

$$p \Rightarrow q,\quad q \Rightarrow r$$

$$\therefore p \Rightarrow r$$

The first conclusion must match the next hypothesis. This gives a new conditional. To conclude that $r$ actually happens, you also need the fact $p$.

## Mnemonics & Memory Aids

To build the contrapositive, remember:

> Flip and negate.

The converse only flips. The inverse only negates. The contrapositive does both.

## Examples

### #1: Naming the Parts

Identify the hypothesis and conclusion: "If a number is divisible by $6$, then it is divisible by $3$."

**Solution:**

1. The hypothesis follows "if": a number is divisible by $6$.
2. The conclusion follows "then": it is divisible by $3$.
3. The conditional is true. Every multiple of $6$, such as $6$, $12$, or $18$, is also a multiple of $3$.

### #2: Writing All Three Forms

Write the converse, inverse, and contrapositive of: "If it is raining, then the ground is wet."

**Solution:**

1. Let $p$ mean "it is raining" and $q$ mean "the ground is wet."
2. Converse: "If the ground is wet, then it is raining."
3. Inverse: "If it is not raining, then the ground is not wet."
4. Contrapositive: "If the ground is not wet, then it is not raining."
5. The contrapositive must have the same truth value as the original. The converse and inverse need not have that truth value.

### #3: Finding a Counterexample

Is this claim always true: "If the ground is wet, then it is raining"?

**Solution:**

1. Consider a sprinkler watering the ground on a day with no rain.
2. The hypothesis is true: the ground is wet. The conclusion is false: it is not raining.
3. This counterexample proves that the claim is not always true.

### #4: Picking the Equivalent Statement

Which statement is logically equivalent to "If a figure is a square, then it has $4$ sides"?

A) If a figure has $4$ sides, then it is a square.

B) If a figure is not a square, then it does not have $4$ sides.

C) If a figure does not have $4$ sides, then it is not a square.

D) A figure has $4$ sides only if it is a square.

**Solution:**

1. Swap the hypothesis and conclusion, then negate both.
2. The contrapositive is "If a figure does not have $4$ sides, then it is not a square."
3. The answer is C. It has the same truth value as the original in every case.

### #5: Chaining Statements and Using a Fact

Assume these statements are true: "If an application is complete, then it is sent for review." "If an application is sent for review, then a tracking number is assigned." Rico's application is complete. What must follow?

<!-- ILLUSTRATION: Statement chain with arrows from application complete to sent for review to tracking number assigned; show Rico's complete application at the start. -->

**Solution:**

1. The first conclusion matches the second hypothesis: the application is sent for review.
2. Use the Law of Syllogism. If an application is complete, then a tracking number is assigned.
3. Rico's application is complete. Use the Law of Detachment with that fact and the new conditional.
4. A tracking number is assigned to Rico's application.

### #6: Proving Both Directions

For an integer $n$, check this statement: "$n$ is even if and only if $n$ is divisible by $2$."

<!-- ILLUSTRATION: Two statements, n is even and n is divisible by 2, connected by arrows in both directions to show the two claims of the biconditional. -->

**Solution:**

1. Check the forward direction. An even integer can be divided into pairs with nothing left over. So it is divisible by $2$.
2. Check the reverse direction. An integer divisible by $2$ has no remainder when split into pairs. So it is even.
3. Both directions are true. The biconditional is true.

## Speed Tricks & Shortcuts

For an equivalent-statement question, first build the contrapositive. Then compare its meaning with the choices. Different wording can express the same statement.

Remember the truth pairs: original with contrapositive, and converse with inverse. If the converse is true, the inverse is true too.

For a chain, match each conclusion to the next hypothesis. Keep the final answer as an if-then statement unless a given fact lets you use detachment.

To test an "always true" claim, look for a counterexample. One case with a true hypothesis and a false conclusion is enough.

## Traps to Watch For

### #1: Believing the Converse

> A true conditional does not prove its converse.

Every square has $4$ sides. A rectangle that is not a square also has $4$ sides. Having $4$ sides alone does not prove that a figure is a square.

### #2: Mixing Up Inverse and Contrapositive

> The inverse only negates. The contrapositive negates and swaps.

Negating both parts without swapping gives the inverse. It need not match the original's truth value. Check that you made both changes when asked for a contrapositive.

### #3: A Bad Counterexample

> A counterexample needs a true hypothesis and a false conclusion.

To disprove "If a number is prime, then it is odd," use $2$. It is prime but not odd. The number $9$ does not work because it is not prime, so the hypothesis is false.

### #4: Starting from the Conclusion

> Detachment starts with a true hypothesis, not just a true conclusion.

"If it rains, then the ground is wet" and "the ground is wet" do not prove that it rains. A sprinkler could have wet the ground. That conclusion would require the converse, which was not given.

### #5: Checking Only Half a Biconditional

> "If and only if" makes two claims.

"If a figure is a square, then it is a rectangle" is true. Its converse is false because some rectangles are not squares. So "a figure is a square if and only if it is a rectangle" is false.
