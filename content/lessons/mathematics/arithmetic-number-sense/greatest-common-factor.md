---
_id: "lesson-arithmetic-number-sense-greatest-common-factor"
title: "Greatest Common Factor"
summary: "Use shared prime factors to make equal groups."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 4
ordering: 12
keyPoints:
  - "Find the GCF with the smallest shared prime exponents."
  - "Use the GCF for identical groups and equal pieces."
---
## Core Concept

### Finding the GCF with Prime Powers

**GCF** stands for greatest common factor. For positive integers, it is the largest positive integer that divides every given number with no remainder.

To find the GCF from prime factorizations:

1. Keep only primes that appear in *every* number.
2. Pick the **smaller** exponent for each shared prime.
3. Multiply those prime powers together.

If the numbers share no prime at all, their GCF is $1$.

Try finding the GCF of $48$ and $180$:

$$48=2^4\times 3^1$$

$$180=2^2\times 3^2\times 5^1$$

Both numbers have $2$ and $3$. Leave out $5$, because $48$ has no factor of $5$.

For $2$, the smaller exponent is $2$. For $3$, the smaller exponent is $1$.

$$\text{GCF}=2^2\times 3^1=4\times 3=12$$

:::why
Why use the smaller exponent? A shared factor must fit inside every number. Since $180$ only has two factors of $2$, a common factor cannot hold four factors of $2$.
:::

:::pair #gcf-larger-exponent
Right: for $48=2^4\times 3$ and $180=2^2\times 3^2\times 5$, the GCF is $2^2\times 3=12$
Wrong: for $48=2^4\times 3$ and $180=2^2\times 3^2\times 5$, the GCF is $2^4\times 3^2\times 5=720$
The wrong line picked the larger powers and even kept $5$. That gives the LCM ($720$), which does not divide $48$.
:::

:::pair #gcf-unshared-prime
Right: for $A=2^3\times 3^4\times 5^2$ and $B=2^5\times 3^2\times 7^1$, the GCF is $2^3\times 3^2=72$
Wrong: include $5$ and $7$ to get $2^3\times 3^2\times 5\times 7=2,520$
Only $A$ has $5$ and only $B$ has $7$. A common factor can include only primes that belong to both numbers.
:::

:::check
Find the GCF of $40=2^3\times 5$ and $60=2^2\times 3\times 5$.
:::answer
The answer is $20$. The shared primes are $2$ and $5$, and their smaller powers give $2^2\times 5=4\times 5=20$.
:::

### Using the GCF for Equal Groups

Use the GCF when a problem asks for the **greatest number of identical groups** with nothing left over. It also gives the **greatest equal piece size** when cutting lengths with no waste.

Read the final question carefully. Some questions ask for the number of groups (the GCF). Others ask how many items go inside each group, which requires dividing each total by the GCF.

Try $18$ apples and $24$ oranges packed into identical bags. Since $18=2\times 3^2$ and $24=2^3\times 3$, the GCF is $2\times 3=6$ bags. Each bag gets:

$$18\div 6=3\text{ apples}$$

$$24\div 6=4\text{ oranges}$$

That makes $3+4=7$ pieces of fruit in each bag.

:::pair #gcf-groups-vs-items
Right: if $144$ pouches and $96$ kits fill $48$ identical boxes, each box holds $144\div 48+96\div 48=5$ items
Wrong: if $144$ pouches and $96$ kits fill $48$ identical boxes, the answer is $48$ items per box
Here $48$ is the number of boxes, not the number of items inside each box. Always check what the last sentence asks for.
:::

:::check
You pack $28$ pens and $42$ pencils into the greatest number of identical kits. How many kits can you make?
:::answer
The answer is $14$. Since $28=2^2\times 7$ and $42=2\times 3\times 7$, their GCF is $2\times 7=14$.
:::

## Examples

### #1: GCF from Two Numbers

What is the greatest common factor of $72$ and $108$?

**Solution:**

1. Write the prime factorization of each number.

$$72=2^3\times 3^2$$

$$108=2^2\times 3^3$$

2. Both numbers share $2$ and $3$. Pick the smaller exponent for each: $2^2$ and $3^2$.

$$\text{GCF}=2^2\times 3^2$$

3. Multiply the powers.

$$\text{GCF}=4\times 9=36$$

The answer is $36$.

**Check:** Divide both numbers by $36$: $72\div 36=2$ and $108\div 36=3$. Because $2$ and $3$ share no factor greater than $1$, no larger common factor exists.

### #2: Equal Groups Word Problem

A relief team has $84$ cans of sardines, $126$ packs of noodles, and $210$ kilograms of rice. It will divide all supplies among the greatest possible number of identical relief bags. Each bag must contain whole cans, whole packs, and a whole number of kilograms of rice. How many bags can it make?

**Solution:**

1. The number of bags must divide all three amounts evenly, so find the GCF. Factor each number into primes.

$$84=2^2\times 3\times 7$$

$$126=2\times 3^2\times 7$$

$$210=2\times 3\times 5\times 7$$

2. Keep only primes present in all three numbers: $2$, $3$, and $7$ (leave out $5$). Each shared prime has a smallest exponent of $1$.

:::try
Finish the last step: multiply the smallest powers of the shared primes to find the maximum number of bags.
:::answer
The answer is $42$. Multiply $2\times 3\times 7=42$ identical bags.

**Check:** Divide each supply by $42$: $84\div 42=2$ cans, $126\div 42=3$ packs, and $210\div 42=5$ kilograms. Since $2$, $3$, and $5$ share no common factor greater than $1$, $42$ is the greatest number of bags.
:::

## Traps to Watch For

:::checklist
- Picking exponents for the GCF: use the smaller exponent of each shared prime, not the larger one. {#gcf-larger-exponent}
- Primes found in only one number: leave them out of the GCF, because only shared bases count. {#gcf-unshared-prime}
- Word problems asking for items per group: divide each total by the GCF instead of stopping at the GCF. {#gcf-groups-vs-items}
:::
