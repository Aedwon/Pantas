---
_id: "lesson-trigonometry-solving-right-triangles"
title: "Solving Right Triangles (Angles of Elevation and Depression)"
summary: "How to use trigonometric ratios to find heights and distances in real-world elevation and depression problems."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 12
isActive: true
---
## Core Concept

To **solve a right triangle** means to find all its missing sides and angles. You need only two tools: the trigonometric ratios (SOH-CAH-TOA) for sides, and the fact that the two acute angles add up to $90^\circ$.

The classic word problems use two special angles, both measured from the horizontal:

**Angle of elevation**: you look up at something. The angle opens upward from your horizontal line of sight to the object (a kite, a building top, an airplane).

**Angle of depression**: you look down from a high place. The angle opens downward from your horizontal line of sight to the object (a boat seen from a cliff).

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Angle of Elevation (up from horizontal)", "Angle of Depression (down from horizontal)"], "semanticsLabel": "Diagram illustrating angle of elevation looking up from ground horizontal and angle of depression looking down from cliff horizontal."} -->

Here is the key connection: the angle of depression from the top equals the angle of elevation from the bottom. They are alternate interior angles between two horizontal (parallel) lines. So you can always move the angle down into the triangle at the ground.

Picking the ratio is mechanical:

- Height and horizontal distance involved? Use tangent (opposite and adjacent).
- The slanted line of sight (or a ladder, a string, a ramp) involved? Use sine or cosine.

## Examples

### #1: Angle of Elevation

From a point $30$ meters from the base of a tree, the angle of elevation of the treetop is $60^\circ$. How tall is the tree?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["Observer", "Tree height = ?", "Ground = 30 m", "Elevation = 60°", "90°"], "semanticsLabel": "Right triangle showing observer 30 meters from tree with 60 degree elevation angle and tree height marked with a question mark."} -->


**Solution:**
Height (opposite) and ground distance (adjacent): tangent.

1. Set up the ratio.

$$\tan 60^\circ = \dfrac{h}{30}$$

2. Substitute the exact value $\tan 60^\circ = \sqrt{3}$.

$$\sqrt{3} = \dfrac{h}{30}$$

3. Multiply both sides by $30$.

$$h = 30\sqrt{3}$$

4. The tree is $30\sqrt{3}$ meters tall, about $51.96$, so roughly $52$ meters.

### #2: Finding the Angle

A $10$-meter ladder leans against a wall, with its foot $5$ meters from the wall. What angle does the ladder make with the ground?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["Ladder = 10 m", "Ground distance = 5 m", "Angle with ground = ?", "90°"], "semanticsLabel": "Right triangle showing 10 meter ladder against wall with foot 5 meters from base and ground angle marked with a question mark."} -->


**Solution:**
We know the hypotenuse (ladder) and the adjacent side (ground): cosine.

1. Set up the ratio.

$$\cos \theta = \dfrac{5}{10} = \dfrac{1}{2}$$

2. Ask: which angle has cosine $\dfrac{1}{2}$? From the memorized values:

$$\theta = 60^\circ$$

3. The ladder makes a $60^\circ$ angle with the ground.

### #3: Angle of Depression

From the top of a $50$-meter lighthouse, the angle of depression of a boat is $30^\circ$. How far is the boat from the base of the lighthouse?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Lighthouse = 50 m", "Depression = 30°", "Boat distance = ?", "90°"], "semanticsLabel": "Lighthouse of height 50 meters with 30 degree angle of depression to a boat and unknown horizontal distance marked with a question mark."} -->


**Solution:**
Slide the depression angle down: the angle of elevation at the boat is also $30^\circ$. Now it is a tangent problem.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Height = 50 m", "Top depression = 30°", "Boat elevation = 30°", "Distance d"], "semanticsLabel": "Diagram showing 50 meter lighthouse with 30 degree angle of depression matching the 30 degree angle of elevation at the boat."} -->

1. Set up the tangent from the boat's position.

$$\tan 30^\circ = \dfrac{50}{d}$$

2. Substitute $\tan 30^\circ = \dfrac{\sqrt{3}}{3}$ and solve for $d$.

$$d = \dfrac{50}{\tan 30^\circ} = \dfrac{50 \times 3}{\sqrt{3}}$$

3. Simplify: $\dfrac{150}{\sqrt{3}} = \dfrac{150\sqrt{3}}{3}$.

$$d = 50\sqrt{3}$$

4. The boat is $50\sqrt{3}$ meters away, about $86.6$ meters.

### #4: Solving the Whole Triangle

In right triangle $ABC$, the right angle is at $C$, angle $A = 35^\circ$, and the hypotenuse is $40$. Find angle $B$ (exactly) and describe how to get sides $a$ and $b$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["A = 35°", "B = 55°", "C = 90°", "Hypotenuse c = 40", "Side a", "Side b"], "semanticsLabel": "Right triangle ABC with right angle at C, angle A equal to 35 degrees, angle B equal to 55 degrees, hypotenuse 40, and legs a and b."} -->


**Solution:**
Angles first, then sides.

1. The acute angles add to $90^\circ$.

$$B = 90 - 35 = 55^\circ$$

2. Side $a$ (opposite angle $A$) uses sine with the hypotenuse.

$$a = 40 \sin 35^\circ$$

3. Side $b$ (adjacent to angle $A$) uses cosine.

$$b = 40 \cos 35^\circ$$

4. On the CET, non-special angles like $35^\circ$ stay as expressions or come with given decimal values. The setup earns the point: know which ratio, and the arithmetic follows.

### #5: Two Observation Points (Exam Level)

From point $A$ on level ground, the angle of elevation of the top of a building is $30^\circ$. After walking $100$ meters straight toward the building to point $B$, the angle of elevation becomes $60^\circ$. Find the height of the building.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "two-triangles-elevation", "labels": ["Point A: 30°", "Point B: 60°", "Distance AB = 100 m", "Building height = ?"], "semanticsLabel": "Diagram of two observation points A and B on ground with 30 and 60 degree elevation angles to a building 100 meters apart."} -->


**Solution:**
Two triangles share the same height. Let $x$ be the distance from $B$ to the building.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "two-triangles-elevation", "labels": ["Point A (30°)", "Point B (60°)", "AB = 100", "Base distance = x", "Height = h"], "semanticsLabel": "Building with two observers A and B on same side showing elevation angles 30 and 60 degrees, separation 100, and distance x to base."} -->

1. From point $B$:

$$\tan 60^\circ = \dfrac{h}{x} \quad \Rightarrow \quad h = x\sqrt{3}$$

2. From point $A$ (distance $x + 100$):

$$\tan 30^\circ = \dfrac{h}{x + 100} \quad \Rightarrow \quad h = \dfrac{x + 100}{\sqrt{3}}$$

3. Both equal $h$, so set them equal.

$$x\sqrt{3} = \dfrac{x + 100}{\sqrt{3}}$$

4. Multiply both sides by $\sqrt{3}$.

$$3x = x + 100$$

5. Solve.

$$2x = 100 \quad \Rightarrow \quad x = 50$$

6. Then the height is:

$$h = 50\sqrt{3} \approx 86.6 \text{ meters}$$

## Speed Tricks & Shortcuts

Draw the triangle every time, even a five-second sketch. Label the horizontal, the vertical, and the line of sight. Most wrong answers come from solving a triangle different from the one described.

When the angle of elevation is $45^\circ$, the height equals the horizontal distance (because $\tan 45^\circ = 1$). Test-makers love this freebie: a $45^\circ$ shadow problem needs no computation at all.

In two-point problems with $30^\circ$ and $60^\circ$ (like Example $5$), the answer height is always the distance between the two points times $\dfrac{\sqrt{3}}{2}$. Check: $100 \times \dfrac{\sqrt{3}}{2} = 50\sqrt{3}$. If you can recall this pattern, you save two minutes.

## Traps to Watch For

### #1: Measuring Depression from the Wall

> The angle of depression is measured from the horizontal, not from the vertical.

Students draw the depression angle between the cliff face and the line of sight, which builds the complementary triangle: their answer is right for the wrong angle. Always start the depression angle from a horizontal line at the eye level of the high observer.

### #2: The Angle Sits at the Observer

> The elevation angle is at the eye of the person looking, never at the object.

Putting the $60^\circ$ at the top of the tree instead of at the observer swaps opposite and adjacent, turning $30\sqrt{3}$ into $\dfrac{30}{\sqrt{3}}$. Both versions appear in the choices, so anchor the angle where the looking happens.

### #3: Forgetting the Observer's Height

> If eye level is given, add it at the end.

When a problem says the observer's eyes are $1.5$ meters above the ground, the tangent computation gives the height above the eyes. The true height of the flagpole is that result plus $1.5$. The choice missing the add-on is always there, looking innocent.

### #4: Sine with a Horizontal Distance

> Distance along the ground pairs with tangent, not sine.

Sine needs the hypotenuse (the slanted line of sight). If the problem gives the horizontal distance to the base, the slant is not involved: use tangent. Reach for sine or cosine only when a ladder, string, ramp, or line-of-sight length is given.
