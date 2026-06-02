---
_id: "lesson-trigonometry-angles-and-radian-measure"
title: "Angles and Radian Measure (Conversion)"
summary: "What radians are and how to convert between degrees and radians quickly."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 10
isActive: true
---
## Core Concept

Degrees and radians are two languages for measuring the same angle.

You know degrees: a full circle is $360^\circ$, a straight line is $180^\circ$, a right angle is $90^\circ$.

A **radian** measures angles using the circle itself. One radian is the angle you get when the arc is exactly as long as the radius. Wrap the radius along the edge of the circle: the angle it covers is $1$ radian.

<!-- ILLUSTRATION: circle with radius r, an arc of the same length r marked along the edge, and the central angle labeled 1 radian -->

The bridge between the two languages:

$$180^\circ = \pi \text{ radians}$$

From this one fact come both conversion rules:

- Degrees to radians: multiply by $\dfrac{\pi}{180}$.
- Radians to degrees: multiply by $\dfrac{180}{\pi}$.

An angle in **standard position** starts from the positive $x$-axis. Counterclockwise is positive, clockwise is negative. Angles that end at the same spot are called **coterminal**; they differ by full turns of $360^\circ$ (or $2\pi$).

Radians also give the cleanest arc length formula. For a central angle $\theta$ in radians and radius $r$:

$$s = r\theta$$

CETs test straight conversions, coterminal angles, and which quadrant an angle lands in. All three are quick points once the conversion is automatic.

## Examples

### #1: Degrees to Radians

Convert $60^\circ$ to radians.

**Solution:**
Multiply by $\dfrac{\pi}{180}$.

1. Set up the product.

$$60 \times \dfrac{\pi}{180}$$

2. Simplify the fraction $\dfrac{60}{180}$ to $\dfrac{1}{3}$.

$$60^\circ = \dfrac{\pi}{3}$$

3. So $60^\circ$ is $\dfrac{\pi}{3}$ radians.

### #2: Radians to Degrees

Convert $\dfrac{3\pi}{4}$ radians to degrees.

**Solution:**
Multiply by $\dfrac{180}{\pi}$. The $\pi$ symbols cancel.

1. Set up the product.

$$\dfrac{3\pi}{4} \times \dfrac{180}{\pi}$$

2. Cancel $\pi$ and divide $180$ by $4$.

$$3 \times 45 = 135$$

3. So $\dfrac{3\pi}{4}$ radians is $135^\circ$.

### #3: Converting Negative and Larger Angles

Convert $150^\circ$ and $-45^\circ$ to radians.

**Solution:**
Same rule; signs just ride along.

1. For $150^\circ$: simplify $\dfrac{150}{180} = \dfrac{5}{6}$.

$$150^\circ = \dfrac{5\pi}{6}$$

2. For $-45^\circ$: simplify $\dfrac{45}{180} = \dfrac{1}{4}$ and keep the minus.

$$-45^\circ = -\dfrac{\pi}{4}$$

3. Quadrant check: $\dfrac{5\pi}{6}$ is a bit less than $\pi$, so it lands in Quadrant II. Reasonable.

### #4: Coterminal Angles

Find the angle between $0^\circ$ and $360^\circ$ that is coterminal with $400^\circ$, and the one coterminal with $-120^\circ$.

**Solution:**
Add or subtract full turns of $360^\circ$ until you land inside the range.

1. For $400^\circ$, subtract one full turn.

$$400 - 360 = 40$$

2. So $400^\circ$ is coterminal with $40^\circ$.
3. For $-120^\circ$, add one full turn.

$$-120 + 360 = 240$$

4. So $-120^\circ$ is coterminal with $240^\circ$, which lies in Quadrant III.

### #5: Arc Length

A circle has a radius of $10$ cm. Find the length of the arc cut off by a central angle of $\dfrac{\pi}{5}$ radians. Then find the arc for a $72^\circ$ central angle.

**Solution:**
Use $s = r\theta$, but $\theta$ must be in radians.

1. First arc: the angle is already in radians.

$$s = 10 \times \dfrac{\pi}{5} = 2\pi \text{ cm}$$

2. Second arc: convert $72^\circ$ first. Simplify $\dfrac{72}{180} = \dfrac{2}{5}$.

$$72^\circ = \dfrac{2\pi}{5}$$

3. Now apply the formula.

$$s = 10 \times \dfrac{2\pi}{5} = 4\pi \text{ cm}$$

4. The arcs are $2\pi$ cm and $4\pi$ cm. Notice both angles gave clean answers because radians and $s = r\theta$ fit together perfectly.

## Speed Tricks & Shortcuts

Memorize the anchor conversions and build everything from them: $30^\circ = \dfrac{\pi}{6}$, $45^\circ = \dfrac{\pi}{4}$, $60^\circ = \dfrac{\pi}{3}$, $90^\circ = \dfrac{\pi}{2}$, $180^\circ = \pi$, $360^\circ = 2\pi$. Then $135^\circ$ is just $3$ copies of $45^\circ$, so it is $\dfrac{3\pi}{4}$. Counting copies beats multiplying fractions.

To place a radian angle in its quadrant without converting: compare it to $\dfrac{\pi}{2} \approx 1.57$, $\pi \approx 3.14$, and $\dfrac{3\pi}{2} \approx 4.71$. An angle like $2$ radians sits between $1.57$ and $3.14$, so it is in Quadrant II.

For coterminal questions, you may need more than one turn: $800^\circ - 360^\circ = 440^\circ$, still too big, so subtract again to get $80^\circ$. Keep going until you land in range.

## Traps to Watch For

### #1: Multiplying by the Wrong Fraction

> Degrees to radians uses $\dfrac{\pi}{180}$. Radians to degrees uses $\dfrac{180}{\pi}$.

Use the wrong one and the answer explodes or shrinks absurdly. Sanity check: a number without $\pi$ and bigger than $7$ is almost surely degrees; radian answers for common angles are small multiples of $\pi$.

### #2: Degrees Inside $s = r\theta$

> The arc length formula only accepts radians.

Plugging $72^\circ$ straight into $s = r\theta$ gives $720$, a nonsense arc for a circle of radius $10$. Convert to radians first, every time. Test-makers pick angle values that produce believable-looking wrong answers.

### #3: A Radian Is Not a Degree Cousin

> $1$ radian is about $57.3^\circ$, much bigger than $1^\circ$.

When choices mix the two units, remember the scale: $2$ radians is already more than $114^\circ$. If you treat radians as "small degree-like numbers", every estimate you make will be wrong by a factor of about $57$.
