---
_id: "lesson-arithmetic-number-sense-grouping-and-fraction-bars"
title: "Grouping and Fraction Bars"
summary: "Evaluate nested groups from the inside out."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 3
ordering: 3
keyPoints:
  - 'Evaluate nested groups from the inside out.'
  - 'Treat fraction numerators and denominators as grouped expressions.'
---
## Core Concept

### Nested Grouping Symbols

Grouping symbols tell you which part of an expression to work out first. They include parentheses $()$, square brackets $[]$, curly braces $\{\}$, and fraction bars.

In exam questions, **simplify** means write an equal expression in a simpler form, and **evaluate** means find the final number answer.

When one group sits inside another, work from the innermost group outward. Inside each group, still follow the order of operations: powers and roots, then multiplication and division, then addition and subtraction.

Evaluate the two-layer expression $50-2\times[3+2\times(4-7)^2]$.

Start with the inner parentheses, then apply the exponent:

$$4-7=-3$$

$$(-3)^2=9$$

Next finish inside the square brackets, multiplying before adding:

$$2\times 9=18$$

$$3+18=21$$

Multiply outside, then subtract last:

$$2\times 21=42$$

$$50-42=8$$

Now look at what happens when multiplication sits right next to a squared group, as in $4\times(8-3)^2$.

:::pair #multiply-into-power
Right: $4\times (8-3)^2=4\times 5^2=4\times 25=100$
Wrong: $4\times (8-3)^2=(4\times 5)^2=20^2=400$
The exponent $2$ applies only to the parentheses right before it, not to the $4$ outside. Square $5$ first, then multiply by $4$.
:::

:::check
Evaluate $5\times [30-(1+3)^2]$.
:::answer
The answer is $70$. Do the inner parentheses ($1+3=4$), then the power ($4^2=16$). Subtract inside the brackets ($30-16=14$), then multiply ($5\times 14=70$).
:::

### Fraction Bars as Grouping Symbols

A fraction bar groups the entire top (**numerator**) and the entire bottom (**denominator**) as if each wore its own parentheses:

$$\dfrac{\text{numerator}}{\text{denominator}}=(\text{numerator})\div(\text{denominator})$$

Work out the whole numerator and the whole denominator before dividing. Inside each part, powers and multiplication still go before addition and subtraction. If the bottom is $0$, the fraction is undefined.

Evaluate $\dfrac{4^2+6\times 2}{10-3\times 2}$.

First evaluate the numerator:

$$4^2=16$$

$$6\times 2=12$$

$$16+12=28$$

Next evaluate the denominator:

$$3\times 2=6$$

$$10-6=4$$

Now divide:

$$\dfrac{28}{4}=7$$

:::why
Why can you not divide $48$ by $6$ first in $\dfrac{48}{6+2}$? The whole sum $6+2$ sits below the fraction bar, so the whole sum $8$ is the divisor. Dividing by $6$ first breaks the group apart.
:::

Next, a fraction with a sum on the bottom, $\dfrac{48}{6+2}$.

:::pair #fraction-bar-not-grouped
Right: $\dfrac{48}{6+2}=48\div 8=6$
Wrong: $\dfrac{48}{6+2}=48\div 6+2=8+2=10$
The wrong line treated the fraction bar like an ordinary division sign without parentheses. Finish the full denominator $6+2=8$ before dividing $48$.
:::

:::pair #subtract-inside-denominator
Right: $10-3\times 2=10-6=4$, so $\dfrac{28}{4}=7$
Wrong: $10-3\times 2=7\times 2=14$, so $\dfrac{28}{14}=2$
Order of operations still applies inside a grouped denominator. Multiply $3\times 2=6$ before subtracting from $10$.
:::

## Examples

### #1: Nested Grouping Symbols

Simplify $2[5+3(4-2)^2]-10$.

**Solution:**

1. Start with the innermost parentheses.

$$4-2=2$$

2. Evaluate the exponent on that result.

$$2^2=4$$

3. Multiply inside the brackets.

$$3\times 4=12$$

4. Add inside the brackets.

$$5+12=17$$

5. Multiply by the $2$ outside the brackets.

$$2(17)=34$$

6. Subtract $10$ last.

$$34-10=24$$

The answer is $24$.

### #2: Fraction Bars as Grouping Symbols

What is the value of $\dfrac{3^2+4\times 5}{6-2^3+4}$?

**Solution:**

1. Evaluate the power in the numerator.

$$3^2=9$$

2. Multiply inside the numerator.

$$4\times 5=20$$

3. Add the parts of the numerator.

$$9+20=29$$

4. Evaluate the denominator as one group: power first, then add and subtract from left to right.

$$2^3=8$$

$$6-8=-2$$

$$-2+4=2$$

:::try
Finish the last step: write the value of the fraction $\dfrac{29}{2}$ as a decimal.
:::answer
The answer is $14.5$. Divide the numerator by the denominator: $29\div 2=14.5$.
:::

## Speed Tricks & Shortcuts

When there are no grouping symbols around them, addition and subtraction between terms split a long line into separate pieces. A minus sign stays attached to its number, such as the minus in $-4$. In $5\times 4-3^2+20\div 5$, you can work out the three pieces at once: $5\times 4=20$, $3^2=9$, and $20\div 5=4$.

$$20-9=11$$

$$11+4=15$$

Do this only when you do not break a group or a higher-priority operation.

## Traps to Watch For

:::checklist
- Number outside a squared group: apply the exponent to the group first, then multiply. {#multiply-into-power}
- Expression above or below a fraction bar: finish the whole top and whole bottom before dividing. {#fraction-bar-not-grouped}
- Operations inside a fraction's top or bottom: multiply and divide before adding or subtracting. {#subtract-inside-denominator}
:::
