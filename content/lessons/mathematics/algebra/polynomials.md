---
_id: "lesson-algebra-polynomials"
title: "Polynomials"
summary: "Add, multiply, divide, factor, and evaluate polynomials using standard algebraic rules."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 12
isActive: true
---
## Core Concept

A polynomial in $x$ is a finite sum of terms of the form $a_kx^k$, where each coefficient $a_k$ is a number and each exponent $k$ is a nonnegative integer. Negative or fractional powers of the variable are not polynomial terms.

### Operations on Polynomials

When adding or subtracting polynomials, combine like terms: terms with the same variables raised to the same powers. When multiplying, use the distributive property so every relevant term is multiplied.

### Special Products and Factoring

Useful identities include the difference of squares and perfect-square trinomials. When factoring, first check for a greatest common factor, then look for special patterns or other suitable factoring methods.

For a monic quadratic $x^2+bx+c$, two numbers that multiply to $c$ and add to $b$ give a direct factorization. If the leading coefficient is not $1$, a method such as splitting the middle term can be used.

### Polynomial Division

Polynomial long division works for division by a nonzero polynomial. Standard synthetic division is a shortcut for a linear divisor of the form $x-c$.

### Remainder and Factor Theorems

When a polynomial $P(x)$ is divided by $x-c$, the remainder is $P(c)$. Therefore, $x-c$ is a factor of $P(x)$ exactly when $P(c)=0$.

## Mnemonics & Memory Aids

> FOIL: First, Outer, Inner, Last.

FOIL is one way to remember distribution when multiplying two binomials.

For sums or differences of cubes, the common **SOAP** mnemonic can help with signs: Same, Opposite, Always Positive.

## Examples

### #1: Simplifying Polynomial Operations

If $A=3x^2-2x+5$ and $B=-x^2+4x-1$, simplify $2A-B$.

**Solution:**

$$2A=6x^2-4x+10$$

Then subtract all terms of $B$:

$$2A-B=6x^2-4x+10+x^2-4x+1$$

$$=7x^2-8x+11$$

### #2: Using Special Products

Find $(x-3)(x+3)(x^2+9)$.

**Solution:**

$$(x-3)(x+3)=x^2-9$$

Then:

$$(x^2-9)(x^2+9)=x^4-81$$

### #3: Factoring a Quadratic Expression

Factor $6x^2-7x-3$ completely.

**Solution:**

1. Compute $ac=6(-3)=-18$.
2. Find numbers with product $-18$ and sum $-7$: $-9$ and $2$.
3. Split the middle term and factor by grouping.

$$6x^2-9x+2x-3$$

$$3x(2x-3)+1(2x-3)$$

$$(3x+1)(2x-3)$$

### #4: The Remainder Theorem

What is the remainder when $P(x)=x^4-3x^3+2x-5$ is divided by $x-2$?

**Solution:**

By the Remainder Theorem, the remainder is $P(2)$.

$$P(2)=16-24+4-5=-9$$

The remainder is $-9$.

### #5: The Factor Theorem with an Unknown

If $x-3$ is a factor of $x^3-kx^2+4x-12$, find $k$.

**Solution:**

Set the polynomial equal to $0$ at $x=3$.

$$27-9k+12-12=0$$

$$27-9k=0$$

$$k=3$$

### #6: Finding Coefficients with Multiple Factors

If $P(x)=2x^3+ax^2+bx-6$ is divisible by $x^2-x-2$, find $a+b$.

**Solution:**

1. Factor the divisor.

$$x^2-x-2=(x-2)(x+1)$$

2. Therefore $P(2)=0$ and $P(-1)=0$.

From $P(2)=0$:

$$16+4a+2b-6=0$$

$$2a+b=-5$$

From $P(-1)=0$:

$$-2+a-b-6=0$$

$$a-b=8$$

3. Add the two equations.

$$3a=3$$

$$a=1$$

4. Then $b=-7$, so:

$$a+b=-6$$

## Speed Tricks & Shortcuts

A numerical substitution can help **disprove** an incorrect proposed simplification quickly. However, one matching test value alone does not prove two polynomial expressions are identical for all $x$.

When the divisor is $x-c$ and only the remainder is needed, evaluate $P(c)$ instead of carrying out long division.

## Traps to Watch For

### #1: Subtracting a Polynomial

Distribute the subtraction to every term of the polynomial being subtracted.

### #2: Squaring a Binomial

$$(x+y)^2=x^2+2xy+y^2,$$

not $x^2+y^2$.

### #3: Synthetic-Division Sign

For a divisor $x-c$, use $c$ in standard synthetic division. Thus $x-5$ uses $5$, while $x+5=x-(-5)$ uses $-5$.
