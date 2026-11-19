---
_id: "lesson-mechanical-technical-reasoning-torque-from-angled-forces"
title: "Torque from Angled Forces"
summary: "Use the moment arm and sine to find torque from an angled force."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 7
partCount: 7
ordering: 9
keyPoints:
  - "Use the moment arm and sine to find torque from an angled force."
---
## Core Concept

Sometimes the force is not at a right angle to the lever. Let $\theta$ be the angle between the force's line and the lever, from $0^\circ$ to $180^\circ$. A line crosses the lever at two angles, $\theta$ and $180^\circ-\theta$, and both give the same torque.

Split the force into two parts. The part along the lever does not turn it. The part at a right angle to the lever is $F\sin\theta$.

$$\tau=r\,F\sin\theta$$

Here $r$ is the distance from the fulcrum to where the force acts. The product $r\sin\theta$ is the moment arm.

**Sine** ($\sin$) of an angle in a right triangle is the opposite side divided by the hypotenuse. The lesson Basic Trigonometric Ratios teaches it, and here you need only these values: $\sin30^\circ=\dfrac12$ and $\sin90^\circ=1$. An angle and its partner $180^\circ-\theta$ have the same sine, so $\sin150^\circ=\sin30^\circ=\dfrac12$.

At $90^\circ$ the formula becomes $\tau=rF$. As the angle moves toward $0^\circ$ or $180^\circ$, you need a bigger force for the same turning effect. At exactly $0^\circ$ or $180^\circ$, the force points along the lever and gives no torque at all.

The trap below refers to the original lesson’s Example #9, which is now #1.

## Examples

### #1: An Angled Effort

A $600\text{ N}$ load pushes straight down, at a right angle, on a horizontal lever at $0.5\text{ m}$ from the fulcrum. A person pushes on the other side of the fulcrum, $2\text{ m}$ from it, with the force at an angle of $30^\circ$ to the lever. What effort balances the load?

**Solution:**

1. Find the torque of the load.

$$\tau_\text{load}=600(0.5)=300\text{ N}\cdot\text{m}$$

2. Write the torque of the effort using the angle.

$$\tau_\text{effort}=F_e(2)\sin30^\circ=F_e(2)\left(\dfrac12\right)=F_e$$

3. Set the torques equal.

$$F_e=300\text{ N}$$

A right-angle push would need only $150\text{ N}$, because $F_e(2)=300$.

<!-- ILLUSTRATION: a horizontal lever on a central fulcrum; a 600 N load arrow pointing down at 0.5 m to the left of the fulcrum; an effort arrow F pointing down and slanted at 2 m to the right of the fulcrum, with the 30 degree angle between the arrow's line and the lever marked -->

## Traps to Watch For

### #1: Using Ordinary Distance Instead of the Moment Arm

> If a force is angled, use $rF\sin\theta$, not $rF$.

In example #9, using $\tau=Fd$ with $d=2$ gives $150\text{ N}$, which is wrong. Also measure $\theta$ from the lever, not from the vertical, or you will use the wrong sine. Either angle between the line and the lever works.
