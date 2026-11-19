---
_id: "lesson-mechanical-technical-reasoning-gear-speeds-and-tooth-counts"
title: "Gear Speeds and Tooth Counts"
summary: "Use tooth counts to compare how fast meshing gears turn."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 2
partCount: 2
ordering: 2
keyPoints:
  - "Calculate the speed or turns of a gear from tooth counts."
  - "Distinguish speed from direction and identify matching speeds at the pitch point."
---
## Core Concept

### Speed Ratio

A **pitch circle** is the circle a gear would roll on if it had a smooth rim. The two pitch circles touch at the **pitch point**. At that point the rims of the two pitch circles move at the same speed. For compatible gears with tooth counts $N_1$ and $N_2$,

$$\frac{|\omega_1|}{|\omega_2|}=\frac{N_2}{N_1}.$$

So the gear with fewer teeth has the larger angular speed magnitude.

The tooth-count rule concerns **angular speed**, not direction. Direction depends on the type and arrangement of the gear connection. In a simple chain of external gears, the middle tooth counts cancel when you multiply the pairwise speed ratios. Only the first and last tooth counts set the overall speed ratio.

## Examples

### #1: Tooth-Count Ratio

A 10-tooth external gear meshes with a 30-tooth external gear. If the 10-tooth gear completes 6 rotations, how many rotations does the 30-tooth gear complete?

**Solution:**

The same number of tooth engagements passes the mesh:

$$10(6)=30n$$

$$n=2.$$

The larger gear makes **2 rotations**, in the opposite direction.

<!-- FIGURE: {"kind": "gear-train", "gears": 2, "showFirstTurn": false, "teeth": [10, 30], "semanticsLabel": "A small 10-tooth gear meshing with a large 30-tooth gear, where the small gear turns 6 times while the large gear turns 2 times."} -->

## Speed Tricks & Shortcuts

**For speed, use tooth counts.** Angular speeds are inversely proportional to tooth counts for an ideal meshing pair.

## Traps to Watch For

### #1: Confusing Tooth Count with Direction

> Tooth count determines the speed ratio; mesh type determines the direction relation.
