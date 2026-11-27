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

Test $4,218$ and $5,742$ for $3$ and $9$.

$$4+2+1+8=15$$

Since $15\div3=5$, $4,218$ is divisible by $3$. Since $15$ is not divisible by $9$, $4,218$ is not divisible by $9$.

$$5+7+4+2=18$$

Since $18\div9=2$, $5,742$ is divisible by $9$ (and by $3$ as well).

Every multiple of $9$ is also a multiple of $3$, because $9=3\times3$. Passing the test for $3$ does not mean a number passes the test for $9$.

:::pair #three-instead-of-nine
Right: for $57x81$ to pass $9$, $21+x$ must equal $27$, giving $x=6$
Wrong: for $57x81$ to pass $9$, $21+x=24$ works, giving $x=3$
The sum $24$ passes $3$, not $9$. Check that your digit sum divides evenly by $9$ when the problem asks for $9$.
:::

:::why
Why does adding digits work for $3$ and $9$? Take a nonnegative whole number. Notice that $10=9+1$, $100=99+1$, and $1,000=999+1$. Each place value leaves a remainder of $1$ when divided by $9$ or $3$, so the number leaves the same remainder as its digit sum. To test a negative integer for divisibility, ignore the minus sign.
:::

:::check
The number $6,3d4$ is divisible by $3$, where $d$ is a digit. List every possible value of $d$.
:::answer
The answer is $d=2$, $5$ or $8$. The digit sum is $13+d$, which is from $13$ to $22$. The multiples of $3$ there are $15$, $18$ and $21$.
:::

### Rule for $6$

Since $6=2\times3$, a number is divisible by $6$ exactly when it passes **both** tests:

1. It is even (last digit is $0$, $2$, $4$, $6$, or $8$).
2. Its digit sum is divisible by $3$.

Passing only one test is not enough. Also, ending in the digit $6$ does not make a number divisible by $6$.

Test $2,514$, $2,516$, and $2,517$ for $6$:

- $2,514$: even, and $2+5+1+4=12$ (divisible by $3$). Passes $6$.
- $2,516$: even, and $2+5+1+6=14$ (not divisible by $3$). Fails $6$.
- $2,517$: odd, even though $2+5+1+7=15$ passes $3$. Fails $6$.

:::pair #ends-in-six-for-six
Right: $24,534$ passes $6$ because it is even and $2+4+5+3+4=18$
Wrong: $24,536$ passes $6$ because it ends in $6$
The tests for $2$, $5$, and $10$ use the last digit alone. For $6$, you must check the digit sum too.
:::

When the missing digit is in the middle of a multiple of $6$, it does not need to be even. Only the last digit decides whether the number is even.

:::pair #only-even-middle-digit
Right: in $42d18$, the last digit $8$ passes the test for $2$. The digit sum $15+d$ passes $3$ exactly for $d=0,3,6,9$
Wrong: in $42d18$, $d$ must be even, so the greatest choice is $d=8$
The last digit $8$ already satisfies the $2$ test. With $d=8$ the digit sum is $4+2+8+1+8=23$, which fails $3$. Any digit from $0$ to $9$ that makes the digit sum a multiple of $3$ works for $d$.
:::

## Examples

### #1: Finding a Missing Digit for $9$

The five-digit number $47x81$ is divisible by $9$. What is the value of the digit $x$?

**Solution:**

1. Add the digits of $47x81$. Since $x$ is a single digit from $0$ to $9$, the sum goes from $20$ to $29$. The only multiple of $9$ in that range is $27$.

$$4+7+x+8+1=20+x=27$$

2. Subtract $20$ from both sides.

$$x=27-20$$

$$x=7$$

The digit is $7$.

### #2: Testing Choices for $6$

A shipping company packs exactly $6$ books per box. Which inventory count can be packed with no books left over?

- A) $36,418$
- B) $36,420$
- C) $36,422$
- D) $36,424$

**Solution:**

1. A number divisible by $6$ must pass the tests for $2$ and $3$. All four choices end in an even digit, so every choice passes the test for $2$.
2. Add the digits of each choice to test $3$. Choice A first.

$$3+6+4+1+8=22$$

Since $22$ is not divisible by $3$, choice A fails.

:::try
Finish the last step: add the digits of B, C and D, then pick the choice that is divisible by $6$.
:::answer
The answer is B, $36,420$. The digit sums are $15$, $17$ and $19$ for B, C and D. Only $15$ is divisible by $3$ ($15\div3=5$).
:::

## Speed Tricks & Shortcuts

### Cast Out Nines

When testing divisibility by $3$ or $9$, cross out any digit $9$ and any group of digits that adds to $9$, then add what is left.

Test $945,712$. Cross out $9$, then $4+5=9$, then $7+2=9$. Only $1$ remains. Since $1$ is divisible by neither $3$ nor $9$, $945,712$ passes neither test.

## Traps to Watch For

:::checklist
- Testing a digit sum for $9$: the sum must divide by $9$, not only by $3$. {#three-instead-of-nine}
- Testing divisibility by $6$: check both evenness and the digit sum for $3$, even if the number ends in $6$. {#ends-in-six-for-six}
- Finding a missing middle digit for $6$: only the last digit must be even, so odd middle digits like $3$ or $9$ are allowed. {#only-even-middle-digit}
:::
