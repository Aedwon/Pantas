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

Evaluate $36\div 4\times 3+2^3$.

Do the power first:

$$2^3=8$$

That leaves $36\div 4\times 3+8$. Next, multiply and divide from left to right:

$$36\div 4=9$$

$$9\times 3=27$$

Add last:

$$27+8=35$$

The answer is $35$.

### Powers and Roots Come Before Multiplying

An **exponent** tells how many copies of the base to multiply. So $2^3$ means $2\times 2\times 2=8$, not $2\times 3=6$.

A **root** undoes a power. For example, the square root $\sqrt{49}=7$ because $7^2=49$.

Evaluate $\sqrt{49}+2^3$.

$$\sqrt{49}=7$$

$$2^3=8$$

$$7+8=15$$

:::pair #power-not-product
Right: $\sqrt{49}+2^3=7+8=15$
Wrong: $\sqrt{49}+2^3=7+6=13$
The wrong line multiplied $2\times 3=6$. An exponent counts copies of the base, so $2^3=2\times 2\times 2=8$.
:::

### Left to Right for Tied Operations

Multiplication and division share the exact same priority. Neither beats the other. Work from left to right.

Addition and subtraction also share one priority level. Work from left to right.

Evaluate $18\div 3\times 2$ and $15-5+4$:

$$18\div 3=6$$

$$6\times 2=12$$

$$15-5=10$$

$$10+4=14$$

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
Evaluate $40-3^2+48\div 4\times 2$.
:::answer
The answer is $55$. Do the power ($3^2=9$), then $48\div 4=12$ and $12\times 2=24$. Last, subtract and add from the left: $40-9=31$, then $31+24=55$.
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

$$16 \div 4 \times 2 = 4 \times 2$$

$$4 \times 2 = 8$$

3. Add last.

$$8 + 3 = 11$$

The answer is $11$.

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
:::

## Traps to Watch For

:::checklist
- Division and multiplication in a row: work from left to right, so $18\div 3\times 2=12$. {#multiply-before-divide}
- Subtraction and addition in a row: work from left to right, so $15-5+4=14$. {#add-before-subtract}
- Powers like $2^3$: write $3$ copies of the base and multiply, so $2\times 2\times 2=8$. {#power-not-product}
:::
