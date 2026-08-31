---
_id: "lesson-mechanical-technical-reasoning-pulleys-and-levers"
title: "Pulleys and Levers (Mechanical Advantage, Balance, Fulcrums)"
summary: "Learn ideal pulley mechanical advantage from supporting rope segments and lever balance from torque."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 11
isActive: true
---
## Core Concept

**Pulleys** and **levers** are simple machines. In an ideal machine, they can reduce the effort force by increasing the distance through which that force acts; they do not reduce the total ideal work required. Real machines also lose energy through friction, bending, deformation, and other effects.

### Pulleys

A single **fixed pulley** changes the direction of a pull but has ideal mechanical advantage $1$.

For an ideal pulley system with one continuous rope and equal tension throughout that rope, a reliable rule is:

> **Ideal mechanical advantage = number of rope segments directly supporting the moving load or moving block.**

If two tensioned rope segments support the moving load, the ideal mechanical advantage is $2$: the required effort is half the load force, and the free end must move twice as far as the load. Four supporting segments give ideal mechanical advantage $4$, and so on.

Do **not** determine mechanical advantage merely by counting movable pulleys. Different arrangements with the same number of pulleys can have different numbers of supporting rope segments.


<!-- FIGURE: {"kind": "pulley-system", "fixed": 1, "movable": 1, "comparison": true, "semanticsLabel": "Two ideal pulley setups: a single fixed pulley with mechanical advantage 1 and a movable-load setup supported by two rope segments with mechanical advantage 2."} -->
### Levers and Torque

A **lever** is a rigid body that can rotate about a fulcrum or pivot. Rotational effect is measured by **torque**:

$$\tau=rF\sin\theta=F d_\perp,$$

where $d_\perp$ is the perpendicular moment arm from the pivot to the force's line of action.

For a simple horizontal lever with forces applied perpendicular to the lever and in static balance,

$$F_\text{effort}d_\text{effort}=F_\text{load}d_\text{load}.$$

A longer effort arm can therefore reduce the effort force needed to balance a given load, under the stated ideal assumptions.

## Examples

### #1: Fixed Pulley

An ideal fixed pulley lifts a load whose weight is $490\text{ N}$. Neglecting friction, what pulling force is required?

**Solution:**

A fixed pulley has ideal mechanical advantage $1$, so the rope tension must equal the load's weight:

$$F=490\text{ N}.$$

It changes the direction of the pull, not the ideal force magnitude.

<!-- FIGURE: {"kind":"pulley-system","fixed":1,"movable":0,"semanticsLabel":"An ideal fixed pulley lifting a 490 N load; neglecting friction, the rope tension and required pull are 490 N, with the pulley changing direction only."} -->
### #2: Two Supporting Rope Segments

A $60\text{ kg}$ mass is lifted by an ideal movable-pulley arrangement in which **two rope segments support the moving load**. Approximately what effort is required if $g=9.8\text{ m/s}^2$, and how much rope must be pulled to raise the load $2\text{ m}$?


**Solution:**

1. Load weight:

$$W=mg=(60)(9.8)=588\text{ N}.$$

2. Two supporting segments give ideal mechanical advantage $2$:

$$F_\text{effort}=588/2=294\text{ N}.$$

3. The effort end must move twice the load distance, so raising the load $2\text{ m}$ requires pulling about $4\text{ m}$ of rope.

<!-- FIGURE: {"kind": "pulley-system", "fixed": 1, "movable": 1, "semanticsLabel": "An ideal movable pulley supporting a load with two rope segments; the free end moves twice the load distance."} -->
### #3: Lever Balance

A downward load force of $980\text{ N}$ acts $2\text{ m}$ from a fulcrum. A perpendicular effort force is applied $5\text{ m}$ from the fulcrum on the other side. What effort balances the lever?

**Solution:**

$$F_e(5)=980(2)$$

$$F_e=392\text{ N}.$$

<!-- FIGURE: {"kind":"lever-balance","loadDistance":2,"effortDistance":5,"semanticsLabel":"A lever with a 980 N load acting 2 m from the fulcrum and a perpendicular effort applied 5 m away; torque balance requires 392 N of effort."} -->
### #4: Changing the Moment Arm

If the same $980\text{ N}$ load is moved to $1\text{ m}$ from the fulcrum while the perpendicular effort remains applied $5\text{ m}$ away,

$$F_e(5)=980(1),$$

so

$$F_e=196\text{ N}.$$

The shorter load arm reduces the balancing effort required.

<!-- FIGURE: {"kind":"lever-balance","loadDistance":1,"effortDistance":5,"semanticsLabel":"The same 980 N load moved to 1 m from the fulcrum with the perpendicular effort still 5 m away; torque balance requires 196 N of effort."} -->
## Speed Tricks & Shortcuts

**For ideal pulleys, count supporting rope segments—not pulleys.** Count the tensioned segments that directly support the moving load/block.

**Keep force and mass units separate.** Kilograms are mass; newtons are force. Convert with $W=mg$ when necessary.

**For levers, use perpendicular moment arms.** The simple force-times-distance form assumes the forces are perpendicular to the lever.

## Traps to Watch For

### #1: "Each Movable Pulley Halves the Force"

> That is not a general rule. Ideal mechanical advantage depends on how the rope is routed and how many rope segments support the moving load.

### #2: Counting a Fixed Pulley as Extra Mechanical Advantage

> A fixed pulley used only to redirect the rope normally changes direction without increasing ideal mechanical advantage.

### #3: Calling a 50 kg Mass a 50 kg Force

> Use newtons for force, or explicitly state kilogram-force if a non-SI convention is intentionally being used.

### #4: Using Ordinary Distance Instead of the Moment Arm

> Torque depends on perpendicular distance to the force's line of action. If a force is angled, use $rF\sin\theta$ or the perpendicular moment arm.

### #5: Ignoring Friction

> Ideal mechanical advantage is a model. Real pulley and lever systems require more input because of losses and component weight.
