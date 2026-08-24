---
_id: "lesson-trigonometry-solving-right-triangles"
title: "Solving Right Triangles (Angles of Elevation and Depression)"
summary: "How to use trigonometric ratios to find heights and distances in elevation and depression problems."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

To **solve a right triangle** means to find its missing sides and angles. Two main tools are the trigonometric ratios (SOH-CAH-TOA) and the fact that the two acute angles of a right triangle add to $90^\circ$.

Many word problems use two special angles, both measured from a horizontal line:

**Angle of elevation**: the angle from a horizontal line of sight upward to an object.

**Angle of depression**: the angle from a horizontal line of sight downward to an object.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Angle of Elevation (up from horizontal)", "Angle of Depression (down from horizontal)"], "semanticsLabel": "Diagram illustrating angle of elevation looking up from ground horizontal and angle of depression looking down from cliff horizontal."} -->

When the observer's horizontal line and the ground are parallel, the angle of depression from the top equals the corresponding angle of elevation from the lower point. This follows from alternate interior angles formed by the line of sight crossing the parallel horizontals.

Picking a ratio depends on the sides in the particular triangle:

- If the unknown height and a horizontal distance are the opposite and adjacent sides, tangent is convenient.
- If a slanted hypotenuse such as a ladder, string, ramp, or line of sight is known, sine or cosine may be convenient.

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

### #2: Finding the Angle

A $10$-meter ladder leans against a vertical wall, with its foot $5$ meters from the wall. What angle does the ladder make with the horizontal ground?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["Ladder = 10 m", "Ground distance = 5 m", "Angle with ground = ?", "90°"], "semanticsLabel": "Right triangle showing 10 meter ladder against wall with foot 5 meters from base and ground angle marked with a question mark."} -->


**Solution:**
The ladder is the hypotenuse and the ground distance is adjacent to the wanted angle, so use cosine.

1. Set up the ratio.

$$\cos\theta=\dfrac{5}{10}=\dfrac12$$

2. The principal acute angle with cosine $1/2$ is:

$$\theta=60^\circ$$

3. The ladder makes a $60^\circ$ angle with the ground.

### #3: Angle of Depression

From the top of a $50$-meter lighthouse above level sea level, the angle of depression of a boat is $30^\circ$. How far horizontally is the boat from the base of the lighthouse?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Lighthouse = 50 m", "Depression = 30°", "Boat distance = ?", "90°"], "semanticsLabel": "Lighthouse of height 50 meters with 30 degree angle of depression to a boat and unknown horizontal distance marked with a question mark."} -->


**Solution:**
The horizontal through the observer and the sea level are parallel, so the angle of elevation at the boat is also $30^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Height = 50 m", "Top depression = 30°", "Boat elevation = 30°", "Distance d"], "semanticsLabel": "Diagram showing 50 meter lighthouse with 30 degree angle of depression matching the 30 degree angle of elevation at the boat."} -->

1. Use tangent from the boat's position.

$$\tan30^\circ=\dfrac{50}{d}$$

2. Substitute $\tan30^\circ=\dfrac{\sqrt3}{3}$ and solve.

$$d=\dfrac{50}{\tan30^\circ}=\dfrac{150}{\sqrt3}=50\sqrt3$$

3. The horizontal distance is $50\sqrt3$ meters, approximately $86.6$ meters.

### #4: Solving the Whole Triangle

In right triangle $ABC$, the right angle is at $C$, angle $A=35^\circ$, and the hypotenuse is $40$. Find angle $B$ exactly and describe how to obtain sides $a$ and $b$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["A = 35°", "B = 55°", "C = 90°", "Hypotenuse c = 40", "Side a", "Side b"], "semanticsLabel": "Right triangle ABC with right angle at C, angle A equal to 35 degrees, angle B equal to 55 degrees, hypotenuse 40, and legs a and b."} -->


**Solution:**
1. The acute angles add to $90^\circ$.

$$B=90-35=55^\circ$$

2. Side $a$, opposite angle $A$, is found with sine.

$$a=40\sin35^\circ$$

3. Side $b$, adjacent to angle $A$, is found with cosine.

$$b=40\cos35^\circ$$

4. If a numerical approximation is required, evaluate the trigonometric functions with a calculator or with values supplied by the problem.

### #5: Two Observation Points

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

Draw a quick triangle before choosing a ratio. Label the horizontal distance, vertical height, line of sight, and the given angle. This prevents most opposite/adjacent mix-ups.

When an angle of elevation is $45^\circ$ and the right-triangle model uses height as the opposite side and horizontal distance as the adjacent side, those two lengths are equal because $\tan45^\circ=1$.

For the **specific geometry in Example #5**—two ground-level observation points on the same side of the object, separated by distance $D$, with elevation angles $30^\circ$ and $60^\circ$—the height simplifies to:

$$h=\dfrac{\sqrt3}{2}D$$

Do not apply that shortcut if the observation points, eye heights, terrain, or angles differ.

## Traps to Watch For

### #1: Measuring Depression from the Vertical

> The angle of depression is measured from a horizontal line, not from the vertical.

Draw a horizontal through the observer before marking the depression angle.

### #2: Putting the Elevation Angle at the Object

> The elevation angle is located at the observer.

Putting the angle at the top of the object changes which side is opposite and which is adjacent.

### #3: Forgetting the Observer's Height

> If an eye height is given, account for it explicitly.

A tangent calculation often gives the vertical difference between eye level and the target. Add or subtract the observer's height as the geometry requires to get the requested total height.

### #4: Choosing a Ratio from the Story Instead of the Triangle

> Choose sine, cosine, or tangent from the sides actually known and wanted.

A horizontal ground distance often leads to tangent when height is the other side, but that is not a rule by itself. Label the triangle first and then choose the ratio.
