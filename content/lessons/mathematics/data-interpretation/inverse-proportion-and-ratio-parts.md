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

In an **inverse proportion**, one quantity goes up while the other goes down so their product stays the same. This happens when a fixed job is shared by workers or machines all working at the same unchanged rate.

$$\text{workers}\times\text{time}=\text{total work}$$

Suppose $9$ identical machines finish a fixed scanning job in $8$ hours.

1. Multiply to find the fixed total work in machine-hours:

$$9\times8=72$$

2. To finish the same $72$-machine-hour job in $6$ hours, divide by $6$:

$$\dfrac{72}{6}=12\text{ machines}$$

If the question asks how many *additional* machines are needed, subtract the $9$ machines you already have: $12-9=3$ additional machines.

:::pair #total-instead-of-additional-machines
Right: $12-9=3\text{ additional machines}$
Wrong: $12\text{ machines}$
$12$ is the total number of machines required. When a question asks for additional machines or workers, subtract the starting count from the new total.
:::

Sometimes part of the job finishes before the team size changes. Subtract the completed work from the total work first, then divide the remaining work by the remaining workers.

Suppose $8$ clerks can finish a batch in $15$ hours ($8\times15=120$ clerk-hours). After all $8$ work for $5$ hours ($8\times5=40$ clerk-hours done), $120-40=80$ clerk-hours remain, and $2$ clerks leave ($6$ left).

$$\dfrac{80}{6}=13\dfrac{1}{3}\text{ hours}$$

:::why
Why does losing $2$ clerks make the remaining time go up instead of down? Those $80$ clerk-hours of work now get shared by $6$ clerks instead of $8$, so each hour accomplishes less and the remaining job takes longer.
:::

:::pair #scale-time-like-direct
Right: $\dfrac{80\text{ clerk-hours}}{6\text{ clerks}}=13\dfrac{1}{3}\text{ hours}$
Wrong: $10\text{ hours}\times\dfrac{6}{8}=7\dfrac{1}{2}\text{ hours}$
The wrong line reduced the time when the team shrank. With fewer equal workers on the same remaining work, the time must go up, not down.
:::

:::check
Six workers can finish a fixed job in $10$ hours at the same work rate. How many hours will $15$ workers take for the same job?
:::answer
The answer is $4$ hours. Total work is $6\times10=60$ worker-hours, and $\dfrac{60}{15}=4$ hours.
:::

### Dividing a Total into Ratio Parts

A ratio can split one fixed total into unequal parts. If a problem reserves or spends a fixed amount first, subtract that amount before dividing the rest.

<!-- FIGURE WANTED: a horizontal bar labeled "360 folders = 9 equal parts (40 per part)", divided into 9 equal boxes: first 2 boxes bracketed as "Unit A (2 parts = 80)", next 3 boxes as "Unit B (3 parts = 120)", last 4 boxes as "Unit C (4 parts = 160)" -->

To divide a total in a ratio such as $2:3:4$:

1. Add all ratio terms to count the total parts.
2. Divide the total amount by the number of parts to find $1$ part.
3. Multiply $1$ part by the requested term or difference of terms.

Suppose $360$ folders are divided among Units A, B, and C in the ratio $2:3:4$.

$$2+3+4=9\text{ parts}$$

$$\dfrac{360}{9}=40\text{ folders per part}$$

Unit A gets $2\times40=80$, Unit B gets $3\times40=120$, and Unit C gets $4\times40=160$. So Unit C gets $160-80=80$ more folders than Unit A.

:::pair #divide-equally-instead-of-ratio
Right: $2+3+4=9\text{ parts}$, so $1\text{ part}=\dfrac{360}{9}=40$ and $C-A=2\times40=80\text{ folders}$
Wrong: $\dfrac{360}{3}=120\text{ folders}$
The wrong line divided $360$ equally among the $3$ units. Ratio shares are unequal, so add the ratio terms ($9$) to find the number of parts.
:::

:::check
An office reserves $12,000$ pesos from a $96,000$-peso fund and divides the rest between training and travel in the ratio $3:4$. How much goes to travel?
:::answer
The answer is $48,000$ pesos. The remainder is $96,000-12,000=84,000$. Divide by $3+4=7$ parts to get $12,000$ per part, so travel gets $4\times12,000=48,000$ pesos.
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

**Check:** The team doubled from $6$ to $12$ workers at the same rate. Doubling the team cuts the time in half, and half of $8$ hours is $4$ hours.

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

**Check:** Program A gets $2\times9,000=18,000$ pesos. Adding both shares gives $18,000+27,000=45,000$ pesos, which matches the total fund.
:::

## Speed Tricks & Shortcuts

Check direction first: if both quantities move together by the same factor, use direct proportion. If one goes up while the other goes down to keep a fixed total work unchanged, use inverse proportion.

## Traps to Watch For

:::checklist
- Fewer workers on a fixed remaining job: keep total worker-hours constant so time goes up, not down. {#scale-time-like-direct}
- Asked for "additional" machines or workers: subtract the starting count from the new total needed. {#total-instead-of-additional-machines}
- Splitting a total in a ratio: add all ratio terms to find total parts, never divide equally by the number of groups. {#divide-equally-instead-of-ratio}
:::
