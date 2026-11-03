---
_id: "lesson-physics-dynamics"
title: "Dynamics"
summary: "Newton's laws, weight, normal force, tension, friction, and free-body diagrams, with worked problems on level surfaces, ropes, and inclines."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 15
isActive: true
---
## Core Concept

**Dynamics** studies how forces change motion. A **force** is a push or a pull. It has a size and a direction, so it is a vector. Its unit is the **newton** ($\mathrm N$), where $1\,\mathrm N=1\,\mathrm{kg\cdot m/s^2}$.

The **net force** is the vector sum of all the forces on an object. Forces in opposite directions subtract. Forces at an angle are added by components: first split each force into a part along $x$ and a part along $y$, then add the parts along each axis.

Newton's laws work in an **inertial reference frame**. This is a viewpoint that is not speeding up, slowing down, or turning. The ground is close enough for the problems in this lesson. A braking bus is not an inertial frame.

<!-- ILLUSTRATION: three small panels labeled "first law", "second law", "third law": a book at rest on a table with equal up and down arrows; a hand pushing a cart with a force arrow F and a longer acceleration arrow a pointing the same way; a swimmer pushing water backward with an arrow, and the water pushing the swimmer forward with an equal arrow -->
### Newton's Laws

**First law:** if the net force on an object is zero, its velocity does not change. A resting object stays at rest. A moving object keeps moving in a straight line at the same speed. The reverse also holds: if the velocity is constant, the net force is zero.

**Inertia** is the tendency of an object to keep its velocity. A passenger lurches forward when a bus brakes because the body tends to keep moving. Mass measures inertia. A larger mass is harder to speed up or slow down.

**Second law:** for an object of constant mass,

$$\sum \vec F=m\vec a.$$

Here $\sum \vec F$ is the net force in newtons, $m$ is the mass in kilograms ($\mathrm{kg}$), and $\vec a$ is the acceleration in $\mathrm{m/s^2}$. The acceleration points in the same direction as the net force.

Forces and acceleration are vectors, so write the law once for each axis: $\sum F_x=ma_x$ and $\sum F_y=ma_y$. Choose a positive direction on each axis and give a force a minus sign if it points the other way. The first law is the case $\vec a=0$.

**Third law:** if object A pushes or pulls on object B, then B pushes or pulls on A with a force of equal size in the opposite direction. The two forces are an **interaction pair**. They act at the same time, they are the same kind of force, and they act on **different objects**.

To name a pair, say "A on B" and "B on A". The pair to "Earth pulls the book down" is "the book pulls Earth up".

### Common Forces

**Weight** is the pull of gravity on an object. Near Earth's surface it points toward Earth, and

$$W=mg,$$

where $g\approx 9.8\,\mathrm{m/s^2}$. Mass is the amount of matter and is the same everywhere. Weight is a force, so it changes if $g$ changes.

**Normal force** $N$ is the push of a surface on an object that touches it. "Normal" means perpendicular: the force points straight away from the surface. A surface can push but cannot pull, so $N$ is never negative. If $N$ would have to be zero or less, the object has left the surface.

The size of $N$ is not fixed by the weight. It adjusts so the object does not sink into the surface. You find it from the force balance, using the second law along the line perpendicular to the surface.

**Tension** $T$ is the pull of a rope, string, or cable. It pulls along the rope, toward the rope, on whatever is attached to its ends. A rope can pull but cannot push.

In problems, the rope is usually **ideal**: it has no mass and does not stretch. Any pulley is ideal too: it has no mass and no friction. For an ideal rope, the tension is the same all along it, and connected objects move with the same acceleration while the rope stays tight. A heavy rope or a rough pulley breaks this rule.

### Friction

**Friction** is a force along the surface between two touching objects. It acts against sliding, or against the tendency to slide, between the two surfaces. For dry surfaces, school problems use a simple model with a **coefficient of friction** $\mu$ (a number with no unit that depends on the two surfaces).

**Static friction** acts while the surfaces do not slip. It adjusts to whatever is needed, up to a maximum:

$$f_s\le\mu_sN$$

$$f_{s,\max}=\mu_sN.$$

If the push is smaller than the maximum, static friction equals the push and the object stays at rest. It is not always equal to $\mu_sN$.

**Kinetic friction** acts while the surfaces slide. In the model,

$$f_k=\mu_kN.$$

Here $N$ is the normal force, not necessarily the weight. For most pairs of dry surfaces $\mu_s$ is larger than $\mu_k$, so it takes more force to start a slide than to keep it going.

<!-- ILLUSTRATION: graph of friction force f against applied horizontal force F; a straight line at 45 degrees (f = F) rising to a peak labeled "f_s,max = mu_s N", then dropping to a flat horizontal line labeled "f_k = mu_k N"; regions labeled "at rest" and "sliding" -->
The model is a good guide, not an exact law. Real friction also depends on temperature, surface condition, and lubrication. In the model, the size of the friction does not depend on the contact area.

### Free-Body Diagrams

A **free-body diagram** shows one chosen object by itself, drawn as a dot or a box. Then it shows every force that other objects exert on it, as arrows from the dot.

To build one:

1. Choose the object.
2. Draw gravity first: a weight arrow pointing down.
3. Look at everything that touches the object: a surface gives a normal force and maybe friction, a rope gives tension, and a hand gives a push.
4. Draw each arrow in its true direction and label it.
5. Choose axes. On a slope, put one axis along the slope and one perpendicular to it.
6. Split any arrow that is not along an axis into components.
7. Write $\sum F=ma$ for each axis.

Do not draw the forces that the chosen object exerts on other things. Do not draw $m\vec a$ as a force. It is the result of the forces, not one of them.

On a slope with angle $\theta$ above the horizontal, the weight splits into two parts. One part, $mg\sin\theta$, points down along the slope. The other, $mg\cos\theta$, presses into the slope.

<!-- ILLUSTRATION: block on an incline of angle theta = 30 degrees above the horizontal; arrows: weight mg straight down, normal force N perpendicular to the slope, friction f_k up the slope; dashed components of the weight: mg sin(theta) down the slope and mg cos(theta) into the slope; axes drawn along and perpendicular to the slope -->
## Examples

### #1: Newton's Second Law

A $5\,\mathrm{kg}$ object has a net force of $20\,\mathrm N$ in the positive $x$ direction. Find its acceleration.

**Solution:**

1. The net force is the force in the second law.
2. Divide by the mass.

$$a_x=\dfrac{F_{\text{net},x}}{m}=\dfrac{20}{5}=4\,\mathrm{m/s^2}.$$

The acceleration is $4\,\mathrm{m/s^2}$ in the positive $x$ direction.

### #2: Constant Velocity and Inertia

A $1200\,\mathrm{kg}$ car moves at a constant $20\,\mathrm{m/s}$ on a straight, level road. The engine pushes it forward with $900\,\mathrm N$. Find the total resistive force. Then the engine force rises to $1500\,\mathrm N$ and the resistive force stays the same. Find the acceleration.

**Solution:**

1. The velocity is constant, so the net force is zero. The resistive force has the same size as the engine force.

$$F_{\text{resist}}=900\,\mathrm N.$$

2. Now the net force is the engine force minus the resistive force.

$$F_{\text{net}}=1500-900=600\,\mathrm N.$$

3. Apply the second law.

$$a=\dfrac{600}{1200}=0.5\,\mathrm{m/s^2}.$$

The resistive force is $900\,\mathrm N$ and the acceleration is $0.5\,\mathrm{m/s^2}$ forward. The car needed no net force to keep its velocity. The $900\,\mathrm N$ only cancelled the resistance.

### #3: Mass and Weight

A student has a mass of $60\,\mathrm{kg}$. Use $g=9.8\,\mathrm{m/s^2}$ for Earth. Find the weight on Earth. Then find the weight and mass on a planet where $g=4.0\,\mathrm{m/s^2}$.

**Solution:**

1. Use $W=mg$ on Earth.

$$W=60\times 9.8=588\,\mathrm N.$$

2. On the other planet, use the new $g$.

$$W=60\times 4.0=240\,\mathrm N.$$

The weight changes from $588\,\mathrm N$ to $240\,\mathrm N$. The mass stays $60\,\mathrm{kg}$.

### #4: Normal Force on a Level Surface

A $10\,\mathrm{kg}$ box rests on a level table. Use $g=9.8\,\mathrm{m/s^2}$. Find the normal force (a) with nothing else acting, (b) when a hand pushes straight down on it with $30\,\mathrm N$, and (c) when a rope pulls straight up on it with $30\,\mathrm N$. The box stays at rest in each case.

**Solution:**

1. The box does not move, so $a_y=0$. Take up as positive. The weight is $mg=10\times 9.8=98\,\mathrm N$.
2. Case (a): only $N$ and the weight act.

$$N-98=0\Rightarrow N=98\,\mathrm N.$$

3. Case (b): the hand adds a downward force.

$$N-98-30=0\Rightarrow N=128\,\mathrm N.$$

4. Case (c): the rope adds an upward force.

$$N+30-98=0\Rightarrow N=68\,\mathrm N.$$

So $N$ equals the weight only in case (a). It is positive in case (c), so the box is still touching the table.

<!-- ILLUSTRATION: three side-by-side free-body diagrams of a box on a level table: (a) N = 98 N up and W = 98 N down; (b) N = 128 N up, W = 98 N down, hand force 30 N down; (c) N = 68 N up, rope tension 30 N up, W = 98 N down -->
### #5: Interaction Pair vs. Balanced Forces

A book rests on a level table. Which forces on the book balance? What is the third-law partner of the table's push on the book?

**Solution:**

1. List the forces on the book: Earth pulls it down and the table pushes it up.
2. The book has zero acceleration, so by the second law these two forces on the book add to zero.
3. Now find the pair. The table pushes up on the book, so the book pushes down on the table. These act on different objects, and they are the same kind of force (contact).
4. The partner of "Earth pulls the book down" is "the book pulls Earth up".

The table's push and the book's weight balance because the book is not accelerating. They are not a third-law pair, because both act on the book. Each force has its own partner on another object.

### #6: Equal Forces, Unequal Accelerations

A $1000\,\mathrm{kg}$ car and a $3000\,\mathrm{kg}$ truck collide. During the collision the truck pushes on the car with $12\,000\,\mathrm N$. Find the force of the car on the truck and the acceleration of each vehicle. Ignore other forces.

**Solution:**

1. The car's force on the truck is the third-law partner. It is $12\,000\,\mathrm N$ in the opposite direction.
2. Apply the second law to each vehicle, using only this force.

$$a_{\text{car}}=\dfrac{12\,000}{1000}=12\,\mathrm{m/s^2}.$$

$$a_{\text{truck}}=\dfrac{12\,000}{3000}=4\,\mathrm{m/s^2}.$$

The forces are equal, but the lighter car accelerates three times as much. The accelerations point in opposite directions.

### #7: Reading Friction From Motion

A crate on a level floor is just on the verge of sliding when a horizontal force of $200\,\mathrm N$ is applied. Once it slides at constant speed, a horizontal force of $150\,\mathrm N$ keeps it moving. Find the maximum static friction and the kinetic friction.

**Solution:**

1. At the verge of sliding, static friction is at its maximum and balances the push.

$$f_{s,\max}=200\,\mathrm N.$$

2. At constant speed the net force is zero, so kinetic friction balances the push.

$$f_k=150\,\mathrm N.$$

These numbers come from this crate and this floor. For other surface pairs, the values differ.

### #8: Static or Kinetic Friction?

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

### #9: Tension Between Two Blocks

A $3\,\mathrm{kg}$ block A and a $2\,\mathrm{kg}$ block B are joined by an ideal rope on a frictionless level table. A horizontal force of $20\,\mathrm N$ pulls A, and B trails behind it. Find the acceleration and the tension in the rope.

**Solution:**

1. The rope is tight, so both blocks have the same acceleration. Treat them together as one object of mass $3+2=5\,\mathrm{kg}$.

$$a=\dfrac{20}{5}=4\,\mathrm{m/s^2}.$$

2. Only the rope pulls B forward, so use B alone.

$$T=m_Ba=2\times 4=8\,\mathrm N.$$

3. Check with A: the $20\,\mathrm N$ pulls forward and the rope pulls back.

$$20-8=12=3\times 4.$$

The tension is $8\,\mathrm N$, smaller than the $20\,\mathrm N$ pull.

<!-- ILLUSTRATION: top view of block A (3 kg) and block B (2 kg) joined by a rope on a frictionless table; a 20 N arrow pulls A to the right; separate free-body diagrams: A with 20 N right and T left, B with T right -->
### #10: Tension in a Hanging Cable

A $4\,\mathrm{kg}$ lamp hangs from an ideal cable. Use $g=9.8\,\mathrm{m/s^2}$. Find the tension when the lamp hangs at rest. Then find the tension when the lamp is pulled upward with an acceleration of $2\,\mathrm{m/s^2}$.

**Solution:**

1. The forces on the lamp are the tension up and the weight down. Take up as positive. The weight is $4\times 9.8=39.2\,\mathrm N$.
2. At rest, $a=0$.

$$T-39.2=0\Rightarrow T=39.2\,\mathrm N.$$

3. Accelerating upward at $2\,\mathrm{m/s^2}$:

$$T-39.2=4\times 2.$$

$$T=39.2+8=47.2\,\mathrm N.$$

The tension equals the weight only when the lamp is not accelerating up or down.

### #11: Block on a Rough Incline

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

## Speed Tricks & Shortcuts

Draw a free-body diagram before writing $\sum\vec F=m\vec a$. Then write one equation for each axis.

To check a third-law pair, test three things: both forces come from the same interaction, they are equal and opposite, and they act on different objects.

For static friction, find the friction needed to keep the object still. Then compare it with $\mu_sN$. Use $f_s=\mu_sN$ only when the object is just about to slide.

When blocks joined by a tight, ideal rope move together, find the acceleration of the whole group first. Then find the tension by applying the second law to one block.

For a block on a slope with angle $\theta$, with no other force perpendicular to the slope, $N=mg\cos\theta$. For a level surface with no other vertical force and no vertical acceleration, $N=mg$.

## Traps to Watch For

### #1: Confusing Third-Law Pairs With Balanced Forces

> A third-law pair acts on two different objects. Balanced forces act on one object.

The normal force and the weight on a resting book are equal and opposite, but they are not a pair. Both act on the book. They are equal because the book's acceleration is zero. If the book were in an accelerating elevator, they would differ, while each force would still have its own partner.

### #2: Thinking a Force Is Needed to Keep Moving

> In an inertial frame, constant velocity means the net force is zero, not that no force acts.

A car at constant speed still has an engine force. That force is cancelled by drag and friction. If the opposing forces were absent, no force would be needed.

### #3: Using $\mu_sN$ as the Friction Every Time

> Static friction is at most $\mu_sN$. Only at the verge of sliding does it equal $\mu_sN$.

A crate at rest with a small push has a small friction force. Do not substitute $\mu_sN$ without checking whether the object is about to slide. Also remember that these formulas are models, and real surfaces can behave differently.

### #4: Assuming the Normal Force Equals the Weight

> The normal force comes from the force balance perpendicular to the surface.

It equals $mg$ on a level surface with no other vertical force and no vertical acceleration. It is different on a slope, with an extra push or pull, or in an accelerating elevator.

### #5: Mixing Up Mass and Weight

> Mass is in kilograms and does not change with place. Weight is in newtons and depends on $g$.

An object on another planet has the same mass but a different weight. A bathroom scale marked in kilograms reports mass. A force in newtons is a weight.

### #6: Setting Tension Equal to Weight

> $T=mg$ holds only when the hanging object has no vertical acceleration.

If the object speeds up or slows down, the tension and the weight differ (see example #10). Write the second law first, then solve for $T$.
