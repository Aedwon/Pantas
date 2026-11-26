---
_id: "lesson-arithmetic-number-sense-inverse-proportion-and-remaining-work"
title: "Inverse Proportion and Remaining Work"
summary: "Keep the product constant in inverse proportion and separate finished work first."
subject: "subject-mathematics"
topic: "topic-arithmetic-number-sense"
isActive: true
part: 2
partCount: 3
ordering: 22
keyPoints:
  - "Use a constant product for inverse proportion."
  - "Find what remains before applying a changed group size or rate."
---
## Core Concept

### Constant Product in Inverse Proportion

In an **inverse proportion**, two nonzero quantities keep the same product. If $y$ is inversely proportional to $x$, then:

$$xy=k$$

$$y=\dfrac{k}{x}$$

Here $k$ is a fixed number. When $k>0$, making one quantity larger makes the other smaller. Doubling $x$ cuts $y$ in half so their product stays $k$.

Suppose $6$ identical pumps empty a pool in $10$ hours. First find the constant product, the total pump-hours for the job.

$$6\times10=60$$

Now find how long $5$ pumps take to do that same $60$ pump-hour job.

$$5\times x=60$$

$$x=\dfrac{60}{5}=12$$

Five pumps take $12$ hours. Notice that fewer pumps need more time, not less.

:::pair #direct-instead-of-inverse
Right: $5x=6\times10=60$, so $x=12\text{ hours}$
Wrong: $\dfrac{6}{10}=\dfrac{5}{x}$, giving $x=8\dfrac{1}{3}\text{ hours}$
The wrong line scaled time down with fewer pumps. For a fixed job, fewer pumps need more time, so multiply each pair instead of dividing.
:::

Just going in opposite directions does not prove inverse proportion. You must check that the product $xy$ stays equal.

:::pair #constant-product-not-sum
Right: compare products: $2\times8=16$ and $4\times6=24$, not inverse proportion
Wrong: compare sums: $2+8=10$ and $4+6=10$, so inverse proportion
Inverse proportion keeps the product $xy$ constant, never the sum $x+y$.
:::

:::why
Why does a fixed job keep $xy$ constant? If each pump removes $1$ part of the pool per hour, then $6$ pumps working $10$ hours remove $6\times10=60$ parts. Any other number of pumps must still remove those same $60$ parts.
:::

:::check
Four printers finish a job in $15$ minutes. Working at the same rate, how long do $6$ printers take?
:::answer
The answer is $10\text{ minutes}$. The job takes $4\times15=60$ printer-minutes, so $6$ printers need $60\div6=10\text{ minutes}$.
:::

### Handling a Mid-Problem Change

When workers join or leave partway through a job, do not apply the new group size to the whole job. First subtract the work already done.

One **worker-day** is the work $1$ worker does in $1$ day. Follow three steps:

1. Find the total worker-days for the whole job.
2. Subtract the worker-days already finished to find what remains.
3. Divide the remaining worker-days by the new number of workers.

<!-- ILLUSTRATION: two stacked horizontal bars. Top bar labeled "Total job = 10 x 12 = 120 worker-days". Bottom bar split into shaded left section "Done in 4 days: 10 x 4 = 40 worker-days" and right section "Remaining: 80 worker-days, 8 workers x 10 days" -->

Suppose $10$ workers can finish a project in $12$ days. After $4$ days, $2$ workers leave. How many more days do the remaining workers need?

$$10\times12=120\text{ worker-days}$$

$$10\times4=40\text{ worker-days done}$$

$$120-40=80\text{ worker-days left}$$

There are $10-2=8$ workers left, so divide $80$ by $8$.

$$\dfrac{80}{8}=10\text{ more days}$$

:::pair #use-total-not-remaining
Right: remaining work is $120-40=80$, so $80\div8=10\text{ days}$
Wrong: divide total work by $8$, so $120\div8=15\text{ days}$
The first $4$ days of work are already finished. Divide only the remaining $80$ worker-days by the $8$ remaining workers.
:::

:::check
A camp has food for $30$ hikers for $12$ days. After $2$ days, $5$ hikers leave. How many more days will the remaining food last?
:::answer
The answer is $12\text{ days}$. Total food is $30\times12=360$ hiker-days. Two days use $30\times2=60$, leaving $300$ hiker-days for $25$ hikers, and $300\div25=12$.
:::

## Examples

### #1: Changing the Crew Size

A contractor estimates that $6$ workers, all working at the same constant rate, can finish a fixed job in $15$ days. If $9$ workers work at that same rate, how many days will the job take?

**Solution:**

1. For a fixed job with equal worker rates, workers times days stays constant.

$$6\times15=90\text{ worker-days}$$

2. Set the new product equal to $90$.

$$9x=90$$

3. Divide by $9$.

$$x=\dfrac{90}{9}=10$$

It will take $10$ days.

**Check:** Check the direction and product. More workers ($9$ instead of $6$) should take fewer days than $15$, and $10<15$. Also $9\times10=90$, matching $6\times15=90$.

### #2: Remaining Supplies After People Leave

A group of $40$ people has enough identical daily food portions for $30$ days. After $10$ days, $10$ people leave. If each person keeps receiving the same daily portion, how many more days will the remaining food last?

**Solution:**

1. After $10$ days, there are $30-10=20$ days of food left for the original $40$ people. One **person-day** is enough food for $1$ person for $1$ day.

$$40\times20=800\text{ person-days}$$

2. Find the new group size after $10$ people leave.

$$40-10=30\text{ people}$$

:::try
Finish the last step: divide the $800$ remaining person-days by $30$ people.
:::answer
The answer is $26\dfrac{2}{3}$ more days. Divide $\dfrac{800}{30}=\dfrac{80}{3}=26\dfrac{2}{3}$.

**Check:** With all $40$ people, the remaining food lasted $20$ days. With $30$ people (fewer mouths), it must last longer than $20$ days, and $30\times26\dfrac{2}{3}=800$ person-days matches.
:::

## Speed Tricks & Shortcuts

When everyone works at the same rate up to the change, you can skip total work and multiply the old group by the remaining days right away. In Example $2$, $30-10=20$ days remain for $40$ people, so $40\times20=800$ person-days left.

## Traps to Watch For

:::checklist
- Fewer workers or pumps on a fixed job: keep the product constant so time goes up, not down. {#direct-instead-of-inverse}
- Checking if two quantities are inversely proportional: test that the product $xy$ stays equal, not the sum. {#constant-product-not-sum}
- Workers or people leaving partway through: subtract the finished work or used supplies first before dividing. {#use-total-not-remaining}
:::
