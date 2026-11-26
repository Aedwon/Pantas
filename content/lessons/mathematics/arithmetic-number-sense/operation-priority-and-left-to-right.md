---
_id: "lesson-arithmetic-number-sense-operation-priority-and-left-to-right"
title: "Operation Priority and Left to Right"
summary: "Apply the order of operations and the left-to-right rule."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 4
ordering: 0
keyPoints:
  - 'Apply the order of operations and the left-to-right rule.'
  - 'Evaluate powers and roots before multiplication and addition.'
---
## Core Concept

### The Four Priority Levels

When an expression has more than one operation, follow one standard order so everyone gets the same answer.

In exam questions, **evaluate** means find the final number answer.

Work through these four levels from top to bottom:

1. **Grouping symbols**: parentheses $()$, square brackets $[]$, curly braces $\{\}$, and fraction bars.
2. **Exponents and roots**: powers like $2^3$ and roots like $\sqrt{49}$.
3. **Multiplication and division**: tied at the same level, left to right.
4. **Addition and subtraction**: tied at the same level, left to right.

Try this example: evaluate $36\div 4\times 3+2^3$.

Do the power first:

$$2^3=8$$

That leaves $36\div 4\times 3+8$. Next, multiply and divide from left to right:

$$36\div 4\times 3=9\times 3=27$$

Add last:

$$27+8=35$$

The answer is $35$.

:::check
Evaluate $4+3\times 2^2$.
:::answer
The answer is $16$. Do the power first ($2^2=4$), multiply next ($3\times 4=12$), then add ($4+12=16$).
:::

### Powers and Roots Come Before Multiplying

An **exponent** tells how many times to multiply the base by itself. So $2^3$ means $2\times 2\times 2=8$, not $2\times 3=6$.

A **root** reverses a power. For example, $\sqrt{49}=7$ because $7^2=49$.

Try this example: evaluate $\sqrt{49}+2^3$.

$$\sqrt{49}+2^3=7+8=15$$

:::pair #power-not-product
Right: $\sqrt{49}+2^3=7+8=15$
Wrong: $\sqrt{49}+2^3=7+6=13$
The wrong line multiplied $2\times 3=6$. An exponent multiplies the base by itself, so $2^3=2\times 2\times 2=8$.
:::

:::check
Evaluate $\sqrt{36}+3^2$.
:::answer
The answer is $15$. Find the root ($\sqrt{36}=6$) and the power ($3^2=9$) first, then add $6+9=15$.
:::

### Left to Right for Tied Operations

Multiplication and division share the exact same priority. Neither beats the other. Work from left to right.

Addition and subtraction also share one priority level. Work from left to right.

Try $18\div 3\times 2$ and $15-5+4$:

$$18\div 3\times 2=6\times 2=12$$

$$15-5+4=10+4=14$$

:::why
Why does left to right matter? In $18\div 3\times 2$, only $3$ sits after the division sign. Multiplying $3\times 2$ first turns dividing by $3$ and multiplying by $2$ into dividing by $6$.
:::

:::pair #multiply-before-divide
Right: $18\div 3\times 2=6\times 2=12$
Wrong: $18\div 3\times 2=18\div 6=3$
In PEMDAS, M comes before D, so it can look like multiplication goes first. Because they share priority, divide $18\div 3=6$ first from the left.
:::

:::pair #add-before-subtract
Right: $15-5+4=10+4=14$
Wrong: $15-5+4=15-9=6$
Addition and subtraction are tied. Subtract $15-5=10$ from the left instead of adding $5+4=9$ first.
:::

:::check
Evaluate $24\div 6\times 2\div 4$.
:::answer
The answer is $2$. From left to right: $24\div 6=4$, then $4\times 2=8$, then $8\div 4=2$.
:::

## Mnemonics & Memory Aids

To remember the four levels as **PEMDAS**, use:

> Please Excuse My Dear Aunt Sally.

If you prefer **GEMDAS** (where G stands for Grouping), use:

> Giant Elephants March Down A Street.

In both sayings, M and D are tied left to right, and A and S are tied left to right.

## Examples

### #1: Tied Operations Left to Right

Evaluate $16 \div 4 \times 2 + 3$.

**Solution:**

1. There are no grouping symbols, exponents, or roots.
2. Multiply and divide from left to right.

$$16 \div 4 \times 2 = 4 \times 2 = 8$$

3. Add last.

$$8 + 3 = 11$$

The answer is $11$.

**Check:** Working from the left gives $16\div 4=4$, then $4\times 2=8$, then $8+3=11$. Multiplying $4\times 2=8$ first would give $16\div 8+3=5$, which breaks the left-to-right rule.

### #2: Roots, Powers, and Multiplying

Evaluate $\sqrt{81}+2^3\times 3$.

**Solution:**

1. Evaluate the root and the power first.

$$\sqrt{81}=9$$

$$2^3=8$$

2. Multiply before adding.

$$8\times 3=24$$

:::try
Finish the last step: add $9+24$.
:::answer
The answer is $33$. Adding $9+24=33$ finishes the evaluation.

**Check:** Adding $9+8=17$ before multiplying by $3$ would give $51$, which breaks priority. Powers and multiplication must finish before addition.
:::

## Traps to Watch For

:::checklist
- Division and multiplication in a row: work from left to right, so $18\div 3\times 2=12$. {#multiply-before-divide}
- Subtraction and addition in a row: work from left to right, so $15-5+4=14$. {#add-before-subtract}
- Powers like $2^3$: multiply the base by itself ($2\times 2\times 2=8$), never base times exponent. {#power-not-product}
:::
