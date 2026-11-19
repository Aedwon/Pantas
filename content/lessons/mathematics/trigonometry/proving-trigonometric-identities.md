---
_id: "lesson-trigonometry-proving-trigonometric-identities"
title: "Proving Trigonometric Identities"
summary: "Use algebra to prove an identity and a counterexample to disprove one."
subject: "subject-mathematics"
topic: "topic-trigonometry"
isActive: true
part: 5
partCount: 6
ordering: 0
keyPoints:
  - "Use algebra to prove an identity and a counterexample to disprove one."
---
## Core Concept

Start with the more complicated side and work toward the other side.

## Examples

### #1: Proving an Identity

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

## Speed Tricks & Shortcuts

When an expression looks complicated, try this sequence: convert functions to sines and cosines, apply a known identity, then simplify while keeping the original domain restrictions.

To check a choice in a multiple-choice question, test an angle where every function in the question is defined. If the two sides give different numbers, the choice is wrong. If they match, the choice may still be wrong, because one matching angle does **not** prove an identity. Use algebra for the final check.
