## Core Concept

### Negation Scope in Compound Statements

A negation sign applies only to what sits right after it. When it stands outside parentheses, it flips the value of the whole group; when it stands inside, it flips only the single letter beside it.

Let's evaluate both forms when $P$ is true and $Q$ is false:

$$\neg(P \land Q) = \neg(\text{T} \land \text{F}) = \neg\text{F} = \text{T}$$

$$(\neg P) \land Q = \text{F} \land \text{F} = \text{F}$$

:::why
Why do the two forms differ? The parentheses decide what the negation reaches. Outside, it waits for the whole group to give one value and then flips that value. Inside, it flips $P$ before the group is even formed.
:::

:::pair #negate-wrong-scope
Right: $\neg(P \land Q)$ with $P$ true and $Q$ false gives $\neg\text{F} = \text{T}$
Wrong: $\neg(P \land Q)$ with $P$ true and $Q$ false gives $\text{F} \land \text{F} = \text{F}$
The wrong line moved the negation inside the parentheses and flipped only $P$, so the whole group was never flipped as one value.
:::

:::check
If $P$ is false and $Q$ is true, what is the value of $\neg(P \lor Q)$?
:::answer
The answer is false. First $P \lor Q = \text{F} \lor \text{T} = \text{T}$, then the outside negation flips it:

$$\neg\text{T} = \text{F}$$
:::

### Infinite Geometric Series

An infinite geometric series adds up to one number only when its ratio is between $-1$ and $1$. Then the sum is the first term divided by one minus the ratio.

Let's find the sum of $8 + 4 + 2 + 1 + \dots$, where $a_1 = 8$ and $r = \dfrac{1}{2}$:

$$S_\infty = \dfrac{a_1}{1-r} = \dfrac{8}{1-\dfrac{1}{2}} = \dfrac{8}{\dfrac{1}{2}} = 16$$

:::pair #when-an-infinite-geometric-series-converges
Right: $2 + 4 + 8 + \dots$ has $r = 2$, so it has no sum
Wrong: $2 + 4 + 8 + \dots$ has $S_\infty = \dfrac{2}{1-2} = -2$
The wrong line used the formula without checking $|r| < 1$ first, so it gave a negative sum for a series of growing positive terms.
:::

## Examples

### #1: Seven Moves With Signs

If $x = -2$ and $y = 3$, evaluate $x^2 - 3xy + \dfrac{12}{x}$.

**Solution:**

1. Substitute $x = -2$ and $y = 3$, putting $-2$ in parentheses.

$$x^2 - 3xy + \dfrac{12}{x} = (-2)^2 - 3(-2)(3) + \dfrac{12}{(-2)}$$

2. Do the power. The exponent applies to $-2$, so multiply two negatives.

$$(-2)^2 = 4$$

3. Do the product. There is one negative sign, so the product is negative.

$$3(-2)(3) = -18$$

4. Do the division. The signs are different, so the answer is negative.

$$\dfrac{12}{(-2)} = -6$$

5. Put each answer back. Keep the signs between the parts.

$$x^2 - 3xy + \dfrac{12}{x} = 4 - (-18) + (-6)$$

6. Subtracting $-18$ is the same as adding $18$:

:::pair #minus-before-negative
Right: $4 - (-18) + (-6) = 4 + 18 + (-6)$
Wrong: $4 - (-18) + (-6) = 4 - 18 + (-6)$
The wrong line kept only one minus sign, so it ends at $-20$ instead of $16$.
:::

7. Add from left to right.

$$4 + 18 = 22$$

$$22 + (-6) = 16$$

The answer is $16$.

**Check:** The parts are $+4$, $+18$ and $-6$, and $4 + 18 - 6 = 16$, which matches.

### #2: Finish the Sum

Find the sum of $27 + 9 + 3 + 1 + \dots$.

**Solution:**

1. Read the first term and the ratio: $a_1 = 27$ and $r = \dfrac{9}{27} = \dfrac{1}{3}$.

2. Check the ratio: $\left|\dfrac{1}{3}\right| < 1$, so the series has a sum.

3. Put the values into the formula.

$$S_\infty = \dfrac{27}{1 - \dfrac{1}{3}}$$

:::try
Finish the last step: $\dfrac{27}{1 - \dfrac{1}{3}}$.
:::answer
The answer is $\dfrac{81}{2}$. First $1 - \dfrac{1}{3} = \dfrac{2}{3}$, then $27 \div \dfrac{2}{3} = 27 \times \dfrac{3}{2} = \dfrac{81}{2}$.

**Check:** The terms add to $40$ after four terms and keep adding less each time, so a sum of $40.5$ fits.
:::

## Traps to Watch For

:::checklist
- Negation scope $\neg(P \land Q)$ vs $(\neg P) \land Q$: an outside $\neg$ flips one value, the result of the entire group, while an inside $\neg$ flips only the single letter beside it. {#negate-wrong-scope}
- Before using $S_\infty=\dfrac{a_1}{1-r}$ (including alternating series): when $a_1\neq 0$, check $|r|<1$ first, because nonzero series with $|r|\ge 1$ diverge. {#when-an-infinite-geometric-series-converges}
- A minus sign before a negative number inside a long expression with several parts and signs: the two signs make a plus, so $4-(-18)=22$. {#minus-before-negative}
:::
