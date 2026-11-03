---
_id: "lesson-mechanical-technical-reasoning-pulleys-and-levers"
title: "Pulleys and Levers (Mechanical Advantage, Balance, Fulcrums)"
summary: "Learn ideal pulley mechanical advantage from supporting rope segments and lever balance from torque, including angled forces."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 14
isActive: true
---
## Core Concept

**Pulleys** and **levers** are simple machines. Many of them let you move a load with less force, by moving your hand through a longer distance. Some do not: a fixed pulley only changes direction, and a third-class lever trades force for distance.

The **effort** is the force you apply. The **load** is the force you work against, such as a weight. The **mechanical advantage** (MA) tells how many times the machine multiplies your force:

$$\text{MA}=\dfrac{F_\text{load}}{F_\text{effort}}$$

A machine is **ideal** when it has no friction and its rope or bar has no weight. Then the work you put in equals the work you get out. Work is force times distance, so a smaller effort must act through a longer distance:

$$F_\text{effort}\,d_\text{effort}=F_\text{load}\,d_\text{load}$$

So MA is also the effort distance divided by the load distance. In a lever the ends move along arcs, and these distances are in the same ratio as the lever arms. Real machines usually need more effort than the ideal value because of friction.

Weight is a force in newtons (N): $W=mg$, with mass $m$ in kilograms and $g=9.8\text{ m/s}^2$.

### Pulleys

A **fixed pulley** is fastened in place. It only changes the direction of a pull, so its ideal MA is $1$.

A **movable pulley** moves with the load. **Tension** is the pull along a rope. If one rope runs through the whole system and there is no friction, its tension is the same everywhere. Some systems use several ropes, and each rope has its own tension. This lesson counts segments only for one-rope systems.

Each rope segment that pulls on the moving load carries that same tension. This gives a reliable rule for an ideal system with one rope and segments that hang straight up:

> **Ideal MA = the number of rope segments that pull directly on the moving load.**

Count a segment if it is attached to the moving block or runs around the moving pulley. A segment that runs from a fixed pulley to your hand does not pull on the load, so do not count it. If your hand pulls the end that leaves the moving block, that end counts.

Two supporting segments give MA $2$: the effort is half the load, and the free end moves twice as far as the load. Three segments give MA $3$, four give MA $4$, and so on. The rule fails if the segments pull at a slant, because only part of each pull lifts the load.

Do not count pulleys. Systems with the same number of pulleys can have different numbers of supporting segments.

<!-- FIGURE: {"kind": "pulley-system", "fixed": 1, "movable": 1, "comparison": true, "semanticsLabel": "Two ideal pulley setups: a single fixed pulley with mechanical advantage 1 and a movable-load setup supported by two rope segments with mechanical advantage 2."} -->
### Levers

A **lever** is a rigid bar that turns about a point called the **fulcrum**. The distance from the fulcrum to the effort is the **effort arm**. The distance from the fulcrum to the load is the **load arm**.

The class of a lever depends on which of the three is in the middle.

- **First class:** the fulcrum is in the middle, as on a seesaw or scissors. The MA can be more than, equal to or less than $1$.
- **Second class:** the load is in the middle, as on a wheelbarrow. The effort arm is longer, so the MA is more than $1$.
- **Third class:** the effort is in the middle, as on tweezers. The MA is less than $1$, but the load moves farther than the effort.

<!-- ILLUSTRATION: three levers on triangle fulcrums labeled First class (fulcrum in the middle), Second class (load in the middle), Third class (effort in the middle), each with effort, load and fulcrum marked -->

### Torque and Balance

**Torque** is the turning effect of a force about the fulcrum, in newton-meters ($\text{N}\cdot\text{m}$). The **moment arm** is the shortest distance from the fulcrum to the line along which the force acts. If the force pushes at a right angle ($90^\circ$) to the lever, the moment arm is just the distance along the lever, and $\tau=F\,d$.

A lever is balanced when the torques turning it one way equal the torques turning it the other way. Ignore the weight of the bar. For a perpendicular load and effort:

$$F_\text{effort}\,L_\text{effort}=F_\text{load}\,L_\text{load}$$

Here $L$ means the arm, the distance from the fulcrum to the force. This gives $\text{MA}=\dfrac{L_\text{effort}}{L_\text{load}}$. A longer effort arm needs a smaller effort.

### Angled Forces

Sometimes the force is not at a right angle to the lever. Let $\theta$ be the angle between the force's line and the lever, from $0^\circ$ to $180^\circ$.

Split the force into two parts. The part along the lever does not turn it. The part at a right angle to the lever is $F\sin\theta$.

$$\tau=r\,F\sin\theta$$

Here $r$ is the distance from the fulcrum to where the force acts. The product $r\sin\theta$ is the moment arm.

**Sine** ($\sin$) of an angle in a right triangle is the opposite side divided by the hypotenuse. The lesson Basic Trigonometric Ratios teaches it. Here you need only these values: $\sin30^\circ=\dfrac12$ and $\sin90^\circ=1$.

At $90^\circ$ the formula becomes $\tau=rF$. As the angle moves toward $0^\circ$ or $180^\circ$, you need a bigger force for the same turning effect. At exactly $0^\circ$ or $180^\circ$, the force points along the lever and gives no torque at all.

## Examples

### #1: Fixed Pulley

An ideal fixed pulley lifts a load whose weight is $490\text{ N}$. Neglecting friction, what pulling force is required?

**Solution:**

A fixed pulley has ideal mechanical advantage $1$, so the rope tension must equal the load's weight:

$$F=490\text{ N}.$$

It changes the direction of the pull, not the size of the force.

<!-- FIGURE: {"kind":"pulley-system","fixed":1,"movable":0,"semanticsLabel":"An ideal fixed pulley lifting a 490 N load; neglecting friction, the rope tension and required pull are 490 N, with the pulley changing direction only."} -->
### #2: Two Supporting Rope Segments

A $60\text{ kg}$ mass is lifted by an ideal movable-pulley arrangement in which **two rope segments support the moving load**. Approximately what effort is required if $g=9.8\text{ m/s}^2$, and how much rope must be pulled to raise the load $2\text{ m}$?

**Solution:**

1. Load weight:

$$W=mg=(60)(9.8)=588\text{ N}.$$

2. Two supporting segments give ideal mechanical advantage $2$:

$$F_\text{effort}=\dfrac{588}{2}=294\text{ N}.$$

3. The effort end must move twice the load distance, so raising the load $2\text{ m}$ requires pulling about $4\text{ m}$ of rope.

<!-- FIGURE: {"kind": "pulley-system", "fixed": 1, "movable": 1, "semanticsLabel": "An ideal movable pulley supporting a load with two rope segments; the free end moves twice the load distance."} -->
### #3: Counting the Supporting Segments

A $900\text{ N}$ load hangs from one movable pulley. The rope is tied to the ceiling, runs down and under the movable pulley, then up over a fixed pulley on the ceiling, and down to the hand. Ignore friction. What effort is needed, and how much rope must be pulled to raise the load $0.5\text{ m}$?

**Solution:**

1. Two segments pull on the movable pulley: the one tied to the ceiling and the one running up to the fixed pulley. The segment from the fixed pulley to the hand does not touch the load.
2. The ideal MA is $2$.

$$F_\text{effort}=\dfrac{900}{2}=450\text{ N}$$

3. The rope moves twice as far as the load: $2\times0.5=1\text{ m}$.

<!-- ILLUSTRATION: a 900 N load on one movable pulley; the rope is tied to the ceiling, runs under the movable pulley, over a fixed pulley and down to a hand; the two segments on the movable pulley are marked 1 and 2, the hand segment "not counted" -->

### #4: Three Supporting Segments

A $900\text{ N}$ load hangs from a frame that holds one movable pulley. One end of the rope is tied to the frame. The rope goes up and over a fixed pulley on the ceiling, down and under the movable pulley, then straight up to a person who pulls that end upward. Ignore friction. What effort is needed, and how much rope must be pulled to raise the load $0.4\text{ m}$?

**Solution:**

1. Three segments pull up on the frame: the tied segment, the segment coming down from the fixed pulley, and the segment going up to the hand. The hand pulls the end that leaves the movable pulley, so it counts.
2. The ideal MA is $3$, even though there are only two pulleys.

$$F_\text{effort}=\dfrac{900}{3}=300\text{ N}$$

3. The rope moves three times as far as the load: $3\times0.4=1.2\text{ m}$.

<!-- ILLUSTRATION: a 900 N load on a frame with one movable pulley; one rope end tied to the frame, going up over a fixed ceiling pulley, down under the movable pulley, then up to a hand pulling up; the three segments on the frame marked 1, 2 and 3 -->

### #5: Four Supporting Segments

A block and tackle has two pulleys in a fixed upper block and two pulleys in a movable lower block. One continuous rope is tied to the upper block. It runs down around a lower pulley, up around an upper pulley, down around the other lower pulley and up around the other upper pulley. The free end then hangs down to the hand. The lower block carries a $1600\text{ N}$ load. Ignore friction and the weight of the blocks. What effort is needed to raise the load $0.75\text{ m}$, and how much rope is pulled?

**Solution:**

1. Four segments touch the lower block. The last segment, from the top pulley to the hand, does not.
2. The ideal MA is $4$.

$$F_\text{effort}=\dfrac{1600}{4}=400\text{ N}$$

3. The rope moves four times as far as the load: $4\times0.75=3\text{ m}$.

<!-- ILLUSTRATION: a block and tackle with two pulleys in an upper fixed block and two in a lower movable block carrying a 1600 N load; the rope is tied to the upper block; the four segments touching the lower block are marked 1 to 4, and the hand segment is marked "not counted" -->

### #6: Lever Balance

A downward load force of $980\text{ N}$ acts $2\text{ m}$ from a fulcrum. A perpendicular effort force is applied $5\text{ m}$ from the fulcrum on the other side. What effort balances the lever, and what is the MA?

**Solution:**

1. Set the torques equal.

$$F_e(5)=980(2)$$

2. Solve.

$$F_e=392\text{ N}$$

3. Check the MA: $\dfrac{980}{392}=2.5$, which equals $\dfrac52$, the ratio of the arms.

If the load moved closer, to $1\text{ m}$, the effort would drop to $196\text{ N}$, because the MA would rise to $5$.

<!-- FIGURE: {"kind":"lever-balance","loadDistance":2,"effortDistance":5,"semanticsLabel":"A lever with a 980 N load acting 2 m from the fulcrum and a perpendicular effort applied 5 m away; torque balance requires 392 N of effort."} -->
### #7: Balancing a Seesaw

Two children sit on a balanced seesaw. A $30\text{ kg}$ child sits $2.0\text{ m}$ from the fulcrum. A $40\text{ kg}$ child sits on the other side. Ignore the weight of the seesaw. How far from the fulcrum does the second child sit?

**Solution:**

1. The torques are equal.

$$(30g)(2.0)=(40g)\,d$$

2. The value of $g$ is on both sides, so it cancels. Solve for $d$.

$$d=\dfrac{(30)(2.0)}{40}=1.5\text{ m}$$

<!-- ILLUSTRATION: a balanced seesaw on a central fulcrum; a 30 kg child 2.0 m to the left; a 40 kg child an unknown distance d to the right -->

### #8: Finding the Class of a Lever

A wheelbarrow carries a load of $600\text{ N}$. The load acts $0.5\text{ m}$ from the axle of the wheel. The handles are lifted straight up at $1.5\text{ m}$ from the axle. What class of lever is this, and what lifting force is needed?

**Solution:**

1. The axle is the fulcrum. The load is between the fulcrum and the effort, so this is a second-class lever.
2. Set the torques equal.

$$F_e(1.5)=600(0.5)$$

3. Solve.

$$F_e=200\text{ N}$$

The MA is $\dfrac{600}{200}=3$.

<!-- ILLUSTRATION: a wheelbarrow with the axle marked fulcrum, a 600 N load arrow 0.5 m from the axle, and an upward effort arrow at the handles 1.5 m from the axle -->

### #9: An Angled Effort

A $600\text{ N}$ load pushes down on a lever at $0.5\text{ m}$ from the fulcrum. A person pushes on the other side of the fulcrum, $2\text{ m}$ from it, with the force at an angle of $30^\circ$ to the lever. What effort balances the load?

**Solution:**

1. Find the torque of the load.

$$\tau_\text{load}=600(0.5)=300\text{ N}\cdot\text{m}$$

2. Write the torque of the effort using the angle.

$$\tau_\text{effort}=F_e(2)\sin30^\circ=F_e(2)\left(\dfrac12\right)=F_e$$

3. Set the torques equal.

$$F_e=300\text{ N}$$

A right-angle push would need only $150\text{ N}$, because $F_e(2)=300$.

<!-- ILLUSTRATION: a horizontal lever on a central fulcrum; a 600 N load arrow pointing down at 0.5 m to the left of the fulcrum; an effort arrow F pointing down and slanted at 2 m to the right of the fulcrum, with the 30 degree angle between the arrow's line and the lever marked -->

## Speed Tricks & Shortcuts

**For ideal one-rope pulley systems, count supporting segments.** Divide the load by the count to get the effort. This works only when the segments hang straight and friction is ignored.

**If both sides are weights from masses, skip $g$.** It cancels when both weights are on the same planet, so compare mass times distance on each side.

## Traps to Watch For

### #1: Counting Pulleys Instead of Segments

> For one continuous rope, ideal MA is the number of supporting segments, not the number of pulleys.

Example #4 has two pulleys but MA $3$. Example #3 has two pulleys but MA $2$. Count the rope segments that pull on the moving load.

### #2: Counting a Fixed Pulley as Extra Mechanical Advantage

> A fixed pulley that only redirects the rope adds no mechanical advantage.

The segment from a fixed pulley to your hand does not pull on the load. Only its direction changes.

### #3: Calling a 50 kg Mass a 50 kg Force

> Kilograms measure mass. Use newtons for force: on Earth, $50\text{ kg}$ weighs $490\text{ N}$.

Test questions often give a mass and ask for a force. Multiply by $g$ first.

### #4: Using Ordinary Distance Instead of the Moment Arm

> If a force is angled, use $rF\sin\theta$, not $rF$.

In example #9, using $\tau=Fd$ with $d=2$ gives $150\text{ N}$, which is wrong. Also measure $\theta$ from the lever, not from the vertical, or you will use the wrong sine.

### #5: Measuring the Whole Bar Instead of the Arms

> Measure each arm from the fulcrum, not from the end of the bar.

The fulcrum is not always at the end or the middle. In the wheelbarrow, the effort arm is $1.5\text{ m}$ from the axle, not the length of the handles.

### #6: Ignoring Friction

> Ideal MA is a model. Friction usually makes the real effort larger, and the weight of the parts can change it.

In a pulley system, friction and the weight of the moving pulley raise the effort. A lever bar's own weight can raise or lower the effort, depending on which side its middle lies. If a question gives no friction or bar weight to use, answer with the ideal value.
