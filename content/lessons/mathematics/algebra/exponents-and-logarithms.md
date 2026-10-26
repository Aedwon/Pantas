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

A **logarithm** asks which exponent gives a number. For $b>0$, $b\ne1$, and $x>0$:

$$\log_b(x)=y\quad\Longleftrightarrow\quad b^y=x$$

The **argument** is the expression inside the logarithm. In $\log_2(8)$, the base is $2$ and the argument is $8$. Its value is $3$ because $2^3=8$.

**Simplify** means rewrite an expression in a shorter equivalent form. **Evaluate** means find the final number answer.

**Express** means write the answer in the form the question asks for. **Solve** means find all values that make an equation true.

### Laws of Exponents

For positive bases and real exponents, multiply powers with the same base by adding exponents. Divide them by subtracting exponents:

$$a^m a^n=a^{m+n}$$

$$\dfrac{a^m}{a^n}=a^{m-n}$$

These rules also hold for nonzero negative bases when the exponents are integers. An **integer** is a whole number, its negative, or $0$.

For integer exponents and a nonzero base, raising a power to another power multiplies the exponents:

$$(a^m)^n=a^{mn}$$

This rule also holds for a positive base and real exponents. With a negative base and fractional exponents, the shortcut can fail even when both sides have real values:

$$\bigl((-1)^2\bigr)^{1/2}=1$$

$$(-1)^{2(1/2)}=-1$$

A negative exponent means take $1$ divided by the matching positive power:

$$a^{-n}=\dfrac{1}{a^n}\qquad(a\ne0)$$

A zero exponent equals $1$ for a nonzero base:

$$a^0=1\qquad(a\ne0)$$

Dividing a nonzero power by itself explains why:

$$\dfrac{a^m}{a^m}=a^{m-m}=a^0=1$$

This rule does not give a value for $0^0$.

For integer $m$, positive whole-number $n$, and $a>0$, a fractional exponent means a root:

$$a^{m/n}=\sqrt[n]{a^m}=(\sqrt[n]{a})^m$$

The $n$th root of a positive number is the positive number whose $n$th power gives it. For example, $\sqrt[3]{8}=2$ because $2^3=8$.

For $b>0$ and $b\ne1$, different exponents give different powers. Thus, if $b^u=b^v$, then $u=v$.

### Laws of Logarithms

For a base $b>0$, $b\ne1$, and positive $M$ and $N$:

$$\log_b(MN)=\log_b M+\log_b N$$

$$\log_b\left(\dfrac{M}{N}\right)=\log_b M-\log_b N$$

$$\log_b(M^p)=p\log_b M$$

These rules come from the exponent rules. Multiplying powers adds their exponents, so the logarithm of a product becomes a sum.

A logarithm written as $\log(x)$ with no base shown is the **common logarithm**, with base $10$ in this lesson.

Exponential powers and logarithms with the same allowed base undo each other:

$$b^{\log_b x}=x\qquad(x>0)$$

$$\log_b(b^x)=x$$

## Mnemonics & Memory Aids

For powers with the same base:

> Multiply powers: add exponents. Divide powers: subtract exponents. Power of a power: multiply exponents.

For logarithms:

> Products become sums, quotients become differences, and powers move in front.

Use these reminders only under the conditions in Core Concept.

## Examples

### #1: Zero Exponent

Evaluate $7^0+3$.

**Solution:**

1. The base $7$ is nonzero.

$$7^0=1$$

2. Add $3$.

$$1+3=4$$

### #2: Simplifying Terms with the Same Base

Simplify $\dfrac{(x^3y^2)(x^4y^{-1})}{x^2y^3}$ for nonzero $x$ and $y$.

**Solution:**

1. Combine powers in the numerator.

$$\dfrac{x^7y}{x^2y^3}$$

2. Subtract exponents when dividing like bases.

$$x^{7-2}y^{1-3}=x^5y^{-2}$$

3. Rewrite the negative exponent.

$$\dfrac{x^5}{y^2}$$

### #3: Negative and Fractional Exponents

Evaluate $8^{-\dfrac{2}{3}}$.

**Solution:**

1. Use the negative exponent rule.

$$8^{-2/3}=\dfrac{1}{8^{2/3}}$$

2. Find the cube root, then square.

$$8^{2/3}=(\sqrt[3]{8})^2=2^2=4$$

3. Put that value in the denominator.

$$8^{-2/3}=\dfrac{1}{4}$$

### #4: Finding a Basic Logarithm

Evaluate $\log_3(81)$.

**Solution:**

1. Let $x$ be the logarithm's value. Rewrite it as a power equation.

$$3^x=81$$

2. Write $81$ as a power of $3$.

$$3^4=81$$

3. The required exponent is $4$.

$$\log_3(81)=4$$

### #5: Finding an Unknown Logarithm Argument

Solve $\log_2(x-1)=3$.

**Solution:**

1. The argument $x-1$ must be positive.

$$x-1>0\quad\Rightarrow\quad x>1$$

2. Rewrite the equation in exponential form.

$$x-1=2^3=8$$

3. Add $1$.

$$x=9$$

4. Check the argument and the original equation.

$$9-1=8>0$$

$$\log_2(8)=3$$

### #6: Condensing Logarithmic Expressions

For $x>0$, $y>0$, and $z>0$, express $2\log(x)+\log(y)-3\log(z)$ as a single common logarithm.

**Solution:**

1. Use the power rule.

$$\log(x^2)+\log(y)-\log(z^3)$$

2. Use the product rule.

$$\log(x^2y)-\log(z^3)$$

3. Use the quotient rule.

$$\log\left(\dfrac{x^2y}{z^3}\right)$$

### #7: Equation with an Unknown Exponent

Solve $4^{2x-1}=8^{x+1}$.

**Solution:**

1. Rewrite both sides with base $2$.

$$(2^2)^{2x-1}=(2^3)^{x+1}$$

2. Multiply exponents. The base is positive, so this rule applies.

$$2^{4x-2}=2^{3x+3}$$

3. Equal powers of base $2$ have equal exponents.

$$4x-2=3x+3$$

4. Subtract $3x$ and add $2$.

$$x=5$$

### #8: Logarithms in Terms of Given Variables

If $\log_{10}(2)=a$ and $\log_{10}(3)=b$, express $\log_{10}(12)$ in terms of $a$ and $b$.

**Solution:**

1. Factor $12$.

$$12=2^2\times3$$

2. Use the product rule.

$$\log_{10}(12)=\log_{10}(2^2)+\log_{10}(3)$$

3. Move the exponent in front.

$$\log_{10}(12)=2\log_{10}(2)+\log_{10}(3)$$

4. Use the given values.

$$\log_{10}(12)=2a+b$$

## Speed Tricks & Shortcuts

For a nonzero base, a negative exponent moves a factor across a fraction bar by taking $1$ divided by the matching power. Check the sign of the exponent before doing any multiplication.

When both sides of an equation can use the same positive base other than $1$, compare the exponents. This avoids working with large powers.

To check a logarithm answer, turn it back into a power. For example, $\log_5(25)=2$ checks because $5^2=25$.

## Traps to Watch For

### #1: Multiplying Like Bases

> For the same base, add exponents when multiplying.

The rule gives $x^2x^3=x^5$, not $x^6$. Multiplying exponents belongs to a power raised to another power.

### #2: Squaring a Sum

> An exponent does not spread over addition.

The correct expansion is $(x+y)^2=x^2+2xy+y^2$. Writing $x^2+y^2$ leaves out the two cross products.

### #3: Logarithm of a Sum

> There is no general sum rule for logarithms.

In general, $\log_b(x+y)$ cannot become $\log_b x+\log_b y$. The product rule needs multiplication inside the logarithm.

### #4: Missing Logarithm Conditions

> Real logarithms need an allowed base and a positive argument.

The base must satisfy $b>0$ and $b\ne1$. Check the original argument after solving an equation, since a zero or negative argument cannot be used.
