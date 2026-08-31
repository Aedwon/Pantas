---
_id: "lesson-algebra-exponents-and-logarithms"
title: "Laws of Exponents and Logarithms"
summary: "Use exponent and logarithm laws with the conditions that make those laws valid."
subject: "subject-mathematics"
topic: "topic-algebra"
estimatedMinutes: 10
isActive: true
---
## Core Concept

For a positive integer exponent, $a^n$ means repeated multiplication of the base $a$. For example, $2^3=2\times2\times2=8$.

A logarithm reverses an exponential relationship. For $b>0$, $b\ne1$, and $x>0$:

$$\log_b(x)=y \quad\text{if and only if}\quad b^y=x.$$

So $\log_2(8)=3$ because $2^3=8$.

### Laws of Exponents

For expressions where the indicated powers and divisions are defined:

$$a^m a^n=a^{m+n}$$

$$\dfrac{a^m}{a^n}=a^{m-n}\qquad(a\ne0)$$

$$(a^m)^n=a^{mn}$$

$$a^{-n}=\dfrac{1}{a^n}\qquad(a\ne0)$$

For real-valued fractional exponents, domain restrictions depend on the root involved. In the common case $a>0$:

$$a^{m/n}=\sqrt[n]{a^m}.$$

### Laws of Logarithms

For a valid logarithm base $b>0$, $b\ne1$, and positive $M,N$:

$$\log_b(MN)=\log_b M+\log_b N$$

$$\log_b\left(\dfrac{M}{N}\right)=\log_b M-\log_b N$$

$$\log_b(M^p)=p\log_b M$$

## Mnemonics & Memory Aids

For exponent rules with the same base:

> Multiply powers: add exponents. Divide powers: subtract exponents. Power of a power: multiply exponents.

For logarithms:

> Products become sums, quotients become differences, and powers move in front.

These shortcuts apply only when the logarithms themselves are defined.

## Examples

### #1: Simplifying Terms with the Same Base

Simplify $\dfrac{(x^3y^2)(x^4y^{-1})}{x^2y^3}$ for nonzero $x$ and $y$.

**Solution:**

1. Combine powers in the numerator.

$$\dfrac{x^7y}{x^2y^3}$$

2. Subtract exponents when dividing.

$$x^{7-2}y^{1-3}=x^5y^{-2}$$

3. Rewrite the negative exponent.

$$\dfrac{x^5}{y^2}$$

### #2: Negative and Fractional Exponents

Evaluate $8^{-\dfrac{2}{3}}$.

**Solution:**

1. Use the negative exponent.

$$8^{-2/3}=\dfrac{1}{8^{2/3}}$$

2. Evaluate the cube root and then square.

$$8^{2/3}=(\sqrt[3]{8})^2=2^2=4$$

3. Therefore:

$$8^{-2/3}=\dfrac{1}{4}$$

### #3: Finding a Basic Logarithm

Evaluate $\log_3(81)$.

**Solution:**

Write the equivalent exponential equation:

$$3^x=81$$

Since $3^4=81$:

$$\log_3(81)=4$$

### #4: Condensing Logarithmic Expressions

For $x>0$, $y>0$, and $z>0$, express $2\log(x)+\log(y)-3\log(z)$ as a single common logarithm.

**Solution:**

1. Use the power rule.

$$\log(x^2)+\log(y)-\log(z^3)$$

2. Use the product and quotient rules.

$$\log\left(\dfrac{x^2y}{z^3}\right)$$

### #5: Equation with an Unknown Exponent

Solve $4^{2x-1}=8^{x+1}$.

**Solution:**

1. Rewrite both sides with base $2$.

$$(2^2)^{2x-1}=(2^3)^{x+1}$$

2. Simplify the powers.

$$2^{4x-2}=2^{3x+3}$$

3. Because the exponential function with base $2$ is one-to-one, equate exponents.

$$4x-2=3x+3$$

$$x=5$$

### #6: Finding Logarithms in Terms of Given Variables

If $\log_{10}(2)=a$ and $\log_{10}(3)=b$, express $\log_{10}(12)$ in terms of $a$ and $b$.

**Solution:**

1. Write $12=2^2\times3$.
2. Apply the logarithm laws.

$$\log_{10}(12)=\log_{10}(2^2)+\log_{10}(3)$$

$$=2\log_{10}(2)+\log_{10}(3)$$

$$=2a+b$$

## Speed Tricks & Shortcuts

For nonzero bases, a negative exponent moves a factor across a fraction bar by taking its reciprocal:

$$x^{-n}=\dfrac{1}{x^n}.$$

Exponential and logarithmic functions with the same valid base undo one another on their domains:

$$b^{\log_b x}=x\qquad(x>0)$$

and

$$\log_b(b^x)=x.$$

## Traps to Watch For

### #1: Multiplying Like Bases

> For the same base, add exponents when multiplying.

$$x^2x^3=x^5,$$

not $x^6$.

### #2: Squaring a Sum

> An exponent does not distribute over addition.

$$(x+y)^2=x^2+2xy+y^2,$$

not $x^2+y^2$.

### #3: Logarithm of a Sum

There is no general rule that turns $\log_b(x+y)$ into $\log_b x+\log_b y$.

### #4: Missing Logarithm Conditions

For real logarithms, the base must satisfy $b>0$ and $b\ne1$, and the argument must be positive.

In this lesson, $\log(x)$ without a written base means the **common logarithm**, base $10$. Other fields sometimes use different conventions, so follow any notation explicitly defined in the problem or source.
