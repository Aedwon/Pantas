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

<!-- ILLUSTRATION: observer on the ground looking up at a bird with the elevation angle marked from the horizontal, and an observer on a cliff looking down at a boat with the depression angle marked from the horizontal -->

Here is the key connection: the angle of depression from the top equals the angle of elevation from the bottom. They are alternate interior angles between two horizontal (parallel) lines. So you can always move the angle down into the triangle at the ground.

Picking the ratio is mechanical:

- Height and horizontal distance involved? Use tangent (opposite and adjacent).
- The slanted line of sight (or a ladder, a string, a ramp) involved? Use sine or cosine.

## Examples

### #1: Angle of Elevation

From a point $30$ meters from the base of a tree, the angle of elevation of the treetop is $60^\circ$. How tall is the tree?

<!-- ILLUSTRATION: a right triangle with a 30 m horizontal ground distance from an observer to a tree, the 60° angle of elevation at the observer, and the tree height marked "?" -->


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

<!-- ILLUSTRATION: a right triangle with a 10 m ladder as the hypotenuse against a wall, the foot 5 m from the wall along the ground, the angle with the ground marked "?" -->


**Solution:**
We know the hypotenuse (ladder) and the adjacent side (ground): cosine.

1. Set up the ratio.

$$\cos \theta = \dfrac{5}{10} = \dfrac{1}{2}$$

2. Ask: which angle has cosine $\dfrac{1}{2}$? From the memorized values:

$$\theta = 60^\circ$$

3. The ladder makes a $60^\circ$ angle with the ground.

### #3: Angle of Depression

From the top of a $50$-meter lighthouse, the angle of depression of a boat is $30^\circ$. How far is the boat from the base of the lighthouse?

<!-- ILLUSTRATION: a 50 m lighthouse with a horizontal line at the top, the 30° angle of depression down to a boat, and the horizontal distance from the base to the boat marked "?" -->


**Solution:**
Slide the depression angle down: the angle of elevation at the boat is also $30^\circ$. Now it is a tangent problem.

<!-- ILLUSTRATION: lighthouse of height 50 with a horizontal dashed line at the top, depression angle 30 degrees to a boat, and the equal elevation angle marked at the boat -->

1. Set up the tangent from the boat's position.

$$\tan 30^\circ = \dfrac{50}{d}$$

2. Substitute $\tan 30^\circ = \dfrac{\sqrt{3}}{3}$ and solve for $d$.

$$d = \dfrac{50}{\tan 30^\circ} = \dfrac{50 \times 3}{\sqrt{3}}$$

3. Simplify: $\dfrac{150}{\sqrt{3}} = \dfrac{150\sqrt{3}}{3}$.

$$d = 50\sqrt{3}$$

4. The boat is $50\sqrt{3}$ meters away, about $86.6$ meters.

### #4: Solving the Whole Triangle

In right triangle $ABC$, the right angle is at $C$, angle $A = 35^\circ$, and the hypotenuse is $40$. Find angle $B$ (exactly) and describe how to get sides $a$ and $b$.

<!-- ILLUSTRATION: right triangle ABC with the right angle at C, angle A = 35°, hypotenuse AB = 40, and sides a (opposite A) and b (opposite B) marked -->


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

<!-- ILLUSTRATION: a building of height "?" with two observation points on the ground; point A farther away with a 30° angle of elevation, point B 100 m closer with a 60° angle of elevation -->


**Solution:**
Two triangles share the same height. Let $x$ be the distance from $B$ to the building.

<!-- ILLUSTRATION: building with two observers on the same side, far point A with 30 degree elevation, near point B with 60 degree elevation, distance 100 between A and B, distance x from B to the base -->

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
