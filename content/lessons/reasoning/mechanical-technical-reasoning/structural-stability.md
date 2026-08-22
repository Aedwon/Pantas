---
_id: "lesson-mechanical-technical-reasoning-structural-stability"
title: "Structural Stability and Center of Gravity"
summary: "Learn how center of gravity and base of support determine whether an object stays balanced or tips over."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 9
isActive: true
---
## Core Concept

An object's **center of gravity** is the single point where its entire weight can be thought of as concentrated, balancing perfectly in every direction. For a symmetric, evenly-shaped object (like a uniform ball or box), the center of gravity sits at its geometric center.

An object's **base of support** is the area on the ground enclosed by its points (or edges) of contact with the ground. A four-legged table's base of support is the rectangle connecting its four feet; a person's base of support is the area between their two feet.

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "pyramid", "baseWidth": 3, "height": 1}, {"form": "pyramid", "baseWidth": 1, "height": 3, "tilt": 18}], "semanticsLabel": "Two triangular shapes standing upright: a short wide one with a low center of gravity within its wide base, and a tall narrow one with a high center of gravity tipping over."} -->

The core stability rule: an object remains stable (will not tip over) as long as an imaginary vertical line dropped straight down from its center of gravity falls within its base of support. If that vertical line falls outside the base of support (for example, if the object is tilted too far), the object becomes unstable and tips over.

This leads to two general principles for improving stability:

- A lower center of gravity makes an object more stable (harder to tip), since it takes a larger tilt before the vertical line from the center of gravity can be pushed outside the base of support.
- A wider base of support makes an object more stable, since there is more "room" for the vertical line from the center of gravity to stay within before tipping.

## Examples

### #1: Comparing Two Shapes' Stability

A short, wide pyramid and a tall, narrow pyramid have the same weight and are made of the same uniform material. Which one is more stable, and why?

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "pyramid", "baseWidth": 3, "height": 1}, {"form": "pyramid", "baseWidth": 1, "height": 3}], "semanticsLabel": "A short wide pyramid beside a tall narrow pyramid, each with its center of gravity marked, showing the short wide pyramid is more stable."} -->


**Solution:**
1. The short, wide pyramid has a lower center of gravity (since it is shorter) and a wider base of support (since it is wider).
2. Both factors, lower center of gravity and wider base, independently improve stability.
3. The short, wide pyramid is more stable.

### #2: Predicting When an Object Tips Over

A rectangular box is slowly tilted to one side. At what point does the box tip over, rather than settling back down?

<!-- FIGURE: {"kind": "stability-shape", "tilt": 22, "shapes": [{"form": "box", "baseWidth": 2, "height": 3}], "semanticsLabel": "A rectangular box tilted on one edge with a vertical plumb line dropped from its center of gravity to show tipping."} -->


**Solution:**
1. The box remains stable as long as the vertical line dropped from its center of gravity stays within its base of support (the bottom edge still touching the ground).
2. As the box tilts further, this vertical line shifts closer to the edge of the base of support.
3. The box tips over at the exact moment this vertical line moves beyond the edge of the base of support (falls outside the remaining contact edge with the ground): beyond that point, gravity pulls the box the rest of the way over instead of back down to its original position.

### #3: Why Lowering a Load Increases Stability

A moving truck carries cargo either stacked very high or spread out lower (same total weight either way). Which loading method makes the truck more stable while turning corners?

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "truck", "baseWidth": 2, "height": 3}, {"form": "truck", "baseWidth": 3, "height": 1}], "semanticsLabel": "Two truck cargo profiles: one with cargo stacked tall giving a high center of gravity, and one with cargo spread low giving a low center of gravity."} -->


**Solution:**
1. Stacking cargo high raises the truck's overall center of gravity; spreading cargo lower keeps the center of gravity closer to the ground.
2. A lower center of gravity requires a larger tilt (like from a sharp turn) before the vertical line from the center of gravity could be pushed outside the truck's base of support (the width between its wheels).
3. Loading the cargo lower makes the truck more stable while turning, since it can tilt further before tipping compared to a high-stacked load.

### #4: Widening the Base of Support

A person standing normally with feet close together is compared to the same person standing with feet spread wider apart. Which stance is more stable against being pushed sideways?

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "person", "baseWidth": 1, "height": 3}, {"form": "person", "baseWidth": 3, "height": 3}], "semanticsLabel": "Two stances comparing base of support width: feet close together with a narrow base, and feet spread wide with a wider, more stable base."} -->


**Solution:**
1. Spreading the feet wider apart increases the person's base of support (the ground area between the feet).
2. A wider base of support means the vertical line from the person's center of gravity can shift farther sideways (due to a push) before falling outside that base.
3. The wider stance (feet spread apart) is more stable against sideways pushes.

## Speed Tricks & Shortcuts

**Remember the two-factor stability rule together: Lower center of gravity + wider base of support = more stable.** Most stability comparison questions can be answered by checking these two factors against each other.

**Picture the "vertical line" test**: imagine dropping a straight line down from the center of gravity to the ground, and check whether that line stays within the object's base of support at the given tilt angle: this mental model directly predicts tipping.

**For real-world stability examples (trucks, furniture, people standing), identify what raises or lowers the center of gravity (like stacking cargo high vs. low) and what widens or narrows the base of support (like feet position or table leg spacing).**

## Traps to Watch For

### #1: Assuming Only Height (Not Base Width) Matters for Stability

> Stability depends on both the center of gravity's height and the base of support's width: considering only one factor while ignoring the other gives an incomplete comparison.

An object could have a low center of gravity but still be unstable if its base of support is extremely narrow; both factors must be considered together, not just one in isolation.

### #2: Assuming a Heavier Object Is Automatically More Stable

> Stability depends on the location of the center of gravity relative to the base of support, not simply on how much an object weighs overall.

A very heavy object with a high center of gravity and a narrow base can still tip over easily, despite its large weight: weight alone does not guarantee stability; the geometry (height and base width) is what matters.

### #3: Forgetting That Tipping Depends on the Tilt Angle, Not Just the Static Position

> An object can be perfectly stable while sitting still, but become unstable once tilted enough that the center of gravity's vertical line moves outside the base of support: stability is not a fixed, permanent property regardless of orientation.

Assuming an object "is stable" as an absolute, unchanging fact (rather than "is stable at this specific tilt angle") misses that further tilting can push any object past its tipping point, given enough tilt.
