---
_id: "lesson-spatial-abstract-reasoning-figure-series"
title: "Figure Series (Predicting the Next Shape in a Pattern)"
summary: "Learn how to track how a shape changes step by step across a series of figures and predict what comes next."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 10
isActive: true
---
## Core Concept

A **figure series** shows a sequence of shapes or figures, each one changing slightly from the one before it, following a hidden rule. Your task is to figure out the rule and predict the next figure in the sequence.

Since figures cannot easily be described with numbers alone, describe each figure using its individual features, then track how each feature changes step by step:

- **Number of sides or parts**: does the shape gain or lose sides, dots, or lines each step?
- **Rotation**: does the shape (or a marking on it, like an arrow or a dot) turn a certain number of degrees each step (commonly $45°$, $90°$, or $180°$)?
- **Shading/fill**: does the shape (or parts of it) switch between filled (black) and empty (white) each step, or does the shaded portion grow or shrink?
- **Size**: does the shape grow or shrink at each step?
- **Position**: does an element (like a dot or small shape) move to a different location within or around the main figure at each step?

<!-- ILLUSTRATION: a row of four squares, each with a black dot in a different corner, moving clockwise one corner at a time from square to square, illustrating a rotating-position pattern -->

The strongest strategy is to check each feature separately against every figure in the series, since a series can combine multiple changing features at once (for example, a shape that both rotates and changes shading at each step).

## Examples

### #1: A Rotating Line Pattern

A series shows a square with a single line inside it, pointing in different directions: first pointing straight up, then pointing to the upper-right (a $45°$ turn clockwise), then pointing directly right (another $45°$ turn clockwise). What direction should the line point in the fourth figure?

**Solution:**
1. Track the rotation feature: the line turns $45°$ clockwise at each step (up → upper-right → right).
2. Continuing this same $45°$ clockwise rotation from "right," the next position would be "lower-right."
3. The fourth figure's line should point to the lower-right (a further $45°$ clockwise turn from "right").

### #2: A Growing Number of Sides

A series shows a triangle (3 sides), then a square (4 sides), then a pentagon (5 sides). How many sides should the fourth figure have?

**Solution:**
1. Track the number of sides feature: $3, 4, 5, \ldots$, increasing by $1$ each step.
2. Continuing the pattern, the fourth figure should have $6$ sides.
3. The fourth figure should be a hexagon.

### #3: An Alternating Shading Pattern

A series shows a fully black circle, then a fully white (empty) circle, then a fully black circle again. What should the fourth figure look like?

**Solution:**
1. Track the shading feature: black, white, black, following an alternating (every-other) pattern.
2. Since the pattern alternates strictly, the figure after "black" should return to "white."
3. The fourth figure should be a fully white (empty) circle.

### #4: Combining Two Changing Features

A series shows: a small black triangle, then a medium white triangle, then a large black triangle. Predict the fourth figure, tracking both the size and shading features separately.

**Solution:**
1. Track size separately: small, medium, large, increasing by one step size each time. The next size should be extra large.
2. Track shading separately: black, white, black, alternating. The next shading should be white.
3. Combining both tracked features, the fourth figure should be an extra large, white triangle.

## Speed Tricks & Shortcuts

**List each feature (shape, rotation, shading, size, position) on separate mental "tracks," and follow only one track at a time.** Trying to track everything at once often causes confusion; isolating one feature per pass is faster and more accurate.

**For rotation patterns, identify the exact number of degrees turned between each figure** (commonly $45°$, $90°$, or $180°$) by comparing the position of a marked feature (like a dot, line, or arrow) between consecutive figures.

**Check whether a pattern is cumulative (steadily increasing/decreasing, like sides growing by $1$ each time) or alternating (switching back and forth between just two states, like black/white)** — these are the two most common pattern families.

## Traps to Watch For

### #1: Tracking Only One Feature When Multiple Are Changing

> A figure series can change several features at once (shape, shading, size, rotation) — check each feature separately rather than assuming only one thing is changing.

Missing that both size and shading are changing at once (as in Example 4) leads to only half-correct predictions, even if the other feature was tracked accurately.

### #2: Assuming a Rotation Pattern Continues in the Same Visual "Direction" You Expect

> Carefully confirm whether a shape is rotating clockwise or counterclockwise by comparing at least two consecutive steps, rather than assuming a direction.

Predicting the wrong rotation direction for the next figure produces a plausible-looking but incorrect answer, especially in multiple-choice options that include the opposite rotation direction as a trap.

### #3: Missing an Alternating Pattern by Assuming It's Cumulative

> Not every changing feature increases or decreases steadily — some features (especially shading) commonly alternate between just two states instead.

Assuming shading will keep "getting darker" rather than recognizing a simple black-white-black alternating pattern leads to predicting an impossible fourth state instead of correctly returning to the earlier one.
