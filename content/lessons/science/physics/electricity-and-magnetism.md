---
_id: "lesson-physics-electricity-and-magnetism"
title: "Electricity and Magnetism"
summary: "This lesson teaches you Coulomb's law, Ohm's law, how series and parallel circuits behave differently, and the basics of magnetism."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

### Coulomb's Law and Electric Fields

**Coulomb's Law** describes the force between two ELECTRIC CHARGES:

$$F = k\dfrac{q_1 q_2}{r^2}$$

where $q_1$ and $q_2$ are the charges, $r$ is the distance between them, and $k$ is a constant. Like Newton's gravitation law, this is an INVERSE-SQUARE relationship: doubling the distance QUARTERS the force. Like charges REPEL (push apart); opposite charges ATTRACT (pull together).

An **electric field** is the invisible "influence region" surrounding a charge, which would exert a force on any OTHER charge placed within it. Field lines point AWAY from positive charges and TOWARD negative charges.

<!-- ILLUSTRATION: two diagrams, one showing two positive charges with field lines pointing away from each and a repelling force arrow, one showing a positive and negative charge with field lines connecting them and an attracting force arrow -->

### Ohm's Law

**Ohm's Law** relates voltage, current, and resistance in a circuit:

$$V = IR$$

where $V$ is voltage (measured in volts), $I$ is current (measured in amperes), and $R$ is resistance (measured in ohms). For a FIXED resistance, MORE voltage pushes MORE current through; for a FIXED voltage, MORE resistance means LESS current flows.

### Electric Circuits (Series, Parallel, Complex)

In a **series circuit**, components are connected in ONE single path, one after another. The SAME current flows through every component, but the voltage SPLITS between them. If one component fails (breaks the path), the ENTIRE circuit stops working.

In a **parallel circuit**, components are connected across MULTIPLE separate paths (branches). The SAME voltage is applied across each branch, but the current SPLITS between them, with each branch carrying its own share depending on its resistance. If one branch fails, the OTHER branches keep working independently.

<!-- ILLUSTRATION: two simple circuit diagrams side by side, a series circuit showing a battery connected to two bulbs in a single loop one after another, and a parallel circuit showing a battery connected to two bulbs on separate side-by-side branches -->

A **complex circuit** combines BOTH series and parallel sections within the same overall circuit, requiring you to analyze each section according to its own type before combining the results.

### Magnetism and Electromagnetism

A **magnet** has two poles (north and south); LIKE poles repel, OPPOSITE poles attract — following the exact same "like repels, opposite attracts" pattern as electric charges.

**Electromagnetism** is the deep connection between electricity and magnetism: a moving electric CURRENT creates a MAGNETIC FIELD around it, and conversely, a CHANGING magnetic field can induce an electric current. The **right-hand rule** predicts the direction of the magnetic field around a current-carrying wire: if your thumb points in the direction of conventional current flow, your curled fingers show the direction the magnetic field circles around the wire.

## Examples

### #1: Applying Coulomb's Law Conceptually

Two charges are moved to TWICE their original distance apart. By what factor does the electric force between them change?

**Solution:**
Apply the inverse-square relationship.

1. Since force is inversely proportional to distance SQUARED, doubling the distance means dividing the force by $2^2$.

$$2^2 = 4$$

2. The new force is $\dfrac{1}{4}$ of the original force.

### #2: Applying Ohm's Law

A circuit has a resistance of $10 \text{ ohms}$ and a current of $2 \text{ amperes}$ flowing through it. Find the voltage.

**Solution:**
Apply Ohm's law directly.

1. Substitute the values.

$$V = (2)(10)$$

2. Compute.

$$V = 20 \text{ volts}$$

### #3: Series vs. Parallel Behavior

In a series circuit with two light bulbs, one bulb suddenly burns out. In a separate parallel circuit with two light bulbs, one bulb burns out. Predict what happens to the OTHER bulb in each case.

**Solution:**
Recall how each circuit type responds to a broken path.

1. In the SERIES circuit, all components share ONE single path. If one bulb burns out (breaking that path), the current can no longer flow AT ALL, so the OTHER bulb also GOES OUT.
2. In the PARALLEL circuit, each bulb has its OWN separate branch. If one bulb burns out, only THAT branch is broken; the other branch remains a complete, separate path, so the OTHER bulb STAYS LIT.

### #4: Predicting Magnetic Field Direction

A straight wire carries current flowing directly upward. Using the right-hand rule, describe the direction of the magnetic field circling the wire.

**Solution:**
Apply the right-hand rule directly.

1. Point your right thumb in the direction of the current: UPWARD.
2. Your curled fingers show the magnetic field's direction, circling AROUND the wire.
3. Looking down from above (from the direction the current is heading), the magnetic field circles COUNTERCLOCKWISE around the wire.

## Speed Tricks & Shortcuts

Notice that Coulomb's law and Newton's law of gravitation share the SAME inverse-square structure — if you can handle one, you can handle the other, just swapping charges for masses and using a different constant.

For Ohm's law, remember the triangle trick: cover the letter you want to find in "$V$ over $IR$" (arranged with $V$ on top, $I$ and $R$ on the bottom), and the remaining letters show you exactly how to compute it.

For series versus parallel circuit questions, remember the one-word test: "does breaking ONE path break EVERYTHING?" Yes means series (one shared path); no means parallel (multiple independent paths).

## Traps to Watch For

### #1: Forgetting the Inverse-Square Relationship in Coulomb's Law

> Coulomb's law force depends on distance SQUARED in the denominator — doubling the distance QUARTERS the force, it does not simply halve it.

This is the exact same trap as Newton's law of gravitation, since both follow an inverse-square pattern. Always square the distance-change factor before dividing.

### #2: Assuming Series and Parallel Circuits Behave the Same Way

> In series circuits, current is the SAME everywhere and voltage SPLITS. In parallel circuits, voltage is the SAME across each branch and current SPLITS.

Mixing up which quantity (current or voltage) stays constant and which one splits between components is one of the most common circuit errors. Always identify the circuit type FIRST before deciding which quantity to treat as shared.

### #3: Believing One Broken Bulb Always Kills the Whole Circuit

> Only in a SERIES circuit does one broken component stop the ENTIRE circuit. In a PARALLEL circuit, other branches keep working independently.

A question describing holiday lights that ALL go out when one bulb fails describes a SERIES circuit; a question describing house wiring where other outlets keep working when one bulb burns out describes a PARALLEL circuit (which is why household wiring is typically parallel).

### #4: Misapplying the Right-Hand Rule

> Point your THUMB in the direction of CURRENT flow; your CURLED FINGERS show the magnetic field's direction — do not reverse thumb and fingers.

Using the left hand, or swapping which part represents current versus magnetic field direction, gives the OPPOSITE (incorrect) field direction. Always use the RIGHT hand specifically, with the thumb representing current.
