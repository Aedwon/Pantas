---
_id: "lesson-algebra-coin-and-digit-problems"
title: "Coin and Digit Problems"
summary: "Use count, value, and place value to solve coin and digit problems."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 6
partCount: 6
ordering: 70
keyPoints:
  - "Use separate equations for coin count and value."
  - "Write a two-digit number as ten times its tens digit plus its units digit."
---
## Core Concept

### Coin Count and Coin Value

**Coin problems** use two separate equations: one for how many coins there are (**count**) and one for how much money they are worth (**value**).

For the value equation, multiply each coin's count by its peso value and add them up.

Find how many of each coin Lito has from the coin total and the total value. He has $20$ coins made of $5$-peso and $10$-peso coins, worth $160$ pesos in all. Let $f$ be the number of $5$-peso coins and $t$ be the number of $10$-peso coins.

$$f+t=20$$

$$5f+10t=160$$

Multiply the count equation by $5$ so $f$ matches: $5f+5t=100$. Subtract it from the value equation:

$$5t=160-100$$

$$5t=60$$

$$t=12$$

Then $f=20-12=8$. There are $8$ five-peso coins and $12$ ten-peso coins.

:::pair #missing-coin-value
Right: count is $f+t=20$, and value is $5f+10t=160$
Wrong: $5f+10t=20$
Keep count and value in separate equations. Because $5f+10t$ gives total pesos, the right side must be $160$ pesos, not the $20$-coin count.
:::

:::check
A purse has $12$ coins made of $5$-peso and $20$-peso coins, worth $135$ pesos in all. How many pesos are in $5$-peso coins?
:::answer
The answer is $35$ pesos. With $x$ five-peso and $y$ twenty-peso coins, $x+y=12$ and $5x+20y=135$. Multiplying the first by $5$ and subtracting gives $15y=75$, so $y=5$ and $x=12-5=7$. The $5$-peso coins are worth $5\times7=35$ pesos.
:::

### Place Value in Two-Digit Numbers

A **digit** is a single symbol from $0$ through $9$. In a two-digit number with tens digit $t$ and units digit $u$, the tens digit counts groups of $10$, so the number's value is:

$$10t+u$$

Reversing the digits swaps $t$ and $u$, giving the new value:

$$10u+t$$

The original tens digit cannot be $0$. If the reversed number must also have two digits, the original units digit cannot be $0$ either.

Find the number from its digit sum and the link between its digits. The tens digit is twice the units digit, and the digits add up to $12$. Let $u$ be the units digit, so $t=2u$.

$$2u+u=12$$

$$3u=12$$

$$u=4$$

Then $t=2(4)=8$, and the number is:

$$10(8)+4=84$$

:::why
Why multiply $t$ by $10$? In $84$, the digit $8$ sits in the tens place, so it stands for $80$, not $8$. Adding $t+u$ gives $8+4=12$, which is only the sum of the digits.
:::

:::pair #reversed-digits
Right: tens digit $t=8$ and units digit $u=4$ gives $10(8)+4=84$
Wrong: $48$
Keep track of which letter stands for the tens digit and which stands for the units digit. Putting $4$ in the tens place reverses the number.
:::

## Examples

### #1: Solving a Coin Problem

A jar contains $1$-peso and $5$-peso coins. There are $20$ coins in all, worth $52$ pesos. How many $5$-peso coins are there?

**Solution:**

1. Let $x$ be the number of $1$-peso coins and $y$ be the number of $5$-peso coins.
2. Write the count equation.

$$x+y=20$$

3. Write the value equation in pesos.

$$x+5y=52$$

4. Subtract the count equation from the value equation to cancel $x$.

$$4y=52-20=32$$

5. Divide both sides by $4$.

$$y=8$$

There are $8$ five-peso coins.

### #2: Reversing a Two-Digit Number

The sum of the digits of a two-digit number is $9$. When the digits are reversed, the new number is $27$ more than the original. Find the original number.

**Solution:**

1. Let $t$ be the tens digit and $u$ be the units digit.
2. Write the digit-sum equation.

$$t+u=9$$

3. Subtract the original number from the reversed number.

$$(10u+t)-(10t+u)=27$$

4. Distribute the minus sign and combine like terms.

$$9u-9t=27$$

5. Divide both sides by $9$.

$$u-t=3$$

6. Add this equation to $t+u=9$ to cancel $t$.

$$2u=9+3=12$$

$$u=6$$

7. Use $t+u=9$ to find $t$.

$$t=9-6=3$$

:::try
Finish the last step: use $u=6$ and $t=3$ to write the original two-digit number.
:::answer
The answer is $36$. Using $10t+u$, $10(3)+6=36$.
:::

## Traps to Watch For

:::checklist
- Coin equations: keep total coins on the count equation and total pesos on the value equation. {#missing-coin-value}
- Two-digit number value: multiply the tens digit by $10$, as in $10t+u$, instead of adding the digits. {#place-value-in-two-digit-numbers}
- Writing the final number: check which digit is tens and which is units so you do not reverse them. {#reversed-digits}
:::
