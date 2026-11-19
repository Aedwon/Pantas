---
_id: "lesson-physics-resultants-of-two-vectors"
title: "Resultants of Two Vectors"
summary: "Find a resultant when two vectors meet at an angle."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 4
partCount: 6
ordering: 11
keyPoints:
  - "Find the resultant of perpendicular vectors."
  - "Find the resultant of two vectors at any angle."
---
## Core Concept

For vectors in a plane, use **tip-to-tail** construction. Draw the first arrow. Draw the second arrow starting at the tip of the first. The resultant runs from the start of the first arrow to the tip of the last.

### Perpendicular Vectors

Two vectors are **perpendicular** when they meet at a right angle. If their magnitudes are $A$ and $B$, they form the two legs of a right triangle, and the resultant is the hypotenuse:

$$R=\sqrt{A^2+B^2}.$$

This Pythagorean shortcut works only when the two vectors are perpendicular. For other angles, use components (see Resolving Vector Components) or the law of cosines.

### Vectors at Any Angle

Draw both vectors from the same starting point. Let $\varphi$ be the angle between them. Then

$$R^2=A^2+B^2+2AB\cos\varphi.$$

At $\varphi=90^\circ$, $\cos\varphi=0$, and this becomes the Pythagorean rule. At $\varphi=0^\circ$ it gives $R=A+B$. At $\varphi=180^\circ$ it gives $R=|A-B|$.

The angle $\varphi$ is the angle between the arrows drawn tail to tail. It is not the angle between them in a tip-to-tail drawing.

## Mnemonics & Memory Aids

**SOH-CAH-TOA** gives the three ratios in order: **S**ine is **O**pposite over **H**ypotenuse, **C**osine is **A**djacent over **H**ypotenuse, **T**angent is **O**pposite over **A**djacent.

## Examples

### #1: Perpendicular Displacements

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

### #2: Two Forces at an Angle

A $3\,\mathrm N$ force and a $5\,\mathrm N$ force pull on the same point. The angle between them, with both arrows drawn from that point, is $60^\circ$. Find the magnitude of the resultant.

**Solution:**

1. The angle is not $90^\circ$, so the Pythagorean rule does not apply. Use the law of cosines with $\varphi=60^\circ$:

$$R^2=3^2+5^2+2(3)(5)\cos60^\circ.$$

2. Since $\cos60^\circ=0.5$:

$$R^2=9+25+15=49.$$

3. Take the square root:

$$R=7\,\mathrm N.$$

<!-- ILLUSTRATION: two arrows drawn from one point, a 3 N arrow along the positive x-axis and a 5 N arrow at 60 degrees above it, with the 60 degree angle between them labeled and a dashed resultant labeled 7 N -->

## Speed Tricks & Shortcuts

If the resultant's components are a multiple of $3$ and $4$, or of $5$ and $12$, the magnitude is the matching multiple of $5$ or $13$, with no square root needed.

## Traps to Watch For

### #1: Using the Pythagorean Theorem for Any Two Vectors

> $R=\sqrt{A^2+B^2}$ needs perpendicular vectors.

Two forces at $60^\circ$ do not combine by this rule. Use components or the law of cosines, as in Example #2.
