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

Find the GCF of $48$ and $180$ from their prime factorizations:

$$48=2^4\times 3^1$$

$$180=2^2\times 3^2\times 5^1$$

Both numbers have $2$ and $3$. Leave out $5$, because $48$ has no factor of $5$.

For $2$, the smaller exponent is $2$. For $3$, the smaller exponent is $1$.

$$\text{GCF}=2^2\times 3^1$$

$$\text{GCF}=4\times 3$$

$$\text{GCF}=12$$

<!-- ILLUSTRATION: Two rows of prime tiles. 48 = 2^4 x 3 is the tiles 2, 2, 2, 2, 3. 180 = 2^2 x 3^2 x 5 is the tiles 2, 2, 3, 3, 5. In each row the shared tiles 2, 2, 3 come first and are outlined. The other tiles are not outlined, and the 5 tile is marked "only in 180". Below: GCF = 2^2 x 3 = 12. -->

:::why
Why use the smaller exponent? A shared factor must fit inside every number. Since $180$ only has two factors of $2$, a common factor cannot hold four factors of $2$.
:::

:::pair #gcf-larger-exponent
Right: for $48=2^4\times 3$ and $180=2^2\times 3^2\times 5$, the GCF is $2^2\times 3=12$
Wrong: for $48=2^4\times 3$ and $180=2^2\times 3^2\times 5$, the GCF is $2^4\times 3^2\times 5=720$
The wrong line picked the larger powers and even kept $5$. That is a multiple of both numbers ($720$), which does not divide $48$.
:::

:::pair #gcf-unshared-prime
Right: for $A=2^3\times 3^4\times 5^2$ and $B=2^5\times 3^2\times 7^1$, the GCF is $2^3\times 3^2=72$
Wrong: include $5$ and $7$ to get $2^3\times 3^2\times 5\times 7=2,520$
Only $A$ has $5$ and only $B$ has $7$. A common factor can include only primes that belong to both numbers.
:::

:::check
Find the GCF of $150$ and $270$. Factor each number into primes first.
:::answer
The answer is $30$. Since $150=2\times 3\times 5^2$ and $270=2\times 3^3\times 5$, the smaller powers give $2\times 3\times 5=30$.
:::

### Using the GCF for Equal Groups

Use the GCF when a problem asks for the **greatest number of identical groups** with nothing left over. It also gives the **greatest equal piece size** when cutting lengths with no waste.

Read the final question carefully. Some questions ask for the number of groups, which is the GCF. Others ask how many items go inside each group, which requires dividing each total by the GCF.

Find how much fruit goes in each bag when $18$ apples and $24$ oranges fill the greatest number of identical bags. Since $18=2\times 3^2$ and $24=2^3\times 3$, the GCF is $2\times 3=6$ bags. Each bag gets:

$$18\div 6=3\text{ apples}$$

$$24\div 6=4\text{ oranges}$$

That makes $3+4=7$ pieces of fruit in each bag.

:::pair #gcf-groups-vs-items
Right: if $144$ pouches and $96$ kits fill $48$ identical boxes, each box holds $144\div 48+96\div 48=5$ items
Wrong: if $144$ pouches and $96$ kits fill $48$ identical boxes, the answer is $48$ items per box
Here $48$ is the number of boxes, not the number of items inside each box. Check what the last sentence asks for.
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

$$\text{GCF}=4\times 9$$

$$\text{GCF}=36$$

The answer is $36$.

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
:::

## Traps to Watch For

:::checklist
- Picking exponents for the GCF: use the smaller exponent of each shared prime, not the larger one. {#gcf-larger-exponent}
- Primes found in only one number: leave them out of the GCF, because only shared bases count. {#gcf-unshared-prime}
- Word problems asking for items per group: divide each total by the GCF instead of stopping at the GCF. {#gcf-groups-vs-items}
:::
