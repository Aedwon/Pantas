---
_id: "lesson-algebra-mixture-word-problems"
title: "Mixture Problems"
summary: "Track the pure amount to solve a mixture problem."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 5
partCount: 6
ordering: 69
keyPoints:
  - "Multiply concentration by total amount and balance the pure amounts."
---
## Core Concept

### Finding the Pure Amount

A solution has two parts: the **pure substance** (such as salt, sugar, or alcohol) and the liquid holding it. **Concentration** tells what percent of the whole mixture is that pure substance.

**Percent** means per hundred. Divide a percent by $100$ to write it as a decimal:

$$10\%=\dfrac{10}{100}=0.10$$

Multiply that decimal by the total volume to find the pure amount:

$$\text{pure amount}=\text{concentration}\times\text{total amount}$$

Pure water has $0\%$ salt or sugar ($0.00$). A pure substance has $100\%$ concentration ($1.00$).

Try this example. A store has $10$ liters of a $10\%$ vinegar solution. How much pure vinegar is inside?

$$0.10\times 10=1$$

There is $1$ liter of pure vinegar.

:::check
A $45$-liter sugar solution holds $18$ liters of pure sugar. What is its concentration, as a percent?
:::answer
The answer is $40\%$. Divide the pure amount by the total: $18\div 45=0.40$.

**Check:** $0.40\times 45=18$ liters of pure sugar.
:::

### Balancing Pure Amounts When Mixing

When two solutions are mixed under the standard assumption that volumes add and no liquid or pure material is lost, both the volumes and the pure amounts add up:

$$\text{pure}_1+\text{pure}_2=\text{pure}_{\text{final}}$$

Under that model assumption, the final volume is the sum of the two starting volumes.

<!-- FIGURE WANTED: two beakers pouring into one larger beaker. Left beaker: "8 L at 50%" with "0.50(8) = 4 L pure". Middle beaker: "x L at 20%" with "0.20x L pure". Right beaker: "(8 + x) L at 30%" with "0.30(8 + x) L pure" -->

Try this example. A teacher needs $20$ liters of a $20\%$ salt solution by mixing a $30\%$ solution and a $10\%$ solution. Let $x$ be the liters of the $30\%$ solution. Then the $10\%$ solution has volume $20-x$.

$$0.30x+0.10(20-x)=0.20(20)$$

$$0.30x+2-0.10x=4$$

$$0.20x+2=4$$

$$0.20x=2$$

$$x=10$$

She needs $10$ liters of the $30\%$ solution.

:::pair #omit-original-volume
Right: $0.50(8)+0.20x=0.30(8+x)$
Wrong: $0.50(8)+0.20x=0.30x$
The final mixture holds both the original $8$ liters and the added $x$ liters, so its total volume is $8+x$, not $x$ alone.
:::

:::pair #report-final-volume
Right: $12\times 0.25=3$, final volume $=3\div 0.10=30$ liters, so added water is $30-12=18$ liters.
Wrong: $12\times 0.25=3$, final volume $=3\div 0.10=30$ liters, so the answer is $30$ liters.
When adding pure water to dilute $12$ liters of a $25\%$ solution to a $10\%$ solution, $30$ liters is the new total. Subtract the starting $12$ liters to report only the water added.
:::

:::check
A shop has $4$ liters of a $50\%$ solution and adds $x$ liters of a $10\%$ solution to make a $20\%$ solution. How many liters of the $10\%$ solution must be added?
:::answer
The answer is $12$ liters. Set the starting pure amounts equal to the final pure amount: $0.50(4)+0.10x=0.20(4+x)$. Then $2+0.10x=0.80+0.20x$, so $1.2=0.10x$ and $x=12$.

**Check:** Pure amount $2+0.10(12)=3.2$ liters, total volume $4+12=16$ liters, and $\dfrac{3.2}{16}=0.20$.
:::

## Examples

### #1: Mixing Two Solutions

How many liters of a $20\%$ alcohol solution must be added to $8$ liters of a $50\%$ alcohol solution to make a $30\%$ alcohol solution? Assume the volumes add and no liquid or alcohol is lost.

**Solution:**

1. Let $x$ be the liters of the $20\%$ solution to add. Then the final volume is $x+8$ liters.
2. Convert each percent to a decimal.

$$20\%=0.20,\qquad 50\%=0.50,\qquad 30\%=0.30$$

3. Set the starting pure alcohol equal to the final pure alcohol.

$$0.20x+0.50(8)=0.30(x+8)$$

4. Multiply $0.50(8)$ on the left side.

$$0.20x+4=0.30(x+8)$$

5. Expand the right side.

$$0.20x+4=0.30x+2.4$$

6. Subtract $0.20x$ from both sides.

$$4=0.10x+2.4$$

7. Subtract $2.4$ from both sides.

$$1.6=0.10x$$

8. Divide by $0.10$.

$$x=16$$

Add $16$ liters of the $20\%$ solution.

**Check:** The pure alcohol is $0.20(16)+4=3.2+4=7.2$ liters, and the total volume is $16+8=24$ liters. Dividing gives $\dfrac{7.2}{24}=0.30$, or $30\%$.

### #2: Diluting With Pure Water

How many liters of pure water must be added to $15$ liters of a $20\%$ salt solution to dilute it into a $12\%$ salt solution? Assume the volumes add and no liquid or salt is lost.

**Solution:**

1. Find the pure salt in the starting $15$ liters.

$$0.20(15)=3$$

2. Pure water adds $0$ salt, so the final mixture still holds $3$ liters of salt. Let $w$ be the liters of water added, so the final volume is $15+w$.

$$0.12(15+w)=3$$

3. Expand the left side.

$$1.8+0.12w=3$$

4. Subtract $1.8$ from both sides.

$$0.12w=1.2$$

:::try
Finish the last step: divide $1.2$ by $0.12$ to find how many liters of water to add.
:::answer
The answer is $10$ liters. Dividing $1.2\div 0.12=10$ gives $w=10$.

**Check:** Adding $10$ liters of water makes a final volume of $15+10=25$ liters. With $3$ liters of pure salt, $\dfrac{3}{25}=0.12$, or $12\%$.
:::

## Speed Tricks & Shortcuts

Before solving, check which starting concentration sits closer to the target. In the first example, $30\%$ is closer to $20\%$ than to $50\%$, so the mixture must use more of the $20\%$ solution ($16$ liters) than of the $50\%$ solution ($8$ liters).

## Traps to Watch For

:::checklist
- Final mixture volume: add both starting volumes together, as in $0.30(8+x)$. {#omit-original-volume}
- Diluting with water: subtract the starting volume from the final total to report only the water added. {#report-final-volume}
- Pure water or pure substance: use $0\%$ ($0.00$) for pure water and $100\%$ ($1.00$) for a pure substance. {#finding-the-pure-amount}
:::
