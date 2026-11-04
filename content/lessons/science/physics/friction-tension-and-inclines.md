---
_id: "lesson-physics-friction-tension-and-inclines"
title: "Friction, Tension and Inclines"
summary: "Friction, tension in ropes and cables, and motion on inclines, with worked problems on level surfaces, ropes, slopes and angled pulls."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 10
isActive: true
---
## Core Concept

This lesson builds on the lesson Dynamics (Newton's Laws, Forces and Free-Body Diagrams). Read that lesson first. It teaches Newton's laws, weight, the normal force, and how to draw a free-body diagram.

Friction, tension and the slope of a surface each change the net force on an object. You find them the same way as in that lesson: draw a free-body diagram, then write the second law for each axis.

### Tension

**Tension** $T$ is the pull of a rope, string, or cable. It pulls along the rope, toward the rope, on whatever is attached to its ends. A rope can pull but cannot push.

In problems, the rope is usually **ideal**: it has no mass and does not stretch. Any pulley is ideal too: it has no mass and no friction. For an ideal rope, the tension is the same all along it.

Two objects tied to the ends of a tight rope have accelerations of the same size, if the rope passes only over fixed pulleys. Over a pulley the directions can differ: one object moves up while the other moves down, so give each its own sign.

A movable pulley changes this. If one end of the rope is fixed and a block hangs from a movable pulley, that block's acceleration is half the acceleration of the free end. A heavy rope or a rough pulley also breaks these rules.

### Friction

**Friction** is a force along the surface between two touching objects. It acts against sliding, or against the tendency to slide, between the two surfaces. For dry surfaces, school problems use a simple model with a **coefficient of friction** $\mu$ (a number with no unit that depends on the two surfaces).

**Static friction** acts while the surfaces do not slip. It adjusts to whatever is needed, up to a maximum:

$$f_s\le\mu_sN$$

$$f_{s,\max}=\mu_sN.$$

Suppose the only other force along the surface is a horizontal push, and it is smaller than the maximum. Then static friction equals the push and the object stays at rest.

If other forces act along the surface, for example on a slope or with an angled push, find $f_s$ from the force balance along the surface. It must still be at most $\mu_sN$, and it is not always equal to $\mu_sN$.

**Kinetic friction** acts while the surfaces slide. In the model,

$$f_k=\mu_kN.$$

Here $N$ is the normal force, not necessarily the weight. For most pairs of dry surfaces $\mu_s$ is larger than $\mu_k$, so it takes more force to start a slide than to keep it going.

<!-- ILLUSTRATION: graph of friction force f against applied horizontal force F; a straight line at 45 degrees (f = F) rising to a peak labeled "f_s,max = mu_s N", then dropping to a flat horizontal line labeled "f_k = mu_k N"; regions labeled "at rest" and "sliding" -->
The model is a good guide, not an exact law. Real friction also depends on temperature, surface condition, and lubrication. In the model, the size of the friction does not depend on the contact area.

### Forces on an Incline

On a slope with angle $\theta$ above the horizontal, the weight splits into two parts. One part, $mg\sin\theta$, points down along the slope. The other, $mg\cos\theta$, presses into the slope.

<!-- ILLUSTRATION: block on an incline of angle theta = 30 degrees above the horizontal; arrows: weight mg straight down, normal force N perpendicular to the slope, friction f_k up the slope; dashed components of the weight: mg sin(theta) down the slope and mg cos(theta) into the slope; axes drawn along and perpendicular to the slope -->
## Examples

### #1: Reading Friction From Motion

A crate on a level floor is just on the verge of sliding when a horizontal force of $200\,\mathrm N$ is applied. Once it slides at constant speed, a horizontal force of $150\,\mathrm N$ keeps it moving. Find the maximum static friction and the kinetic friction.

**Solution:**

1. At the verge of sliding, static friction is at its maximum and balances the push.

$$f_{s,\max}=200\,\mathrm N.$$

2. At constant speed the net force is zero, so kinetic friction balances the push.

$$f_k=150\,\mathrm N.$$

These numbers come from this crate and this floor. For other surface pairs, the values differ.

### #2: Static or Kinetic Friction?

A $50\,\mathrm{kg}$ crate rests on a level floor. The coefficients are $\mu_s=0.40$ and $\mu_k=0.30$. Use $g=9.8\,\mathrm{m/s^2}$. A horizontal push of $150\,\mathrm N$ is applied. Find the friction force. Then the push is $250\,\mathrm N$. Find the acceleration.

**Solution:**

1. The floor is level and nothing else acts vertically, so $N=mg=50\times 9.8=490\,\mathrm N$.
2. Find the largest static friction.

$$f_{s,\max}=0.40\times 490=196\,\mathrm N.$$

3. Push of $150\,\mathrm N$: this is less than $196\,\mathrm N$, so the crate does not move. Static friction matches the push, so $f_s=150\,\mathrm N$, not $196\,\mathrm N$.
4. Push of $250\,\mathrm N$: this is more than $196\,\mathrm N$, so the crate slides. Now friction is kinetic.

$$f_k=0.30\times 490=147\,\mathrm N.$$

5. Apply the second law along the floor.

$$a=\dfrac{250-147}{50}=\dfrac{103}{50}=2.06\,\mathrm{m/s^2}.$$

### #3: Tension Between Two Blocks

A $3\,\mathrm{kg}$ block A and a $2\,\mathrm{kg}$ block B are joined by an ideal rope on a frictionless level table. A horizontal force of $20\,\mathrm N$ pulls A, and B trails behind it. Find the acceleration and the tension in the rope.

**Solution:**

1. The rope is tight, so both blocks have accelerations of the same size, and here they point the same way. Treat them together as one system of mass $3+2=5\,\mathrm{kg}$. The rope pulls B forward and pulls A back with equal force, and both forces are inside the system, so they cancel. Only the outside force, the $20\,\mathrm N$ pull, is left.

$$a=\dfrac{20}{5}=4\,\mathrm{m/s^2}.$$

2. Only the rope pulls B forward, so use B alone.

$$T=m_Ba=2\times 4=8\,\mathrm N.$$

3. Check with A: the $20\,\mathrm N$ pulls forward and the rope pulls back.

$$20-8=12=3\times 4.$$

The tension is $8\,\mathrm N$, smaller than the $20\,\mathrm N$ pull.

<!-- ILLUSTRATION: top view of block A (3 kg) and block B (2 kg) joined by a rope on a frictionless table; a 20 N arrow pulls A to the right; separate free-body diagrams: A with 20 N right and T left, B with T right -->
### #4: Tension in a Hanging Cable

A $4\,\mathrm{kg}$ lamp hangs from an ideal cable. Use $g=9.8\,\mathrm{m/s^2}$. Find the tension when the lamp hangs at rest. Then find the tension when the lamp is pulled upward with an acceleration of $2\,\mathrm{m/s^2}$.

**Solution:**

1. The forces on the lamp are the tension up and the weight down. Take up as positive. The weight is $4\times 9.8=39.2\,\mathrm N$.
2. At rest, $a=0$.

$$T-39.2=0\Rightarrow T=39.2\,\mathrm N.$$

3. Accelerating upward at $2\,\mathrm{m/s^2}$:

$$T-39.2=4\times 2.$$

$$T=39.2+8=47.2\,\mathrm N.$$

The tension equals the weight only when the lamp is not accelerating up or down.

### #5: Block on a Rough Incline

A $5\,\mathrm{kg}$ block slides down a slope that makes $30^\circ$ with the horizontal. The coefficient of kinetic friction is $0.20$. Use $g=9.8\,\mathrm{m/s^2}$, $\sin 30^\circ=0.50$, and $\cos 30^\circ=0.866$. Find the acceleration of the block.

**Solution:**

1. Draw the forces: weight down, normal force perpendicular to the slope, and kinetic friction up the slope. Put the positive axis down the slope.
2. There is no motion perpendicular to the slope, so the normal force balances the part of the weight that presses into the slope.

$$N=mg\cos\theta=5\times 9.8\times 0.866=42.4\,\mathrm N.$$

3. Find the friction.

$$f_k=\mu_kN=0.20\times 42.4=8.5\,\mathrm N.$$

4. The part of the weight along the slope is

$$mg\sin\theta=5\times 9.8\times 0.50=24.5\,\mathrm N.$$

5. Apply the second law along the slope.

$$24.5-8.5=5a\Rightarrow a=\dfrac{16.0}{5}=3.2\,\mathrm{m/s^2}.$$

The block accelerates down the slope at $3.2\,\mathrm{m/s^2}$. Here $N$ is $42.4\,\mathrm N$, less than the weight of $49\,\mathrm N$.

### #6: Pulling at an Angle

A $10\,\mathrm{kg}$ box is on a level floor. A rope pulls it with $40\,\mathrm N$ at $30^\circ$ above the horizontal. The coefficient of kinetic friction is $0.20$. Use $g=9.8\,\mathrm{m/s^2}$, $\sin 30^\circ=0.50$, and $\cos 30^\circ=0.866$. Find the acceleration.

**Solution:**

1. Split the pull. The part along the floor is $40\cos30^\circ=34.6\,\mathrm N$. The part up is $40\sin30^\circ=20\,\mathrm N$.
2. The weight is $mg=10\times 9.8=98\,\mathrm N$. The box does not move up or down, so $a_y=0$.

$$N+20-98=0\Rightarrow N=78\,\mathrm N.$$

3. The pull lifts part of the weight, so $N$ is less than $mg$.

$$f_k=0.20\times 78=15.6\,\mathrm N.$$

4. Apply the second law along the floor.

$$a=\dfrac{34.6-15.6}{10}=1.9\,\mathrm{m/s^2}.$$

The box accelerates at $1.9\,\mathrm{m/s^2}$ along the floor.

## Speed Tricks & Shortcuts

For static friction, find the friction needed to keep the object still. Then compare it with $\mu_sN$. Use $f_s=\mu_sN$ only when the object is just about to slide.

When blocks joined by a tight, ideal rope move along one line in the same direction, find the acceleration of the whole group first. Only forces from outside the group count, because the rope forces inside cancel. Then find the tension by applying the second law to one block.

Do not use this over a pulley, where one block moves up and the other moves down. Write the second law for each block, with its own sign for the direction it moves.

For a block on a slope with angle $\theta$, with no other force perpendicular to the slope, $N=mg\cos\theta$.

## Traps to Watch For

### #1: Using $\mu_sN$ as the Friction Every Time

> Static friction is at most $\mu_sN$. Only at the verge of sliding does it equal $\mu_sN$.

A crate at rest with a small push has a small friction force. Do not substitute $\mu_sN$ without checking whether the object is about to slide. Also remember that these formulas are models, and real surfaces can behave differently.

### #2: Setting Tension Equal to Weight

> $T=mg$ holds only when the hanging object has no vertical acceleration.

If the object speeds up or slows down, the tension and the weight differ (see example #4). Write the second law first, then solve for $T$.
