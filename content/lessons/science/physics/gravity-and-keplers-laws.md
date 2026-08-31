---
_id: "lesson-physics-gravity-kepler"
title: "Gravity and Kepler's Laws of Planetary Motion"
summary: "Newton's law of universal gravitation and Kepler's three laws describing how planets orbit the Sun."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

### Newton's Law of Universal Gravitation

Every object with mass attracts every other object with mass. Newton's law of universal gravitation gives the magnitude of the force between two point masses (or spherically symmetric bodies treated from their centers):

$$F = G\dfrac{m_1 m_2}{r^2}$$

where $m_1$ and $m_2$ are the two masses, $r$ is the distance between their centers, and $G$ is the universal gravitational constant. Notice the force depends on $r^2$ in the denominator: this is an **inverse-square law**. Double the distance, and the force drops to one-quarter its original strength.

<!-- FIGURE: {"kind": "concept-diagram", "type": "gravitational-force", "masses": ["m1", "m2"], "distance": "r", "comparison": "2r (F/4)", "semanticsLabel": "Two spheres separated by distance r with inward gravity arrows, and a comparison at distance 2r with one fourth the force."} -->

### Kepler's Three Laws

Using the careful observational data collected by Tycho Brahe, Johannes Kepler found mathematical patterns that describe planetary motion.

**Kepler's First Law (Law of Ellipses)**: planets orbit the Sun in elliptical paths, with the Sun at one focus of the ellipse. A circle is the special case of an ellipse with zero eccentricity.

**Kepler's Second Law (Law of Equal Areas)**: a line connecting a planet to the Sun sweeps out equal areas in equal time intervals. This means a planet moves faster near perihelion and slower near aphelion.

**Kepler's Third Law (Harmonic Law)**: for objects orbiting the same dominant central mass, the square of the orbital period $T$ is proportional to the cube of the orbit's **semimajor axis** $a$:

$$T^2 \propto a^3$$

For an elliptical orbit, $a$ is half the length of the major axis; equivalently, it is half the sum of the perihelion and aphelion distances measured from the focus. In a circular orbit, $a$ equals the orbital radius.

For a relatively small orbiting mass around central mass $M$, Newtonian gravity gives

$$T^2 = \dfrac{4\pi^2}{GM}a^3$$

Newton later showed that Kepler's laws follow from gravitational dynamics under the appropriate two-body approximation: Kepler established the empirical orbital patterns, and Newton supplied a dynamical explanation.

## Examples

### #1: Applying the Inverse-Square Law

Two objects are moved to three times their original distance apart. By what factor does the gravitational force between them change?

**Solution:**
Apply the inverse-square relationship.

1. Since force is inversely proportional to distance squared, tripling the distance means dividing the force by $3^2$.

$$3^2 = 9$$

2. The new force is $\dfrac{1}{9}$ of the original force.

### #2: Comparing Orbital Speed

A planet's orbit is elliptical. At **perihelion** it is closest to the Sun; at **aphelion** it is farthest away. At which point does the planet move faster?

<!-- ILLUSTRATION: an elliptical orbit with the Sun at one focus; perihelion marked close to the Sun with a long velocity arrow (fast) and aphelion marked far from the Sun with a short velocity arrow (slow) -->

**Solution:**
Apply Kepler's second law.

1. Equal areas must be swept out in equal times.
2. Near perihelion, the planet must move through a longer arc in the same interval than it does near aphelion.
3. Therefore the planet moves faster at perihelion and slower at aphelion.

### #3: Applying Kepler's Third Law

Planet A and Planet B orbit the same star. Planet A's orbital period is $4$ times Planet B's. How does Planet A's semimajor axis compare with Planet B's?

**Solution:**
Use the ratio form of Kepler's third law.

$$\frac{T_A^2}{T_B^2} = \frac{a_A^3}{a_B^3}$$

1. Given $T_A/T_B=4$,

$$\frac{T_A^2}{T_B^2}=4^2=16$$

2. Therefore,

$$\frac{a_A^3}{a_B^3}=16$$

3. Take the cube root.

$$\frac{a_A}{a_B}=\sqrt[3]{16}\approx2.52$$

4. Planet A's semimajor axis is about $2.52$ times Planet B's, not four times and not sixteen times.

### #4: Why Orbits Are Not Necessarily Perfect Circles

Explain how Kepler's first law changed the older circular-orbit assumption.

**Solution:**

1. Earlier astronomical models often favored circles or combinations of circular motions.
2. Kepler found that an ellipse with the Sun at one focus matched Brahe's planetary observations, especially Mars, much better.
3. Real planetary orbits are ellipses, though several are close enough to circular that a circle can sometimes be a useful approximation.

## Speed Tricks & Shortcuts

For inverse-square problems, multiply the distance by a factor $k$, then divide the force by $k^2$.

For Kepler's second law, remember: closer to the Sun means faster orbital speed; farther means slower.

For Kepler's third law, remember the exact pair of quantities: **period squared** and **semimajor axis cubed**. When comparing two objects orbiting the same central mass,

$$\left(\frac{T_1}{T_2}\right)^2 = \left(\frac{a_1}{a_2}\right)^3$$

## Traps to Watch For

### #1: Forgetting to Square the Distance Change in Gravity

> Gravitational force follows an inverse-square law.

Tripling the distance divides the force by $9$, not by $3$.

### #2: Treating the Sun as Being at the Center of Every Ellipse

> In an elliptical planetary orbit, the Sun lies at one focus, not generally at the ellipse's geometric center.

A nearly circular orbit can make the offset small, but the geometric statement is still one focus.

### #3: Assuming Planets Move at Constant Speed

> Kepler's second law requires varying speed around an elliptical orbit.

The speed is greatest near perihelion and smallest near aphelion.

### #4: Using an Undefined "Average Distance" in Kepler's Third Law

> The precise orbital-size quantity is the semimajor axis $a$.

For an ellipse, do not substitute an arbitrary time-average or arithmetic average of distances unless the problem explicitly establishes that it equals the semimajor axis.

### #5: Applying the Same Proportionality Constant to Different Central Masses

> $T^2/a^3$ depends on the central mass.

The simple ratio comparison works directly for planets orbiting the same star (or satellites orbiting the same planet). If the central masses differ, use the Newtonian form with $GM$.
