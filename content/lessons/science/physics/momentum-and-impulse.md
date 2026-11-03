---
_id: "lesson-physics-momentum-and-impulse"
title: "Momentum and Impulse (Conservation of Momentum, Elastic vs. Inelastic Collisions)"
summary: "How a force acting over time changes momentum, when the total momentum of a system stays the same, and how kinetic energy behaves in different collisions."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 14
isActive: true
---
## Core Concept

### Momentum

**Momentum** tells how hard it is to stop a moving object. It is the mass times the velocity:

$$\vec p=m\vec v$$

Mass $m$ is in kilograms ($\mathrm{kg}$). Velocity $\vec v$ is in meters per second ($\mathrm{m/s}$). So momentum is in $\mathrm{kg\,m/s}$. The formula assumes the mass stays constant during the motion.

Momentum is a **vector**. A vector has a size and a direction. Velocity is a vector too, so momentum points the same way as the velocity.

For motion along one straight line, show direction with a sign. Pick one direction as positive. Motion that way is positive, and motion the other way is negative.

The sign is only a direction. A momentum of $-8\,\mathrm{kg\,m/s}$ is not "less" than $+3\,\mathrm{kg\,m/s}$ in size. It is larger in size and points the other way.

### Impulse

A **force** is a push or a pull, measured in newtons ($\mathrm N$). The **net force** is the sum of all the forces on an object, with directions included.

**Impulse** measures how much a net force changes momentum over a time. It equals the change in momentum:

$$\vec J=\Delta\vec p=m\vec v_f-m\vec v_i$$

Here $\Delta$ means "final minus initial", $\vec v_i$ is the initial velocity, and $\vec v_f$ is the final velocity. Impulse is also a vector. Its unit is $\mathrm{N\,s}$, which equals $\mathrm{kg\,m/s}$.

If the net force is constant, or if you use its **average force** over the time interval, then

$$\vec J=\vec F_{\text{avg}}\Delta t$$

where $\Delta t$ is the time the force acts. Together, the two lines give

$$\vec F_{\text{avg}}=\dfrac{\Delta\vec p}{\Delta t}$$

The same momentum change over a longer time needs a smaller average force. That is one reason airbags, crumple zones, mats, and padded gloves reduce the force of an impact. The real force during an impact is not constant, and its peak can be larger than its average.

<!-- FIGURE: {"kind":"physics-mechanics-diagram","type":"impulse-duration","illustrationKey":"science/physics/momentum-and-impulse#1","impulse":"same","cases":[{"surface":"hard surface","force":"large","time":"very short"},{"surface":"airbag","force":"smaller","time":"longer"}]} -->
### Impulse From a Force-Time Graph

Often the force changes while it acts. Then plot force $F$ on the vertical axis and time $t$ on the horizontal axis.

For a constant force, the graph is a flat line. The area of the rectangle under it is $F\Delta t$. That is the impulse.

The same idea holds for any shape. **The impulse is the area between the force-time curve and the time axis.** Split a straight-sided shape into rectangles and triangles. Add their areas.

Area above the axis counts as positive impulse. Area below the axis counts as negative impulse, because the force points the other way.

Calculus writes this area as an integral:

$$\vec J=\int_{t_i}^{t_f}\vec F(t)\,dt$$

You do not need calculus to find an area from a straight-sided graph.

<!-- ILLUSTRATION: force-time graph, time $t$ in s on the horizontal axis from $0$ to $5.0$, force $F$ in N on the vertical axis; the line rises straight from $0\,\mathrm N$ at $t=0$ to $10\,\mathrm N$ at $t=2.0\,\mathrm s$, then stays flat at $10\,\mathrm N$ until $t=5.0\,\mathrm s$; the triangle is shaded and labeled A1, the rectangle is shaded and labeled A2 -->
### System and Conservation of Momentum

A **system** is the group of objects you choose to study. Everything else is outside it.

A force between two objects inside the system is an **internal force**. A force from something outside the system is an **external force**.

For a system, the impulse of the net external force equals the change in the system's total momentum:

$$\Delta\vec P_{\text{system}}=\vec J_{\text{external}}$$

Here $\vec P_{\text{system}}$ is the vector sum of the momenta of all the objects in the system.

Internal forces come in pairs of equal size and opposite direction. This is Newton's third law. The two pushes cancel when you add up the system's momentum. So internal forces cannot change the total.

This gives the **law of conservation of momentum**. The total momentum of a system stays constant when the net external force on it is zero. The total also stays nearly constant when external forces are present but act so briefly, or are so small, that their impulse is negligible. A short collision is the common case.

Momentum is a vector, so the rule applies to each direction separately. If the net external force is zero along one direction only, the momentum along that direction is conserved.

Conservation does not hold when the net external impulse is large. A ball bouncing off a wall is an example. The ball's momentum changes because the wall pushes on it. See example #7.

### Kinetic Energy and Collisions

**Kinetic energy** is the energy of motion. It is

$$K=\dfrac{1}{2}mv^2$$

and it is measured in joules ($\mathrm J$). Kinetic energy is not a vector. It is never negative, and the direction of motion does not matter.

Collisions are sorted by what happens to the system's total kinetic energy. Assume the collision happens in a system with a negligible net external impulse, so momentum is conserved in all three types.

- **Elastic collision:** the total kinetic energy before equals the total kinetic energy after.
- **Inelastic collision:** the total kinetic energy after is less than before.
- **Perfectly inelastic collision:** the objects stick together and move with one common velocity. This is the inelastic case in which the kinetic energy lost is the greatest for those starting conditions.

Total energy is still conserved in an inelastic collision. Some kinetic energy turns into other forms: heat, sound, and the energy of bending or breaking. The motion loses kinetic energy, but the total energy stays the same.

Collisions of everyday objects are rarely perfectly elastic. Hard balls, such as billiard balls, come close. Collisions between gas molecules can be elastic.

Some events go the other way. When two skaters push apart, or when something explodes, stored energy changes into kinetic energy. The total kinetic energy goes up, and momentum is still conserved. See example #8.

## Examples

### #1: Signed Momentum

A $1000\,\mathrm{kg}$ car moves at $20\,\mathrm{m/s}$ east. A $2000\,\mathrm{kg}$ truck moves at $10\,\mathrm{m/s}$ west. Find the momentum of each and the total momentum of the two. Take east as positive.

**Solution:**

1. Car, east is positive:

$$p_{\text{car}}=(1000)(+20)=+2.0\times10^4\,\mathrm{kg\,m/s}$$

2. Truck, west is negative:

$$p_{\text{truck}}=(2000)(-10)=-2.0\times10^4\,\mathrm{kg\,m/s}$$

3. Add the signed values:

$$P=+2.0\times10^4+(-2.0\times10^4)=0$$

The total momentum is $0$, even though both vehicles are moving.

### #2: Impulse and Average Force

A $0.5\,\mathrm{kg}$ ball moving at $10\,\mathrm{m/s}$ in the positive direction is brought to rest by a catcher's glove in $0.20\,\mathrm s$. Find the average force on the ball. Then find it if the catcher pulls the glove back and the stop takes $0.50\,\mathrm s$.

**Solution:**

1. Find the change in momentum:

$$\Delta p=0-(0.5)(10)=-5\,\mathrm{kg\,m/s}$$

2. Divide by the time for the first stop:

$$F_{\text{avg}}=\dfrac{\Delta p}{\Delta t}=\dfrac{-5}{0.20}=-25\,\mathrm N$$

3. Divide by the time for the second stop:

$$F_{\text{avg}}=\dfrac{-5}{0.50}=-10\,\mathrm N$$

The average force is $25\,\mathrm N$ opposite the original motion in the first case, and $10\,\mathrm N$ in the second case. The longer stop gives the smaller average force.

### #3: Bounce Off a Wall

A $0.40\,\mathrm{kg}$ ball hits a wall at $5.0\,\mathrm{m/s}$ and rebounds in the opposite direction at $3.0\,\mathrm{m/s}$. The contact lasts $0.020\,\mathrm s$. Find the impulse on the ball and the average force on it. Take the direction toward the wall as positive.

**Solution:**

1. Write the signed velocities. Initial is $+5.0\,\mathrm{m/s}$. Final is $-3.0\,\mathrm{m/s}$, because the ball moves away from the wall.
2. Find the impulse:

$$J=m(v_f-v_i)=(0.40)(-3.0-5.0)=-3.2\,\mathrm{N\,s}$$

3. Divide by the time:

$$F_{\text{avg}}=\dfrac{J}{\Delta t}=\dfrac{-3.2}{0.020}=-160\,\mathrm N$$

The impulse is $3.2\,\mathrm{N\,s}$ away from the wall. The average force is $160\,\mathrm N$ away from the wall. The ball reverses, so the velocity change is the sum of the two speeds, not their difference.

### #4: Impulse From a Variable Force

A force along a straight line acts on an $8.0\,\mathrm{kg}$ cart that starts at rest on a level track with negligible friction. The force rises steadily from $0$ to $10\,\mathrm N$ in the first $2.0\,\mathrm s$. Then it stays at $10\,\mathrm N$ for the next $3.0\,\mathrm s$. Find the final speed of the cart at $5.0\,\mathrm s$.

<!-- ILLUSTRATION: force-time graph for the cart, time in s from $0$ to $5.0$, force in N from $0$ to $10$; a straight line from $(0,0)$ to $(2.0,10)$, then a flat line at $10\,\mathrm N$ to $t=5.0\,\mathrm s$; the triangle is labeled $J_1=10\,\mathrm{N\,s}$ and the rectangle is labeled $J_2=30\,\mathrm{N\,s}$ -->

**Solution:**

1. The first part is a triangle with base $2.0\,\mathrm s$ and height $10\,\mathrm N$:

$$J_1=\dfrac{1}{2}(2.0)(10)=10\,\mathrm{N\,s}$$

2. The second part is a rectangle:

$$J_2=(10)(3.0)=30\,\mathrm{N\,s}$$

3. Add the areas:

$$J=J_1+J_2=40\,\mathrm{N\,s}$$

4. The cart starts at rest, so $J=mv_f-0$:

$$v_f=\dfrac{J}{m}=\dfrac{40}{8.0}=5.0\,\mathrm{m/s}$$

### #5: Perfectly Inelastic Collision and Kinetic Energy

A $3\,\mathrm{kg}$ cart moving at $4\,\mathrm{m/s}$ strikes a stationary $1\,\mathrm{kg}$ cart, and they stick together. The net external impulse is negligible. Find the final speed and the kinetic energy lost.

**Solution:**

1. Conserve momentum. The carts move together afterward, so use the sum of the masses:

$$(3)(4)+(1)(0)=(3+1)v_f$$

2. Solve:

$$v_f=\dfrac{12}{4}=3\,\mathrm{m/s}$$

3. Find the kinetic energy before:

$$K_i=\dfrac{1}{2}(3)(4)^2+0=24\,\mathrm J$$

4. Find the kinetic energy after:

$$K_f=\dfrac{1}{2}(4)(3)^2=18\,\mathrm J$$

5. Subtract:

$$K_i-K_f=6\,\mathrm J$$

The carts lose $6\,\mathrm J$ of kinetic energy, which is $25\%$ of the original. That energy became heat, sound, and deformation. Momentum was conserved, but kinetic energy was not.

### #6: Colliding in Opposite Directions

A $2\,\mathrm{kg}$ cart moves east at $5\,\mathrm{m/s}$. A $3\,\mathrm{kg}$ cart moves west at $2\,\mathrm{m/s}$. They collide head-on and stick together. Find the final velocity. Take east as positive.

**Solution:**

1. Write the signed momentum equation first:

$$(2)(+5)+(3)(-2)=(2+3)v_f$$

2. Simplify:

$$10-6=5v_f$$

3. Solve:

$$v_f=\dfrac{4}{5}=+0.8\,\mathrm{m/s}$$

The positive sign means the combined carts move east at $0.8\,\mathrm{m/s}$. Adding the masses first, or ignoring the sign of the second cart, gives a wrong answer.

### #7: Choosing the System

A ball hits a wall. Is the ball's momentum conserved during the collision? Is momentum conserved if the system is the ball and the wall together?

**Solution:**

1. For the ball alone, the wall's push is an external force. It has a large impulse, so the ball's momentum changes. It is not conserved for the ball-only system.
2. For the ball and the wall together, the push between them is an internal force pair. Total momentum is conserved only if the net external impulse on the wall, such as the push from the ground that holds it in place, is negligible.
3. A wall fixed to the ground is not like that. The ground can push on the wall during the collision. So the momentum of this system is not conserved either.

The momentum that the ball loses goes to the wall and the ground. The Earth is so massive that its change in velocity is too small to see. Include the ball, the wall, and the Earth in the system, and the total momentum is conserved.

### #8: Classifying by Calculation, and a Push-Apart

**Part A.** A $1\,\mathrm{kg}$ cart moving at $2\,\mathrm{m/s}$ hits an identical stationary cart. After the collision, the first cart is at rest and the second moves at $2\,\mathrm{m/s}$. Is the collision elastic?

**Solution:**

1. Check momentum. Before it is $(1)(2)+0=2\,\mathrm{kg\,m/s}$. After it is $0+(1)(2)=2\,\mathrm{kg\,m/s}$. Momentum is conserved.
2. Check kinetic energy. Before it is $\dfrac{1}{2}(1)(2)^2=2\,\mathrm J$. After it is $\dfrac{1}{2}(1)(2)^2=2\,\mathrm J$.
3. Both totals are unchanged, so the collision is elastic.

Compare a different outcome with the same carts: they stick and move together at $1\,\mathrm{m/s}$. Momentum is $(2)(1)=2\,\mathrm{kg\,m/s}$, so it is conserved. Kinetic energy is $\dfrac{1}{2}(2)(1)^2=1\,\mathrm J$, which is less than $2\,\mathrm J$. That collision is perfectly inelastic.

**Part B.** A $50\,\mathrm{kg}$ skater and a $70\,\mathrm{kg}$ skater stand at rest on ice with negligible friction. They push apart. The $70\,\mathrm{kg}$ skater moves away at $2.0\,\mathrm{m/s}$. Find the speed of the other skater and compare the kinetic energy before and after.

**Solution:**

1. Take the $70\,\mathrm{kg}$ skater's direction as positive. The total momentum before is $0$. The ice cancels gravity, and friction is negligible, so momentum is conserved:

$$0=(70)(+2.0)+(50)v$$

2. Solve:

$$v=-\dfrac{140}{50}=-2.8\,\mathrm{m/s}$$

3. The $50\,\mathrm{kg}$ skater moves at $2.8\,\mathrm{m/s}$ in the opposite direction.
4. Kinetic energy before is $0$. After it is

$$\dfrac{1}{2}(70)(2.0)^2+\dfrac{1}{2}(50)(2.8)^2=140+196=336\,\mathrm J$$

Momentum is conserved and kinetic energy increases. The extra energy comes from the skaters' bodies.

## Speed Tricks & Shortcuts

Choose the system first. Then check that the net external impulse on it is zero or negligible. Only then write "total momentum before equals total momentum after".

Pick a positive direction and write every velocity with its sign before you add. Do this before you combine masses.

For a collision where the objects stick, use $m_1v_1+m_2v_2=(m_1+m_2)v_f$. This holds in the direction where the net external impulse is negligible.

A quick check for any collision: compute total kinetic energy before and after. Equal means elastic. Less after means inelastic. More after means stored energy was released.

For impulse from a graph, find the area. Rectangle: base times height. Triangle: $\dfrac{1}{2}$ times base times height. Count area under the axis as negative.

When two objects of equal mass collide head-on and elastically, and one is at rest before, they exchange velocities. This works only for a straight-line, head-on, elastic collision. Example #8 Part A is this case.

## Traps to Watch For

### #1: Using $F\Delta t$ With a Changing Force

> The impulse is $F\Delta t$ only when $F$ is constant or is the average force.

If the force changes, a peak value times the time gives the wrong impulse. Use the area under the graph, or the change in momentum.

### #2: Assuming Momentum Is Conserved Whenever Objects Collide

> Total momentum is conserved only for a system whose net external impulse is zero or negligible.

Two objects colliding on rough ground may lose momentum if friction has a large impulse over a long collision. A ball against a fixed wall is a one-object system with a large external impulse, as example #7 shows.

### #3: Saying Energy Is Lost in an Inelastic Collision

> Kinetic energy decreases, but total energy is conserved.

The "missing" kinetic energy turns into heat, sound, and deformation. Do not claim that energy disappears. Do not claim that kinetic energy is conserved either, unless the collision is elastic.

### #4: Ignoring Direction

> Momentum and impulse are vectors, so signs matter. Kinetic energy is not.

Objects moving in opposite directions can give a total momentum of $0$, as in example #1. For motion along a line, assign signs before adding momenta, as in example #6. Do not give kinetic energies signs, because $v^2$ is never negative.

### #5: Thinking Perfectly Inelastic Means All Motion Stops

> Perfectly inelastic means the objects stick together, not that they stop.

The combined object still moves unless the total momentum before was zero. In example #5, the carts keep moving at $3\,\mathrm{m/s}$.
