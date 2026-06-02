---
_id: "lesson-physics-gravity-and-keplers-laws"
title: "Gravity and Kepler's Laws of Planetary Motion"
summary: "Newton's law of universal gravitation and Kepler's three laws describing how planets orbit the Sun."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 12
isActive: true
---
## Core Concept

### Newton's Law of Universal Gravitation

Every object with mass attracts every other object with mass. Newton's law of universal gravitation gives the force between two masses:

$$F = G\dfrac{m_1 m_2}{r^2}$$

where $m_1$ and $m_2$ are the two masses, $r$ is the distance between their centers, and $G$ is the universal gravitational constant. Notice the force depends on $r^2$ in the denominator: this is an **inverse-square law**, meaning gravity weakens very quickly as distance increases. Double the distance, and the force drops to one-quarter its original strength (since $2^2 = 4$).

<!-- ILLUSTRATION: two spheres of different sizes separated by a distance r, with arrows showing the mutual attractive force pulling them together, and a smaller inset showing the same two spheres at double the distance with a much smaller force arrow -->

### Kepler's Three Laws

Before Newton explained why, the astronomer Johannes Kepler had already discovered how planets move, based on careful observations.

**Kepler's First Law (Law of Ellipses)**: planets orbit the Sun in elliptical (oval-shaped) paths, not perfect circles, with the sun at one focus of the ellipse (not the exact center).

**Kepler's Second Law (Law of Equal Areas)**: a line connecting a planet to the Sun sweeps out equal areas in equal time intervals. This means a planet moves faster when it is closer to the Sun, and slower when it is farther away.

**Kepler's Third Law (Law of Harmonies)**: the square of a planet's orbital period is proportional to the cube of its average distance from the Sun. Planets farther from the Sun take disproportionately longer to complete one orbit.

<!-- ILLUSTRATION: elliptical orbit with the Sun at one focus, showing a planet at two positions, near the Sun with a wide swept-area triangle and short arc traveled quickly, and far from the Sun with a similarly-sized swept-area triangle but a longer, slower arc -->

Newton later showed that Kepler's three laws are all a natural consequence of his law of universal gravitation combined with the laws of motion — Kepler discovered the pattern, and Newton later explained the underlying physics causing it.

## Examples

### #1: Applying the Inverse-Square Law

Two objects are moved to three times their original distance apart. By what factor does the gravitational force between them change?

**Solution:**
Apply the inverse-square relationship.

1. Since force is inversely proportional to distance squared, tripling the distance means dividing the force by $3^2$.

$$3^2 = 9$$

2. The new force is $\dfrac{1}{9}$ of the original force.

### #2: Comparing Orbital Speed

A planet's orbit is elliptical. At one point in its orbit (**perihelion**) it is very close to the Sun; at another point (**aphelion**) it is very far from the Sun. At which point does the planet move faster?

**Solution:**
Apply Kepler's second law (equal areas in equal times).

1. To sweep out the same area in the same amount of time, a planet close to the Sun (where the "triangle" connecting it to the Sun is narrow) must travel a longer arc distance quickly to sweep the same area as a wide, short arc far from the Sun.
2. This means the planet moves faster when close to the Sun (at perihelion) and slower when far from the Sun (at aphelion).

### #3: Applying Kepler's Third Law

Planet A orbits its star with an orbital period $4$ times longer than Planet B's period. Using Kepler's third law, describe (in general terms) how Planet A's average distance from the star compares to Planet B's.

**Solution:**
Recall that period squared is proportional to distance cubed.

1. Kepler's third law states $T^2 \propto r^3$ (period squared is proportional to distance cubed).
2. If Planet A's period is $4$ times Planet B's, then Planet A's period squared is $4^2 = 16$ times Planet B's period squared.
3. Since period squared is proportional to distance cubed, Planet A's distance cubed must also be $16$ times Planet B's distance cubed.
4. This means Planet A orbits at a significantly greater average distance than Planet B (proportionally more than $4$ times, since $16 = r_A^3/r_B^3$ needs a cube root to solve exactly, but qualitatively, a much longer period corresponds to a much larger orbital distance).

### #4: Why Orbits Are Not Perfect Circles

Explain how Kepler's first law challenged the earlier, widely-held belief that planets moved in perfect circles.

**Solution:**
Recall the specific shape Kepler's observations revealed.

1. Before Kepler, many astronomers assumed planetary orbits must be perfect circles, since circles were considered the "ideal" celestial shape.
2. Kepler's careful analysis of observational data (particularly of Mars) showed that orbits are actually ellipses (ovals), with the Sun positioned at one focus of the ellipse, not at its exact center.
3. This was a significant break from the older circular-orbit assumption, providing a more accurate model that matched real observational data.

## Speed Tricks & Shortcuts

For inverse-square law problems, remember: multiply the distance by a factor, then square that factor, then divide the force by the result. Doubling distance divides force by $4$; tripling distance divides force by $9$; and so on.

Remember Kepler's second law with one simple rule: "closer means faster, farther means slower." This explains planetary speed changes without needing to calculate anything.

Connect Kepler's laws to their describing word: Law of ellipses (shape), Law of equal areas (speed), Law of harmonies (period vs. distance relationship, "harmonies" referring to the mathematical proportion).

## Traps to Watch For

### #1: Forgetting to Square the Distance Change

> Gravitational force follows an inverse-square law — the distance factor must be squared before dividing.

Tripling the distance does not simply divide the force by $3$; it divides the force by $3^2 = 9$. Skipping the squaring step is the most common error when applying Newton's law of gravitation.

### #2: Believing Planetary Orbits Are Perfect Circles

> Kepler's first law specifically states orbits are ellipses, with the Sun at one focus, not a perfect circle with the Sun at the center.

While many orbits are nearly circular and this approximation is sometimes used for simplicity, the technically correct and testable answer for orbital shape is an ellipse, not a circle.

### #3: Assuming Planets Move at Constant Speed

> Kepler's second law shows that a planet's orbital speed changes throughout its orbit — faster near the Sun, slower far from it.

A common misconception assumes planets move at one constant speed throughout their entire elliptical orbit, similar to a satellite in a perfect circular orbit. In reality, only a perfectly circular orbit would have constant speed; elliptical orbits (which describe real planets) have varying speed.

### #4: Misapplying Kepler's Third Law's Proportionality

> Kepler's third law relates period squared to distance cubed — not period to distance directly, and not some other combination of powers.

Assuming the relationship is directly proportional (period simply equal to distance, with no exponents) leads to a significantly wrong comparison between two orbits, especially as the ratio between their periods or distances grows larger.
