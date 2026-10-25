---
_id: "lesson-algebra-exponents-and-logarithms"
title: "Laws of Exponents and Logarithms"
summary: "Use exponent and logarithm laws, including zero, negative, and fractional powers, with the conditions that make the laws valid."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 12
isActive: true
---
## Core Concept

For a positive whole-number exponent, $a^n$ means repeated multiplication of the base $a$. For example, $2^3=2\times2\times2=8$.

A logarithm reverses an exponential relationship. For $b>0$, $b\ne1$, and $x>0$:

$$\log_b(x)=y\quad\text{if and only if}\quad b^y=x.$$

So $\log_2(8)=3$ because $2^3=8$.

**Simplify** means rewrite an expression in a shorter equivalent form. **Evaluate** means find the final number answer.

**Express** means write the answer in the form the question asks for.

### Laws of Exponents

For powers with the same base, these rules apply when the written powers and divisions are defined:

$$a^m a^n=a^{m+n}$$

$$\dfrac{a^m}{a^n}=a^{m-n}\qquad(a\ne0)$$

For integer exponents, the power-of-a-power rule is:

$$(a^m)^n=a^{mn}.$$

When fractional exponents appear, a safe common case is $a>0$. Do not apply the power-of-a-power shortcut blindly to a negative base with fractional exponents.

A negative exponent means take the reciprocal:

$$a^{-n}=\dfrac{1}{a^n}\qquad(a\ne0).$$

A zero exponent equals $1$ for a nonzero base:

$$a^0=1\qquad(a\ne0).$$

One reason is that dividing a nonzero power by itself gives $1$:

$$\dfrac{a^m}{a^m}=a^{m-m}=a^0=1.$$

For integer $m$, positive whole-number $n$, and $a>0$, a fractional exponent means a root:

$$a^{m/n}=\sqrt[n]{a^m}.$$

### Laws of Logarithms

For a valid base $b>0$, $b\ne1$, and positive $M$ and $N$:

$$\log_b(MN)=\log_b M+\log_b N$$

$$\log_b\left(\dfrac{M}{N}\right)=\log_b M-\log_b N$$

$$\log_b(M^p)=p\log_b M.$$

A logarithm written as $\log(x)$ with no base shown is the **common logarithm**, which has base $10$ in this lesson.

For a valid exponential base, equal powers have equal exponents. In other words, if $b^u=b^v$, then $u=v$.

## Mnemonics & Memory Aids

For exponent rules with the same base:

> Multiply powers: add exponents. Divide powers: subtract exponents. Power of a power: multiply exponents.

For logarithms:

> Products become sums, quotients become differences, and powers move in front.

These shortcuts apply only when the expressions are defined under the conditions above.

## Examples

### #1: Simplifying Terms with the Same Base

Simplify $\dfrac{(x^3y^2)(x^4y^{-1})}{x^2y^3}$ for nonzero $x$ and $y$.

**Solution:**

1. Combine powers in the numerator.

$$\dfrac{x^7y}{x^2y^3}$$

2. Subtract exponents when dividing like bases.

$$x^{7-2}y^{1-3}=x^5y^{-2}$$

3. Rewrite the negative exponent as a reciprocal.

$$\dfrac{x^5}{y^2}$$

### #2: Zero Exponent

Evaluate $7^0+3$.

**Solution:**

1. The base $7$ is nonzero, so $7^0=1$.
2. Add $3$.

$$1+3=4$$

### #3: Negative and Fractional Exponents

Evaluate $8^{-\dfrac{2}{3}}$.

**Solution:**

1. Use the negative exponent rule.

$$8^{-2/3}=\dfrac{1}{8^{2/3}}$$

2. Evaluate the cube root, then square.

$$8^{2/3}=(\sqrt[3]{8})^2=2^2=4$$

3. Substitute that value into the denominator.

$$8^{-2/3}=\dfrac{1}{4}$$

### #4: Finding a Basic Logarithm

Evaluate $\log_3(81)$.

**Solution:**

1. Rewrite the logarithm as an exponential equation.

$$3^x=81$$

2. Write $81$ as a power of $3$.

$$3^4=81$$

3. Therefore, the exponent is $4$.

$$\log_3(81)=4$$

### #5: Condensing Logarithmic Expressions

For $x>0$, $y>0$, and $z>0$, express $2\log(x)+\log(y)-3\log(z)$ as a single common logarithm.

**Solution:**

1. Use the power rule.

$$\log(x^2)+\log(y)-\log(z^3)$$

2. Use the product rule on the first two logarithms.

$$\log(x^2y)-\log(z^3)$$

3. Use the quotient rule.

$$\log\left(\dfrac{x^2y}{z^3}\right)$$

### #6: Equation with an Unknown Exponent

Solve $4^{2x-1}=8^{x+1}$.

**Solution:**

1. Rewrite both sides with base $2$.

$$(2^2)^{2x-1}=(2^3)^{x+1}$$

2. Use the power-of-a-power rule.

$$2^{4x-2}=2^{3x+3}$$

3. The bases are the same and valid, so set the exponents equal.

$$4x-2=3x+3$$

4. Solve for $x$.

$$x=5$$

### #7: Finding Logarithms in Terms of Given Variables

If $\log_{10}(2)=a$ and $\log_{10}(3)=b$, express $\log_{10}(12)$ in terms of $a$ and $b$.

**Solution:**

1. Write $12$ as $2^2\times3$.
2. Use the product and power rules.

$$\log_{10}(12)=\log_{10}(2^2)+\log_{10}(3)$$

3. Move the exponent in front.

$$\log_{10}(12)=2\log_{10}(2)+\log_{10}(3)$$

4. Substitute the given values.

$$\log_{10}(12)=2a+b$$

## Speed Tricks & Shortcuts

For a nonzero base, a negative exponent moves a factor across a fraction bar by taking its reciprocal:

$$x^{-n}=\dfrac{1}{x^n}.$$

Exponential and logarithmic functions with the same valid base undo one another on their domains:

$$b^{\log_b x}=x\qquad(x>0)$$

and

$$\log_b(b^x)=x.$$

When both sides of an exponential equation can be written with the same valid base, compare the exponents instead of expanding large powers.

## Traps to Watch For

### #1: Multiplying Like Bases

> For the same base, add exponents when multiplying.

The rule gives $x^2x^3=x^5$, not $x^6$.

### #2: Squaring a Sum

> An exponent does not distribute over addition.

The correct expansion is $(x+y)^2=x^2+2xy+y^2$. It is not $x^2+y^2$.

### #3: Logarithm of a Sum

> There is no general sum rule for logarithms.

In general, $\log_b(x+y)$ cannot be changed into $\log_b x+\log_b y$.

### #4: Missing Logarithm Conditions

> Real logarithms need a valid base and a positive argument.

The base must satisfy $b>0$ and $b\ne1$, and the argument must be positive. Follow any different notation that a problem defines explicitly.
