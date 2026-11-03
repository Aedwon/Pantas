---
_id: "lesson-mechanical-technical-reasoning-pulleys-and-levers"
title: "Pulleys and Levers (Mechanical Advantage, Balance, Fulcrums)"
summary: "Learn ideal pulley mechanical advantage from supporting rope segments and lever balance from torque, including angled forces."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 12
isActive: true
---
## Core Concept

**Pulleys** and **levers** are simple machines. They let you lift a load with less force.

The **effort** is the force you apply. The **load** is the force you work against, such as a weight. The **mechanical advantage** (MA) tells how many times the machine multiplies your force:

$$\text{MA}=\dfrac{F_\text{load}}{F_\text{effort}}$$

A machine is **ideal** when it has no friction and its rope or bar has no weight. Then the work you put in equals the work you get out. Work is force times distance, so a smaller effort must act through a longer distance:

$$F_\text{effort}\,d_\text{effort}=F_\text{load}\,d_\text{load}$$

So MA is also the effort distance divided by the load distance. Real machines need more effort than the ideal value because of friction.

Weight is a force in newtons (N): $W=mg$, with mass $m$ in kilograms and $g=9.8\text{ m/s}^2$.

### Pulleys

A **fixed pulley** is fastened in place. It only changes the direction of a pull, so its ideal MA is $1$.

A **movable pulley** moves with the load. In an ideal system, one rope runs through everything and its tension is the same everywhere. This gives a reliable rule:

> **Ideal MA = the number of rope segments that pull directly on the moving load.**

Two supporting segments give MA $2$: the effort is half the load, and the free end moves twice as far as the load. Four segments give MA $4$, and so on.

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

**Torque** is the turning effect of a force about the fulcrum, in newton-meters ($\text{N}\cdot\text{m}$). When a force pushes at a right angle ($90^\circ$) to the lever, $\tau=F\,d$, where $d$ is the distance from the fulcrum to the force. A lever is balanced when the torques turning it each way are equal. For a perpendicular load and effort:

$$F_\text{effort}\,d_\text{effort}=F_\text{load}\,d_\text{load}$$

This gives $\text{MA}=\dfrac{d_\text{effort}}{d_\text{load}}$. A longer effort arm needs a smaller effort.

### Angled Forces

If a force makes an angle $\theta$ with the lever, only part of it turns the lever:

$$\tau=r\,F\sin\theta$$

Here $r$ is the distance from the fulcrum to where the force acts. The product $r\sin\theta$ is the perpendicular distance from the fulcrum to the line the force acts along. Know that $\sin30^\circ=\dfrac12$ and $\sin90^\circ=1$. At $90^\circ$ the formula becomes $\tau=rF$. A smaller angle needs a bigger force for the same turning effect.

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
### #3: Counting the Supporting Segments

A $900\text{ N}$ load hangs from one movable pulley. The rope is tied to the ceiling, runs down and under the movable pulley, then up over a fixed pulley on the ceiling, and down to the hand. Ignore friction. What effort is needed, and how much rope must be pulled to raise the load $0.5\text{ m}$?

**Solution:**

1. Two segments pull on the movable pulley: the one tied to the ceiling and the one running up to the fixed pulley. The segment from the fixed pulley to the hand does not touch the load.
2. The ideal MA is $2$.

$$F_\text{effort}=\dfrac{900}{2}=450\text{ N}$$

3. The rope moves twice as far as the load: $2\times0.5=1\text{ m}$.

<!-- ILLUSTRATION: a 900 N load on one movable pulley; the rope is tied to the ceiling, runs under the movable pulley, over a fixed pulley and down to a hand; the two segments on the movable pulley are marked 1 and 2, the hand segment "not counted" -->

### #4: Lever Balance

A downward load force of $980\text{ N}$ acts $2\text{ m}$ from a fulcrum. A perpendicular effort force is applied $5\text{ m}$ from the fulcrum on the other side. What effort balances the lever, and what is the MA?

**Solution:**

1. Set the torques equal.

$$F_e(5)=980(2)$$

2. Solve.

$$F_e=392\text{ N}$$

3. Check the MA: $\dfrac{980}{392}=2.5$, which equals $\dfrac52$, the ratio of the arms.

If the load moved closer, to $1\text{ m}$, the effort would drop to $196\text{ N}$, because the MA would rise to $5$.

<!-- FIGURE: {"kind":"lever-balance","loadDistance":2,"effortDistance":5,"semanticsLabel":"A lever with a 980 N load acting 2 m from the fulcrum and a perpendicular effort applied 5 m away; torque balance requires 392 N of effort."} -->
### #5: Balancing a Seesaw

Two children sit on a balanced seesaw. A $30\text{ kg}$ child sits $2.0\text{ m}$ from the fulcrum. A $40\text{ kg}$ child sits on the other side. Ignore the weight of the seesaw. How far from the fulcrum does the second child sit?

**Solution:**

1. The torques are equal.

$$(30g)(2.0)=(40g)\,d$$

2. The value of $g$ is on both sides, so it cancels. Solve for $d$.

$$d=\dfrac{(30)(2.0)}{40}=1.5\text{ m}$$

<!-- ILLUSTRATION: a balanced seesaw on a central fulcrum; a 30 kg child 2.0 m to the left; a 40 kg child an unknown distance d to the right -->

### #6: Finding the Class of a Lever

A wheelbarrow carries a load of $600\text{ N}$. The load acts $0.5\text{ m}$ from the axle of the wheel. The handles are lifted straight up at $1.5\text{ m}$ from the axle. What class of lever is this, and what lifting force is needed?

**Solution:**

1. The axle is the fulcrum. The load is between the fulcrum and the effort, so this is a second-class lever.
2. Set the torques equal.

$$F_e(1.5)=600(0.5)$$

3. Solve.

$$F_e=200\text{ N}$$

The MA is $\dfrac{600}{200}=3$.

<!-- ILLUSTRATION: a wheelbarrow with the axle marked fulcrum, a 600 N load arrow 0.5 m from the axle, and an upward effort arrow at the handles 1.5 m from the axle -->

### #7: An Angled Effort

A $600\text{ N}$ load is $0.5\text{ m}$ from the fulcrum of a lever. A person pushes down on the other side of the lever, $2\text{ m}$ from the fulcrum. The push makes an angle of $30^\circ$ with the lever. What effort balances the load?

**Solution:**

1. Find the torque of the load.

$$\tau_\text{load}=600(0.5)=300\text{ N}\cdot\text{m}$$

2. Write the torque of the effort using the angle.

$$\tau_\text{effort}=F_e(2)\sin30^\circ=F_e(2)\left(\dfrac12\right)=F_e$$

3. Set the torques equal.

$$F_e=300\text{ N}$$

A right-angle push would need only $150\text{ N}$.

<!-- ILLUSTRATION: a lever with the fulcrum at the left end; a 600 N load arrow down at 0.5 m; an effort arrow F at 2 m making a 30 degree angle with the lever, with the angle marked -->

## Speed Tricks & Shortcuts

**For ideal pulleys, count supporting segments.** Divide the load by the count to get the effort.

**If both sides are weights of masses, skip $g$.** It cancels, so compare mass times distance on each side.

## Traps to Watch For

### #1: "Each Movable Pulley Halves the Force"

> Ideal MA depends on how many rope segments support the moving load, not on the number of pulleys.

### #2: Counting a Fixed Pulley as Extra Mechanical Advantage

> A fixed pulley that only redirects the rope adds no mechanical advantage.

### #3: Calling a 50 kg Mass a 50 kg Force

> Kilograms measure mass. Use newtons for force: $50\text{ kg}$ weighs $490\text{ N}$.

### #4: Using Ordinary Distance Instead of the Moment Arm

> If a force is angled, use $rF\sin\theta$, not $rF$.

In example #7, using $\tau=Fd$ with $d=2$ gives $150\text{ N}$, which is wrong.

### #5: Measuring the Whole Bar Instead of the Arms

> Measure each arm from the fulcrum, not from the end of the bar.

### #6: Ignoring Friction

> Ideal MA is a model. Real systems need more effort because of friction and the weight of parts.
