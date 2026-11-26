---
_id: "lesson-arithmetic-number-sense-digit-sums-and-six"
title: "Digit Sums and Six"
summary: "Use digit sums to test 3 and 9, and combine 2 and 3 to test 6."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 4
ordering: 25
keyPoints:
  - "Use digit sums to test 3 and 9."
  - "Combine the 2 and 3 tests to test 6."
---
## Core Concept

### Rules for $3$ and $9$

To test divisibility by $3$ or $9$, add all the digits of the number.

- **Divisible by $3$:** the sum of all digits is divisible by $3$.
- **Divisible by $9$:** the sum of all digits is divisible by $9$.

If the sum is still large, you can add its digits again.

Try $4,218$ and $5,742$.

$$4+2+1+8=15$$

Since $15\div3=5$, $4,218$ is divisible by $3$. Since $15$ is not divisible by $9$, $4,218$ is not divisible by $9$.

$$5+7+4+2=18$$

Since $18\div9=2$, $5,742$ is divisible by $9$ (and by $3$ as well).

Every multiple of $9$ is also a multiple of $3$, because $9=3\times3$. Passing the test for $3$ does not mean a number passes the test for $9$.

:::pair #three-instead-of-nine
Right: for $57x81$ to pass $9$, $21+x$ must equal $27$, giving $x=6$
Wrong: for $57x81$ to pass $9$, $21+x=24$ works, giving $x=3$
The sum $24$ passes $3$, not $9$. Always check that your digit sum divides evenly by $9$ when the problem asks for $9$.
:::

:::why
Why does adding digits work for $3$ and $9$? Notice that $10=9+1$, $100=99+1$, and $1,000=999+1$. Each place value leaves a remainder of $1$ when divided by $9$ or $3$, so the total remainder equals the sum of the digits.
:::

:::check
Is $6,813$ divisible by $9$?
:::answer
The answer is yes. The digit sum is $6+8+1+3=18$, and $18\div9=2$.
:::

### Rule for $6$

Since $6=2\times3$, a number is divisible by $6$ only when it passes **both** tests:

1. It is even (last digit is $0$, $2$, $4$, $6$, or $8$).
2. Its digit sum is divisible by $3$.

Passing only one test is not enough. Also, ending in the digit $6$ does not make a number divisible by $6$.

Test $2,514$, $2,516$, and $2,517$:

- $2,514$: even, and $2+5+1+4=12$ (divisible by $3$). Passes $6$.
- $2,516$: even, and $2+5+1+6=14$ (not divisible by $3$). Fails $6$.
- $2,517$: odd, even though $2+5+1+7=15$ passes $3$. Fails $6$.

:::pair #ends-in-six-for-six
Right: $24,534$ passes $6$ because it is even and $2+4+5+3+4=18$
Wrong: $24,536$ passes $6$ because it ends in $6$
Only $2$, $5$, and $10$ depend on the last digit alone. For $6$, you must check the digit sum too.
:::

When a middle digit is missing in a multiple of $6$, the missing digit does not need to be even. Only the final digit controls whether the whole number is even.

:::pair #only-even-middle-digit
Right: in $42d18$, $d$ can be $0$, $3$, $6$, or $9$ because the last digit $8$ is already even
Wrong: in $42d18$, $d$ must be even, so $d=9$ is ruled out
The last digit $8$ already satisfies the $2$ test. Any digit from $0$ to $9$ that makes the digit sum a multiple of $3$ works for $d$.
:::

:::check
Which of $3,412$ and $3,414$ is divisible by $6$?
:::answer
The answer is $3,414$. Both are even, and $3+4+1+4=12$ is divisible by $3$, while $3+4+1+2=10$ is not.
:::

## Examples

### #1: Finding a Missing Digit for $9$

The five-digit number $47x81$ is divisible by $9$. What is the value of the digit $x$?

**Solution:**

1. Add the digits of $47x81$.

$$4+7+x+8+1=20+x$$

2. Since $x$ is a single digit from $0$ to $9$, the sum $20+x$ goes from $20$ to $29$. The only multiple of $9$ in that range is $27$.

$$20+x=27$$

3. Subtract $20$ from both sides.

$$x=7$$

The digit is $7$.

**Check:** Replace $x$ with $7$ to get $47,781$. Its digit sum is $4+7+7+8+1=27$, and dividing gives $47,781\div9=5,309$ with no remainder.

### #2: Testing Choices for $6$

A shipping company packs exactly $6$ books per box. Which inventory count can be packed with no books left over?

- A) $24,532$
- B) $24,534$
- C) $24,536$
- D) $24,538$

**Solution:**

1. A number divisible by $6$ must pass the tests for $2$ and $3$. All four choices end in an even digit, so every choice passes the test for $2$.
2. Add the digits of each choice to test $3$.

$$2+4+5+3+2=16$$

$$2+4+5+3+4=18$$

$$2+4+5+3+6=20$$

$$2+4+5+3+8=22$$

:::try
Finish the last step: pick the choice whose digit sum is divisible by $3$.
:::answer
The answer is B, $24,534$. Only $18$ is divisible by $3$ ($18\div3=6$).

**Check:** Divide $24,534\div6=4,089$ boxes with $0$ books left over. None of $16$, $20$, or $22$ divides evenly by $3$.
:::

## Speed Tricks & Shortcuts

### Cast Out Nines

When testing divisibility by $3$ or $9$, cross out any $9$ or any group of digits that adds up to $9$. Only skip groups summing to $9$, never random even digits.

For $945,712$, cross out $9$, then $4+5=9$, then $7+2=9$. Only $1$ remains. Since $1$ is divisible by neither $3$ nor $9$, $945,712$ passes neither test.

## Traps to Watch For

:::checklist
- Testing a digit sum for $9$: the sum must divide by $9$, not only by $3$. {#three-instead-of-nine}
- Testing divisibility by $6$: check both evenness and the digit sum for $3$, even if the number ends in $6$. {#ends-in-six-for-six}
- Finding a missing middle digit for $6$: only the last digit must be even, so odd middle digits like $3$ or $9$ are allowed. {#only-even-middle-digit}
:::
