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

A **spring** stretches (or compresses) by an amount proportional to the force (or weight) applied to it: this relationship is sometimes called Hooke's Law in physics. In simple terms: Double the weight hanging from a spring, and the spring stretches twice as far (as long as the spring is not stretched so far that it becomes permanently deformed or damaged).

$$\text{stretch} = k \times \text{weight}$$

where $k$ is a constant describing that particular spring's stiffness (technically its "spring constant"). A stiffer spring has a smaller stretch for the same weight (harder to stretch); a looser (more flexible) spring has a larger stretch for the same weight (easier to stretch).

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"stretch": 3, "label": "A"}, {"stretch": 8, "label": "B"}], "semanticsLabel": "Two springs side by side where spring A stretches less than spring B under the same weight."} -->

Because stretch is proportional to weight, if you know how far a spring stretches for one known weight, you can predict the stretch for any other weight using a simple ratio: the stretch scales up or down by the same factor as the weight changes.

When comparing two different springs holding the same weight, the spring that stretches more is the looser (less stiff) one, and the spring that stretches less is the stiffer one.

## Examples

### #1: Basic Proportional Stretch

A spring stretches $4 \text{ cm}$ when a $2 \text{ kg}$ weight is attached. How far will it stretch with a $6 \text{ kg}$ weight?

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"stretch": 4}, {"stretch": 12}], "semanticsLabel": "Two hanging springs showing proportional stretch under different weights."} -->


**Solution:**
1. The weight increased by a factor of $6 \div 2 = 3$.
2. Since stretch is proportional to weight, the stretch also increases by the same factor of $3$.
3. New stretch: $4 \times 3 = 12 \text{ cm}$.

### #2: Finding the Weight from a Known Stretch

A spring stretches $3 \text{ cm}$ for every $1 \text{ kg}$ attached. How much weight is attached if the spring has stretched $15 \text{ cm}$?

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"stretch": 15}], "semanticsLabel": "A spring hanging from a beam with a weight attached."} -->


**Solution:**
1. Set up the proportional relationship: $3 \text{ cm}$ per $1 \text{ kg}$.
2. Find how many "$3$ cm units" fit into $15$ cm.

$$15 \div 3 = 5$$

3. Since each $3$ cm unit corresponds to $1$ kg, a stretch of $15$ cm corresponds to $5 \text{ kg}$.

### #3: Comparing Two Springs' Stiffness

Spring A stretches $2 \text{ cm}$ under a $4 \text{ kg}$ weight. Spring B stretches $5 \text{ cm}$ under the same $4 \text{ kg}$ weight. Which spring is stiffer?

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"label": "A", "stretch": 2}, {"label": "B", "stretch": 5}], "semanticsLabel": "Two springs side by side with spring A stretched 2 cm and spring B stretched 5 cm under equal weights."} -->


**Solution:**
1. Under the identical weight, Spring A stretched less ($2$ cm) than Spring B ($5$ cm).
2. A spring that stretches less under the same weight is stiffer (harder to stretch).
3. Spring A is the stiffer spring.

### #4: Predicting Stretch for a Stiffer Spring at a Different Weight

Using Spring A from Example 3 (stretches $2 \text{ cm}$ under $4 \text{ kg}$), predict its stretch under a $10 \text{ kg}$ weight.

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"stretch": 2}, {"stretch": 5}], "semanticsLabel": "A spring shown under two different weights stretching 2 cm and 5 cm."} -->


**Solution:**
1. Find the scaling factor between the weights: $10 \div 4 = 2.5$.
2. Apply the same scaling factor to the stretch: $2 \times 2.5 = 5 \text{ cm}$.
3. Spring A stretches $5 \text{ cm}$ under a $10 \text{ kg}$ weight.

## Speed Tricks & Shortcuts

**Set up stretch and weight as a simple ratio, and scale both sides by the same factor.** If the weight is multiplied by some number, the stretch is multiplied by that exact same number: this proportional scaling avoids needing to calculate the spring's exact stiffness constant.

**For "how much weight" questions, divide the given stretch by the known stretch-per-unit-weight** to directly find the corresponding weight, rather than working through the full proportional formula.

**When comparing springs, remember: More stretch under the same weight means a looser (less stiff) spring; less stretch means stiffer.**

## Traps to Watch For

### #1: Assuming Stretch Increases by a Fixed Amount Instead of a Fixed Ratio

> Stretch is proportional to weight (a constant ratio), not simply increased by the same fixed amount each time weight is added by some fixed increment.

Assuming that if $2$ kg causes $4$ cm of stretch, then every additional $2$ kg simply adds another $4$ cm regardless of the starting point happens to work out the same in most simple proportional cases, but the underlying reasoning must be based on the ratio (multiply by the weight's scaling factor), not just adding fixed amounts blindly: this distinction matters especially when the weight change is not a simple whole-number multiple of the original.

### #2: Confusing "Stiffer" with "Stretches More"

> A stiffer spring stretches less under the same weight; a looser (weaker) spring stretches more under the same weight.

It is easy to intuitively assume "stiffer" means "moves more" or "stretches more": in fact, stiffness describes resistance to stretching, so a stiffer spring is precisely the one that stretches the least for a given weight.

### #3: Comparing Springs Under Different Weights Instead of the Same Weight

> To fairly compare which spring is stiffer, the weight applied to each spring must be the same: comparing stretches under different weights does not directly reveal which spring is inherently stiffer.

If Spring A stretches $2$ cm under $4$ kg, and Spring B stretches $2$ cm under $8$ kg, they are not equally stiff: Spring B is actually stiffer, since it resisted stretching just as much despite a heavier weight. Always equalize the weight before comparing stretch amounts directly.
