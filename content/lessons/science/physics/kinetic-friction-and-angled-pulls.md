---
_id: "lesson-physics-kinetic-friction-and-angled-pulls"
title: "Kinetic Friction and Angled Pulls"
summary: "Find sliding friction from the normal force, including when a rope pulls at an angle."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 5
partCount: 6
ordering: 0
keyPoints:
  - "Find the direction and size of kinetic friction."
  - "Find the effect of an angled pull on normal force, friction, and acceleration."
---
## Core Concept

**Kinetic friction** acts while the surfaces slide. In the model,

$$f_k=\mu_kN.$$

Here $N$ is the normal force, not necessarily the weight. For most pairs of dry surfaces $\mu_s$ is larger than $\mu_k$, so it takes more force to start a slide than to keep it going.

<!-- ILLUSTRATION: graph of friction force f against applied horizontal force F; a straight line at 45 degrees (f = F) rising to a peak labeled "f_s,max = mu_s N", then dropping to a flat horizontal line labeled "f_k = mu_k N"; regions labeled "at rest" and "sliding" -->
The model is a good guide, not an exact law. Real friction also depends on temperature, surface condition, and lubrication. In the model, the size of the friction does not depend on the contact area.

## Examples

### #1: Reading Friction From Motion

A crate on a level floor is just on the verge of sliding when a horizontal force of $200\,\mathrm N$ is applied. Once it slides at constant speed, a horizontal force of $150\,\mathrm N$ keeps it moving. Find the maximum static friction and the kinetic friction.

**Solution:**

1. At the verge of sliding, static friction is at its maximum and balances the push.

$$f_{s,\max}=200\,\mathrm N.$$

2. At constant speed the net force is zero, so kinetic friction balances the push.

$$f_k=150\,\mathrm N.$$

These numbers come from this crate and this floor. For other surface pairs, the values differ.

### #2: Pulling at an Angle

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
