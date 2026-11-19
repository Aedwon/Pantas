---
_id: "lesson-precalculus-basic-calculus-rational-limits-at-infinity"
title: "Rational Limits at Infinity"
summary: "Compare polynomial degrees to find a limit at infinity."
subject: "subject-mathematics"
topic: "topic-precalculus-basic-calculus"
isActive: true
part: 3
partCount: 4
ordering: 6
keyPoints:
  - "Use the degrees and leading terms to find a rational limit at infinity."
---
## Core Concept

### Rational-function limits at infinity

For a rational function, compare the degrees and leading terms:

- numerator degree smaller than denominator degree: the limit as $x\to\pm\infty$ is $0$;
- equal degrees: the limit is the ratio of leading coefficients;
- numerator degree larger: there is no horizontal asymptote. The end behavior follows the leading-term quotient and may tend to $+\infty$ or $-\infty$ (or approach a polynomial/oblique asymptote after division), depending on degrees and signs.

Check the largest exponent in the numerator and the largest exponent in the denominator before you decide which case applies.

## Examples

### #1: A Limit at Infinity

Evaluate $\lim_{x\to\infty}\dfrac{3x^2+5}{x^2-2}$.

**Solution:**
The numerator and denominator have the same degree, so use the leading coefficients.

$$\lim_{x\to\infty}\dfrac{3x^2+5}{x^2-2}=\dfrac31=3$$

## Speed Tricks & Shortcuts

For rational limits at infinity, the leading terms determine end behavior. Equal degrees give the ratio of leading coefficients; a larger denominator degree gives $0$; a larger numerator degree requires attention to the leading-term quotient or polynomial division.
