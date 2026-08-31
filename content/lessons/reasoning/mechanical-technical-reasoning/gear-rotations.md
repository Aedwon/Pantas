---
_id: "lesson-mechanical-technical-reasoning-gear-rotations"
title: "Gear Rotations (Predicting Clockwise vs. Counter-Clockwise Movement)"
summary: "Learn rotation direction and speed ratios for ordinary external gear trains, and recognize when a different gear arrangement changes the rule."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 9
isActive: true
---
## Core Concept

In the common exam-style setup of **ordinary external gears** whose teeth mesh on their outside edges, two directly meshing gears rotate in opposite directions. If one turns clockwise, the other turns counterclockwise.


For a simple line of external gears, direction therefore alternates at every mesh. With gears numbered from the input gear, odd positions rotate in the input gear's direction and even positions rotate opposite it.

<!-- FIGURE: {"kind": "gear-train", "gears": 3, "firstTurns": "clockwise", "semanticsLabel": "A row of three meshing gears in a line, showing alternating direction with the first turning clockwise, second counter-clockwise, and third clockwise."} -->
### Speed Ratio

At an ideal gear mesh, the tangential speeds at the contact point match. For compatible gears with tooth counts $N_1$ and $N_2$,

$$\frac{|\omega_1|}{|\omega_2|}=\frac{N_2}{N_1}.$$

So the gear with fewer teeth has the larger angular speed magnitude.

The tooth-count rule concerns **angular speed**, not direction. Direction depends on the type and arrangement of the gear connection.

### Important Exceptions to the Simple Direction Rule

- **Internal gears:** a pinion meshing with the inside teeth of a ring gear can rotate in the **same** direction as the ring gear.
- **Compound gears on the same shaft:** two gears rigidly fixed to the same shaft share the same angular velocity and direction even though their teeth do not mesh with each other.

Most basic figure questions depict external spur gears, but inspect the diagram before applying the alternating shortcut.

## Examples

### #1: Three External Gears

Three ordinary external gears mesh in a row. Gear 1 turns clockwise. What direction does Gear 3 turn?

**Solution:**

Gear 1 clockwise → Gear 2 counter-clockwise → Gear 3 clockwise. Gear 3 turns **clockwise**.

<!-- FIGURE: {"kind": "gear-train", "gears": 3, "firstTurns": "clockwise", "semanticsLabel": "Three meshing gears in a row with gear 1 turning clockwise, gear 2 counter-clockwise, and gear 3 turning clockwise."} -->
### #2: Five External Gears

Five external gears mesh in a row. Gear 1 turns counter-clockwise. Gear 5 is four meshes away, so the direction has reversed an even number of times. Gear 5 turns **counter-clockwise**.

<!-- FIGURE: {"kind": "gear-train", "gears": 5, "firstTurns": "counter-clockwise", "semanticsLabel": "Five meshing gears in a row with gear 1 turning counter-clockwise and alternating direction down the chain to gear 5 turning counter-clockwise."} -->
### #3: Tooth-Count Ratio

A 10-tooth external gear meshes with a 30-tooth external gear. If the 10-tooth gear completes 6 rotations, how many rotations does the 30-tooth gear complete?

**Solution:**

The same number of tooth engagements passes the mesh:

$$10(6)=30n$$

$$n=2.$$

The larger gear makes **2 rotations**, in the opposite direction.

<!-- FIGURE: {"kind": "gear-train", "gears": 2, "showFirstTurn": false, "teeth": [10, 30], "semanticsLabel": "A small 10-tooth gear meshing with a large 30-tooth gear, where the small gear turns 6 times while the large gear turns 2 times."} -->
### #4: Several External Gears Around One Hub

A central external gear meshes separately with three outer external gears that do not touch one another. If the center turns clockwise, each outer gear turns **counter-clockwise** because each has one external mesh with the center.

<!-- FIGURE: {"kind": "gear-train", "gears": 4, "firstTurns": "clockwise", "layout": "spokes", "semanticsLabel": "A central gear turning clockwise meshing separately with three outer gears arranged like spokes, all turning counter-clockwise."} -->
## Speed Tricks & Shortcuts

**First identify the connection.** External mesh, internal mesh, and same-shaft mounting do not use the same direction rule.

**For a simple external chain, count meshes.** An odd number of external meshes reverses direction; an even number preserves the input direction.

**For speed, use tooth counts.** Angular speeds are inversely proportional to tooth counts for an ideal meshing pair.

## Traps to Watch For

### #1: "Any Meshing Gears Always Rotate Opposite"

> That is true for ordinary **external** gear meshes, not for every possible gear geometry. Internal gear meshes can preserve direction.

### #2: Confusing Tooth Count with Direction

> Tooth count determines the speed ratio; mesh type determines the direction relation.

### #3: Ignoring Same-Shaft Compound Gears

> Gears rigidly attached to the same shaft share the shaft's angular velocity even if their sizes differ.

### #4: Applying the Straight-Chain Shortcut to a Branching Diagram

> Trace each actual mesh path. Outer gears that each contact only a central gear do not mesh with one another.
