---
_id: "lesson-trigonometry-reciprocal-and-quotient-identities"
title: "Reciprocal and Quotient Identities"
summary: "Recognize reciprocal and quotient identities."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 1
partCount: 6
ordering: 19
keyPoints:
  - "Recognize reciprocal and quotient identities."
  - "Keep the original domain when canceling factors."
---
## Core Concept

An **identity** is an equation that is true for every angle where both sides are defined. Identities let you rewrite a trigonometric expression in a simpler form that has the same value.

Some angles make a function undefined. $\tan \theta$ and $\sec \theta$ are undefined when $\cos \theta = 0$, which happens at $90^\circ$, $270^\circ$, and every angle $180^\circ$ apart from them. $\cot \theta$ and $\csc \theta$ are undefined when $\sin \theta = 0$, which happens at $0^\circ$, $180^\circ$, and every angle $180^\circ$ apart from them. An identity is only claimed at angles where every function in it is defined.

**Reciprocal identities**: a function and its reciprocal partner multiply to $1$.

$$\csc \theta = \dfrac{1}{\sin \theta} \qquad \sec \theta = \dfrac{1}{\cos \theta} \qquad \cot \theta = \dfrac{1}{\tan \theta}$$

The first holds where $\sin \theta \neq 0$ and the second where $\cos \theta \neq 0$. The third holds when $\theta$ is not a multiple of $90^\circ$. At $90^\circ$, $\cot \theta = 0$ but $\tan \theta$ is undefined, so $\cot \theta = \dfrac{1}{\tan \theta}$ fails there.

**Quotient identities**:

$$\tan \theta = \dfrac{\sin \theta}{\cos \theta} \qquad \cot \theta = \dfrac{\cos \theta}{\sin \theta}$$

The first holds where $\cos \theta \neq 0$. The second holds where $\sin \theta \neq 0$.

## Examples

### #1: Simplifying with a Quotient Identity

Simplify: $\tan \theta \cdot \cos \theta$.

**Solution:**
The original expression contains $\tan \theta$, so it is defined only where $\cos \theta \neq 0$.

1. Substitute the quotient identity.

$$\dfrac{\sin \theta}{\cos \theta} \cdot \cos \theta$$

2. On the original domain, $\cos \theta \neq 0$, so the factor cancels.

$$\sin \theta$$

3. Therefore $\tan \theta\cos \theta = \sin \theta$ **where the original expression is defined**. The answer $\sin \theta$ alone is defined at $90^\circ$, but the original expression is not. Keep the original restriction in mind.

## Traps to Watch For

### #1: Cancelling Away a Domain Restriction

> Algebraic cancellation can make a formula look defined at more angles than the original expression.

For example, $\tan\theta\cos\theta$ simplifies to $\sin\theta$, but the starting expression is still undefined when $\cos\theta=0$. Keep the domain of the original problem when you report an equivalent simplification.
