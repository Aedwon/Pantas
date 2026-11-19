---
_id: "lesson-geometry-triangle-congruence-tests"
title: "Triangle Congruence Tests"
summary: "Match corresponding parts and choose a valid congruence test."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 4
partCount: 9
ordering: 0
keyPoints:
  - "Match corresponding parts and choose a valid congruence test."
---
## Core Concept

In a **right triangle**, the two sides that form the right angle are the **legs**. The side across from the right angle is the **hypotenuse**. It is the longest side.

### Congruence (SSS, SAS, ASA, AAS, HL)

Two triangles are **congruent** when they are exact copies. Their **corresponding** parts match.

In $\triangle ABC \cong \triangle DEF$, point $A$ matches $D$, $B$ matches $E$, and $C$ matches $F$. So side $AB$ matches $DE$, and $\angle C$ matches $\angle F$.

Prove congruence with these shortcuts. The parts must match in the same places in both triangles:

- **SSS**: all three sides match.
- **SAS**: two sides and the angle between them match.
- **ASA**: two angles and the side between them match.
- **AAS**: two angles and a side that is not between them match.
- **HL**: in right triangles, the hypotenuse and one leg match. (The legs and the hypotenuse are explained above.)

SSA means two sides and an angle that is not between them. It is not a congruence test, because it can build two different triangles. HL is the right-triangle case that does work.

SSA also fixes one triangle when the given side across from the given angle is longer than the other given side, or equal to it when the angle is acute. For example, an angle of $120^\circ$ with a side $5$ next to it and a side $8$ across from it can make only one triangle. If the side across is shorter than the other given side and the angle is acute, two triangles may fit, so do not use SSA.

AAA does not prove congruence either. AAA gives the same shape but maybe a different size.

## Examples

### #1: Matching Parts and Choosing the Rule

In $\triangle ABC$ and $\triangle DEF$, $\angle A = \angle D$, $\angle B = \angle E$, and $BC = EF$. Which congruence rule applies, and which side of $\triangle DEF$ equals $AC$?

<!-- ILLUSTRATION: triangles ABC and DEF; angles A and D one arc, angles B and E two arcs, sides BC and EF one tick -->

**Solution:**
Check where the equal side sits.

1. Two angles match, and side $BC$ is not between $\angle A$ and $\angle B$. The rule is AAS.
2. $AC$ is across from $\angle B$. Its match is across from $\angle E$, which is $DF$.

The rule is AAS, and $AC = DF$.

## Traps to Watch For

### #1: The Fake Postulates

> SSA and AAA do not prove congruence (SSA fixes one triangle only in some cases, such as HL, so do not use it as a test).

Two sides and an angle not between them can build two different triangles. AAA proves only similarity, because the size can differ.
