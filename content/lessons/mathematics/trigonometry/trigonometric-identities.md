---
_id: "lesson-trigonometry-trigonometric-identities"
title: "Trigonometric Identities (Reciprocal, Quotient, Pythagorean)"
summary: "The basic trigonometric identities, with sum, difference, and double-angle formulas, and how to use them to simplify expressions and find missing values."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 15
isActive: true
---
## Core Concept

An **identity** is an equation that is true for every angle where both sides are defined. Identities let you rewrite a trigonometric expression in a simpler form that has the same value.

Some angles make a function undefined. $\tan \theta$ and $\sec \theta$ are undefined when $\cos \theta = 0$, which happens at $90^\circ$, $270^\circ$, and every angle $180^\circ$ apart from them. $\cot \theta$ and $\csc \theta$ are undefined when $\sin \theta = 0$, which happens at $0^\circ$, $180^\circ$, and every angle $180^\circ$ apart from them. An identity is only claimed at angles where every function in it is defined.

The notation $\sin^2 \theta$ means $(\sin \theta)^2$. The sign of each function depends on the quadrant, the quarter of the plane where the angle ends. Quadrant I is $0^\circ$ to $90^\circ$, II is $90^\circ$ to $180^\circ$, III is $180^\circ$ to $270^\circ$, and IV is $270^\circ$ to $360^\circ$. Sine is positive in I and II. Cosine is positive in I and IV. Tangent is positive in I and III. The Unit Circle lesson explains this in full.

**Reciprocal identities**: a function and its reciprocal partner multiply to $1$.

$$\csc \theta = \dfrac{1}{\sin \theta} \qquad \sec \theta = \dfrac{1}{\cos \theta} \qquad \cot \theta = \dfrac{1}{\tan \theta}$$

The first holds where $\sin \theta \neq 0$ and the second where $\cos \theta \neq 0$. The third holds when $\theta$ is not a multiple of $90^\circ$. At $90^\circ$, $\cot \theta = 0$ but $\tan \theta$ is undefined, so $\cot \theta = \dfrac{1}{\tan \theta}$ fails there.

**Quotient identities**:

$$\tan \theta = \dfrac{\sin \theta}{\cos \theta} \qquad \cot \theta = \dfrac{\cos \theta}{\sin \theta}$$

The first holds where $\cos \theta \neq 0$. The second holds where $\sin \theta \neq 0$.

**Pythagorean identities**:

$$\sin^2 \theta + \cos^2 \theta = 1$$

This one holds for every angle. Dividing it by $\cos^2 \theta$, where $\cos \theta \neq 0$, gives $1 + \tan^2 \theta = \sec^2 \theta$. Dividing it by $\sin^2 \theta$, where $\sin \theta \neq 0$, gives $1 + \cot^2 \theta = \csc^2 \theta$.

$$1 + \tan^2 \theta = \sec^2 \theta \qquad 1 + \cot^2 \theta = \csc^2 \theta$$

Why does $\sin^2 \theta + \cos^2 \theta = 1$? On the unit circle, the point for angle $\theta$ is $(\cos \theta, \sin \theta)$, and it is $1$ unit from the center. The identity is the Pythagorean theorem applied to those coordinates.

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

A common plan for simplifying is to rewrite every function in sine and cosine, apply an identity, then cancel. Cancel only factors that are nonzero on the original expression's domain. When you see $1 - \sin^2 \theta$, replace it with $\cos^2 \theta$. In the same way, $1 - \cos^2 \theta = \sin^2 \theta$.

## Examples

### #1: Finding Cosine from Sine

If $\sin \theta = \dfrac{3}{5}$ and $\theta$ is acute, find $\cos \theta$ using an identity.

**Solution:**
Use $\sin^2 \theta + \cos^2 \theta = 1$.

1. Substitute the known sine.

$$\left(\dfrac{3}{5}\right)^2 + \cos^2 \theta = 1$$

2. Square the fraction.

$$\dfrac{9}{25} + \cos^2 \theta = 1$$

3. Subtract $\dfrac{9}{25}$ from both sides.

$$\cos^2 \theta = \dfrac{16}{25}$$

4. Thus $\cos \theta = \pm\dfrac{4}{5}$. Since $\theta$ is acute, cosine is positive.

$$\cos \theta = \dfrac{4}{5}$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 3", "Adjacent = 4", "Hypotenuse = 5", "sin²θ + cos²θ = 1"], "semanticsLabel": "Right triangle with opposite 3, adjacent 4, and hypotenuse 5 confirming the Pythagorean identity."} -->

### #2: All Six Values in Quadrant II

If $\sin \theta = \dfrac{5}{13}$ and $\theta$ is in Quadrant II, find the other five trigonometric values.

**Solution:**
Find cosine first. Then use the quotient and reciprocal identities.

1. Use the Pythagorean identity.

$$\cos^2 \theta = 1 - \left(\dfrac{5}{13}\right)^2 = \dfrac{144}{169}$$

2. Cosine is negative in Quadrant II.

$$\cos \theta = -\dfrac{12}{13}$$

3. Divide sine by cosine for the tangent.

$$\tan \theta = \dfrac{5/13}{-12/13} = -\dfrac{5}{12}$$

4. Flip each of the three values for its reciprocal partner.

$$\csc \theta = \dfrac{13}{5} \qquad \sec \theta = -\dfrac{13}{12} \qquad \cot \theta = -\dfrac{12}{5}$$

### #3: Simplifying with a Quotient Identity

Simplify: $\tan \theta \cdot \cos \theta$.

**Solution:**
The original expression contains $\tan \theta$, so it is defined only where $\cos \theta \neq 0$.

1. Substitute the quotient identity.

$$\dfrac{\sin \theta}{\cos \theta} \cdot \cos \theta$$

2. On the original domain, $\cos \theta \neq 0$, so the factor cancels.

$$\sin \theta$$

3. Therefore $\tan \theta\cos \theta = \sin \theta$ **where the original expression is defined**. The answer $\sin \theta$ alone is defined at $90^\circ$, but the original expression is not. Keep the original restriction in mind.

### #4: Simplifying with a Pythagorean Identity

Simplify: $\dfrac{1 - \cos^2 \theta}{\cos^2 \theta}$.

**Solution:**
The denominator requires $\cos \theta \neq 0$.

1. Replace $1 - \cos^2 \theta$ with $\sin^2 \theta$.

$$\dfrac{\sin^2 \theta}{\cos^2 \theta}$$

2. Sine over cosine is tangent, so:

$$\tan^2 \theta$$

3. This equality holds where $\cos \theta \neq 0$, which is exactly the domain of the original expression.

### #5: Factoring Before Substituting

Simplify: $\sec \theta - \sec \theta \sin^2 \theta$.

**Solution:**
Because the original expression contains secant, it requires $\cos \theta \neq 0$.

1. Factor out $\sec \theta$.

$$\sec \theta (1 - \sin^2 \theta)$$

2. Replace $1 - \sin^2 \theta$ with $\cos^2 \theta$.

$$\sec \theta \cdot \cos^2 \theta$$

3. Rewrite secant as $\dfrac{1}{\cos \theta}$.

$$\dfrac{\cos^2 \theta}{\cos \theta}$$

4. Since $\cos \theta \neq 0$ on the original domain, cancel one factor.

$$\cos \theta$$

5. Thus the expression equals $\cos \theta$ wherever the original secant expression is defined.

### #6: Using the Cotangent-Cosecant Identity

Simplify: $(1 + \cot^2 \theta)\sin^2 \theta$.

**Solution:**
Cotangent needs $\sin \theta \neq 0$. So the expression is defined only where $\sin \theta \neq 0$.

1. Replace $1 + \cot^2 \theta$ with $\csc^2 \theta$.

$$\csc^2 \theta \cdot \sin^2 \theta$$

2. Cosecant is the reciprocal of sine, so the two factors multiply to $1$.

$$\dfrac{1}{\sin^2 \theta} \cdot \sin^2 \theta = 1$$

3. The result is $1$ wherever $\sin \theta \neq 0$. At $\theta = 0^\circ$ the original expression is undefined, even though the number $1$ is not.

### #7: Using the Tangent-Secant Identity

If $\tan \theta = 2$ and $\theta$ is acute, find $\sec \theta$ and $\cos \theta$.

**Solution:**
The identity $1 + \tan^2 \theta = \sec^2 \theta$ connects them directly.

1. Substitute the tangent.

$$1 + 2^2 = \sec^2 \theta$$

2. Compute.

$$\sec^2 \theta = 5$$

3. Therefore $\sec \theta = \pm\sqrt{5}$. Since $\theta$ is acute, secant is positive.

$$\sec \theta = \sqrt{5}$$

4. Cosine is the reciprocal of secant. Rationalize the denominator if desired.

$$\cos \theta = \dfrac{1}{\sqrt{5}} = \dfrac{\sqrt{5}}{5}$$

<!-- FIGURE: {"kind": "geometry-diagram", "type": "right-triangle-trig", "labels": ["θ", "Opposite = 2", "Adjacent = 1", "Hypotenuse = √5", "1 + tan²θ = sec²θ"], "semanticsLabel": "Right triangle with opposite 2, adjacent 1, and hypotenuse square root of 5 verifying tangent and secant identity."} -->

### #8: Proving an Identity

Show that $\dfrac{\sin \theta}{1 + \cos \theta} + \dfrac{1 + \cos \theta}{\sin \theta} = 2\csc \theta$.

**Solution:**
To prove an identity, change one side until it matches the other. Do not move terms across the equals sign. Both sides need $\sin \theta \neq 0$. If $\cos \theta = -1$ then $\sin \theta = 0$, so the case $1 + \cos \theta = 0$ is already excluded.

1. Start with the left side. Write both fractions over the common bottom $\sin \theta (1 + \cos \theta)$.

$$\dfrac{\sin^2 \theta + (1 + \cos \theta)^2}{\sin \theta (1 + \cos \theta)}$$

2. Expand the square in the top.

$$\dfrac{\sin^2 \theta + 1 + 2\cos \theta + \cos^2 \theta}{\sin \theta (1 + \cos \theta)}$$

3. Replace $\sin^2 \theta + \cos^2 \theta$ with $1$, then combine.

$$\dfrac{2 + 2\cos \theta}{\sin \theta (1 + \cos \theta)} = \dfrac{2(1 + \cos \theta)}{\sin \theta (1 + \cos \theta)}$$

4. Cancel $1 + \cos \theta$, which is nonzero here. The left side becomes the right side.

$$\dfrac{2}{\sin \theta} = 2\csc \theta$$

### #9: Exact Value with a Sum Identity

Find the exact value of $\sin 75^\circ$.

**Solution:**
Write $75^\circ$ as $45^\circ + 30^\circ$. Both angles have known exact values.

1. Use the sum formula for sine.

$$\sin 75^\circ = \sin 45^\circ \cos 30^\circ + \cos 45^\circ \sin 30^\circ$$

2. Substitute the exact values.

$$\dfrac{\sqrt{2}}{2} \cdot \dfrac{\sqrt{3}}{2} + \dfrac{\sqrt{2}}{2} \cdot \dfrac{1}{2}$$

3. Multiply and add.

$$\sin 75^\circ = \dfrac{\sqrt{6} + \sqrt{2}}{4}$$

### #10: Using the Double Formulas

If $\sin \theta = \dfrac{3}{5}$ and $\theta$ is acute, find $\sin 2\theta$ and $\cos 2\theta$.

**Solution:**
Example 1 gave $\cos \theta = \dfrac{4}{5}$ for this value of sine.

1. Use $\sin 2\theta = 2\sin \theta \cos \theta$.

$$\sin 2\theta = 2 \cdot \dfrac{3}{5} \cdot \dfrac{4}{5} = \dfrac{24}{25}$$

2. Use $\cos 2\theta = 1 - 2\sin^2 \theta$.

$$\cos 2\theta = 1 - 2 \cdot \dfrac{9}{25} = \dfrac{7}{25}$$

3. Check with the Pythagorean identity. We get $\left(\dfrac{24}{25}\right)^2 + \left(\dfrac{7}{25}\right)^2 = \dfrac{576 + 49}{625} = 1$, so the values fit.

## Speed Tricks & Shortcuts

When an expression looks complicated, try this sequence: convert functions to sines and cosines, apply a known identity, then simplify while keeping the original domain restrictions.

Useful rearrangements of the Pythagorean identities include:

$$1 - \sin^2 \theta = \cos^2 \theta \qquad 1 - \cos^2 \theta = \sin^2 \theta$$

$$\sec^2 \theta - 1 = \tan^2 \theta \qquad \csc^2 \theta - 1 = \cot^2 \theta$$

The first two hold for every angle. The third needs $\cos \theta \neq 0$, and the fourth needs $\sin \theta \neq 0$.

To check a choice in a multiple-choice question, test an angle where every function in the question is defined. If the two sides give different numbers, the choice is wrong. If they match, the choice may still be wrong, because one matching angle does **not** prove an identity. Use algebra for the final check.

When a question asks for $\cos 2\theta$ and gives only $\sin \theta$ or only $\cos \theta$, pick the form of $\cos 2\theta$ that uses the value you have.

## Traps to Watch For

### #1: Different Angles, No Identity

> $\sin^2 A + \cos^2 B = 1$ is not generally true when $A$ and $B$ are different angles.

The Pythagorean identity uses the same angle in both terms. For example, $\sin^2 90^\circ + \cos^2 0^\circ = 2$. Check the angle labels before applying it.

### #2: Dropping the Sign at the Square Root

> From $u^2=k$, taking the square root gives both signs when $k>0$; the angle's quadrant or range determines which sign is valid.

For example, from $\cos^2 \theta = \dfrac{16}{25}$, cosine could be $+\dfrac{4}{5}$ or $-\dfrac{4}{5}$. If $\theta$ is in Quadrant II, cosine must be negative.

### #3: Misreading $\sin^2 \theta$

> $\sin^2 \theta$ means $(\sin \theta)^2$.

It does not mean $\sin(\theta^2)$ and is not the same as $\sin(2\theta)$. If $\sin \theta = \dfrac{3}{5}$, then $\sin^2 \theta = \dfrac{9}{25}$.

### #4: Cancelling Away a Domain Restriction

> Algebraic cancellation can make a formula look defined at more angles than the original expression.

For example, $\tan\theta\cos\theta$ simplifies to $\sin\theta$, but the starting expression is still undefined when $\cos\theta=0$. Keep the domain of the original problem when you report an equivalent simplification.

### #5: Spreading Sine or Doubling It

> $\sin(A + B)$ is not $\sin A + \sin B$, and $\sin 2\theta$ is not $2\sin \theta$ in general.

Take $A = B = 30^\circ$. Then $\sin 60^\circ \approx 0.866$, but $\sin 30^\circ + \sin 30^\circ = 1$. The two sides can match at a few angles, such as $\theta = 0^\circ$ where both are $0$, so a match at one angle proves nothing.
