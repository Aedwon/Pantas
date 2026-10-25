---
_id: "lesson-algebra-polynomials"
title: "Polynomials"
summary: "Recognize polynomial terms and practice polynomial operations, factoring, division, and theorem shortcuts."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 15
isActive: true
---
## Core Concept

A **polynomial** in $x$ is made by adding or subtracting terms. In each term, the exponent of $x$ must be a whole number such as $0$, $1$, $2$, or $3$. Negative exponents and fractional exponents do not make polynomial terms.

A **coefficient** is the number multiplying a variable. An **exponent** tells how many times the variable is used as a factor. A constant such as $7$ is also a polynomial term because it can be written as $7x^0$.

The **degree** of a nonzero polynomial is its highest exponent. For example, the degree of $4x^3-2x+7$ is $3$.

### Operations on Polynomials

**Like terms** have the same variables with the same exponents. Add or subtract only like terms.

To multiply polynomials, use distribution. Multiply each term in one polynomial by every needed term in the other polynomial, then combine like terms.

In exam questions, **simplify** means rewrite an expression in an equivalent form that is easier to read or use.

### Special Products and Factoring

**Factor** means write an expression as a product of factors. First check for a greatest common factor. Then look for a pattern that fits.

These special-product formulas are useful:

$$(a-b)(a+b)=a^2-b^2$$

$$(a+b)^2=a^2+2ab+b^2$$

$$(a-b)^2=a^2-2ab+b^2$$

For cubes:

$$a^3+b^3=(a+b)(a^2-ab+b^2)$$

$$a^3-b^3=(a-b)(a^2+ab+b^2)$$

A **monic quadratic** has coefficient $1$ on its $x^2$ term. For $x^2+bx+c$, find two numbers whose product is $c$ and whose sum is $b$.

If a quadratic is $ax^2+bx+c$ with $a\ne1$, you can split the middle term. Find two numbers whose product is $ac$ and whose sum is $b$, then factor by grouping.

### Polynomial Division

Polynomial long division works when the divisor is a nonzero polynomial. Put both polynomials in descending powers, using a $0$ coefficient for any missing power.

For long division:

1. Divide the first term of the current dividend by the first term of the divisor.
2. Put that result in the quotient.
3. Multiply the whole divisor by that quotient term.
4. Subtract, bring down the next term, and repeat.
5. Stop when the remainder has lower degree than the divisor.

The result has the form:

$$\text{dividend}=(\text{divisor})(\text{quotient})+\text{remainder}$$

**Synthetic division** is a shorter method for a divisor of the form $x-c$. Use only the coefficients. Bring down the first coefficient, multiply by $c$, add to the next coefficient, and repeat. The last number is the remainder.

### Remainder and Factor Theorems

When $P(x)$ is divided by $x-c$, the remainder is $P(c)$. This is the **Remainder Theorem**.

The **Factor Theorem** says $x-c$ is a factor of $P(x)$ exactly when $P(c)=0$.

## Mnemonics & Memory Aids

> FOIL: First, Outer, Inner, Last.

FOIL can help you remember distribution when multiplying two binomials. Distribution still works for any polynomial multiplication.

For sums or differences of cubes, **SOAP** helps with the signs: Same, Opposite, Always Positive. The first factor uses the same sign as the original cube expression, the middle term of the second factor uses the opposite sign, and the last term is positive.

## Examples

### #1: Polynomial or Not

Which expressions are polynomials in $x$: $4x^3-2x+7$, $\dfrac{5}{x}+1$, $x^{1/2}+2$, and $3$?

**Solution:**

1. $4x^3-2x+7$ is a polynomial because its exponents are nonnegative whole numbers.
2. $\dfrac{5}{x}+1$ is not a polynomial. A variable in the denominator would require a negative exponent.
3. $x^{1/2}+2$ is not a polynomial because $x$ has a fractional exponent.
4. $3$ is a polynomial because it can be written as $3x^0$.

### #2: Simplifying Polynomial Operations

If $A=3x^2-2x+5$ and $B=-x^2+4x-1$, simplify $2A-B$.

**Solution:**

1. Multiply every term of $A$ by $2$.

$$2A=6x^2-4x+10$$

2. Subtract every term of $B$.

$$2A-B=6x^2-4x+10+x^2-4x+1$$

3. Combine like terms.

$$2A-B=7x^2-8x+11$$

### #3: General Polynomial Multiplication

Multiply $(2x-3)(x^2+x+4)$.

**Solution:**

1. Distribute $2x$ to every term in the second polynomial.

$$2x(x^2+x+4)=2x^3+2x^2+8x$$

2. Distribute $-3$ to every term in the second polynomial.

$$-3(x^2+x+4)=-3x^2-3x-12$$

3. Combine like terms.

$$2x^3-x^2+5x-12$$

### #4: Using Special Products

Find $(x-3)(x+3)(x^2+9)$.

**Solution:**

1. Use the difference-of-squares formula on the first two factors.

$$(x-3)(x+3)=x^2-9$$

2. Use the same pattern again.

$$(x^2-9)(x^2+9)=x^4-81$$

### #5: Factoring a Monic Quadratic

Factor $x^2-5x+6$.

**Solution:**

1. Find two numbers whose product is $6$ and whose sum is $-5$. They are $-2$ and $-3$.
2. Write the factors.

$$x^2-5x+6=(x-2)(x-3)$$

### #6: Factoring a Nonmonic Quadratic

Factor $6x^2-7x-3$ completely.

**Solution:**

1. Compute $ac$.

$$6(-3)=-18$$

2. Find two numbers with product $-18$ and sum $-7$. They are $-9$ and $2$.
3. Split the middle term.

$$6x^2-9x+2x-3$$

4. Factor by grouping.

$$3x(2x-3)+1(2x-3)$$

$$(3x+1)(2x-3)$$

### #7: Polynomial Long Division

Divide $2x^3+3x^2-5x+6$ by $x+2$.

**Solution:**

1. Divide the first terms.

$$\dfrac{2x^3}{x}=2x^2$$

2. Multiply $x+2$ by $2x^2$, then subtract.

$$(2x^3+3x^2)-(2x^3+4x^2)=-x^2$$

Bring down $-5x$.

3. Divide the new first terms.

$$\dfrac{-x^2}{x}=-x$$

Multiply by $x+2$, then subtract.

$$(-x^2-5x)-(-x^2-2x)=-3x$$

Bring down $+6$.

4. Divide the new first terms.

$$\dfrac{-3x}{x}=-3$$

Multiply by $x+2$, then subtract.

$$(-3x+6)-(-3x-6)=12$$

5. The quotient is $2x^2-x-3$ and the remainder is $12$.

$$2x^3+3x^2-5x+6=(x+2)(2x^2-x-3)+12$$

### #8: Synthetic Division

Use synthetic division to divide $x^3-4x^2+x+6$ by $x-3$.

**Solution:**

1. The divisor is $x-3$, so use $c=3$. Start with coefficients $1,-4,1,6$.
2. Bring down $1$. Multiply by $3$, then add to $-4$.

$$-4+3=-1$$

3. Multiply $-1$ by $3$, then add to $1$.

$$1-3=-2$$

4. Multiply $-2$ by $3$, then add to $6$.

$$6-6=0$$

5. The quotient is $x^2-x-2$. The remainder is $0$.

### #9: The Remainder Theorem

What is the remainder when $P(x)=x^4-3x^3+2x-5$ is divided by $x-2$?

**Solution:**

1. The divisor is $x-2$, so use $c=2$.
2. By the Remainder Theorem, the remainder is $P(2)$.

$$P(2)=16-24+4-5=-9$$

3. The remainder is $-9$.

### #10: The Factor Theorem with an Unknown

If $x-3$ is a factor of $x^3-kx^2+4x-12$, find $k$.

**Solution:**

1. Since $x-3$ is a factor, set $P(3)=0$.

$$27-9k+12-12=0$$

2. Combine the constant terms.

$$27-9k=0$$

3. Solve for $k$.

$$k=3$$

### #11: Finding Coefficients with Multiple Factors

If $P(x)=2x^3+ax^2+bx-6$ is divisible by $x^2-x-2$, find $a+b$.

**Solution:**

1. Factor the divisor.

$$x^2-x-2=(x-2)(x+1)$$

2. Since both linear expressions are factors, use $P(2)=0$ and $P(-1)=0$.

From $P(2)=0$:

$$16+4a+2b-6=0$$

$$2a+b=-5$$

From $P(-1)=0$:

$$-2+a-b-6=0$$

$$a-b=8$$

3. Add the two equations.

$$3a=3$$

$$a=1$$

4. Substitute $a=1$ into $2a+b=-5$.

$$b=-7$$

5. Find the requested sum.

$$a+b=-6$$

## Speed Tricks & Shortcuts

Try a simple value for $x$ when you want to show that a proposed simplification is wrong. One value that gives different results proves the two expressions are not identical. One matching value does not prove they are identical for every $x$.

When the divisor is $x-c$ and you only need the remainder, use $P(c)$ instead of doing polynomial division.

For a divisor $x-c$, synthetic division can be faster than long division. Use $c$, including its sign.

## Traps to Watch For

### #1: Subtracting a Polynomial

> A subtraction sign changes every term in the polynomial after it.

For $A-B$, distribute the minus sign through all of $B$. Missing one sign change gives a different polynomial.

### #2: Squaring a Binomial

> Squaring a binomial creates a middle term.

Use $(x+y)^2=x^2+2xy+y^2$, not $x^2+y^2$. Forgetting $2xy$ is a common algebra mistake.

### #3: Synthetic-Division Sign

> For $x-c$, use $c$ in synthetic division.

The divisor $x-5$ uses $5$. The divisor $x+5=x-(-5)$ uses $-5$.
