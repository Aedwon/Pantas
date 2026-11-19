---
_id: "lesson-physics-magnetic-flux-and-faradays-law"
title: "Magnetic Flux and Faraday’s Law"
summary: "Calculate magnetic flux and the voltage from changing flux."
subject: "subject-science"
topic: "topic-physics"
isActive: true
part: 9
partCount: 11
ordering: 0
keyPoints:
  - "Find the flux through a loop."
  - "Find the voltage induced when flux changes."
---
## Core Concept

**Magnetic flux** is the amount of magnetic field passing through a loop:

$$\Phi=BA\cos\theta$$

Here $A$ is the loop area. The angle $\theta$ is between the field and the line perpendicular (at a right angle) to the loop. The unit is the weber, and $1\ \mathrm{Wb}=1\ \mathrm{T\cdot m^2}$.

This works for a flat loop in an even field. Flux is largest when the field is perpendicular to the loop ($\theta=0^\circ$). It is zero when the field runs along the loop ($\theta=90^\circ$).

The **cosine** ($\cos$) of an angle is a number that depends on the angle. From $0^\circ$ to $90^\circ$, it falls from $\cos0^\circ=1$ to $\cos90^\circ=0$. At $\theta=0^\circ$, then, $\Phi=BA$.

An **emf** (electromotive force) is a voltage made by a source, in volts. A battery has an emf.

Another way to make an emf is to change the flux through a loop. We say the emf is **induced**, which means it is made by the changing flux. This is not the charging by induction above.

**Faraday's law** says a change in flux over time induces an emf in a loop of $N$ turns (the wire goes around $N$ times):

$$\mathcal{E}=-N\dfrac{\Delta\Phi}{\Delta t}$$

This gives the average emf over the time $\Delta t$. The flux can change if $B$, $A$ or $\theta$ changes.

## Examples

### #1: Flux and Induced emf

A coil of $10$ turns has area $0.20\ \mathrm{m^2}$. A magnetic field of $0.50$ T (tesla) is perpendicular to it. The field drops to zero in $0.020$ s. Find the size of the emf.

**Solution:**

1. A field perpendicular to the coil means $\theta=0^\circ$. Flux at first:

$$\Phi=BA\cos0^\circ=(0.50)(0.20)=0.10\ \mathrm{Wb}$$

2. The flux falls to zero, so the change is $0.10$ Wb in $0.020$ s.
3. Size of the average emf:

$$\mathcal{E}=10\times\dfrac{0.10}{0.020}=50\ \mathrm{V}$$
