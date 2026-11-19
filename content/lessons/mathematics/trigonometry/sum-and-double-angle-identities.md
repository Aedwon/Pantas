---
_id: "lesson-trigonometry-sum-and-double-angle-identities"
title: "Sum and Double-Angle Identities"
summary: "Find values for sums and differences of angles."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 6
partCount: 6
ordering: 24
keyPoints:
  - "Find values for sums and differences of angles."
  - "Choose and apply a double-angle formula."
---
## Core Concept

**Sum and difference identities** give the value at $A + B$ or $A - B$ from the values at $A$ and $B$:

$$\sin(A \pm B) = \sin A \cos B \pm \cos A \sin B$$

$$\cos(A \pm B) = \cos A \cos B \mp \sin A \sin B$$

$$\tan(A \pm B) = \dfrac{\tan A \pm \tan B}{1 \mp \tan A \tan B}$$

In the cosine and tangent lines, the lower sign goes with the lower sign. The sine and cosine formulas hold for all angles. The tangent formula needs $\tan A$ and $\tan B$ to be defined and the bottom to be nonzero. If the bottom is $0$, then $A \pm B$ is an odd multiple of $90^\circ$, and its tangent is undefined.

**Double-angle identities** come from the sum formulas with $B = A$. Write $\theta$ for the angle:

$$\sin 2\theta = 2\sin \theta \cos \theta$$

$$\cos 2\theta = \cos^2 \theta - \sin^2 \theta = 1 - 2\sin^2 \theta = 2\cos^2 \theta - 1$$

$$\tan 2\theta = \dfrac{2\tan \theta}{1 - \tan^2 \theta}$$

The sine and cosine formulas hold for all angles. The tangent formula needs $\tan \theta$ defined and $\tan^2 \theta \neq 1$. For example, at $\theta = 45^\circ$ the bottom is $0$, and $\tan 90^\circ$ is undefined. The last two forms of $\cos 2\theta$ follow from the first one and $\sin^2 \theta + \cos^2 \theta = 1$.

Example 1 of Pythagorean Identity and Signs supplies the cosine used in the double-angle example.

## Examples

### #1: Exact Value with a Sum Identity

Find the exact value of $\sin 75^\circ$.

**Solution:**
Write $75^\circ$ as $45^\circ + 30^\circ$. Both angles have known exact values.

1. Use the sum formula for sine.

$$\sin 75^\circ = \sin 45^\circ \cos 30^\circ + \cos 45^\circ \sin 30^\circ$$

2. Substitute the exact values.

$$\dfrac{\sqrt{2}}{2} \cdot \dfrac{\sqrt{3}}{2} + \dfrac{\sqrt{2}}{2} \cdot \dfrac{1}{2}$$

3. Multiply and add.

$$\sin 75^\circ = \dfrac{\sqrt{6} + \sqrt{2}}{4}$$

### #2: Using the Double Formulas

If $\sin \theta = \dfrac{3}{5}$ and $\theta$ is acute, find $\sin 2\theta$ and $\cos 2\theta$.

**Solution:**
Example 1 gave $\cos \theta = \dfrac{4}{5}$ for this value of sine.

1. Use $\sin 2\theta = 2\sin \theta \cos \theta$.

$$\sin 2\theta = 2 \cdot \dfrac{3}{5} \cdot \dfrac{4}{5} = \dfrac{24}{25}$$

2. Use $\cos 2\theta = 1 - 2\sin^2 \theta$.

$$\cos 2\theta = 1 - 2 \cdot \dfrac{9}{25} = \dfrac{7}{25}$$

3. Check with the Pythagorean identity. We get $\left(\dfrac{24}{25}\right)^2 + \left(\dfrac{7}{25}\right)^2 = \dfrac{576 + 49}{625} = 1$, so the values fit.

## Speed Tricks & Shortcuts

When a question asks for $\cos 2\theta$ and gives only $\sin \theta$ or only $\cos \theta$, pick the form of $\cos 2\theta$ that uses the value you have.

## Traps to Watch For

### #1: Spreading Sine or Doubling It

> $\sin(A + B)$ is not $\sin A + \sin B$, and $\sin 2\theta$ is not $2\sin \theta$ in general.

Take $A = B = 30^\circ$. Then $\sin 60^\circ \approx 0.866$, but $\sin 30^\circ + \sin 30^\circ = 1$. The two sides can match at a few angles, such as $\theta = 0^\circ$ where both are $0$, so a match at one angle proves nothing.
