---
_id: "lesson-arithmetic-number-sense-direct-proportion-and-travel"
title: "Direct Proportion and Travel"
summary: "Set up equal ratios in the same order and match units in travel problems."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 3
ordering: 21
keyPoints:
  - "Set up equal ratios in the same order and cross-multiply."
  - "Use distance, rate, and time with matching units."
---
## Core Concept

### What Direct Proportion Means

A **ratio** compares two amounts by division. You can write the ratio of $2$ to $3$ as $2:3$ or $\dfrac{2}{3}$.

In a **direct proportion**, two quantities keep the same ratio as they grow or shrink. If $y$ is directly proportional to $x$, then:

$$y=kx$$

Here $k$ is a fixed number called a constant. When $k>0$, doubling $x$ doubles $y$, and for every nonzero value $x\neq 0$, the ratio $\dfrac{y}{x}$ stays equal to $k$.

For example, in $y=3x$, the pairs $(1,3)$, $(2,6)$, and $(5,15)$ all give the same ratio:

$$\dfrac{3}{1}=\dfrac{6}{2}=\dfrac{15}{5}=3$$

:::pair #increasing-not-direct
Right: $y=3x$ is direct proportion because $\dfrac{y}{x}=3$ stays constant.
Wrong: $y=x+3$ is direct proportion because $y$ goes up when $x$ goes up.
Going up together is not enough. In $y=x+3$, the pairs $(1,4)$ and $(2,5)$ have different ratios, $\dfrac{4}{1}=4$ and $\dfrac{5}{2}=2.5$.
:::

### Equal Ratios and Cross-Multiplying

A **proportion** says that two ratios are equal. When two ratios are equal, their cross products are equal. For nonzero $B$ and $D$:

$$\dfrac{A}{B}=\dfrac{C}{D}$$

$$AD=BC$$

Keep both ratios in the exact same order, such as $\dfrac{\text{blue}}{\text{yellow}}$ on both sides.

Find the yellow paint needed for $15$ liters of blue paint when blue and yellow mix in a $3:2$ ratio. Let $x$ be the liters of yellow paint. Write both fractions as $\dfrac{\text{blue}}{\text{yellow}}$.

$$\dfrac{3}{2}=\dfrac{15}{x}$$

Cross-multiply.

$$3x=2\times15$$

$$3x=30$$

Divide by $3$.

$$x=\dfrac{30}{3}$$

$$x=10$$

You need $10$ liters of yellow paint.

:::pair #reverse-ratio-order
Right: $\dfrac{3}{2}=\dfrac{15}{x}$, giving $x=10$ liters
Wrong: $\dfrac{3}{2}=\dfrac{x}{15}$, giving $x=22.5$ liters
The wrong setup put blue on top in the first ratio and yellow on top in the second. Match the top and bottom labels on both sides.
:::

:::why
Why does cross-multiplying work? Multiplying both sides of $\dfrac{A}{B}=\dfrac{C}{D}$ by $BD$ clears both denominators at once and leaves $AD=BC$.
:::

:::check
A map scale is $1\text{ cm}:12\text{ km}$. A trail is $54\text{ km}$ long. How many centimeters long is it on the map?
:::answer
The answer is $4.5\text{ cm}$. Let $x$ be the map length in centimeters. Write $\dfrac{1}{12}=\dfrac{x}{54}$ with centimeters on top, so $12x=54$ and $x=\dfrac{54}{12}=4.5$.
:::

### Distance, Rate, and Time

**Rate** tells how far something moves in one unit of time. Distance, rate, and time follow this formula:

$$d=rt$$

Here $d$ is distance, $r$ is rate, and $t$ is time. At a fixed rate, distance and time are directly proportional: twice the time covers twice the distance. For a fixed distance, rate and time are inversely proportional because $rt=d$ stays constant.

The time unit in $t$ must match the time unit in $r$. If speed is in kilometers per hour, divide minutes by $60$ to get hours before you multiply. If you get a decimal number of hours, multiply by $60$ to turn it into minutes.

Find the distance traveled at $50\text{ km/h}$ for $48$ minutes. First change $48$ minutes to hours.

$$\dfrac{48}{60}=0.8\text{ hour}$$

Now multiply rate by time.

$$50\times0.8=40\text{ km}$$

:::pair #hours-to-minutes
Right: $0.8\text{ hour}=0.8\times60=48\text{ minutes}$
Wrong: $0.8\text{ hour}=80\text{ minutes}$
An hour has $60$ minutes, not $100$. Multiply decimal hours by $60$ to get minutes.
:::

## Examples

### #1: Scaling a Recipe

A bakery uses $4$ cups of flour to make $24$ large muffins. At this rate, how many cups of flour are needed for $84$ large muffins?

**Solution:**

1. Let $x$ be the cups of flour for $84$ muffins. Both ratios compare cups of flour to number of muffins. Put flour on top and muffins on the bottom in both fractions.

$$\dfrac{4}{24}=\dfrac{x}{84}$$

2. Cross-multiply.

$$24x=4\times84$$

$$24x=336$$

3. Divide both sides by $24$.

$$x=\dfrac{336}{24}$$

$$x=14$$

The bakery needs $14$ cups of flour.

### #2: Distance, Rate, and Time with Unit Conversion

On a road trip, a bus travels $108\text{ kilometers}$ at a steady speed of $45\text{ kilometers per hour}$. How many hours and minutes does the trip take?

**Solution:**

1. Use $d=rt$ with $d=108$ and $r=45$.

$$108=45t$$

2. Divide by $45$ to find the time in hours.

$$\dfrac{108}{45}=2.4\text{ hours}$$

3. Split $2.4$ hours into $2$ whole hours and $0.4$ hour.

:::try
Finish the last step: convert $0.4$ hour into minutes and write the total time.
:::answer
The answer is $2\text{ hours}$ and $24\text{ minutes}$. Multiply $0.4\times60=24\text{ minutes}$.
:::

## Speed Tricks & Shortcuts

In exam questions, **simplify** means write an equal fraction or expression in a simpler form.

- **Simplify before cross-multiplying.** Before cross-multiplying $\dfrac{4}{24}=\dfrac{x}{84}$, simplify $\dfrac{4}{24}$ to $\dfrac{1}{6}$ first. Dividing $84\div6=14$ is much faster than multiplying $4\times84$ and dividing by $24$.
- **Distance shortcut.** For a fixed distance, a higher rate means less time. Check that your answer moves in that direction.

## Traps to Watch For

:::checklist
- Two quantities increasing together: check that the ratio $\dfrac{y}{x}$ stays constant for every nonzero $x$ before calling it direct proportion. {#increasing-not-direct}
- Setting up two equal ratios: put the matching labels in the same top and bottom spots on both sides. {#reverse-ratio-order}
- Converting decimal hours to minutes: multiply by $60$, so $0.8\text{ hour}$ is $48\text{ minutes}$. {#hours-to-minutes}
:::
