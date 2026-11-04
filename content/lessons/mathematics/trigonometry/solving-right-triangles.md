---
_id: "lesson-trigonometry-solving-right-triangles"
title: "Solving Right Triangles (Angles of Elevation and Depression)"
summary: "How to use trigonometric ratios to find heights and distances in elevation and depression problems."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

To **solve a right triangle** means to find its missing sides and angles. A right triangle has one $90^\circ$ angle. The side opposite the right angle is the **hypotenuse**, and it is always the longest side.

Pick one acute angle, called $\theta$. The side across from $\theta$ is the **opposite** side. The leg that touches $\theta$ is the **adjacent** side. The opposite and adjacent sides change when you pick the other acute angle.

The three trigonometric ratios compare two sides of the triangle. Remember them as **SOH-CAH-TOA**.

$$\sin\theta=\dfrac{\text{opposite}}{\text{hypotenuse}}\qquad\cos\theta=\dfrac{\text{adjacent}}{\text{hypotenuse}}\qquad\tan\theta=\dfrac{\text{opposite}}{\text{adjacent}}$$

Because the hypotenuse is the longest side, $\sin\theta$ and $\cos\theta$ of an acute angle are always greater than $0$ and less than $1$. The value of $\tan\theta$ can be any positive number. If you get a sine or cosine of $1$ or more, you put the wrong side on top.

Three more facts help you solve a right triangle.

- The two acute angles add to $90^\circ$, so one acute angle is $90^\circ$ minus the other.
- The **Pythagorean theorem** says $\text{leg}_1^2+\text{leg}_2^2=\text{hypotenuse}^2$.
- Three angles have exact ratios that you should know:
  - $30^\circ$: $\sin=\dfrac12$, $\cos=\dfrac{\sqrt3}{2}$, $\tan=\dfrac{\sqrt3}{3}$.
  - $45^\circ$: $\sin=\dfrac{\sqrt2}{2}$, $\cos=\dfrac{\sqrt2}{2}$, $\tan=1$.
  - $60^\circ$: $\sin=\dfrac{\sqrt3}{2}$, $\cos=\dfrac12$, $\tan=\sqrt3$.

**Finding a side.** Choose the ratio that holds the side you know and the side you want. Write the equation, then solve for the unknown side.

**Finding an angle.** Use an inverse function when you know two sides and want the angle. The inverse sine, written $\sin^{-1}$, undoes the sine: if $\sin\theta=0.6$, then $\theta=\sin^{-1}(0.6)$. The inverse cosine $\cos^{-1}$ and inverse tangent $\tan^{-1}$ work the same way. Put your calculator in degree mode first. In a right triangle the other angles are acute, so the calculator's answer is the angle you want.

If the ratio is an exact value from that list, you can read the angle without a calculator. For other ratios, such as $\tan\theta=0.375$, use the calculator. Round only at the last step.

### Elevation and depression

A **line of sight** is the straight line from the observer's eye to the object. The **horizontal** is the level line through the observer's eye.

**Angle of elevation**: the angle from the horizontal up to the line of sight.

**Angle of depression**: the angle from the horizontal down to the line of sight.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Angle of Elevation (up from horizontal)", "Angle of Depression (down from horizontal)"], "semanticsLabel": "Diagram illustrating angle of elevation looking up from ground horizontal and angle of depression looking down from cliff horizontal."} -->

The angle is always measured from the horizontal, never from the vertical. It sits at the observer's eye, not at the object. If the object is above the observer's eye, the angle is an elevation. If the object is below, it is a depression.

Suppose the high observer and the low object are in the same vertical plane, and the ground is level. Then the horizontal through the high observer is parallel to the ground. The angle of depression from the top equals the angle of elevation from the bottom, because they are alternate interior angles.

### Eye height

An observer's eyes are above the ground. The angle is measured from the eye, so the right triangle starts at eye level, not at the ground. The ratio gives the height above eye level. Add the eye height to get the height above the ground.

If a problem says to assume the observer is at ground level, no adjustment is needed.

### Choosing a ratio

Look at the sides in your triangle, not at the story.

- If you know the angle and a leg, and you want the other leg, tangent connects the two legs.
- If the hypotenuse is known or wanted, such as a ladder, rope, ramp surface, or line of sight, use sine or cosine.
- If you know the angle and the opposite or adjacent side, you can find the other two sides.

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

2. The list gives the angle with cosine $\dfrac12$.

$$\theta=\cos^{-1}\left(\dfrac12\right)=60^\circ$$

3. The ladder makes a $60^\circ$ angle with the ground.

### #3: An Angle That Is Not a Special Angle

A ramp rises $3$ meters over a horizontal distance of $8$ meters. What angle does the ramp make with the ground? Give the answer to the nearest tenth of a degree.

<!-- ILLUSTRATION: A right triangle that models a ramp. The vertical side is labeled "Rise = 3 m", the horizontal side is labeled "Horizontal distance = 8 m", and the angle between the ramp and the ground is labeled "Angle = ?". -->

**Solution:**
The rise is opposite the wanted angle and the horizontal distance is adjacent, so use tangent.

1. Set up the ratio.

$$\tan\theta=\dfrac38=0.375$$

2. The value $0.375$ is not in the list of exact values, so use the inverse tangent on a calculator in degree mode.

$$\theta=\tan^{-1}(0.375)\approx20.6^\circ$$

3. The ramp makes an angle of about $20.6^\circ$ with the ground.

4. Check: $\tan20.6^\circ\approx0.376$, which is close to $\dfrac38$.

### #4: Angle of Depression

From the top of a $50$-meter lighthouse above level sea level, the angle of depression of a boat is $30^\circ$. How far horizontally is the boat from the base of the lighthouse?

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["Lighthouse = 50 m", "Depression = 30°", "Boat distance = ?", "90°"], "semanticsLabel": "Lighthouse of height 50 meters with 30 degree angle of depression to a boat and unknown horizontal distance marked with a question mark."} -->


**Solution:**
The horizontal through the observer and the sea level are parallel, so the angle of elevation at the boat is also $30^\circ$.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "elevation-depression", "labels": ["Height = 50 m", "Top depression = 30°", "Boat elevation = 30°", "Distance d"], "semanticsLabel": "Diagram showing 50 meter lighthouse with 30 degree angle of depression matching the 30 degree angle of elevation at the boat."} -->

1. Use tangent from the boat's position.

$$\tan30^\circ=\dfrac{50}{d}$$

2. Substitute $\tan30^\circ=\dfrac{\sqrt3}{3}$ and solve.

$$d=\dfrac{50}{\tan30^\circ}=\dfrac{150}{\sqrt3}=50\sqrt3$$

3. The horizontal distance is $50\sqrt3$ meters, approximately $86.6$ meters.

### #5: Adding the Observer's Eye Height

A student whose eyes are $1.6$ meters above level ground stands $40$ meters from a flagpole. The angle of elevation of the top of the pole, measured from the student's eyes, is $35^\circ$. How tall is the flagpole? Give the answer to the nearest tenth of a meter.

<!-- ILLUSTRATION: A level ground line with a student on the left and a vertical flagpole on the right. The student's eyes are labeled 1.6 m above the ground. The distance between the student and the pole is labeled 40 m. A line of sight from the student's eyes to the top of the pole makes a 35° angle of elevation. The pole height is labeled "Pole height = ?". -->

**Solution:**
The angle is measured from eye level. The triangle gives only the part of the pole above the student's eyes.

1. Let $h$ be the height above eye level. The horizontal distance is adjacent, so use tangent.

$$\tan35^\circ=\dfrac{h}{40}$$

2. Solve for $h$ with a calculator in degree mode.

$$h=40\tan35^\circ\approx40(0.7002)\approx28.0\text{ m}$$

3. Add the eye height to get the height above the ground.

$$28.0+1.6=29.6\text{ m}$$

4. The flagpole is about $29.6$ meters tall.

### #6: Solving the Whole Triangle From an Angle and the Hypotenuse

In right triangle $ABC$, the right angle is at $C$, angle $A=35^\circ$, and the hypotenuse $c$ is $40$. Find angle $B$ and sides $a$ and $b$. Give sides to the nearest tenth.

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["A = 35°", "B = ?", "C = 90°", "Hypotenuse c = 40", "Side a", "Side b"], "semanticsLabel": "Right triangle ABC with right angle at C, angle A equal to 35 degrees, hypotenuse 40, angle B unknown, and legs a and b."} -->


**Solution:**
1. The acute angles add to $90^\circ$.

$$B=90^\circ-35^\circ=55^\circ$$

2. Side $a$ is opposite angle $A$, and $c$ is the hypotenuse, so use sine.

$$a=40\sin35^\circ\approx40(0.5736)\approx22.9$$

3. Side $b$ is adjacent to angle $A$, so use cosine.

$$b=40\cos35^\circ\approx40(0.8192)\approx32.8$$

4. Check with the Pythagorean theorem: $22.9^2+32.8^2\approx1600$, and $40^2=1600$.

### #7: Solving the Whole Triangle From Two Legs

In right triangle $ABC$, the right angle is at $C$, leg $a=6$, and leg $b=8$. Find the hypotenuse and the angles $A$ and $B$. Give angles to the nearest tenth of a degree.

<!-- ILLUSTRATION: Right triangle ABC with the right angle at C. Leg a is labeled 6 and leg b is labeled 8. The hypotenuse is labeled "c = ?", angle A is labeled "A = ?", and angle B is labeled "B = ?". -->

**Solution:**
1. Find the hypotenuse with the Pythagorean theorem.

$$c=\sqrt{6^2+8^2}=\sqrt{100}=10$$

2. Leg $a$ is opposite angle $A$ and leg $b$ is adjacent to it, so use tangent.

$$\tan A=\dfrac68=0.75\quad\Rightarrow\quad A=\tan^{-1}(0.75)\approx36.9^\circ$$

3. The acute angles add to $90^\circ$.

$$B=90^\circ-36.9^\circ=53.1^\circ$$

4. The hypotenuse is $10$, angle $A$ is about $36.9^\circ$, and angle $B$ is about $53.1^\circ$.

### #8: Two Observation Points

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

When an angle of elevation is $45^\circ$, the height above eye level and the horizontal distance are equal, because $\tan45^\circ=1$. This holds when the height is opposite and the horizontal distance is adjacent.

For the **specific geometry in Example #8**, two ground-level observation points on the same side of the object, separated by distance $D$, with elevation angles $30^\circ$ and $60^\circ$, the height simplifies to:

$$h=\dfrac{\sqrt3}{2}D$$

Check with $D=100$: $\dfrac{\sqrt3}{2}(100)=50\sqrt3$, which matches. Do not apply that shortcut if the observation points, eye heights, terrain, or angles differ.

## Traps to Watch For

### #1: Measuring Depression from the Vertical

> The angle of depression is measured from a horizontal line, not from the vertical.

Draw a horizontal through the observer before marking the depression angle.

### #2: Putting the Elevation Angle at the Object

> The elevation angle is located at the observer.

Putting the angle at the top of the object changes which side is opposite and which is adjacent.

### #3: Forgetting the Observer's Height

> If an eye height is given and the angle is measured from the eyes, add the eye height to the result.

The ratio gives the height above eye level. Add the eye height to get the height above the ground. For a depression from a high eye, the ratio gives the drop from eye level, so subtract it from the eye's height above the ground to find the object's height.

### #4: Choosing a Ratio from the Story Instead of the Triangle

> Choose sine, cosine, or tangent from the sides actually known and wanted.

A horizontal ground distance often leads to tangent when height is the other side, but that is not a rule by itself. Label the triangle first and then choose the ratio.

### #5: Wrong Calculator Mode

> An angle in degrees needs the calculator in degree mode.

In radian mode, $\tan35$ gives about $0.47$ instead of $0.70$, so every answer is wrong. Check the mode before you start, and test it with $\tan45$, which must give $1$ in degree mode.
