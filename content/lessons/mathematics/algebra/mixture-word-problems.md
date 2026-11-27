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

A solution has two parts: the **pure substance** (such as salt, sugar, or alcohol) and the liquid holding it. **Concentration** tells what percent of the whole mixture, by volume, is that pure substance.

**Percent** means per hundred. Divide a percent by $100$ to write it as a decimal:

$$10\%$$

$$=\dfrac{10}{100}$$

$$=0.10$$

For a percent by volume, multiply that decimal by the total volume to find the pure amount:

$$\text{pure amount}=\text{concentration}\times\text{total amount}$$

Pure water has $0\%$ salt or sugar ($0.00$). A pure substance has $100\%$ concentration ($1.00$).

Try this example: find the pure vinegar in the solution. A store has $10$ liters of a $10\%$ vinegar solution by volume.

$$0.10\times 10$$

$$=1$$

There is $1$ liter of pure vinegar.

To find a concentration, divide the pure amount by the total amount. Find the concentration of $8$ liters of pure salt in $25$ liters of solution:

$$\text{concentration}=\dfrac{\text{pure amount}}{\text{total amount}}$$

$$8\div25$$

$$=0.32$$

$$=32\%$$

### Balancing Pure Amounts When Mixing

If no liquid or pure substance is lost and the volumes add, add the two volumes and the two pure amounts:

$$\text{pure}_1+\text{pure}_2=\text{pure}_{\text{final}}$$

<!-- ILLUSTRATION: Three containers in a row. The first is x liters at 30% with 0.30x liters of pure salt. A plus sign joins it to the second, 20 - x liters at 10% with 0.10(20 - x) liters of pure salt. An arrow leads to the third, the mixture of 20 liters at 20% with 0.20(20) = 4 liters of pure salt. The two pure amounts add to the pure amount in the mixture. -->

Try this example: find the liters of the $30\%$ solution needed. A teacher needs $20$ liters of a $20\%$ salt solution by mixing a $30\%$ solution and a $10\%$ solution, all by volume. Use the rule above: the volumes add and nothing is lost. Let $x$ be the liters of the $30\%$ solution. Then the $10\%$ solution has volume $20-x$.

$$0.30x+0.10(20-x)=0.20(20)$$

$$0.30x+2-0.10x=0.20(20)$$

$$0.30x+2-0.10x=4$$

$$0.20x+2=4$$

$$0.20x=2$$

$$x=10$$

She needs $10$ liters of the $30\%$ solution.

Find the water added to dilute $12$ liters of a $25\%$ solution (by volume) to a $10\%$ solution. The volumes add and nothing is lost.

:::pair #report-final-volume
Right: $12\times 0.25=3$, final volume $=3\div 0.10=30$ liters, so added water is $30-12=18$ liters.
Wrong: $12\times 0.25=3$, final volume $=3\div 0.10=30$ liters, so the answer is $30$ liters.
Here $30$ liters is the new total. Subtract the starting $12$ liters to report only the water added.
:::

:::check
A cook mixes $6$ liters of a $25\%$ sugar solution with $14$ liters of a $45\%$ sugar solution. All percents are by volume, the volumes add, and nothing is lost. What is the concentration of the mixture, as a percent?
:::answer
The answer is $39\%$. The pure sugar adds: $0.25(6)+0.45(14)=1.5+6.3=7.8$ liters. The total is $6+14=20$ liters, and $7.8\div 20=0.39$.
:::

## Examples

### #1: Mixing Two Solutions

How many liters of a $20\%$ alcohol solution must be added to $8$ liters of a $50\%$ alcohol solution to make a $30\%$ alcohol solution? All percents are by volume. Assume the volumes add and no liquid or alcohol is lost.

**Solution:**

1. Let $x$ be the liters of the $20\%$ solution to add. Then the final volume is $x+8$ liters.
2. Convert each percent to a decimal.

$$20\%=0.20$$

$$50\%=0.50$$

$$30\%=0.30$$

3. Set the starting pure alcohol equal to the final pure alcohol.

$$0.20x+0.50(8)=0.30(x+8)$$

:::pair #omit-original-volume
Right: $0.50(8)+0.20x=0.30(8+x)$
Wrong: $0.50(8)+0.20x=0.30x$
The final mixture holds both the original $8$ liters and the added $x$ liters, so its total volume is $8+x$, not $x$ alone.
:::

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

### #2: Diluting With Pure Water

How many liters of pure water must be added to $20$ liters of a $30\%$ salt solution to dilute it into a $24\%$ salt solution? All percents are by volume. Assume the volumes add and no liquid or salt is lost.

**Solution:**

1. Find the pure salt in the starting $20$ liters.

$$0.30(20)=6$$

2. Pure water adds $0$ salt, so the final mixture still holds $6$ liters of salt. Let $w$ be the liters of water added, so the final volume is $20+w$.

$$0.24(20+w)=6$$

3. Expand the left side.

$$4.8+0.24w=6$$

4. Subtract $4.8$ from both sides.

$$0.24w=1.2$$

:::try
Finish the last step: divide $1.2$ by $0.24$ to find how many liters of water to add.
:::answer
The answer is $5$ liters. Dividing $1.2\div 0.24=5$ gives $w=5$.
:::

## Speed Tricks & Shortcuts

Before solving, check that the target lies between the two starting concentrations. If it does not, no mix of the two can reach it. If the target is halfway between them, take equal amounts of each. Otherwise the mixture uses more of the closer one. In the first example, $30\%$ is closer to $20\%$ than to $50\%$, so the mixture must use more of the $20\%$ solution ($16$ liters) than of the $50\%$ solution ($8$ liters).

## Traps to Watch For

:::checklist
- Final mixture volume: add both starting volumes together, as in $0.30(8+x)$. {#omit-original-volume}
- Diluting with water: subtract the starting volume from the final total to report only the water added. {#report-final-volume}
- Pure water or pure substance: use $0\%$ ($0.00$) for pure water and $100\%$ ($1.00$) for a pure substance. {#finding-the-pure-amount}
:::
