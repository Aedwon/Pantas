---
_id: "lesson-physics-electricity-and-magnetism"
title: "Electricity and Magnetism"
summary: "Coulomb's law, Ohm's law, how series and parallel circuits behave differently, and the basics of magnetism."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

### Coulomb's Law and Electric Fields

**Coulomb's Law** describes the force between two electric charges:

$$F = k\dfrac{q_1 q_2}{r^2}$$

where $q_1$ and $q_2$ are the charges, $r$ is the distance between them, and $k$ is a constant. Like Newton's gravitation law, this is an inverse-square relationship: doubling the distance quarters the force. Like charges repel (push apart); opposite charges attract (pull together).

An **electric field** is the invisible "influence region" surrounding a charge, which would exert a force on any other charge placed within it. Field lines point away from positive charges and toward negative charges.

<!-- ILLUSTRATION: two diagrams, one showing two positive charges with field lines pointing away from each and a repelling force arrow, one showing a positive and negative charge with field lines connecting them and an attracting force arrow -->

### Ohm's Law

**Ohm's Law** relates voltage, current, and resistance in a circuit:

$$V = IR$$

where $V$ is voltage (measured in volts), $I$ is current (measured in amperes), and $R$ is resistance (measured in ohms). For a fixed resistance, more voltage pushes more current through; for a fixed voltage, more resistance means less current flows.

### Electric Circuits (Series, Parallel, Complex)

In a **series circuit**, components are connected in one single path, one after another. The same current flows through every component, but the voltage splits between them. If one component fails (breaks the path), the entire circuit stops working.

In a **parallel circuit**, components are connected across multiple separate paths (branches). The same voltage is applied across each branch, but the current splits between them, with each branch carrying its own share depending on its resistance. If one branch fails, the other branches keep working independently.

<!-- ILLUSTRATION: two simple circuit diagrams side by side, a series circuit showing a battery connected to two bulbs in a single loop one after another, and a parallel circuit showing a battery connected to two bulbs on separate side-by-side branches -->

A **complex circuit** combines both series and parallel sections within the same overall circuit, requiring you to analyze each section according to its own type before combining the results.

### Magnetism and Electromagnetism

A **magnet** has two poles (north and south); like poles repel, opposite poles attract — following the exact same "like repels, opposite attracts" pattern as electric charges.

**Electromagnetism** is the deep connection between electricity and magnetism: a moving electric current creates a magnetic field around it, and conversely, a changing magnetic field can induce an electric current. The **right-hand rule** predicts the direction of the magnetic field around a current-carrying wire: if your thumb points in the direction of conventional current flow, your curled fingers show the direction the magnetic field circles around the wire.

## Examples

### #1: Applying Coulomb's Law Conceptually

Two charges are moved to twice their original distance apart. By what factor does the electric force between them change?

**Solution:**
Apply the inverse-square relationship.

1. Since force is inversely proportional to distance squared, doubling the distance means dividing the force by $2^2$.

$$2^2 = 4$$

2. The new force is $\dfrac{1}{4}$ of the original force.

### #2: Applying Ohm's Law

A circuit has a resistance of $10 \text{ ohms}$ and a current of $2 \text{ amperes}$ flowing through it. Find the voltage.

<!-- ILLUSTRATION: a simple circuit with a battery, a 10 ohm resistor, and a 2 A current arrow, with the voltage across the battery marked "?" -->


**Solution:**
Apply Ohm's law directly.

1. Substitute the values.

$$V = (2)(10)$$

2. Compute.

$$V = 20 \text{ volts}$$

### #3: Series vs. Parallel Behavior

In a series circuit with two light bulbs, one bulb suddenly burns out. In a separate parallel circuit with two light bulbs, one bulb burns out. Predict what happens to the other bulb in each case.

<!-- ILLUSTRATION: two circuits side by side — a series circuit with two bulbs on one loop (one burned out, the other goes dark) and a parallel circuit with two bulbs on separate branches (one burned out, the other stays lit) -->


**Solution:**
Recall how each circuit type responds to a broken path.

1. In the series circuit, all components share one single path. If one bulb burns out (breaking that path), the current can no longer flow at all, so the other bulb also goes out.
2. In the parallel circuit, each bulb has its own separate branch. If one bulb burns out, only that branch is broken; the other branch remains a complete, separate path, so the other bulb stays lit.

### #4: Predicting Magnetic Field Direction

A straight wire carries current flowing directly upward. Using the right-hand rule, describe the direction of the magnetic field circling the wire.

**Solution:**
Apply the right-hand rule directly.

1. Point your right thumb in the direction of the current: Upward.
2. Your curled fingers show the magnetic field's direction, circling around the wire.
3. Looking down from above (from the direction the current is heading), the magnetic field circles counterclockwise around the wire.

## Speed Tricks & Shortcuts

Notice that Coulomb's law and Newton's law of gravitation share the same inverse-square structure — if you can handle one, you can handle the other, just swapping charges for masses and using a different constant.

For Ohm's law, remember the triangle trick: cover the letter you want to find in "$V$ over $IR$" (arranged with $V$ on top, $I$ and $R$ on the bottom), and the remaining letters show you exactly how to compute it.

For series versus parallel circuit questions, remember the one-word test: "does breaking one path break everything?" Yes means series (one shared path); no means parallel (multiple independent paths).

## Traps to Watch For

### #1: Forgetting the Inverse-Square Relationship in Coulomb's Law

> Coulomb's law force depends on distance squared in the denominator — doubling the distance quarters the force, it does not simply halve it.

This is the exact same trap as Newton's law of gravitation, since both follow an inverse-square pattern. Always square the distance-change factor before dividing.

### #2: Assuming Series and Parallel Circuits Behave the Same Way

> In series circuits, current is the same everywhere and voltage splits. In parallel circuits, voltage is the same across each branch and current splits.

Mixing up which quantity (current or voltage) stays constant and which one splits between components is one of the most common circuit errors. Always identify the circuit type first before deciding which quantity to treat as shared.

### #3: Believing One Broken Bulb Always Kills the Whole Circuit

> Only in a series circuit does one broken component stop the entire circuit. In a parallel circuit, other branches keep working independently.

A question describing holiday lights that all go out when one bulb fails describes a series circuit; a question describing house wiring where other outlets keep working when one bulb burns out describes a parallel circuit (which is why household wiring is typically parallel).

### #4: Misapplying the Right-Hand Rule

> Point your thumb in the direction of current flow; your curled fingers show the magnetic field's direction — do not reverse thumb and fingers.

Using the left hand, or swapping which part represents current versus magnetic field direction, gives the opposite (incorrect) field direction. Always use the right hand specifically, with the thumb representing current.
