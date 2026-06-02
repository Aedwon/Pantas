---
_id: "lesson-trigonometry-inverse-trigonometric-functions"
title: "Inverse Trigonometric Functions"
summary: "How inverse trigonometric functions turn ratios back into angles and which principal values they must return."
subject: "subject-mathematics"
topic: "topic-trigonometry"
estimatedMinutes: 11
isActive: true
---
## Core Concept

Ordinary trigonometric functions take an angle and give a ratio: $\sin 30^\circ = \dfrac{1}{2}$.

Inverse trigonometric functions run backwards. They take a ratio and give back the angle: $\arcsin\left(\dfrac{1}{2}\right) = 30^\circ$. You will see two notations that mean the same thing: $\arcsin x$ and $\sin^{-1} x$.

But there is a catch. Infinitely many angles have a sine of $\dfrac{1}{2}$ ($30^\circ$, $150^\circ$, $390^\circ$, ...). A function may return only one answer. So each inverse function is assigned a fixed window of allowed outputs, called the **principal values**:

- $\arcsin x$ returns angles from $-90^\circ$ to $90^\circ$ (Quadrants IV and I).
- $\arccos x$ returns angles from $0^\circ$ to $180^\circ$ (Quadrants I and II).
- $\arctan x$ returns angles strictly between $-90^\circ$ and $90^\circ$.

The sign of the input tells you which half of the window to use. Positive input: everyone answers in Quadrant I. Negative input: $\arcsin$ and $\arctan$ answer with a negative angle, while $\arccos$ answers in Quadrant II.

Inputs are limited too: $\arcsin x$ and $\arccos x$ only accept $x$ from $-1$ to $1$, because sines and cosines never leave that range. $\arctan x$ accepts every real number.

CETs test three skills: evaluating simple inverses, respecting the principal range with negative inputs, and unwrapping compositions like $\sin\left(\arccos \dfrac{3}{5}\right)$ with a drawn triangle.

## Examples

### #1: Basic Evaluation

Evaluate $\arcsin\left(\dfrac{1}{2}\right)$ and $\arctan(1)$.

**Solution:**
Ask the reverse question for each.

1. Which angle in $[-90^\circ, 90^\circ]$ has sine $\dfrac{1}{2}$?

$$\arcsin\left(\dfrac{1}{2}\right) = 30^\circ$$

2. Which angle in $(-90^\circ, 90^\circ)$ has tangent $1$?

$$\arctan(1) = 45^\circ$$

3. Positive inputs always land in Quadrant I. Easy points.

### #2: Negative Input to Arccosine

Evaluate $\arccos\left(-\dfrac{1}{2}\right)$.

**Solution:**
Arccosine answers only between $0^\circ$ and $180^\circ$. A negative cosine forces Quadrant II.

1. The reference angle comes from $\cos 60^\circ = \dfrac{1}{2}$.
2. Move it to Quadrant II.

$$180 - 60 = 120$$

3. So:

$$\arccos\left(-\dfrac{1}{2}\right) = 120^\circ$$

4. Note: Not $-60^\circ$. Arccosine never returns negative angles.

### #3: Negative Input to Arctangent

Evaluate $\arctan(-\sqrt{3})$.

**Solution:**
Arctangent answers between $-90^\circ$ and $90^\circ$. A negative tangent forces a negative angle.

1. The reference angle comes from $\tan 60^\circ = \sqrt{3}$.
2. Apply the negative sign directly.

$$\arctan(-\sqrt{3}) = -60^\circ$$

3. Note: Not $120^\circ$, even though $\tan 120^\circ$ is also $-\sqrt{3}$. That angle lies outside arctangent's window.

### #4: Composition with a Triangle

Evaluate $\sin\left(\arccos \dfrac{3}{5}\right)$.

**Solution:**
Name the inside first: let $\theta = \arccos \dfrac{3}{5}$, an acute angle whose cosine is $\dfrac{3}{5}$. Now find its sine by building the triangle.

<!-- ILLUSTRATION: right triangle with acute angle theta, adjacent 3, hypotenuse 5, opposite side labeled 4 -->

1. Cosine is adjacent over hypotenuse: adjacent $3$, hypotenuse $5$.
2. Find the opposite side with the Pythagorean theorem.

$$\text{opposite} = \sqrt{5^2 - 3^2} = \sqrt{16} = 4$$

3. Read the sine.

$$\sin \theta = \dfrac{4}{5}$$

4. So $\sin\left(\arccos \dfrac{3}{5}\right) = \dfrac{4}{5}$. The $3$-$4$-$5$ triple strikes again.

### #5: Composition at Exam Level

Evaluate $\tan\left(\arcsin \dfrac{5}{13}\right)$.

**Solution:**
Same triangle method.

1. Let $\theta = \arcsin \dfrac{5}{13}$: an acute angle with opposite $5$ and hypotenuse $13$.
2. Find the adjacent side.

$$\text{adjacent} = \sqrt{13^2 - 5^2} = \sqrt{169 - 25} = \sqrt{144} = 12$$

3. Read the tangent.

$$\tan \theta = \dfrac{5}{12}$$

4. So $\tan\left(\arcsin \dfrac{5}{13}\right) = \dfrac{5}{12}$.

## Speed Tricks & Shortcuts

For any composition like $\sin(\arccos x)$ or $\tan(\arcsin x)$, skip the angle entirely: draw the right triangle the inside function describes, complete the third side with Pythagoras, and read off the outside ratio. Two lines of work, no angle ever computed.

Same-function compositions cancel: $\sin(\arcsin x) = x$ for any allowed $x$. But be careful with the reversed order: $\arcsin(\sin \theta)$ equals $\theta$ only when $\theta$ is already inside the principal window.

Remember the negative-input routing table in three words: arcsin negative, arctan negative, arccos obtuse. That single line answers every sign question in this topic.

## Traps to Watch For

### #1: Answering Outside the Window

> Each inverse function has one allowed output range. Respect it.

For $\arcsin\left(-\dfrac{1}{2}\right)$, the angles $210^\circ$ and $330^\circ$ also have sine $-\dfrac{1}{2}$, and both appear in the choices. The only legal answer is $-30^\circ$, because arcsine lives in $[-90^\circ, 90^\circ]$.

### #2: Confusing $\sin^{-1} x$ with $\dfrac{1}{\sin x}$

> $\sin^{-1} x$ is the inverse function, not the reciprocal.

The reciprocal of sine already has its own name: cosecant. The raised $-1$ on the function symbol means "undo", exactly like $f^{-1}$. Reading it as an exponent turns every problem in this lesson into nonsense.

### #3: Impossible Inputs

> $\arcsin(2)$ and $\arccos(-1.5)$ are undefined.

No angle has a sine of $2$: sines and cosines are trapped between $-1$ and $1$. If an expression feeds an inverse sine or cosine anything outside that range, the correct choice is "undefined", not some computed angle. Arctangent, though, happily accepts any number.
