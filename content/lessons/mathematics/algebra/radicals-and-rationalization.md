---
_id: "lesson-algebra-radicals-and-rationalization"
title: "Radicals and Rationalization"
summary: "Simplify radicals, rationalize denominators, and solve radical equations while respecting domain restrictions."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 12
isActive: true
---
## Core Concept

### Radical Words and Real Roots

A **radical expression** contains a root symbol. In $\sqrt[n]{x}$, $x$ is the **radicand** (the number under the symbol) and $n$ is the **index** (which root to take). If no index is written, the index is $2$.

The **principal square root** of a number $x\ge0$ is the nonnegative number whose square is $x$. So $\sqrt{25}=5$, not $-5$.

An even root, such as a square root or fourth root, of a negative number is not a real number. So for even $n$, the radicand must be nonnegative. An odd root of a negative number is real: $\sqrt[3]{-8}=-2$ because $(-2)^3=-8$.

### Radicals and Rational Exponents

A radical can be written with a fractional exponent:

$$\sqrt[n]{x}=x^{1/n}, \qquad \sqrt[n]{x^m}=x^{m/n}=\left(\sqrt[n]{x}\right)^m$$

Use these for $x\ge0$. The denominator of the exponent is the index. The numerator is the power.

### Rules and Their Limits

For radicals with the same index, when both roots are real numbers:

$$\sqrt[n]{ab}=\sqrt[n]{a}\cdot\sqrt[n]{b}, \qquad \sqrt[n]{\dfrac ab}=\dfrac{\sqrt[n]{a}}{\sqrt[n]{b}}\ (b\ne0)$$

For an even index, this needs $a\ge0$ and $b\ge0$. For an odd index, $a$ and $b$ can be any real numbers.

There is no matching rule for sums. In general, $\sqrt{a+b}\ne\sqrt a+\sqrt b$.

Taking a root of a power needs care with signs:

$$\sqrt{x^2}=|x|,\qquad \sqrt[3]{x^3}=x$$

For an even index, $\sqrt[n]{x^n}=|x|$, not $x$. For an odd index, $\sqrt[n]{x^n}=x$. If a problem says a variable is nonnegative, then $|x|=x$.

### Simplifying and Combining

A radical is in **simplest form** when the radicand has no factor that is a perfect power of the index, and no fraction. Move perfect-square factors out of a square root. Unmatched factors stay inside.

**Like radicals** have the same index and the same radicand. You add or subtract them by adding or subtracting their coefficients, as in $3\sqrt5+2\sqrt5=5\sqrt5$. Simplify each radical first, because unlike-looking radicals can turn out to be like.

### Rationalizing a Denominator

**Rationalizing a denominator** means rewriting a fraction so its denominator has no radical. The new fraction has the same value. This is a conventional simplest form. The original fraction is not undefined.

You multiply the top and bottom by the same nonzero number. That is the same as multiplying by $1$.

- For a denominator $\sqrt y$ with $y>0$, multiply by $\dfrac{\sqrt y}{\sqrt y}$.
- For a denominator $a+\sqrt b$ or $a-\sqrt b$, multiply by its **conjugate**: the same two terms with the sign between them changed. The middle terms cancel, so $(a+\sqrt b)(a-\sqrt b)=a^2-b$ for $b\ge0$. The same works when both terms are square roots.
- For a cube-root denominator $\sqrt[3]{c^k}$ with $k=1$ or $k=2$, multiply by $\sqrt[3]{c^{3-k}}$. The radicand becomes $c^3$, and $\sqrt[3]{c^3}=c$.

Each of these needs the denominator to be nonzero.

### Radical Equations

A **radical equation** has the unknown inside a radical. To solve it:

1. Get one radical alone on one side.
2. Raise both sides to the power equal to the index.
3. If a radical is still left, get it alone and raise both sides to the power again.
4. Solve the new equation.
5. Substitute each answer into the original equation.

Two tools help in step 4. Squaring a binomial gives $(a-b)^2=a^2-2ab+b^2$. If a product is $0$, one of its factors is $0$, so $x(x-5)=0$ gives $x=0$ or $x=5$.

Step $5$ matters for square roots. Squaring turns $a=b$ into $a^2=b^2$, and that is also true when $a=-b$. So squaring can add a false answer, called an **extraneous root**. Cubing does not add false real answers, because $a^3=b^3$ gives $a=b$ for real numbers.

### Nested Radicals

A **nested radical** goes on without end, such as $\sqrt{20+\sqrt{20+\cdots}}$. If the expression settles on one value $L$, then the part under the first root is also $L$. That gives $L=\sqrt{20+L}$, which you solve as a radical equation. Because $L$ is a principal square root, $L\ge0$.

## Examples

### #1: Radicals and Rational Exponents

Evaluate $16^{3/4}$ (find its final value), and write $\sqrt[3]{x^2}$ as a power of $x$ for $x\ge0$.

**Solution:**

1. The exponent $\dfrac34$ has denominator $4$, so take the fourth root. The numerator $3$ is the power.

$$16^{3/4}=\left(\sqrt[4]{16}\right)^3=2^3=8$$

2. In $\sqrt[3]{x^2}$, the index is $3$ and the power is $2$.

$$\sqrt[3]{x^2}=x^{2/3}$$

### #2: Simplifying with Nonnegative Variables

Assume $x\ge0$ and $y\ge0$. Simplify $\sqrt{72x^3y^4}$.

**Solution:**

1. Factor the radicand into a perfect-square part and a leftover.

$$72x^3y^4=36x^2y^4\cdot2x$$

2. Take the square root of the perfect-square part. The assumptions give $x\ge0$ and $y^2\ge0$.

$$\sqrt{36x^2y^4}=6xy^2$$

3. Therefore:

$$\sqrt{72x^3y^4}=6xy^2\sqrt{2x}$$

### #3: Simplifying When a Sign Is Unknown

Assume $a\ge0$, and let $b$ be any nonzero real number. Simplify $\sqrt{50a^5b^6}$.

**Solution:**

1. Factor out perfect squares.

$$50a^5b^6=25a^4b^6\cdot2a$$

2. Take the root of each square factor. Here $\sqrt{b^6}=|b^3|$, because $b^3$ can be negative.

$$\sqrt{25a^4b^6}=5a^2|b|^3$$

3. Therefore:

$$\sqrt{50a^5b^6}=5a^2|b|^3\sqrt{2a}$$

### #4: Adding and Subtracting Radicals

Find $3\sqrt{20}-\sqrt{45}+2\sqrt5$.

**Solution:**

1. Simplify the first two radicals.

$$\sqrt{20}=\sqrt{4\cdot5}=2\sqrt5, \qquad \sqrt{45}=\sqrt{9\cdot5}=3\sqrt5$$

2. Now all three terms are like radicals. Combine the coefficients.

$$3(2\sqrt5)-3\sqrt5+2\sqrt5=(6-3+2)\sqrt5=5\sqrt5$$

### #5: Rationalizing a Simple Denominator

For $x>0$, rationalize $\dfrac{10}{\sqrt{5x}}$.

**Solution:**

1. Multiply the top and bottom by $\sqrt{5x}$.

$$\dfrac{10}{\sqrt{5x}}\cdot\dfrac{\sqrt{5x}}{\sqrt{5x}}=\dfrac{10\sqrt{5x}}{5x}$$

2. Divide the top and bottom by $5$.

$$\dfrac{10\sqrt{5x}}{5x}=\dfrac{2\sqrt{5x}}{x}$$

### #6: Rationalizing with a Binomial

Simplify $\dfrac4{3-\sqrt5}$ by rationalizing the denominator.

**Solution:**

1. The conjugate of $3-\sqrt5$ is $3+\sqrt5$. Multiply the top and bottom by it.

$$\dfrac4{3-\sqrt5}\cdot\dfrac{3+\sqrt5}{3+\sqrt5}$$

2. The new denominator is:

$$(3-\sqrt5)(3+\sqrt5)=9-5=4$$

3. So:

$$\dfrac{4(3+\sqrt5)}4=3+\sqrt5$$

### #7: Binomial with Two Square Roots

Rationalize $\dfrac6{\sqrt7+\sqrt3}$.

**Solution:**

1. Multiply the top and bottom by the conjugate $\sqrt7-\sqrt3$.

$$\dfrac6{\sqrt7+\sqrt3}\cdot\dfrac{\sqrt7-\sqrt3}{\sqrt7-\sqrt3}$$

2. The denominator is $7-3=4$.

$$\dfrac{6(\sqrt7-\sqrt3)}{4}$$

3. Divide the top and bottom by $2$.

$$\dfrac{3(\sqrt7-\sqrt3)}{2}$$

### #8: Rationalizing a Cube-Root Denominator

For $x\ne0$, rationalize $\dfrac2{\sqrt[3]{4x}}$.

**Solution:**

1. Write $4x=2^2x$. Each factor needs a power of $3$ to leave the cube root, so multiply by $\sqrt[3]{2x^2}$.

$$\dfrac2{\sqrt[3]{4x}}\cdot\dfrac{\sqrt[3]{2x^2}}{\sqrt[3]{2x^2}}=\dfrac{2\sqrt[3]{2x^2}}{\sqrt[3]{8x^3}}$$

2. Because $\sqrt[3]{8x^3}=2x$ for real $x$:

$$\dfrac{2\sqrt[3]{2x^2}}{2x}=\dfrac{\sqrt[3]{2x^2}}{x}$$

### #9: A Radical Equation with an Extraneous Root

Solve $\sqrt{x+4}+2=x$.

**Solution:**

1. Get the radical alone.

$$\sqrt{x+4}=x-2$$

2. Square both sides.

$$x+4=x^2-4x+4$$

3. Move everything to one side and factor.

$$x^2-5x=0 \quad\Rightarrow\quad x(x-5)=0$$

So $x=0$ or $x=5$.

4. Check in the original equation. For $x=5$: $\sqrt9+2=5$, which is true. For $x=0$: $\sqrt4+2=4$, but the right side is $0$. So $x=0$ is extraneous.

The solution is $x=5$.

### #10: A Radical Equation with Two Radicals

Solve $\sqrt{3m+4}-\sqrt{m+2}=2$.

**Solution:**

1. Get one radical alone, then square both sides.

$$\sqrt{3m+4}=2+\sqrt{m+2} \quad\Rightarrow\quad 3m+4=4+4\sqrt{m+2}+m+2$$

2. A radical is still left. Get it alone and square again.

$$2m-2=4\sqrt{m+2} \quad\Rightarrow\quad m-1=2\sqrt{m+2} \quad\Rightarrow\quad m^2-2m+1=4m+8$$

3. Move everything to one side and factor.

$$m^2-6m-7=0 \quad\Rightarrow\quad (m-7)(m+1)=0$$

4. Check. For $m=7$: $\sqrt{25}-\sqrt9=2$, which is true. For $m=-1$: $\sqrt1-\sqrt1=0$, not $2$. So $m=-1$ is extraneous.

The solution is $m=7$.

### #11: A Cube-Root Equation

Solve $\sqrt[3]{2x-1}=3$.

**Solution:**

1. Cube both sides.

$$2x-1=27$$

2. Solve.

$$2x=28 \quad\Rightarrow\quad x=14$$

3. Check: $\sqrt[3]{27}=3$, which is true.

### #12: A Nested Radical

Assume $L=\sqrt{20+\sqrt{20+\cdots}}$ settles on a real value. Find $L$.

**Solution:**

1. The part under the first root is also $L$.

$$L=\sqrt{20+L}$$

2. Square both sides and move everything to one side.

$$L^2-L-20=0 \quad\Rightarrow\quad (L-5)(L+4)=0$$

So $L=5$ or $L=-4$.

3. A principal square root is nonnegative, so $L=-4$ is extraneous. Check $L=5$: $\sqrt{20+5}=5$.

The value is $L=5$.

## Speed Tricks & Shortcuts

For $y>0$:

$$\dfrac{x}{\sqrt y}=\dfrac{x\sqrt y}{y}$$

For example, $\dfrac{10}{\sqrt2}=\dfrac{10\sqrt2}{2}=5\sqrt2$.

To spot perfect squares fast, know $4,9,16,25,36,49,64,81,100,121,144$. To simplify $\sqrt{n}$, divide out the largest of these that divides $n$. Then check the number left inside for another square factor, and repeat. For example, if you take out $4$ first, $\sqrt{288}=2\sqrt{72}=2\cdot6\sqrt2=12\sqrt2$. The largest square, $144$, gives $12\sqrt2$ in one step. If no listed square divides $n$, the number may have a larger square factor, as in $\sqrt{338}=13\sqrt2$ because $338=169\cdot2$.

For a nested radical, set up $L=\sqrt{k+L}$ only when the problem gives or assumes that the expression settles on a real value. Then discard any negative answer for $L$.

## Traps to Watch For

### #1: Splitting a Sum Under a Root

> $\sqrt{a+b}$ is usually not $\sqrt a+\sqrt b$.

For example, $\sqrt9+\sqrt{16}=3+4=7$, but $\sqrt{9+16}=\sqrt{25}=5$. The two sides are equal only in special cases, such as when $a=0$ or $b=0$.

### #2: Dropping the Absolute Value

> $\sqrt{x^2}$ is $|x|$, which equals $x$ only when $x\ge0$.

If $x=-3$, then $\sqrt{(-3)^2}=\sqrt9=3$, not $-3$. A problem that does not state the sign of $x$ expects $|x|$.

### #3: Using the Product Rule on Negatives

> $\sqrt a\cdot\sqrt b=\sqrt{ab}$ needs $a\ge0$ and $b\ge0$ for square roots.

The expression $\sqrt{-4}\cdot\sqrt{-9}$ has no real value, because $\sqrt{-4}$ is not real. But $\sqrt{(-4)(-9)}=\sqrt{36}=6$. The two sides do not match, so the rule cannot be used here.

### #4: Principal Root vs. Equation Solutions

> The symbol $\sqrt{25}$ means $5$ only, but $x^2=25$ has two solutions.

The symbol $\sqrt{25}$ is the principal square root, $5$. Solving $x^2=25$ gives both $x=5$ and $x=-5$, because both square to $25$.

### #5: Skipping the Check in a Radical Equation

> Squaring can create answers that do not satisfy the original equation.

In Example #9, the algebra gave $x=0$ and $x=5$, but only $x=5$ works. Always substitute back into the original equation when you square both sides.

### #6: Multiplying by the Wrong Thing

> Rationalize with a factor that clears the radical, and use it on the top too.

For a binomial denominator, multiplying by the same expression, $3-\sqrt5$, does not remove the radical. Use the conjugate. For $\dfrac1{\sqrt[3]x}$, multiplying by $\sqrt[3]x$ leaves $\sqrt[3]{x^2}$ in the denominator. Multiply by $\sqrt[3]{x^2}$ instead, so the denominator becomes $x$ for $x\ne0$.
