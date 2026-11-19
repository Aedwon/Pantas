---
_id: "lesson-physics-static-friction-and-its-limit"
title: "Static Friction and Its Limit"
summary: "Compare the friction needed at rest with the maximum static friction."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 4
partCount: 6
ordering: 37
keyPoints:
  - "Find actual and maximum static friction."
  - "Compare static and kinetic friction when motion starts."
---
## Core Concept

### Friction

**Friction** is a force along the surface between two touching objects. It acts against sliding, or against the tendency to slide, between the two surfaces. For dry surfaces, school problems use a simple model with a **coefficient of friction** $\mu$ (a number with no unit that depends on the two surfaces).

**Static friction** acts while the surfaces do not slip. It adjusts to whatever is needed, up to a maximum:

$$f_s\le\mu_sN$$

$$f_{s,\max}=\mu_sN.$$

Suppose the only other force along the surface is a horizontal push, and it is smaller than the maximum. Then static friction equals the push and the object stays at rest.

If other forces act along the surface, for example on a slope or with an angled push, find $f_s$ from the force balance along the surface. It must still be at most $\mu_sN$, and it is not always equal to $\mu_sN$.

## Examples

### #1: Static or Kinetic Friction?

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

## Speed Tricks & Shortcuts

For static friction, find the friction needed to keep the object still. Then compare it with $\mu_sN$. Use $f_s=\mu_sN$ only when the object is just about to slide.

## Traps to Watch For

### #1: Using $\mu_sN$ as the Friction Every Time

> Static friction is at most $\mu_sN$. Only at the verge of sliding does it equal $\mu_sN$.

A crate at rest with a small push has a small friction force. Do not substitute $\mu_sN$ without checking whether the object is about to slide. Also remember that these formulas are models, and real surfaces can behave differently.
