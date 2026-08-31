---
_id: "lesson-physics-momentum-and-impulse"
title: "Momentum and Impulse (Conservation of Momentum, Elastic vs. Inelastic Collisions)"
summary: "How momentum changes through impulse and how momentum and kinetic energy behave in collision models."
subject: "subject-science"
topic: "topic-physics"
estimatedMinutes: 13
isActive: true
---
## Core Concept

Linear **momentum** is the vector

$$\vec p=m\vec v$$

for a particle of constant mass in introductory mechanics.

### Impulse

The **impulse** delivered by a force over a time interval equals the change in momentum:

$$\vec J=\Delta\vec p.$$

In general,

$$\vec J=\int_{t_i}^{t_f}\vec F(t)\,dt.$$

If the force is constant, or if $\vec F$ denotes the **average force** over the interval,

$$\vec J=\vec F_{\text{avg}}\Delta t.$$

Therefore a fixed momentum change spread over a longer stopping time requires a smaller **average force magnitude**, which is one reason airbags, crumple zones, mats, and padded gloves can reduce peak/average impact forces. The actual force-time curve need not be constant.

### Conservation of Momentum

For a system,

$$\Delta\vec P_{\text{system}}=\vec J_{\text{external}}.$$

Thus total momentum is conserved when the **net external impulse is zero or negligible** over the interval. It is not necessary that every external force vanish at every instant; what matters to momentum conservation is the net external impulse.

During a short collision, internal forces between colliding bodies occur in Newton-third-law pairs and cancel from the system's total momentum balance. External impulses may still matter if they are not negligible.

### Elastic and Inelastic Collisions

For an isolated collision system:

- **Elastic collision:** total momentum and total kinetic energy are conserved.
- **Inelastic collision:** total momentum is conserved but kinetic energy of the bodies is not; energy is redistributed into deformation, internal energy, sound, rotation, and other forms.
- **Perfectly inelastic collision:** colliding bodies stick together and share a final velocity.

Total **energy** is still conserved in an inelastic collision; it is specifically the system's translational/ordinary kinetic energy that decreases.

Real billiard-ball collisions can be approximately elastic, not perfectly so.

## Examples

### #1: Momentum

A $1000\,\mathrm{kg}$ car moves at $20\,\mathrm{m/s}$ east.

$$\vec p=(1000)(20)=2.0\times10^4\,\mathrm{kg\,m/s}$$

east.

### #2: Average Force from Impulse

A $0.5\,\mathrm{kg}$ ball moving at $10\,\mathrm{m/s}$ in the positive direction is brought to rest in $0.20$ s.

$$\Delta p=0-(0.5)(10)=-5\,\mathrm{kg\,m/s}$$

$$F_{\text{avg}}=\frac{\Delta p}{\Delta t}=\frac{-5}{0.20}=-25\,\mathrm N.$$

The average force is $25\,\mathrm N$ opposite the original motion. The instantaneous force may vary during the catch.

### #3: Perfectly Inelastic Collision

A $3\,\mathrm{kg}$ cart moving at $4\,\mathrm{m/s}$ strikes a stationary $1\,\mathrm{kg}$ cart and they stick. External horizontal impulse is negligible.

$$(3)(4)+(1)(0)=(3+1)v_f$$

$$v_f=3\,\mathrm{m/s}.$$

### #4: Elastic Collision Criterion

Measurements show that an isolated two-body collision has the same total momentum and kinetic energy before and after.

**Solution:** It is elastic by definition of the collision model.

### #5: When Momentum Is Not Conserved for the Chosen System

A ball hits a wall. Is the ball's momentum alone conserved during the collision?

**Solution:**

No. The wall exerts a large external impulse on the **ball-only system**, changing its momentum. If the chosen system is enlarged to ball + wall + Earth and external impulse on that larger system is negligible, total momentum can be treated as conserved.

## Speed Tricks & Shortcuts

Choose the **system boundary** before invoking momentum conservation.

For a perfectly inelastic collision, combine the masses only after writing the signed/vector momentum equation.

For impulse, use area under the force-time graph. $F\Delta t$ is exact only for constant force or when $F$ is the average force.

## Traps to Watch For

### #1: Saying $J=Ft$ for Any Time-Varying Force Without Qualification

> General impulse is $\int F\,dt$.

Use $F_{\text{avg}}\Delta t$ for an average-force treatment.

### #2: Saying Momentum Is Conserved Whenever Objects Collide

> Momentum of the chosen system is conserved only when net external impulse is zero or negligible.

Internal collision forces cancel in the system balance; external forces need not.

### #3: Saying Energy Is "Lost" in an Inelastic Collision

> Total energy is conserved.

Kinetic energy is transformed into internal energy, deformation, sound, and other forms.

### #4: Ignoring Direction

> Momentum and impulse are vectors.

Assign signs/components consistently before adding momenta.
