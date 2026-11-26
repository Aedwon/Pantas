---
_id: "lesson-arithmetic-number-sense-fibonacci-type-sequence-terms"
title: "Fibonacci-Type Sequence Terms"
summary: "Find Fibonacci-type terms by adding the previous two terms."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 9
partCount: 9
ordering: 36
keyPoints:
  - 'Find Fibonacci-type terms by adding the previous two terms.'
---
## Core Concept

A **sequence** is an ordered list of numbers called **terms**. A **series** is a sum of terms from a sequence. The dots at the end of a list mean that it continues.

### How Fibonacci-Type Sequences Work

In a **Fibonacci-type sequence**, each term after the first two is the sum of the two terms right before it. For any three neighboring terms $x,y,z$ in that order:

$$z=x+y$$

The classic Fibonacci sequence starts $1,1,2,3,5,8,\dots$ (or $0,1,1,2,3,5,\dots$). A Fibonacci-type sequence can start with any two numbers and follow the same add-the-last-two rule.

Suppose a Fibonacci-type sequence starts $2,5$. Find its fifth term step by step.

1. Term $3$ adds terms $1$ and $2$.

$$2+5=7$$

2. Term $4$ adds terms $2$ and $3$.

$$5+7=12$$

3. Term $5$ adds terms $3$ and $4$.

$$7+12=19$$

The sequence is $2,5,7,12,19,\dots$, so the fifth term is $19$.

:::pair #stop-at-earlier-term
Right: Term $5$ is $7+12=19$.
Wrong: Term $4$ is $5+7=12$.
Write the position number next to each new term so you do not stop at term $4$ when the question asks for term $5$.
:::

:::pair #double-instead-of-add-prior-two
Right: Term $5$ is $7+12=19$.
Wrong: Term $5$ is $2\times12=24$.
Do not double the previous term. Always add the two terms right before the one you want.
:::

:::check
A Fibonacci-type sequence starts $3,4$. What is its sixth term?
:::answer
The answer is $29$. Write the terms in order: $3,4,7,11,18,29$.
:::

### Working Backward by Subtraction

Because $z=x+y$, knowing two neighboring terms $y$ and $z$ lets you subtract to step backward: $x=z-y$.

Suppose the fourth term is $29$ and the fifth term is $47$. Find the second term.

1. Term $3+$ Term $4=$ Term $5$, so subtract Term $4$ from Term $5$ to get Term $3$.

$$47-29=18$$

2. Term $2+$ Term $3=$ Term $4$, so subtract Term $3$ from Term $4$ to get Term $2$.

$$29-18=11$$

The second term is $11$.

:::why
Why does working backward use subtraction? Each forward step adds the earlier term to the middle term, so subtracting the middle term from the later term undoes that addition and recovers the earlier term.
:::

:::pair #add-instead-of-work-backward
Right: Term $3$ is $47-29=18$, then term $2$ is $29-18=11$.
Wrong: $29+47=76$
Adding $29+47$ moves forward to term $6$. When the question asks for an earlier term, subtract instead of adding.
:::

:::check
In a Fibonacci-type sequence, the third term is $10$ and the fourth term is $16$. What is the first term?
:::answer
The answer is $4$. Subtract to get the second term ($16-10=6$), then subtract again to get the first term ($10-6=4$).
:::

### Combining Like Terms with Variables

Sometimes the terms of a Fibonacci-type sequence contain a letter such as $a$. A **coefficient** is the number multiplying a variable. In $2a$, the coefficient of $a$ is $2$.

To add two expressions with the same variable, add their coefficients together and add their plain numbers together.

Add $2a+3$ and $a+5$:

$$(2a+3)+(a+5)=(2+1)a+(3+5)=3a+8$$

:::check
If $x=a+4$ and $y=2a-1$ are two consecutive terms of a Fibonacci-type sequence, what is the next term?
:::answer
The answer is $3a+3$. Combine coefficients and plain numbers: $(1+2)a+(4-1)=3a+3$.
:::

## Examples

### #1: Fibonacci-Type Sequence with Variables

If $x,y,z$ are three consecutive terms of a Fibonacci-type sequence in that order, $x=2a+1$, and $y=3a-2$, what is $z$ in terms of $a$?

**Solution:**

1. Write the Fibonacci-type rule for three neighboring terms.

$$z=x+y$$

2. Substitute $x=2a+1$ and $y=3a-2$.

$$z=(2a+1)+(3a-2)$$

3. Group the $a$-terms together and the plain numbers together.

:::try
Finish the last step: add the coefficients of $a$ and combine the plain numbers to find $z$.
:::answer
The answer is $5a-1$. Combining gives $z=(2+3)a+(1-2)=5a-1$.

**Check:** Test with a sample number, such as $a=3$. Then $x=2(3)+1=7$ and $y=3(3)-2=7$, so $z=7+7=14$. Plug $a=3$ into $5a-1$: $5(3)-1=14$. Both match.
:::

## Traps to Watch For

:::checklist
- Counting forward to a requested position: label each position ($3,4,5$) so you do not stop one term early. {#stop-at-earlier-term}
- Finding the next Fibonacci-type term: add the previous two terms, never double the last term ($7+12=19$). {#double-instead-of-add-prior-two}
- Asked for an earlier term when given later terms: step backward by subtracting, not adding ($47-29=18$). {#add-instead-of-work-backward}
:::
