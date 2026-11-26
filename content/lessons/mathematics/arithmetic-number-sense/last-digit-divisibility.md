---
_id: "lesson-arithmetic-number-sense-last-digit-divisibility"
title: "Last-Digit Divisibility"
summary: "Use the last one, two, or three digits to test divisibility by 2, 4, 8, 5, and 10."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 4
ordering: 24
keyPoints:
  - "Use the last one, two, or three digits to test 2, 4, and 8."
  - "Use the last digit to test 5 and 10."
---
## Core Concept

### Rules for $2$, $4$, and $8$

An integer is **divisible** by a nonzero integer when dividing leaves a remainder of $0$. A **factor** divides a number evenly. A **multiple** is the product of an integer and another integer.

Divisibility rules let you check digits instead of doing long division. For a negative integer, test its positive value, because the minus sign does not change whether the remainder is $0$.

To test $2$, $4$, and $8$, look only at the end of the number:

- **Divisible by $2$:** the last $1$ digit is even ($0$, $2$, $4$, $6$, or $8$).
- **Divisible by $4$:** the number formed by the last $2$ digits is divisible by $4$.
- **Divisible by $8$:** the number formed by the last $3$ digits is divisible by $8$.

If a number has fewer digits than the rule needs, test the whole number.

Try $5,116$. The last digit is $6$ (even), so it passes $2$. The last $2$ digits form $16$, and $16\div4=4$, so $5,116$ passes $4$.

:::pair #add-digits-for-four
Right: for $4,516$, test the last $2$ digits ($16\div4=4$)
Wrong: for $4,516$, add all digits ($4+5+1+6=16$)
Never add digits to test $4$. Read the last $2$ digits together as one two-digit number.
:::

Now test $48,672$ for $8$. Look at the last $3$ digits: $672$.

$$672\div8=84$$

It divides evenly, so $48,672$ is divisible by $8$. What if the hundreds digit were $3$, giving $48,372$? Even though $72$ divides by $8$, $372\div8=46$ with remainder $4$, so $48,372$ fails $8$.

:::pair #last-two-for-eight
Right: for $48,k72$ to pass $8$, test all $3$ ending digits ($k72$)
Wrong: $72$ divides by $8$, so $48,372$ passes $8$
Testing only $72$ checks $4$, not $8$. You must include the hundreds digit when testing for $8$.
:::

:::why
Why can we ignore the front digits? Every $10$ is divisible by $2$, every $100$ is divisible by $4$, and every $1,000$ is divisible by $8$. Everything to the left of those ending digits is already an exact multiple of the divisor.
:::

:::check
Is $7,324$ divisible by $4$? Is it divisible by $8$?
:::answer
The answer is yes for $4$, no for $8$. The last $2$ digits are $24$ ($24\div4=6$), while the last $3$ digits are $324$ ($324=8\times40+4$, remainder $4$).
:::

### Rules for $5$ and $10$

Both $5$ and $10$ depend only on the very last digit.

- **Divisible by $5$:** the last digit is $0$ or $5$.
- **Divisible by $10$:** the last digit is $0$.

Try $735$ and $740$. Both end in $5$ or $0$, so both pass $5$. Only $740$ ends in $0$, so only $740$ passes $10$.

Every multiple of $10$ is also a multiple of $5$, because $10=5\times2$. A number that is divisible by $5$ but *not* by $10$ must end in $5$.

:::pair #ending-zero-passes-ten
Right: divisible by $5$ but not $10$ means the last digit is $5$
Wrong: divisible by $5$ but not $10$ allows a last digit of $0$
A number ending in $0$ passes both $5$ and $10$. When $10$ is ruled out, $0$ is ruled out too.
:::

:::why
Why does only the last digit matter for $5$ and $10$? Every multiple of $10$ is $10$ times a whole number, and $10=5\times2$. So the tens, hundreds, and thousands parts already divide evenly by both $5$ and $10$.
:::

:::check
What single digit from $1$ to $9$ must be added to $6,482$ so the sum is divisible by both $5$ and $10$?
:::answer
The answer is $8$. To pass both $5$ and $10$, the sum must end in $0$, and $6,482+8=6,490$.
:::

## Examples

### #1: Choosing a Digit for $5$ and Not $10$

An inventory count $N$ is a four-digit number $6,47d$ that is a multiple of $5$ but not a multiple of $10$. What is the digit $d$?

**Solution:**

1. A multiple of $5$ ends in $0$ or $5$, so $d$ can only be $0$ or $5$.
2. A multiple of $10$ ends in $0$. Since $N$ is not a multiple of $10$, rule out $d=0$.
3. Only $d=5$ remains, giving $N=6,475$.

The digit is $d=5$.

**Check:** Divide $6,475$ by $5$ and $10$. You get $6,475\div5=1,295$ (no remainder), while $6,475\div10=647.5$ (not a whole number).

### #2: Testing the Last Two and Three Digits

A warehouse packs boxes into crates of $4$ or crates of $8$. Can an order of $5,116$ boxes be packed evenly into crates of $4$? Can it be packed evenly into crates of $8$?

**Solution:**

1. To test $4$, check the number formed by the last $2$ digits of $5,116$, which is $16$.

$$16\div4=4$$

The division is exact, so $5,116$ can be packed evenly into crates of $4$.

2. To test $8$, check the number formed by the last $3$ digits of $5,116$, which is $116$.

:::try
Finish the last step: divide $116$ by $8$ to see if $5,116$ is divisible by $8$.
:::answer
The answer is no for $8$ (and yes for $4$). Dividing $116=8\times14+4$ leaves a remainder of $4$, so $5,116$ is not divisible by $8$.

**Check:** Split $5,116$ into $5,000+116$. Since $1,000$ is divisible by $8$, $5,000$ is $8\times625$, and $116$ is $8\times14+4$. The whole number leaves a remainder of $4$ when divided by $8$.
:::

## Speed Tricks & Shortcuts

Remember $2$, $4$, and $8$ as powers of $2$:

- $2=2^1$: check the last $1$ digit.
- $4=2^2$: check the last $2$ digits.
- $8=2^3$: check the last $3$ digits.

## Traps to Watch For

:::checklist
- Testing divisibility by $4$: read the last $2$ digits as one number, never add the digits together. {#add-digits-for-four}
- Testing divisibility by $8$: check all last $3$ digits, not only the last $2$. {#last-two-for-eight}
- Multiple of $5$ that is not a multiple of $10$: the last digit must be $5$, never $0$. {#ending-zero-passes-ten}
:::
