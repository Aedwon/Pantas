---
_id: "lesson-trigonometry-elevation-and-depression"
title: "Elevation and Depression"
summary: "Measure elevation and depression from the horizontal at the observer."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 4
partCount: 6
ordering: 0
keyPoints:
  - "Measure elevation and depression from the horizontal at the observer."
  - "Use elevation or depression to find height or horizontal distance."
---
## Core Concept

### Elevation and depression

A **line of sight** is the straight line from the observer's eye to the object. The **horizontal** is the level line through the observer's eye.

**Angle of elevation**: the angle from the horizontal up to the line of sight.

**Angle of depression**: the angle from the horizontal down to the line of sight.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Angle of Elevation (up from horizontal)", "Angle of Depression (down from horizontal)"], "semanticsLabel": "Diagram illustrating angle of elevation looking up from ground horizontal and angle of depression looking down from cliff horizontal."} -->

The angle is always measured from the horizontal, never from the vertical. It sits at the observer's eye, not at the object. If the object is above the observer's eye, the angle is an elevation. If the object is below, it is a depression.

Suppose the high observer and the low object are in the same vertical plane, and the ground is level. Then the horizontal through the high observer is parallel to the ground. The angle of depression from the top equals the angle of elevation from the bottom, because they are alternate interior angles.

## Examples

### #1: Angle of Elevation

From a point $30$ meters from the base of a tree on level ground, the angle of elevation of the treetop is $60^\circ$. Assume the observation point is at ground level. How tall is the tree?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["Observer", "Tree height = ?", "Ground = 30 m", "Elevation = 60°", "90°"], "semanticsLabel": "Right triangle showing observer 30 meters from tree with 60 degree elevation angle and tree height marked with a question mark."} -->


**Solution:**
Height is opposite the $60^\circ$ angle and the ground distance is adjacent, so use tangent.

1. Set up the ratio.

$$\tan 60^\circ = \dfrac{h}{30}$$

2. Substitute $\tan60^\circ=\sqrt3$.

$$\sqrt3=\dfrac{h}{30}$$

3. Multiply by $30$.

$$h=30\sqrt3$$

4. The height is $30\sqrt3$ meters, approximately $51.96$ meters.

### #2: Angle of Depression

From the top of a $50$-meter lighthouse above level sea level, the angle of depression of a boat is $30^\circ$. How far horizontally is the boat from the base of the lighthouse?

**Solution:**
The horizontal through the observer and the sea level are parallel, so the angle of elevation at the boat is also $30^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Height = 50 m", "Top depression = 30°", "Boat elevation = 30°", "Distance d"], "semanticsLabel": "Diagram showing 50 meter lighthouse with 30 degree angle of depression matching the 30 degree angle of elevation at the boat."} -->

1. Use tangent from the boat's position.

$$\tan30^\circ=\dfrac{50}{d}$$

2. Substitute $\tan30^\circ=\dfrac{\sqrt3}{3}$ and solve.

$$d=\dfrac{50}{\tan30^\circ}=\dfrac{150}{\sqrt3}=50\sqrt3$$

3. The horizontal distance is $50\sqrt3$ meters, approximately $86.6$ meters.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Lighthouse = 50 m", "Depression = 30°", "Boat distance = ?", "90°"], "semanticsLabel": "Lighthouse of height 50 meters with 30 degree angle of depression to a boat and unknown horizontal distance marked with a question mark."} -->

## Speed Tricks & Shortcuts

When an angle of elevation is $45^\circ$, the height above eye level and the horizontal distance are equal, because $\tan45^\circ=1$. This holds when the height is opposite and the horizontal distance is adjacent.

## Traps to Watch For

### #1: Measuring Depression from the Vertical

> The angle of depression is measured from a horizontal line, not from the vertical.

Draw a horizontal through the observer before marking the depression angle.

### #2: Putting the Elevation Angle at the Object

> The elevation angle is located at the observer.

Putting the angle at the top of the object changes which side is opposite and which is adjacent.
