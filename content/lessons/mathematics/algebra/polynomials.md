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

A **term** is a part of an expression separated by addition or subtraction. Keep its sign with it. In $4x^2-3x+7$, the terms are $4x^2$, $-3x$, and $7$.

A **coefficient** is the number multiplying the variable part. An **exponent** tells how many times a base is used as a factor. For example, $x^3=x\times x\times x$.

A **polynomial** in $x$ is an expression with a limited number of terms such as $4x^2$, $-3x$, and $7$. Each exponent of $x$ must be a whole number: $0$, $1$, $2$, and so on. Negative or fractional exponents of $x$ are not allowed.

A constant such as $7$ is a polynomial. For nonzero $x$, $x^0=1$, so a constant is often written as $7x^0$ when listing powers.

The **degree** of a nonzero polynomial is its highest exponent after like terms are combined. For example, $4x^3-2x+7$ has degree $3$. A nonzero constant has degree $0$; the zero polynomial has no degree under this convention.

### Operations on Polynomials

**Like terms** have the same variables with the same exponents. Add or subtract their coefficients. For example, $3x^2+5x^2=8x^2$.

**Simplify** means rewrite an expression in a form with the same value that is easier to read or use. When subtracting a polynomial, change the sign of every term being subtracted.

To multiply, use **distribution**: multiply each term in one polynomial by every term in the other. Then combine like terms.

$$a(b+c)=ab+ac$$

When multiplying powers with the same base, add the exponents:

$$x^m x^n=x^{m+n}$$

For polynomial terms, $m$ and $n$ are whole numbers. When dividing powers with the same nonzero base, subtract the exponents:

$$\dfrac{x^m}{x^n}=x^{m-n}$$

### Special Products and Factoring

**Factor** means write an expression as a product. The parts being multiplied are its **factors**. Factoring reverses distribution.

First look for a **greatest common factor**, the largest shared number factor and shared variable powers. For example, $6x^2+9x=3x(2x+3)$.

A **binomial** has two terms. These special products can be used to multiply or to factor:

$$(a-b)(a+b)=a^2-b^2$$

$$(a+b)^2=a^2+2ab+b^2$$

$$(a-b)^2=a^2-2ab+b^2$$

The first pattern is a difference of squares. The next two are perfect-square trinomials, expressions with three terms that are squares of binomials.

For a sum or difference of cubes, use:

$$a^3+b^3=(a+b)(a^2-ab+b^2)$$

$$a^3-b^3=(a-b)(a^2+ab+b^2)$$

These cube patterns apply when each of the two terms is a cube. Choose $a$ and $b$ so that their cubes match those terms.

A **quadratic** has degree $2$. A **monic quadratic** has coefficient $1$ on its $x^2$ term. For $x^2+bx+c$, find numbers $r$ and $s$ whose product is $c$ and whose sum is $b$:

$$x^2+bx+c=(x+r)(x+s)$$

For $ax^2+bx+c$ with $a\ne0$, find two numbers whose product is $ac$ and whose sum is $b$. Split the middle term using those numbers, then group terms to find shared factors.

The integer-pair methods work when the needed integers exist. Some quadratics cannot be factored into linear factors with integer coefficients. "Factor completely" means keep factoring until no factor can be split further using the allowed numbers.

### Polynomial Division

The **dividend** is what you divide. The **divisor** is what you divide by. The **quotient** is the answer before any leftover part, called the **remainder**.

The **leading term** is the nonzero term with the highest power after like terms are combined. For example, the leading term of $2x^3+3x^2-5x+6$ is $2x^3$.

Polynomial long division works with any nonzero polynomial divisor. Write terms from highest power to lowest, and put a $0$ coefficient in place of a missing power.

1. Divide the leading term of the current expression by the leading term of the divisor.
2. Write that result as the next quotient term.
3. Multiply the entire divisor by that quotient term.
4. Subtract the product and bring down the next dividend term.
5. Repeat until the remainder is $0$ or has lower degree than the divisor.

Each subtraction removes the highest-power term still being divided. The result follows this rule:

$$P(x)=D(x)Q(x)+R(x)$$

Here, $P$ is the dividend, $D$ is the divisor, $Q$ is the quotient, and $R$ is the remainder. If the dividend already has lower degree than the divisor, the quotient is $0$ and the dividend is the remainder.

**Synthetic division** is a shorter method for division by $x-c$. It tracks coefficients instead of writing each power of $x$. Write the dividend's coefficients from highest power to lowest, including zeros for missing powers.

Bring down the first coefficient. Multiply it by $c$, then add to the next coefficient. Repeat the multiply-and-add steps until you reach the last coefficient.

The last result is the remainder. The earlier results are the quotient's coefficients, from highest power to lowest.

When the dividend has degree at least $1$, the quotient's degree is one less than the dividend's degree. A cubic dividend gives a quadratic quotient. For a constant dividend, the quotient is $0$ and the remainder is that constant.

### Remainder and Factor Theorems

Write $P(c)$ to mean the value found by replacing $x$ with $c$ in $P(x)$. When dividing by $x-c$, the **Remainder Theorem** says the remainder is $P(c)$.

The **Factor Theorem** says $x-c$ is a factor of $P(x)$ exactly when $P(c)=0$. A remainder of $0$ means the division has no leftover part.

## Mnemonics & Memory Aids

> FOIL: First, Outer, Inner, Last.

FOIL names the four products when multiplying two binomials. For larger polynomials, multiply every term by every term using distribution.

> SOAP: Same, Opposite, Always Positive.

For the cube identities, the binomial uses the same sign as the original expression. The middle term in the second factor uses the opposite sign. Its last term is positive.

## Examples

### #1: Polynomial or Not

Which expressions are polynomials in $x$: $4x^3-2x+7$, $\dfrac{5}{x}+1$, $x^{1/2}+2$, and $3$?

**Solution:**

1. $4x^3-2x+7$ is a polynomial. Its powers of $x$ are whole numbers.
2. $\dfrac{5}{x}+1$ is not a polynomial. The term $\dfrac{5}{x}=5x^{-1}$ has a negative exponent.
3. $x^{1/2}+2$ is not a polynomial because its variable has a fractional exponent.
4. $3$ is a polynomial because constants are allowed. Its degree is $0$.

### #2: Simplifying Polynomial Operations

If $A=3x^2-2x+5$ and $B=-x^2+4x-1$, simplify $2A-B$.

**Solution:**

1. Multiply every term of $A$ by $2$.

$$2A=6x^2-4x+10$$

2. Subtract every term of $B$, changing each sign.

$$2A-B=6x^2-4x+10+x^2-4x+1$$

3. Combine like terms.

$$2A-B=7x^2-8x+11$$

### #3: General Polynomial Multiplication

Multiply $(2x-3)(x^2+x+4)$.

**Solution:**

1. Multiply $2x$ by every term in the second polynomial.

$$2x(x^2+x+4)=2x^3+2x^2+8x$$

2. Multiply $-3$ by every term in the second polynomial.

$$-3(x^2+x+4)=-3x^2-3x-12$$

3. Add the products and combine like terms.

$$2x^3-x^2+5x-12$$

### #4: Repeated Difference of Squares

Find $(x-3)(x+3)(x^2+9)$.

**Solution:**

1. Use the difference-of-squares pattern on the first two factors.

$$(x-3)(x+3)=x^2-9$$

2. Apply the pattern again, since $9^2=81$.

$$(x^2-9)(x^2+9)=x^4-81$$

### #5: Common Factor and a Perfect Square

Factor $3x^2+12x+12$ completely.

**Solution:**

1. Take out the greatest common factor, $3$.

$$3(x^2+4x+4)$$

2. The expression inside is a perfect square because $4x=2(x)(2)$ and $4=2^2$.

$$3(x+2)^2$$

### #6: Factoring a Monic Quadratic

Factor $x^2-5x+6$.

**Solution:**

1. Find two numbers with product $6$ and sum $-5$. They are $-2$ and $-3$.
2. Write the factors.

$$x^2-5x+6=(x-2)(x-3)$$

### #7: Factoring a Nonmonic Quadratic

Factor $6x^2-7x-3$ completely.

**Solution:**

1. Compute $ac$.

$$6(-3)=-18$$

2. Find two numbers with product $-18$ and sum $-7$. They are $-9$ and $2$.
3. Split the middle term.

$$6x^2-9x+2x-3$$

4. Take a shared factor from each pair.

$$3x(2x-3)+1(2x-3)$$

5. Take out the shared binomial.

$$(3x+1)(2x-3)$$

### #8: Sum of Cubes

Factor $8x^3+27$.

**Solution:**

1. Identify the two cubes.

$$8x^3=(2x)^3,\qquad 27=3^3$$

2. Use the sum-of-cubes pattern with $a=2x$ and $b=3$.

$$(2x+3)((2x)^2-(2x)(3)+3^2)$$

3. Work out each term in the second factor.

$$(2x+3)(4x^2-6x+9)$$

### #9: Difference of Cubes

Factor $x^3-64$.

**Solution:**

1. Write $64$ as a cube.

$$x^3-64=x^3-4^3$$

2. Use the difference-of-cubes pattern with $a=x$ and $b=4$.

$$(x-4)(x^2+4x+16)$$

### #10: Polynomial Long Division

Divide $2x^3+3x^2-5x+6$ by $x+2$.

**Solution:**

1. Divide the leading terms to get the first quotient term.

$$\dfrac{2x^3}{x}=2x^2$$

2. Multiply the divisor by $2x^2$, then subtract.

$$(2x^3+3x^2)-(2x^3+4x^2)=-x^2$$

3. Bring down $-5x$. Divide the new leading terms.

$$\dfrac{-x^2}{x}=-x$$

4. Multiply the divisor by $-x$, then subtract.

$$(-x^2-5x)-(-x^2-2x)=-3x$$

5. Bring down $+6$. Divide the new leading terms.

$$\dfrac{-3x}{x}=-3$$

6. Multiply the divisor by $-3$, then subtract.

$$(-3x+6)-(-3x-6)=12$$

7. The constant remainder has lower degree than $x+2$, so stop. Read the quotient and remainder.

$$Q(x)=2x^2-x-3$$

$$R(x)=12$$

8. Check by multiplying the quotient by the divisor and adding the remainder.

$$(x+2)(2x^2-x-3)+12$$

$$=2x^3+3x^2-5x+6$$

### #11: Synthetic Division

Use synthetic division to divide $x^3-4x^2+x+6$ by $x-3$.

**Solution:**

1. Use $c=3$. List the coefficients from highest power to lowest: $1,-4,1,6$.
2. Bring down $1$. Multiply by $3$ and add to the next coefficient.

$$-4+3(1)=-1$$

3. Multiply that result by $3$ and add to the next coefficient.

$$1+3(-1)=-2$$

4. Repeat for the last coefficient.

$$6+3(-2)=0$$

5. The results before the last number are $1,-1,-2$. The dividend has degree $3$, so these are the coefficients of $x^2$, $x$, and the constant.

$$Q(x)=x^2-x-2$$

6. The last number is the remainder.

$$R(x)=0$$

### #12: The Remainder Theorem

What is the remainder when $P(x)=x^4-3x^3+2x-5$ is divided by $x-2$?

**Solution:**

1. The divisor is $x-2$, so the remainder is $P(2)$.
2. Replace $x$ with $2$ and compute.

$$P(2)=16-24+4-5=-9$$

3. The remainder is $-9$.

### #13: The Factor Theorem with an Unknown

If $x-3$ is a factor of $x^3-kx^2+4x-12$, find $k$.

**Solution:**

1. Since $x-3$ is a factor, set $P(3)=0$.

$$27-9k+12-12=0$$

2. Combine the constants.

$$27-9k=0$$

3. Subtract $27$, then divide by $-9$.

$$-9k=-27$$

$$k=3$$

### #14: Finding Coefficients with Multiple Factors

If $P(x)=2x^3+ax^2+bx-6$ is divisible by $x^2-x-2$, find $a+b$.

**Solution:**

1. Factor the divisor.

$$x^2-x-2=(x-2)(x+1)$$

2. Each linear factor divides $P(x)$ with no remainder. Use $P(2)=0$.

$$16+4a+2b-6=0$$

3. Combine constants and divide by $2$.

$$2a+b=-5$$

4. Use $P(-1)=0$.

$$-2+a-b-6=0$$

$$a-b=8$$

5. Add the two equations to remove $b$.

$$3a=3$$

$$a=1$$

6. Put $a=1$ into $2a+b=-5$.

$$2+b=-5$$

$$b=-7$$

7. Find the requested sum.

$$a+b=1-7=-6$$

## Speed Tricks & Shortcuts

Try a simple value for $x$ to check a possible answer. If the original and the answer give different results, they are not the same expression. One matching result does not prove that they match for every value.

When the divisor is $x-c$ and you only need the remainder, use $P(c)$ instead of polynomial division.

Synthetic division can be faster for a divisor $x-c$. Include a $0$ for every missing power so each coefficient stays in its proper place.

## Traps to Watch For

### #1: Subtracting a Polynomial

> A subtraction sign changes every term in the polynomial after it.

For $A-B$, distribute the minus sign through all of $B$. Changing only the first sign gives the wrong polynomial.

### #2: Squaring a Binomial

> Squaring a binomial creates a middle term.

Use $(x+y)^2=x^2+2xy+y^2$. The answer $x^2+y^2$ leaves out the two products that combine to give $2xy$.

### #3: Synthetic-Division Sign

> For $x-c$, use $c$ in synthetic division.

The divisor $x-5$ uses $5$. The divisor $x+5=x-(-5)$ uses $-5$. Using the wrong sign means you divide by a different expression.
