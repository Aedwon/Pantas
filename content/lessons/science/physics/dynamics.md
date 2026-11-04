---
_id: "lesson-physics-dynamics"
title: "Dynamics (Newton's Laws, Forces and Free-Body Diagrams)"
summary: "Newton's laws, weight, the normal force, and free-body diagrams, with worked problems on forces and acceleration."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 10
isActive: true
---
## Core Concept

**Dynamics** studies how forces change motion. A **force** is a push or a pull. It has a size and a direction, so it is a vector. Its unit is the **newton** ($\mathrm N$), where $1\,\mathrm N=1\,\mathrm{kg\cdot m/s^2}$.

The **net force** is the vector sum of all the forces on an object. Forces in opposite directions subtract. Forces at an angle are added by components: first split each force into a part along $x$ and a part along $y$, then add the parts along each axis.

Suppose a force $F$ points at an angle $\theta$ from the $x$ axis. Its parts are $F_x=F\cos\theta$ along that axis and $F_y=F\sin\theta$ along the other. Cosine and sine are the side ratios of a right triangle: $\cos\theta$ is the side next to the angle divided by the long side, and $\sin\theta$ is the side opposite the angle divided by the long side. The Scalars and Vectors lesson teaches this in full.

Newton's laws work in an **inertial reference frame**, a viewpoint that is not speeding up, slowing down, or turning. The ground is close enough for the problems in this lesson. A braking bus is not an inertial frame.

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"newton-laws","illustrationKey":"science/physics/dynamics#1","laws":[{"label":"first law","scene":"book motionless on table","relationship":"balanced forces"},{"label":"second law","scene":"hand pushing cart","relationship":"force arrow and acceleration arrow"},{"label":"third law","scene":"swimmer pushes water backward","relationship":"water pushes swimmer forward equally"}]} -->
### Newton's Laws

**First law:** if the net force on an object is zero, its velocity does not change. A resting object stays at rest. A moving object keeps moving in a straight line at the same speed. The reverse also holds: if the velocity is constant, the net force is zero.

**Inertia** is the tendency of an object to keep its velocity. A passenger lurches forward when a bus brakes because the body tends to keep moving. Mass measures inertia. A larger mass is harder to speed up or slow down.

**Second law:** for an object of constant mass,

$$\sum \vec F=m\vec a.$$

Here $\sum \vec F$ is the net force in newtons, $m$ is the mass in kilograms ($\mathrm{kg}$), and $\vec a$ is the acceleration in $\mathrm{m/s^2}$. Velocity tells how fast and in which direction an object moves. Acceleration is how fast the velocity changes (see the Kinematics lesson). The acceleration points in the same direction as the net force.

Forces and acceleration are vectors, so write the law once for each axis: $\sum F_x=ma_x$ and $\sum F_y=ma_y$. Choose a positive direction on each axis and give a force a minus sign if it points the other way. The first law is the case $\vec a=0$.

**Third law:** if object A pushes or pulls on object B, then B pushes or pulls on A with a force of equal size in the opposite direction. The two forces are an **interaction pair**. They act at the same time, they are the same kind of force, and they act on different objects.

To name a pair, say "A on B" and "B on A". The pair to "Earth pulls the book down" is "the book pulls Earth up".

### Common Forces

**Weight** is the pull of gravity on an object. Near Earth's surface it points toward Earth, and

$$W=mg,$$

where $g\approx 9.8\,\mathrm{m/s^2}$ is the acceleration of a falling object near Earth's surface when air resistance is ignored. Mass is the amount of matter and is the same everywhere. Weight is a force, so it changes if $g$ changes.

**Normal force** $N$ is the push of a surface on an object that touches it. "Normal" means perpendicular: the force points straight away from the surface. A surface can push but cannot pull, so $N$ is never negative.

If the force balance gives $N=0$, the object just touches the surface and is about to leave it. If the balance would need a negative $N$, the surface cannot supply it, so the object lifts off.

The size of $N$ is not fixed by the weight. It adjusts so the object does not sink into the surface. You find it from the force balance, using the second law along the line perpendicular to the surface.

### Free-Body Diagrams

A **free-body diagram** shows one chosen object by itself, drawn as a dot or a box. Then it shows every force that other objects exert on it, as arrows from the dot.

To build one:

1. Choose the object.
2. Draw gravity first: a weight arrow pointing down.
3. Look at everything that touches the object: a surface gives a normal force and maybe friction, a rope gives tension, and a hand gives a push.
4. Draw each arrow in its true direction and label it.
5. Choose axes. On a slope, put one axis along the slope and one perpendicular to it.
6. Split any arrow that is not along an axis into components, using $F\cos\theta$ and $F\sin\theta$ with $\theta$ measured from an axis.
7. Write $\sum F=ma$ for each axis.

Do not draw the forces that the chosen object exerts on other things. Do not draw $m\vec a$ as a force. It is the result of the forces, not one of them.

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

The resistive force is $900\,\mathrm N$ and the acceleration is $0.5\,\mathrm{m/s^2}$ forward. The car needed no net force to keep its velocity. The $900\,\mathrm N$ only canceled the resistance.

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

<!-- FIGURE: {"kind": "concept-diagram", "type": "free-body", "forces": [{"label": "Normal Force (Fn)", "direction": "up"}, {"label": "Weight (Fg)", "direction": "down"}], "semanticsLabel": "A free body diagram of a box with an upward normal force arrow and an equal downward gravity arrow."} -->
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

## Speed Tricks & Shortcuts

Draw a free-body diagram before writing $\sum\vec F=m\vec a$. Then write one equation for each axis.

To check a third-law pair, test three things: both forces come from the same interaction, they are equal and opposite, and they act on different objects.

For a level surface with no other vertical force and no vertical acceleration, $N=mg$.

## Traps to Watch For

### #1: Confusing Third-Law Pairs With Balanced Forces

> A third-law pair acts on two different objects. Balanced forces act on one object.

The normal force and the weight on a resting book are equal and opposite, but they are not a pair. Both act on the book. They are equal because the book's acceleration is zero. If the book were in an accelerating elevator, they would differ, while each force would still have its own partner.

### #2: Thinking a Force Is Needed to Keep Moving

> In an inertial frame, constant velocity means the net force is zero, not that no force acts.

A car at constant speed still has an engine force. That force is canceled by drag and friction. If the opposing forces were absent, no force would be needed.

### #3: Assuming the Normal Force Equals the Weight

> The normal force comes from the force balance perpendicular to the surface.

It equals $mg$ on a level surface with no other vertical force and no vertical acceleration. It is different on a slope, with an extra push or pull, or in an accelerating elevator.

### #4: Mixing Up Mass and Weight

> Mass is in kilograms and does not change with place. Weight is in newtons and depends on $g$.

An object on another planet has the same mass but a different weight.
