---
_id: "lesson-arithmetic-number-sense-complex-products-and-quotients"
title: "Complex Products and Quotients"
summary: "Multiply complex numbers and replace the square of i with negative one."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 3
partCount: 3
ordering: 6
keyPoints:
  - "Multiply complex numbers and replace the square of i with negative one."
  - "Use a conjugate to divide by a nonzero complex number."
---
## Core Concept

### Multiplying Complex Numbers

Multiply every term in the first complex number by every term in the second, using FOIL (first, outer, inner, last). Next, replace $i^2$ with $-1$. Then combine the real numbers and the $i$ terms.

For real numbers $a,b,c,d$:

$$(a+bi)(c+di)=ac+adi+bci+bdi^2$$

Using $i^2=-1$, the $bdi^2$ term becomes $-bd$, so the product is $(ac-bd)+(ad+bc)i$.

Multiply $(3+2i)(4-5i)$:

$$(3+2i)(4-5i)=12-15i+8i-10i^2$$

Combine the $i$ terms:

$$12-15i+8i-10i^2=12-7i-10i^2$$

Replace $i^2$ with $-1$:

$$12-7i-10i^2=12-7i-10(-1)$$

Add the real numbers:

$$12-7i+10=22-7i$$

:::pair #i-squared-sign
Right: for $12-7i-10i^2$, $12-7i-10(-1)=12+10-7i=22-7i$
Wrong: for $12-7i-10i^2$, $12-7i-10(1)=12-10-7i=2-7i$
The wrong line replaced $i^2$ with $+1$ instead of $-1$. Because $i^2=-1$, subtracting $10i^2$ turns into adding $10$.
:::

:::pair #missing-cross-terms
Right: $(3+2i)(4-5i)=12-15i+8i-10i^2=22-7i$
Wrong: $(3+2i)(4-5i)=12-10i$
The wrong line made two slips: it skipped both cross terms ($-15i$ and $+8i$) and wrote $(2i)(-5i)$ as $-10i$ instead of $-10i^2=10$. Multiply all four pairs and replace $i^2$ with $-1$.
:::

:::check
Multiply $(2+3i)^2$.
:::answer
The answer is $-5+12i$. Squaring means multiplying $2+3i$ by itself: $4+6i+6i+9i^2$ becomes $4+12i-9$, which is $-5+12i$.
:::

### Conjugates and Dividing Complex Numbers

The **conjugate** of $a+bi$ is $a-bi$. Keep the real part the same and flip only the sign of the $i$ term.

For real $a$ and $b$, multiplying $a+bi$ by its conjugate cancels the $i$ terms and gives a real number:

$$(a+bi)(a-bi)=a^2-b^2i^2=a^2+b^2$$

Multiply $5-3i$ by its conjugate $5+3i$:

$$(5-3i)(5+3i)=25+15i-15i-9i^2$$

$$25+15i-15i-9i^2=25-9i^2$$

$$25-9i^2=25+9=34$$

:::why
Why does $(a+bi)(a-bi)$ equal $a^2+b^2$? The middle terms $+abi$ and $-abi$ cancel to $0$, and $-b^2i^2=-b^2(-1)=+b^2$.
:::

To divide by a nonzero complex number $c+di$, multiply both top and bottom by the denominator's conjugate $c-di$:

$$\dfrac{a+bi}{c+di}\times\dfrac{c-di}{c-di}$$

Multiplying by $\dfrac{c-di}{c-di}$ multiplies by $1$, so the value stays the same while the denominator becomes the real number $c^2+d^2$. The divisor must never be $0$, because division by $0$ is undefined.

Divide $\dfrac{4+2i}{3-i}$. Multiply top and bottom by the conjugate $3+i$.

Multiply the numerator:

$$(4+2i)(3+i)=12+4i+6i+2i^2$$

$$12+4i+6i+2i^2=12+4i+6i-2$$

$$12+4i+6i-2=10+10i$$

Multiply the denominator:

$$(3-i)(3+i)=9-i^2$$

$$9-i^2=9+1=10$$

Divide both terms in the numerator by $10$:

$$\dfrac{10+10i}{10}=1+i$$

:::pair #conjugate-denominator-sign
Right: to divide $\dfrac{4+2i}{3-i}$, $(3-i)(3+i)=9-i^2=9+1=10$, so $\dfrac{10+10i}{10}=1+i$
Wrong: to divide $\dfrac{4+2i}{3-i}$, $(3-i)(3+i)=9-1=8$, so $\dfrac{10+10i}{8}=\dfrac{5}{4}+\dfrac{5}{4}i$
Because $i^2=-1$, subtracting $i^2$ adds $1$ instead of subtracting $1$. Add the squares: $c^2+d^2$.
:::

## Examples

### #1: Multiplying Two Complex Numbers

What is $(3-4i)(2+5i)$?

**Solution:**

1. Multiply each term in the first factor by each term in the second.

$$(3-4i)(2+5i)=6+15i-8i-20i^2$$

2. Combine the $i$ terms.

$$6+15i-8i-20i^2=6+7i-20i^2$$

3. Replace $i^2$ with $-1$.

$$6+7i-20i^2=6+7i-20(-1)$$

4. Add the real parts.

$$6+7i+20=26+7i$$

The answer is $26+7i$.

### #2: Dividing by a Complex Number

"Express" means write an equal answer in the form asked for.

Express $\dfrac{2+3i}{1-i}$ in standard form $a+bi$.

**Solution:**

1. The conjugate of $1-i$ is $1+i$. Multiply numerator and denominator by $1+i$.

$$\dfrac{2+3i}{1-i}\times\dfrac{1+i}{1+i}$$

2. Multiply the numerator and replace $i^2$ with $-1$.

$$(2+3i)(1+i)=2+2i+3i+3i^2$$

$$2+2i+3i+3i^2=2+5i+3(-1)$$

$$2+5i+3(-1)=-1+5i$$

3. Multiply the denominator.

$$(1-i)(1+i)=1-i^2$$

$$1-i^2=1+1=2$$

:::try
Finish the last step: divide $-1+5i$ by $2$ and write the answer in standard form $a+bi$.
:::answer
The answer is $-\dfrac{1}{2}+\dfrac{5}{2}i$. Divide both parts of the numerator by $2$ to get $\dfrac{-1}{2}+\dfrac{5}{2}i$.
:::

## Speed Tricks & Shortcuts

- **Quick conjugate product:** for real $a$ and $b$, $(a+bi)(a-bi)=a^2+b^2$ skips FOIL.
- **Standard form:** split the final fraction into two terms, $a+bi$, with real part first.

## Traps to Watch For

:::checklist
- Replacing $i^2$: substitute $-1$, so subtracting $10i^2$ adds $10$. {#i-squared-sign}
- Multiplying two complex numbers: expand all four products, including both cross terms. {#missing-cross-terms}
- Conjugate denominator: $(a+bi)(a-bi)$ equals $a^2+b^2$, not $a^2-b^2$, and the divisor cannot be $0$. {#conjugate-denominator-sign}
:::
