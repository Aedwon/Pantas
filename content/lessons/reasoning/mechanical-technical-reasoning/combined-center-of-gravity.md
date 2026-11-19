---
_id: "lesson-mechanical-technical-reasoning-combined-center-of-gravity"
title: "Combined Center of Gravity"
summary: "Calculate the center of gravity of parts fastened together."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 6
partCount: 8
ordering: 22
keyPoints:
  - "Calculate the center of gravity of parts fastened together."
---
## Core Concept

An object made of several parts fastened together has one center of gravity for the whole. Each part has its own mass $m$ in kilograms. Its position $x$ in meters is where its own center of gravity lies. Measure every position from the same zero point, along the same line.

If gravity is the same throughout, use the masses. For two parts:

$$x_{cg} = \dfrac{m_1x_1 + m_2x_2}{m_1 + m_2}$$

For three parts, add the third part's term to the top and its mass to the bottom. The result lies in the range from the smallest to the largest position. With two parts of unequal mass, it sits closer to the heavier part, and with equal masses it is the midpoint.

With more parts, the formula decides, so do not guess by the heaviest part. The same formula works for heights if you measure each position upward from the floor.

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "pyramid", "baseWidth": 3, "height": 1}, {"form": "pyramid", "baseWidth": 1, "height": 3, "tilt": 18}], "semanticsLabel": "A short wide object and a tall narrow object with center-of-gravity projections shown relative to their bases of support."} -->

## Examples

### #1: Loads High or Low

A cabinet of mass $30$ kg is $1.2$ m tall. Its own center of gravity is $0.6$ m above the floor. It holds $90$ kg of books, centered side to side. The books' center of gravity is $0.2$ m up when they are on the bottom shelf, or $0.9$ m up when they are on the top shelf. Find the height of the combined center of gravity in each case. Which loading is harder to tip?

**Solution:**

1. Use the combined-position formula for heights, with the height called $y$. With the books low:

$$y = \dfrac{30(0.6) + 90(0.2)}{30 + 90} = \dfrac{36}{120} = 0.30 \text{ m}$$

2. With the books high:

$$y = \dfrac{30(0.6) + 90(0.9)}{30 + 90} = \dfrac{99}{120} = 0.825 \text{ m}$$

3. The base is the same in both cases, so $d$ is the same. A smaller $h_c$ gives a larger $\tan\theta$.
4. Books on the bottom shelf are harder to tip.

<!-- ILLUSTRATION: a tall cabinet 1.2 m high drawn twice, once with 90 kg of books on the bottom shelf and once on the top shelf, with a dot at 0.30 m and a dot at 0.825 m showing the combined center of gravity -->

### #2: A Load That Sticks Out

A crate has a base $1.0$ m wide and a mass of $40$ kg. Its center of gravity is $0.5$ m from the left edge. A $120$ kg load is fastened on top and sticks out to the right. The load's center of gravity is $1.3$ m from the left edge. Does the crate stay down?

**Solution:**

1. Measure from the left edge. The crate's base runs from $0$ to $1.0$ m.
2. Find the combined center of gravity:

$$x = \dfrac{40(0.5) + 120(1.3)}{40 + 120} = \dfrac{176}{160} = 1.1 \text{ m}$$

3. The weight line is at $1.1$ m, which is past the right edge at $1.0$ m.
4. It is outside the base, so the crate tips to the right.

<!-- ILLUSTRATION: a crate with a base 1.0 m wide from 0 to 1.0 m, a 120 kg load sticking out on the right, a dot at 1.1 m for the combined center of gravity, and a weight line landing past the right edge -->
