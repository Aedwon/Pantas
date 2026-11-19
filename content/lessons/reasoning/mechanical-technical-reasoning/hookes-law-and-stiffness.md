---
_id: "lesson-mechanical-technical-reasoning-hookes-law-and-stiffness"
title: "Hooke’s Law and Spring Stiffness"
summary: "Find displacement from a spring’s unstretched length and tell which way the restoring force acts."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
isActive: true
part: 1
partCount: 2
ordering: 10
keyPoints:
  - "Find displacement from a spring’s unstretched length and tell which way the restoring force acts."
  - "Use force and extension to find or compare spring constants."
  - "Recognize when an ideal spring’s linear rule no longer applies."
---
## Core Concept

For an ideal spring operating within its **elastic limit**, Hooke's law says the restoring force is proportional to displacement from equilibrium:

$$F_s=-kx$$

where:

- $F_s$ is the spring's restoring force,
- $x$ is the extension or compression from its unstretched/equilibrium length,
- $k$ is the **spring constant**, measured in newtons per meter ($\text{N/m}$).

The minus sign means the restoring force points opposite the displacement. When comparing magnitudes in a static hanging setup,

$$F=kx \qquad\Rightarrow\qquad x=\frac{F}{k}.$$

This distinction matters: a **larger $k$ means a stiffer spring**, so the same applied force produces a **smaller** extension.

Hooke's law is an approximation over the range where the spring behaves elastically. A real spring can stop following the linear relation if it is stretched or compressed too far.

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"label": "stiff spring", "stretch": 1}, {"label": "less stiff spring", "stretch": 2}], "semanticsLabel": "Two springs under the same hanging weight: a stiffer spring stretches less and a less stiff spring stretches more."} -->

## Examples

### #1: Comparing Spring Constants

Spring A extends $2\text{ cm}$ under the same load that makes Spring B extend $5\text{ cm}$. Which spring is stiffer?


**Solution:**

For equal force, $k=F/x$. The spring with the smaller extension has the larger $k$. Therefore **Spring A is stiffer**.

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"label": "A", "stretch": 2}, {"label": "B", "stretch": 5}], "semanticsLabel": "Two springs under identical loads: Spring A extends 2 cm and Spring B extends 5 cm, so Spring A has the larger spring constant."} -->

### #2: Calculating the Spring Constant

A spring extends $0.050\text{ m}$ under a downward force of $10\text{ N}$. What is its spring constant?

**Solution:**

$$k=\frac{F}{x}=\frac{10}{0.050}=200\text{ N/m}.$$

<!-- FIGURE: {"kind":"spring-scale","springs":[{"label":"10 N","stretch":5}],"semanticsLabel":"A spring extending 0.050 m (5 cm) under a 10 N force, corresponding to a spring constant of 200 N/m."} -->

## Speed Tricks & Shortcuts

**Keep the proportional direction straight:** for the same spring, more force means more extension; for the same force, a larger spring constant means less extension.

**Use $F=kx$, not $x=kF$.** If the problem gives $k$, solve $x=F/k$.

## Traps to Watch For

### #1: Reversing the Meaning of the Spring Constant

> A larger $k$ means the spring is harder to stretch or compress.

The same force gives a smaller $x$ when $k$ is larger.

### #2: Writing the Wrong Hooke-Law Relationship

> The spring constant multiplies displacement in the force equation: $F=kx$ in magnitude. Therefore $x=F/k$.

### #3: Extending the Linear Rule Beyond the Elastic Range

> Real springs follow Hooke's law only over an appropriate range. Large deformations can become nonlinear or permanent.
