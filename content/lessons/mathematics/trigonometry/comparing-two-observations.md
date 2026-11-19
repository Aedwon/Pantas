---
_id: "lesson-trigonometry-comparing-two-observations"
title: "Comparing Two Observations"
summary: "Use two sight lines to relate heights and distances."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 6
partCount: 6
ordering: 30
keyPoints:
  - "Use two sight lines to relate heights and distances."
---
## Core Concept

Draw both right triangles and use one equation for each line of sight.

## Examples

### #1: Two Observation Points

From point $A$ on level ground, the angle of elevation of the top of a building is $30^\circ$. After walking $100$ meters straight toward the building to point $B$, the angle of elevation becomes $60^\circ$. Find the height of the building. Assume both observations are from ground level and both points lie on the same straight line from the building.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "two-triangles-elevation", "labels": ["Point A: 30°", "Point B: 60°", "Distance AB = 100 m", "Building height = ?"], "semanticsLabel": "Diagram of two observation points A and B on ground with 30 and 60 degree elevation angles to a building 100 meters apart."} -->


**Solution:**
Let $x$ be the horizontal distance from $B$ to the building and $h$ the height.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "two-triangles-elevation", "labels": ["Point A (30°)", "Point B (60°)", "AB = 100", "Base distance = x", "Height = h"], "semanticsLabel": "Building with two observers A and B on same side showing elevation angles 30 and 60 degrees, separation 100, and distance x to base."} -->

1. From point $B$:

$$\tan60^\circ=\dfrac{h}{x}\quad\Rightarrow\quad h=x\sqrt3$$

2. From point $A$, whose distance to the building is $x+100$:

$$\tan30^\circ=\dfrac{h}{x+100}\quad\Rightarrow\quad h=\dfrac{x+100}{\sqrt3}$$

3. Set the two expressions for $h$ equal.

$$x\sqrt3=\dfrac{x+100}{\sqrt3}$$

4. Multiply by $\sqrt3$.

$$3x=x+100$$

5. Solve.

$$2x=100\quad\Rightarrow\quad x=50$$

6. Then:

$$h=50\sqrt3\approx86.6\text{ m}$$

## Speed Tricks & Shortcuts

For the **setup in Two Observation Points**, two ground-level observation points on the same side of the object, separated by distance $D$, with elevation angles $30^\circ$ and $60^\circ$, the height simplifies to:

$$h=\dfrac{\sqrt3}{2}D$$

Check with $D=100$: $\dfrac{\sqrt3}{2}(100)=50\sqrt3$, which matches. Do not apply that shortcut if the observation points, eye heights, terrain, or angles differ.
