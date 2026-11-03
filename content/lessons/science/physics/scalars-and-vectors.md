---
_id: "lesson-physics-scalars-and-vectors"
title: "Scalars and Vectors (Vector Addition and Resolution)"
summary: "The difference between scalar and vector physical quantities, and how to add vectors, split them into components, and rebuild a resultant with its direction."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

### Scalars and Vectors

The **magnitude** of a quantity is its size, such as $5$ or $20$. The **unit** says what is being measured, such as meters or newtons.

A **scalar** is fully described by a magnitude and a unit. Examples are mass, temperature, time, speed, energy, and distance (the length of the path traveled).

A **vector** needs a magnitude, a unit, and a direction. Examples are displacement, velocity, acceleration, force, and momentum. A vector also follows the vector-addition rules below.

Whether a quantity is a vector depends on the quantity itself. It does not depend on whether a sentence happens to use a direction word. A problem may ask only for the magnitude of a vector, and that magnitude is then a scalar.

A scalar can be negative, as in $-5\,^{\circ}\mathrm C$. That sign shows a position on a scale. It is not a direction.

We draw a vector as an arrow. The arrow points in the vector's direction. Its length shows the magnitude on a chosen scale.

<!-- FIGURE: {"kind": "concept-diagram", "type": "vector-diagram", "vectors": [{"label": "5 N East", "angle": 0, "magnitude": 5}, {"label": "8 N Northeast", "angle": 45, "magnitude": 8}], "semanticsLabel": "Two vector arrows comparing a 5 N force pointing east and an 8 N force pointing northeast."} -->
### Distance, Displacement, Speed, and Velocity

**Distance** is the total length of the path traveled. It is a scalar. **Displacement** is the straight-line change in position, from the start to the end, with its direction. It is a vector.

**Speed** is how fast something moves. **Velocity** is speed together with direction. At any instant, the speed is the magnitude of the velocity.

**Average speed** is the total distance divided by the time. **Average velocity** is the displacement divided by the time. These two can differ, as Example #3 shows.

### Adding Vectors

The sum of vectors is called the **resultant**. It is the single vector that has the same effect as all of them together. Only vectors of the same kind, in the same unit, can be added. A force can be added to a force, but not to a velocity.

The order of adding does not change the resultant. $\vec A+\vec B$ gives the same vector as $\vec B+\vec A$.

The **negative** of a vector has the same magnitude and the opposite direction. To subtract, add the negative: $\vec A-\vec B=\vec A+(-\vec B)$.

On a straight line, choose one direction as positive. Give each vector a sign: positive if it points that way, negative if it points the other way. Then add the signed numbers. This is how vectors in opposite directions "subtract".

The resultant can be larger than, equal to, or smaller than the vectors added. It equals the sum of the magnitudes only when the vectors point the same way.

For vectors in a plane, use **tip-to-tail** construction. Draw the first arrow. Draw the second arrow starting at the tip of the first. The resultant runs from the start of the first arrow to the tip of the last.

### Perpendicular Vectors

Two vectors are **perpendicular** when they meet at a right angle. If their magnitudes are $A$ and $B$, they form the two legs of a right triangle, and the resultant is the hypotenuse:

$$R=\sqrt{A^2+B^2}.$$

This Pythagorean shortcut works only when the two vectors are perpendicular. For other angles, use components (below) or the law of cosines.

### Vectors at Any Angle

Draw both vectors from the same starting point. Let $\varphi$ be the angle between them. Then

$$R^2=A^2+B^2+2AB\cos\varphi.$$

At $\varphi=90^\circ$, $\cos\varphi=0$, and this becomes the Pythagorean rule. At $\varphi=0^\circ$ it gives $R=A+B$. At $\varphi=180^\circ$ it gives $R=|A-B|$.

The angle $\varphi$ is the angle between the arrows drawn tail to tail. It is not the angle between them in a tip-to-tail drawing.

### Sine, Cosine, and Tangent

Take a right triangle and one of its acute angles, $\theta$. The **hypotenuse** is the longest side, across from the right angle. The **opposite** side faces $\theta$. The **adjacent** side touches $\theta$ and is not the hypotenuse.

$$\sin\theta=\dfrac{\text{opposite}}{\text{hypotenuse}},\quad \cos\theta=\dfrac{\text{adjacent}}{\text{hypotenuse}},\quad \tan\theta=\dfrac{\text{opposite}}{\text{adjacent}}.$$

The **inverse tangent**, written $\tan^{-1}$, goes the other way. If $\tan\theta=k$, then $\theta=\tan^{-1}k$. Set the calculator to degrees.

### Resolving a Vector into Components

The **components** of a vector are two perpendicular vectors that add up to it. Usually they lie along the $x$-axis (horizontal) and the $y$-axis (vertical). Finding them is called **resolving** the vector.

Suppose a vector of magnitude $V$ points at angle $\theta$, measured counterclockwise from the positive $x$-axis. Then

$$V_x=V\cos\theta,\qquad V_y=V\sin\theta.$$

These formulas work for any angle from $0^\circ$ to $360^\circ$, and the signs come out correctly by themselves. If the angle is measured from another line, such as the vertical, draw the right triangle and use opposite and adjacent sides again.

### Adding Vectors by Components

This method works for any number of vectors in a plane.

1. Resolve each vector into $x$ and $y$ components.
2. Add all the $x$ components to get $R_x$. Add all the $y$ components to get $R_y$.
3. Rebuild the resultant from $R_x$ and $R_y$.

### Magnitude and Direction from Components

The components are perpendicular, so

$$R=\sqrt{R_x^2+R_y^2}.$$

To find the direction, first find the acute angle $\alpha$ between the resultant and the $x$-axis:

$$\alpha=\tan^{-1}\!\left(\dfrac{|R_y|}{|R_x|}\right).$$

Then use the signs of $R_x$ and $R_y$ to find the **quadrant**. The quadrants are the four regions of the plane, numbered counterclockwise from the upper right. The angle from the positive $x$-axis, counterclockwise, is then:

- Quadrant I ($R_x>0$, $R_y>0$): $\theta=\alpha$.
- Quadrant II ($R_x<0$, $R_y>0$): $\theta=180^\circ-\alpha$.
- Quadrant III ($R_x<0$, $R_y<0$): $\theta=180^\circ+\alpha$.
- Quadrant IV ($R_x>0$, $R_y<0$): $\theta=360^\circ-\alpha$.

A calculator's $\tan^{-1}$ of the ratio $\dfrac{R_y}{R_x}$ gives an angle only between $-90^\circ$ and $90^\circ$. It cannot tell which quadrant the vector is in. That is why the signs must be checked.

If $R_x=0$, the ratio cannot be computed. The resultant points straight up (if $R_y>0$) or straight down (if $R_y<0$). If both components are $0$, the resultant is the zero vector and has no direction.

## Mnemonics & Memory Aids

**SOH-CAH-TOA** gives the three ratios in order: **S**ine is **O**pposite over **H**ypotenuse, **C**osine is **A**djacent over **H**ypotenuse, **T**angent is **O**pposite over **A**djacent.

## Examples

### #1: Scalar or Vector?

Classify each quantity as scalar or vector:

(a) distance traveled $=10\,\mathrm{km}$;  
(b) displacement $=6\,\mathrm{km}$ east;  
(c) temperature $=30\,^{\circ}\mathrm C$;  
(d) speed $=20\,\mathrm{m/s}$;  
(e) velocity $=20\,\mathrm{m/s}$ north;  
(f) energy $=50\,\mathrm J$.

**Solution:**

1. Distance has a magnitude only: scalar.
2. Displacement has a magnitude and a direction: vector.
3. Temperature: scalar.
4. Speed is the magnitude of velocity and has no direction: scalar.
5. Velocity has a direction (north): vector.
6. Energy: scalar.

### #2: Perpendicular Displacements

A hiker walks $3\,\mathrm{km}$ east and then $4\,\mathrm{km}$ north. Find the distance traveled, and the magnitude and direction of the displacement.

**Solution:**

1. The distance is the sum of the path lengths:

$$3+4=7\,\mathrm{km}.$$

2. East and north are perpendicular, so the displacement magnitude is

$$R=\sqrt{3^2+4^2}=5\,\mathrm{km}.$$

3. The direction is measured from east toward north:

$$\alpha=\tan^{-1}\!\left(\dfrac{4}{3}\right)\approx 53^\circ.$$

The displacement is $5\,\mathrm{km}$ at about $53^\circ$ north of east. The distance and the displacement magnitude are different quantities.

<!-- FIGURE: {"kind": "concept-diagram", "type": "vector-addition", "components": [{"label": "3 km East", "dx": 3, "dy": 0}, {"label": "4 km North", "dx": 0, "dy": 4}], "resultant": {"label": "5 km Resultant", "dx": 3, "dy": 4}, "semanticsLabel": "A vector addition right triangle with 3 km east, 4 km north, and a 5 km resultant hypotenuse."} -->
### #3: A Round Trip

A runner completes one lap of a $400\,\mathrm m$ track in $80\,\mathrm s$ and stops where she started. Find the distance, the displacement, the average speed, and the average velocity.

**Solution:**

1. The distance is the path length: $400\,\mathrm m$.
2. She ends at her starting point, so the displacement is $0\,\mathrm m$.
3. Average speed is distance over time:

$$\dfrac{400}{80}=5\,\mathrm{m/s}.$$

4. Average velocity is displacement over time:

$$\dfrac{0}{80}=0\,\mathrm{m/s}.$$

### #4: Opposite Forces

Take right as positive. A $600\,\mathrm N$ force acts to the left and a $450\,\mathrm N$ force acts to the right. Find the net force.

**Solution:**

1. The left force is negative: $-600\,\mathrm N$. The right force is positive: $+450\,\mathrm N$.
2. Add the signed numbers:

$$F_{\text{net}}=(-600)+(450)=-150\,\mathrm N.$$

The negative sign means the net force is $150\,\mathrm N$ to the left. This resultant is smaller than both forces.

<!-- FIGURE: {"kind": "concept-diagram", "type": "tug-of-war", "forces": [{"label": "Team A (600 N)", "direction": "left", "magnitude": 600}, {"label": "Team B (450 N)", "direction": "right", "magnitude": 450}], "netForce": {"label": "Net Force (150 N)", "direction": "left"}, "semanticsLabel": "A tug-of-war diagram with 600 N pulling left, 450 N pulling right, and a net force of 150 N to the left."} -->
### #5: Two Forces at an Angle

A $3\,\mathrm N$ force and a $5\,\mathrm N$ force pull on the same point. The angle between them, with both arrows drawn from that point, is $60^\circ$. Find the magnitude of the resultant.

**Solution:**

1. The angle is not $90^\circ$, so the Pythagorean rule does not apply. Use the law of cosines with $\varphi=60^\circ$:

$$R^2=3^2+5^2+2(3)(5)\cos60^\circ.$$

2. Since $\cos60^\circ=0.5$:

$$R^2=9+25+15=49.$$

3. Take the square root:

$$R=7\,\mathrm N.$$

<!-- ILLUSTRATION: two arrows drawn from one point, a 3 N arrow along the positive x-axis and a 5 N arrow at 60 degrees above it, with the 60 degree angle between them labeled and a dashed resultant labeled 7 N -->
### #6: Components

A $10\,\mathrm N$ force acts $30^\circ$ above the positive horizontal axis. Find its horizontal and vertical components.

**Solution:**

1. The angle is measured from the positive $x$-axis, so use the component formulas:

$$F_x=10\cos30^\circ=5\sqrt3\approx 8.66\,\mathrm N.$$

2. For the vertical component:

$$F_y=10\sin30^\circ=5\,\mathrm N.$$

Both components are positive because the vector lies in quadrant I. As a check, $\sqrt{8.66^2+5^2}=10$.

<!-- FIGURE: {"kind": "concept-diagram", "type": "vector-components", "magnitude": 10, "angle": 30, "unit": "N", "components": {"horizontal": "10 cos 30°", "vertical": "10 sin 30°"}, "semanticsLabel": "A 10 N force vector at 30 degrees above the horizontal resolved into horizontal and vertical components."} -->
### #7: Angle Measured from the Vertical

A rope pulls a crate with a force of $50\,\mathrm N$. The rope makes an angle of $40^\circ$ with the vertical, and the pull is upward and to the right. Find the horizontal and vertical components.

**Solution:**

1. Draw the right triangle. The angle $40^\circ$ is at the vertical side. So the vertical component is the adjacent side, and the horizontal component is the opposite side.
2. Horizontal component:

$$F_x=50\sin40^\circ\approx 32.1\,\mathrm N.$$

3. Vertical component:

$$F_y=50\cos40^\circ\approx 38.3\,\mathrm N.$$

Here the formulas are swapped compared with Example #6, because the angle is measured from the vertical.

<!-- ILLUSTRATION: a 50 N arrow pointing up and to the right, a vertical dashed line from its tail with the 40 degree angle between the dashed line and the arrow labeled, and the horizontal component 50 sin 40 and vertical component 50 cos 40 marked -->
### #8: Several Vectors and the Quadrant

A $20\,\mathrm N$ force acts at $150^\circ$ from the positive $x$-axis, measured counterclockwise. A $12\,\mathrm N$ force acts straight down. Find the magnitude and direction of the resultant.

**Solution:**

1. Resolve the $20\,\mathrm N$ force:

$$F_x=20\cos150^\circ\approx -17.32\,\mathrm N,\qquad F_y=20\sin150^\circ=10\,\mathrm N.$$

2. The $12\,\mathrm N$ force has components $0$ and $-12\,\mathrm N$.
3. Add the components:

$$R_x=-17.32+0=-17.32\,\mathrm N,\qquad R_y=10-12=-2\,\mathrm N.$$

4. Find the magnitude:

$$R=\sqrt{(-17.32)^2+(-2)^2}\approx 17.4\,\mathrm N.$$

5. Find the acute angle:

$$\alpha=\tan^{-1}\!\left(\dfrac{2}{17.32}\right)\approx 6.6^\circ.$$

6. Both components are negative, so the resultant is in quadrant III:

$$\theta=180^\circ+6.6^\circ=186.6^\circ.$$

The resultant is about $17.4\,\mathrm N$ at $186.6^\circ$ from the positive $x$-axis. That is $6.6^\circ$ below the negative $x$-axis. A calculator's $\tan^{-1}\!\left(\dfrac{-2}{-17.32}\right)$ would show only $6.6^\circ$, which points into quadrant I and is wrong.

<!-- ILLUSTRATION: x-y axes with a 20 N arrow at 150 degrees from the positive x-axis, a 12 N arrow pointing straight down, and the resultant of 17.4 N at 186.6 degrees in quadrant III with the 6.6 degree angle below the negative x-axis labeled -->
## Speed Tricks & Shortcuts

First read the name of the quantity. Speed and distance are scalars. Velocity and displacement are vectors.

On a straight line, choose a positive direction and use signed numbers. This is safer than remembering "subtract the smaller from the larger".

For vectors in a plane, the general method is components: resolve, add the $x$ components, add the $y$ components, then rebuild the magnitude and direction.

If the resultant's components are a multiple of $3$ and $4$, or of $5$ and $12$, the magnitude is the matching multiple of $5$ or $13$, with no square root needed.

Before you trust an angle from $\tan^{-1}$, sketch the signs of $R_x$ and $R_y$. The sketch tells you the quadrant.

## Traps to Watch For

### #1: Using a Direction Word as the Definition of a Vector

> A direction word in the sentence does not make a quantity a vector.

Check the quantity itself. A question may give only the magnitude of a vector, such as "a speed of $20\,\mathrm{m/s}$". A scalar may also be described with a place, such as "the temperature in the north".

### #2: Confusing Distance and Displacement

> Distance is the total path length. Displacement is the change in position.

Distance is never negative and does not decrease as you move. A round trip has a positive distance and zero displacement. Displacement can be smaller than the distance, and equals it only for straight-line motion in one direction.

### #3: Adding Magnitudes Instead of Vectors

> The magnitude of $\vec A+\vec B$ is generally not $A+B$.

Adding magnitudes gives the right resultant only when the vectors point the same way. For other directions the resultant is smaller than $A+B$, and it can even be smaller than either vector.

### #4: Using the Pythagorean Theorem for Any Two Vectors

> $R=\sqrt{A^2+B^2}$ needs perpendicular vectors.

Two forces at $60^\circ$ do not combine by this rule. Use components or the law of cosines, as in Example #5.

### #5: Using Cosine for the Horizontal Component Every Time

> $V_x=V\cos\theta$ holds when $\theta$ is measured from the positive $x$-axis.

If the angle is measured from the vertical, the sine and cosine swap, as in Example #7. Draw the triangle and name the opposite and adjacent sides.

### #6: Trusting the Calculator Angle

> $\tan^{-1}$ returns an angle between $-90^\circ$ and $90^\circ$.

A vector in quadrant II or III needs a correction, as in Example #8. Check the signs of the components first, and then pick the quadrant.
