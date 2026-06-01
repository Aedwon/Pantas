---
_id: "lesson-mechanical-technical-reasoning-springs-and-weights"
title: "Springs and Weights"
summary: "Learn how springs stretch or compress in proportion to the weight attached, and how to compare springs of different stiffness."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 9
isActive: true
---
## Core Concept

A **spring** stretches (or compresses) by an amount PROPORTIONAL to the force (or weight) applied to it — this relationship is sometimes called Hooke's Law in physics. In simple terms: DOUBLE the weight hanging from a spring, and the spring stretches TWICE as far (as long as the spring is not stretched so far that it becomes permanently deformed or damaged).

$$\text{stretch} = k \times \text{weight}$$

where $k$ is a constant describing that particular spring's STIFFNESS (technically its "spring constant"). A STIFFER spring has a SMALLER stretch for the same weight (harder to stretch); a LOOSER (more flexible) spring has a LARGER stretch for the same weight (easier to stretch).

<!-- ILLUSTRATION: two springs side by side, one labeled "stiff spring" showing only a small stretch under a hanging weight, and one labeled "loose spring" showing a much larger stretch under the identical hanging weight -->

Because stretch is PROPORTIONAL to weight, if you know how far a spring stretches for ONE known weight, you can predict the stretch for ANY other weight using a simple ratio: the stretch SCALES UP or DOWN by the SAME FACTOR as the weight changes.

When comparing TWO DIFFERENT springs holding the SAME weight, the spring that stretches MORE is the LOOSER (less stiff) one, and the spring that stretches LESS is the STIFFER one.

## Examples

### #1: Basic Proportional Stretch

A spring stretches $4 \text{ cm}$ when a $2 \text{ kg}$ weight is attached. How far will it stretch with a $6 \text{ kg}$ weight?

**Solution:**
1. The weight increased by a factor of $6 \div 2 = 3$.
2. Since stretch is proportional to weight, the stretch also increases by the SAME factor of $3$.
3. New stretch: $4 \times 3 = 12 \text{ cm}$.

### #2: Finding the Weight from a Known Stretch

A spring stretches $3 \text{ cm}$ for every $1 \text{ kg}$ attached. How much weight is attached if the spring has stretched $15 \text{ cm}$?

**Solution:**
1. Set up the proportional relationship: $3 \text{ cm}$ per $1 \text{ kg}$.
2. Find how many "$3$ cm units" fit into $15$ cm.

$$15 \div 3 = 5$$

3. Since each $3$ cm unit corresponds to $1$ kg, a stretch of $15$ cm corresponds to $5 \text{ kg}$.

### #3: Comparing Two Springs' Stiffness

Spring A stretches $2 \text{ cm}$ under a $4 \text{ kg}$ weight. Spring B stretches $5 \text{ cm}$ under the SAME $4 \text{ kg}$ weight. Which spring is stiffer?

**Solution:**
1. Under the IDENTICAL weight, Spring A stretched LESS ($2$ cm) than Spring B ($5$ cm).
2. A spring that stretches LESS under the same weight is STIFFER (harder to stretch).
3. Spring A is the STIFFER spring.

### #4: Predicting Stretch for a Stiffer Spring at a Different Weight

Using Spring A from Example 3 (stretches $2 \text{ cm}$ under $4 \text{ kg}$), predict its stretch under a $10 \text{ kg}$ weight.

**Solution:**
1. Find the scaling factor between the weights: $10 \div 4 = 2.5$.
2. Apply the same scaling factor to the stretch: $2 \times 2.5 = 5 \text{ cm}$.
3. Spring A stretches $5 \text{ cm}$ under a $10 \text{ kg}$ weight.

## Speed Tricks & Shortcuts

**Set up stretch and weight as a simple ratio, and scale both sides by the SAME factor.** If the weight is multiplied by some number, the stretch is multiplied by that EXACT same number — this proportional scaling avoids needing to calculate the spring's exact stiffness constant.

**For "how much weight" questions, divide the given stretch by the KNOWN stretch-per-unit-weight** to directly find the corresponding weight, rather than working through the full proportional formula.

**When comparing springs, remember: MORE stretch under the SAME weight means a LOOSER (less stiff) spring; LESS stretch means STIFFER.**

## Traps to Watch For

### #1: Assuming Stretch Increases by a Fixed Amount Instead of a Fixed Ratio

> Stretch is PROPORTIONAL to weight (a constant RATIO), not simply increased by the same fixed AMOUNT each time weight is added by some fixed increment.

Assuming that if $2$ kg causes $4$ cm of stretch, then EVERY additional $2$ kg simply adds ANOTHER $4$ cm regardless of the starting point happens to work out the same in most simple proportional cases, but the underlying reasoning must be based on the RATIO (multiply by the weight's scaling factor), not just adding fixed amounts blindly — this distinction matters especially when the weight change is not a simple whole-number multiple of the original.

### #2: Confusing "Stiffer" with "Stretches More"

> A STIFFER spring stretches LESS under the same weight; a LOOSER (weaker) spring stretches MORE under the same weight.

It is easy to intuitively assume "stiffer" means "moves more" or "stretches more" — in fact, stiffness describes RESISTANCE to stretching, so a stiffer spring is precisely the one that stretches the LEAST for a given weight.

### #3: Comparing Springs Under Different Weights Instead of the Same Weight

> To fairly compare which spring is stiffer, the WEIGHT applied to each spring must be the SAME — comparing stretches under DIFFERENT weights does not directly reveal which spring is inherently stiffer.

If Spring A stretches $2$ cm under $4$ kg, and Spring B stretches $2$ cm under $8$ kg, they are NOT equally stiff — Spring B is actually STIFFER, since it resisted stretching just as much despite a HEAVIER weight. Always equalize the weight before comparing stretch amounts directly.
