---
_id: "lesson-data-interpretation-inverse-proportion-and-ratio-parts"
title: "Sharing a Fixed Total"
summary: "Share a fixed job or amount using inverse proportion or ratio parts."
subject: "subject-mathematics"
topic: "topic-data-interpretation"
isActive: true
part: 4
partCount: 4
ordering: 7
keyPoints:
  - "Use inverse proportion only for a fixed job and unchanged work rate."
  - "Divide a total into the number of parts given by a ratio."
---
## Core Concept

### Inverse Proportion for a Fixed Job

In an **inverse proportion**, two quantities have a product that stays the same. In a fixed job with positive worker counts and times, more workers or machines at the same unchanged rate means less time.

$$\text{workers}\times\text{time}=\text{total work}$$

$9$ identical machines finish a fixed scanning job in $8$ hours. Each machine scans at the same steady rate in both cases. Find how many machines finish the same job in $6$ hours.

1. Multiply to find the fixed total work in machine-hours:

$$9\times8=72$$

2. Divide the total work by the new time, $6$ hours:

$$\dfrac{72}{6}=12\text{ machines}$$

If the question asks how many *additional* machines are needed, subtract the $9$ machines you already have: $12-9=3$ additional machines.

:::pair #total-instead-of-additional-machines
Right: $12-9=3\text{ additional machines}$
Wrong: $12\text{ machines}$
$12$ is the total number of machines required. When a question asks for additional machines or workers, subtract the starting count from the new total.
:::

Sometimes part of the job finishes before the team size changes. Subtract the completed work from the total work first, then divide the remaining work by the remaining workers.

$8$ clerks, all at the same steady rate, can finish a batch in $15$ hours. After all $8$ work for $5$ hours, $2$ clerks leave. Find the hours the $6$ remaining clerks need.

The total work, in clerk-hours:

$$8\times15=120$$

The completed work, in clerk-hours:

$$8\times5=40$$

The remaining work, in clerk-hours:

$$120-40=80$$

The hours for $6$ clerks:

$$\dfrac{80}{6}=13\dfrac{1}{3}\text{ hours}$$

<!-- ILLUSTRATION: one horizontal bar of 120 clerk-hours, labeled "Total 8 × 15 = 120 clerk-hours", drawn to scale. The first third, 40 clerk-hours, is shaded and labeled "Done 8 × 5 = 40". The remaining two thirds are labeled "Left 120 - 40 = 80". Under the left part, a bracket reads "80 / 6 = 13 1/3 hours for 6 clerks", so the remaining work is divided by the remaining workers. -->

:::why
Why does losing $2$ clerks make the remaining time go up instead of down? Those $80$ clerk-hours of work now get shared by $6$ clerks instead of $8$, so each hour accomplishes less and the remaining job takes longer.
:::

The $8$ clerks would need $15-5=10$ more hours. Find the time for $6$ clerks.

:::pair #scale-time-like-direct
Right: $\dfrac{80\text{ clerk-hours}}{6\text{ clerks}}=13\dfrac{1}{3}\text{ hours}$
Wrong: $10\text{ hours}\times\dfrac{6}{8}=7\dfrac{1}{2}\text{ hours}$
The wrong line reduced the time when the team shrank. With fewer equal workers on the same remaining work, the time must go up, not down.
:::

:::check
$12$ pumps, all at the same steady rate, empty a tank in $7$ hours. How many hours would $6$ of these pumps need?
:::answer
The answer is $14$ hours. Total work is $12\times7=84$ pump-hours, and $\dfrac{84}{6}=14$ hours.
:::

### Dividing a Total into Ratio Parts

A ratio can split one fixed total into unequal parts. If a problem reserves or spends a fixed amount first, subtract that amount before dividing the rest.

To divide a total in a ratio such as $2:3:4$:

1. Add all ratio terms to count the total parts.
2. Divide the total amount by the number of parts to find $1$ part.
3. Multiply $1$ part by the requested term or difference of terms.

A $60,000$-peso fund reserves $10,000$ pesos first, and the rest is split in the ratio $1:4$. The amount to split is the fund minus the reserve:

$$60,000-10,000=50,000$$

Then $1+4=5$ parts, and $\dfrac{50,000}{5}=10,000$ per part. The shares are $10,000$ and $40,000$ pesos.

$360$ folders are divided among Units A, B, and C in the ratio $2:3:4$. Find how many more folders Unit C gets than Unit A.

$$2+3+4=9\text{ parts}$$

$$\dfrac{360}{9}=40\text{ folders per part}$$

Unit A gets $2\times40=80$, Unit B gets $3\times40=120$, and Unit C gets $4\times40=160$. So Unit C gets $160-80=80$ more folders than Unit A.

<!-- ILLUSTRATION: a horizontal bar labeled "360 folders = 9 equal parts (40 per part)", divided into 9 equal boxes. The first 2 boxes are bracketed as "Unit A, 2 parts = 80", the next 3 boxes as "Unit B, 3 parts = 120", and the last 4 boxes as "Unit C, 4 parts = 160". One part is the unit that every ratio term counts in. -->

:::pair #divide-equally-instead-of-ratio
Right: $2+3+4=9\text{ parts}$, so $1\text{ part}=\dfrac{360}{9}=40$ and $C-A=2\times40=80\text{ folders}$
Wrong: $\dfrac{360}{3}=120\text{ folders}$
The wrong line divided $360$ equally among the $3$ units. These ratio shares are unequal, so add the ratio terms ($9$) to find the number of parts.
:::

## Examples

### #1: Using an Inverse Proportion

Six workers can finish one fixed job in $8$ hours when all workers have the same work rate. If $12$ workers do the same job at the same rate, how many hours will it take?

**Solution:**

1. Multiply workers by hours to find the fixed total work in worker-hours.

$$6\times8=48$$

2. Divide the $48$ worker-hours by the $12$ workers.

$$\dfrac{48}{12}=4$$

The job will take $4$ hours.

### #2: Dividing a Total in a Ratio

A fund of $45,000$ pesos is divided between Program A and Program B in the ratio $2:3$. How much does Program B receive?

**Solution:**

1. Add the ratio terms to find the total number of parts.

$$2+3=5$$

2. Divide the fund by $5$ to find the value of $1$ part.

$$\dfrac{45,000}{5}=9,000$$

:::try
Finish the last step: find the amount for Program B's $3$ parts.
:::answer
The answer is $27,000$ pesos. Multiply $3\times9,000=27,000$.
:::

## Speed Tricks & Shortcuts

Check direction first: if both quantities move together by the same factor, use direct proportion. If one goes up while the other goes down to keep a fixed total work unchanged, use inverse proportion.

## Traps to Watch For

:::checklist
- Fewer equal workers on a fixed remaining job: keep total worker-hours constant so time goes up, not down. {#scale-time-like-direct}
- Asked for "additional" machines or workers: subtract the starting count from the new total needed. {#total-instead-of-additional-machines}
- Splitting a total in a ratio: add all ratio terms to find total parts, then divide by that count, not by the number of groups. {#divide-equally-instead-of-ratio}
:::
