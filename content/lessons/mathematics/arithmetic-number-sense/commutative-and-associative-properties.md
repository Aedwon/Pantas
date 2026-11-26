---
_id: "lesson-arithmetic-number-sense-commutative-and-associative-properties"
title: "Commutative and Associative Properties"
summary: "Tell a change of order from a change of grouping."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 1
partCount: 4
ordering: 7
keyPoints:
  - "Tell a change of order from a change of grouping."
  - "Explain why these properties do not apply to subtraction or division in general."
---
## Core Concept

### Real Numbers

**Real numbers** include whole numbers, fractions, decimals, and numbers such as $\sqrt{2}$. In the rules below, each letter stands for a real number.

In addition, each number being added is an **addend**. In multiplication, each number being multiplied is a **factor**. Writing $ab$ means $a\times b$.

### Commutative Property

The **commutative property** lets you swap order in addition and multiplication. Walking $3$ blocks east then $4$ blocks east reaches $7$ blocks either way.

Swap $7$ and $12$:

$$7+12=19$$

$$12+7=19$$

The same holds when you multiply two numbers.

$$3\times 4=12$$

$$4\times 3=12$$

In symbols:

$$a+b=b+a$$

$$ab=ba$$

:::why
Why does order not change the sum or product? Adding puts two groups into one pile, and multiplying counts the tiles in a rectangle turned on its side. Neither action changes how many items you have.
:::

:::check
Swap the two terms inside the parentheses of $(9+2x)\times 3$.
:::answer
The answer is $(2x+9)\times 3$. The terms $9$ and $2x$ trade places, while the grouping does not move.
:::

### Associative Property

The **associative property** lets you change grouping in repeated addition or multiplication. Parentheses show which pair goes first; order stays the same.

Regroup $3$, $5$, and $4$:

$$(3+5)+4=8+4=12$$

$$3+(5+4)=3+9=12$$

Multiplication works the same way when you move parentheses.

$$(2\times 3)\times 5=6\times 5=30$$

$$2\times (3\times 5)=2\times 15=30$$

In symbols:

$$(a+b)+c=a+(b+c)$$

$$(ab)c=a(bc)$$

:::pair #order-vs-grouping
Right: $(3+5)+4=3+(5+4)$ shows the associative property
Wrong: $(3+5)+4=3+(5+4)$ shows the commutative property
The numbers stayed in the order $3, 5, 4$. Only the parentheses moved, so the grouping changed, not the order.
:::

:::check
Regroup $(4\times 7)\times 5$ so the last two numbers are multiplied first.
:::answer
The answer is $4\times (7\times 5)$. The order $4, 7, 5$ stayed the same, and only the parentheses moved. Both sides equal $140$.
:::

### Why Subtraction and Division Fail

Subtraction and division are not commutative or associative in general. Swapping order or moving parentheses usually changes the answer.

Try swapping order in subtraction:

$$5-3=2$$

$$3-5=-2$$

Since $2$ and $-2$ are different numbers, subtraction is not commutative.

:::pair #subtraction-order
Right: $5-3=2$ and $3-5=-2$, so subtraction is not commutative
Wrong: $5-3$ and $3-5$ both equal $2$, so subtraction is commutative
Ignoring the minus sign gives $2$ both times. Because $2$ and $-2$ sit on opposite sides of $0$, swapping order changes the answer.
:::

Try moving parentheses in division:

$$(12\div 4)\div 2=3\div 2=1.5$$

$$12\div (4\div 2)=12\div 2=6$$

The two groupings give $1.5$ and $6$, so division is not associative. Subtraction fails regrouping too: $(8-4)-2=2$, while $8-(4-2)=6$.

:::pair #division-grouping
Right: $(12\div 4)\div 2=1.5$ and $12\div (4\div 2)=6$ show division is not associative
Wrong: $(12\div 4)\div 2$ and $12\div (4\div 2)$ differ because division is not commutative
The numbers stayed in the order $12, 4, 2$. Changing which pair you divide first is a grouping change, not an order change.
:::

:::check
Find $(17-9)-4$ and $17-(9-4)$.
:::answer
The answer is $4$ and $12$. First $(17-9)-4=8-4=4$, while $17-(9-4)=17-5=12$.
:::

## Examples

### #1: Identifying Order vs. Grouping

Starting with $3+(8+x)$, which sequence of properties transforms the expression into $(8+3)+x$?

**Solution:**

1. Compare $3+(8+x)$ with the next step, $(3+8)+x$. The order stays $3, 8, x$, and only the parentheses move to the first two terms.

$$3+(8+x)=(3+8)+x$$

This uses the associative property of addition.

2. Now compare $(3+8)+x$ with $(8+3)+x$. The parentheses stay around the first two terms, and $3$ swaps places with $8$.

$$(3+8)+x=(8+3)+x$$

This uses the commutative property of addition.

The sequence is associative, then commutative.

**Check:** Plug in $x=4$ to check both ends. The start gives $3+(8+4)=3+12=15$, and the end gives $(8+3)+4=11+4=15$.

### #2: Regrouping a Product

"Evaluate" means find the final number answer.

Evaluate $25\times (4\times 17)+15$.

**Solution:**

1. Look at the multiplication $25\times (4\times 17)$. Use the associative property to group $25$ and $4$ together first.

$$25\times (4\times 17)+15=(25\times 4)\times 17+15$$

2. Multiply the easy pair inside the parentheses.

$$25\times 4=100$$

3. Put $100$ back in place of $25\times 4$.

$$100\times 17+15$$

:::try
Finish the last step: multiply $100\times 17$, then add $15$.
:::answer
The answer is $1,715$. First $100\times 17=1,700$, and then $1,700+15=1,715$.

**Check:** Multiply the original order instead: $4\times 17=68$, then $25\times 68=1,700$, and $1,700+15=1,715$. Both ways give $1,715$.
:::

## Traps to Watch For

:::checklist
- Parentheses move while order stays the same: that is the associative property, not commutative. {#order-vs-grouping}
- Subtraction swaps order: check the signs, since $5-3=2$ and $3-5=-2$. {#subtraction-order}
- Parentheses move in subtraction or division: do not regroup, because $(12\div 4)\div 2=1.5$ while $12\div (4\div 2)=6$. {#division-grouping}
:::
