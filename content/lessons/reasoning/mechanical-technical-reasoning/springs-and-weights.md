---
_id: "lesson-mechanical-technical-reasoning-springs-and-weights"
title: "Springs and Weights"
summary: "Learn how an ideal spring's extension relates to applied force and how the spring constant measures stiffness."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 9
isActive: true
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

For a hanging mass at rest, the applied force is its weight $mg$ (ignoring the spring's own mass), so

$$x=\frac{mg}{k}.$$

Mass is measured in kilograms; **weight is a force measured in newtons**. In simple proportional exam questions, you can compare masses directly only when the same gravitational field is assumed, because weight then scales with mass.


Hooke's law is an approximation over the range where the spring behaves elastically. A real spring can stop following the linear relation if it is stretched or compressed too far.

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"label": "stiff spring", "stretch": 1}, {"label": "less stiff spring", "stretch": 2}], "semanticsLabel": "Two springs under the same hanging weight: a stiffer spring stretches less and a less stiff spring stretches more."} -->
## Examples

### #1: Proportional Extension for One Spring

A spring extends $4\text{ cm}$ when a $2\text{ kg}$ mass hangs from it. Assuming the spring stays in its Hooke-law range and gravity is unchanged, how far will it extend with a $6\text{ kg}$ mass?


**Solution:**

1. For the same spring, $x=F/k$. Since $F=mg$, extension is proportional to mass when $g$ and $k$ are fixed.
2. The mass increases by $6/2=3$.
3. The extension also increases by a factor of $3$:

$$4\text{ cm}\times3=12\text{ cm}.$$

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"stretch": 4}, {"stretch": 12}], "semanticsLabel": "The same ideal spring shown with a 2 kg mass causing 4 cm extension and a 6 kg mass causing 12 cm extension."} -->
### #2: Finding Mass from a Known Extension Ratio

The same spring extends $3\text{ cm}$ under a $1\text{ kg}$ mass. What mass would produce a $15\text{ cm}$ extension, assuming linear behavior?

**Solution:**

The extension is five times larger, so the required weight—and therefore the mass under the same gravity—is five times larger:

$$15/3=5.$$

The mass is **$5\text{ kg}$**.

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"stretch": 15}], "semanticsLabel": "A hanging spring stretched 15 cm with an unknown weight labeled with a question mark attached, balancing 5 kg."} -->
### #3: Comparing Spring Constants

Spring A extends $2\text{ cm}$ under the same load that makes Spring B extend $5\text{ cm}$. Which spring is stiffer?


**Solution:**

For equal force, $k=F/x$. The spring with the smaller extension has the larger $k$. Therefore **Spring A is stiffer**.

<!-- FIGURE: {"kind": "spring-scale", "springs": [{"label": "A", "stretch": 2}, {"label": "B", "stretch": 5}], "semanticsLabel": "Two springs under identical loads: Spring A extends 2 cm and Spring B extends 5 cm, so Spring A has the larger spring constant."} -->
### #4: Calculating the Spring Constant

A spring extends $0.050\text{ m}$ under a downward force of $10\text{ N}$. What is its spring constant?

**Solution:**

$$k=\frac{F}{x}=\frac{10}{0.050}=200\text{ N/m}.$$

<!-- FIGURE: {"kind":"spring-scale","springs":[{"label":"10 N","stretch":5}],"semanticsLabel":"A spring extending 0.050 m (5 cm) under a 10 N force, corresponding to a spring constant of 200 N/m."} -->
## Speed Tricks & Shortcuts

**Keep the proportional direction straight:** for the same spring, more force means more extension; for the same force, a larger spring constant means less extension.

**Use $F=kx$, not $x=kF$.** If the problem gives $k$, solve $x=F/k$.

**Do not call kilograms a force.** Convert a mass to weight with $W=mg$ when an actual force value is required.

## Traps to Watch For

### #1: Reversing the Meaning of the Spring Constant

> A larger $k$ means the spring is harder to stretch or compress.

The same force gives a smaller $x$ when $k$ is larger.

### #2: Writing the Wrong Hooke-Law Relationship

> The spring constant multiplies displacement in the force equation: $F=kx$ in magnitude. Therefore $x=F/k$.

### #3: Treating Mass and Weight as the Same Quantity

> Kilograms measure mass. Weight is the gravitational force $mg$ and is measured in newtons.

### #4: Extending the Linear Rule Beyond the Elastic Range

> Real springs follow Hooke's law only over an appropriate range. Large deformations can become nonlinear or permanent.
