---
_id: "lesson-algebra-work-rate-problems"
title: "Work Problems"
summary: "Add work rates to find how long a shared job takes."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 4
partCount: 6
ordering: 68
keyPoints:
  - "Add work rates and divide one job by the combined rate."
---
## Core Concept

### Turning Time Into a Work Rate

A **work rate** tells what fraction of $1$ whole job a worker finishes in $1$ unit of time. If a painter finishes $1$ room in $6$ hours at a steady pace, the painter finishes $\dfrac{1}{6}$ of the room each hour.

For $1$ whole job done in $t$ hours, the rate is:

$$r=\dfrac{1}{t}$$

When two or more workers work together on the same job, each at a steady rate from start to finish, add their rates:

$$r_{\text{together}}=r_1+r_2+\cdots$$

To find the hours for $1$ whole job, divide $1$ by the combined rate, which flips the fraction (its **reciprocal**):

$$t=\dfrac{1}{r}$$

Each worker must keep the same steady positive rate alone and when working together for the whole time. If one starts late or stops early, find the work done in each part separately.

Try this example: find the hours both pipes take together from their solo times. Pipe A fills a tank in $4$ hours, and Pipe B fills the same tank in $12$ hours. Their rates are $\dfrac{1}{4}$ and $\dfrac{1}{12}$ tank per hour. Add the rates:

$$\dfrac{1}{4}+\dfrac{1}{12}$$

$$=\dfrac{3}{12}+\dfrac{1}{12}$$

$$=\dfrac{4}{12}$$

$$=\dfrac{1}{3}$$

Flip the combined rate to find the hours:

$$1\div\dfrac{1}{3}$$

$$=3$$

Both pipes together fill the tank in $3$ hours.

:::why
Why must the shared time be less than $4$ hours? Pipe A alone takes $4$ hours, and Pipe B adds extra water every hour. When both keep a steady rate, working together finishes faster than the fastest worker alone.
:::

:::check
Three workers can each build the same fence alone in $20$, $30$ and $60$ hours. What is their combined rate, and how many hours will they take together?
:::answer
The answer is $\dfrac{1}{10}$ fence per hour, and $10$ hours. Add $\dfrac{1}{20}+\dfrac{1}{30}+\dfrac{1}{60}=\dfrac{3}{60}+\dfrac{2}{60}+\dfrac{1}{60}=\dfrac{6}{60}=\dfrac{1}{10}$, then flip it: $1\div\dfrac{1}{10}=10$.
:::

### Finding a Missing Solo Time

Sometimes you know the shared time and one worker's solo time, and need the second worker's solo time. Subtract the known rate from the shared rate:

$$r_2=r_{\text{together}}-r_1$$

Try this example: find Bea's solo time from the shared time and Ana's solo time. Ana and Bea finish a report together in $3$ hours. Ana alone takes $8$ hours. Their shared rate is $\dfrac{1}{3}$ and Ana's rate is $\dfrac{1}{8}$ report per hour. Subtract Ana's rate:

$$\dfrac{1}{3}-\dfrac{1}{8}$$

$$=\dfrac{8}{24}-\dfrac{3}{24}$$

$$=\dfrac{5}{24}$$

Flip Bea's rate to find her hours for $1$ whole report:

$$1\div\dfrac{5}{24}$$

$$=\dfrac{24}{5}$$

$$=4.8$$

Bea takes $4.8$ hours alone.

:::pair #rate-not-time
Right: $r_2=\dfrac{5}{24}$ report per hour, so $t=\dfrac{24}{5}=4.8$ hours
Wrong: $t=\dfrac{5}{24}$ hour
$\dfrac{5}{24}$ is the fraction of the report Bea finishes in $1$ hour, not her total time. Flip the rate (divide $1$ by the rate) to get hours.
:::

:::pair #subtract-solo-times
Right: $\dfrac{1}{3}-\dfrac{1}{8}=\dfrac{5}{24}$, so $t=4.8$ hours
Wrong: $8-3=5$ hours
Subtracting solo times gives the wrong answer here. Turn the shared time and the known solo time into rates before subtracting.
:::

## Examples

### #1: Working Together From Start to Finish

Marco can paint a room in $6$ hours. Liza can paint the same room in $3$ hours. They work together from start to finish, each keeping the same steady rate alone and together. How long will they take?

**Solution:**

1. Write each worker's hourly rate in rooms per hour: Marco $\dfrac{1}{6}$, Liza $\dfrac{1}{3}$.
2. Add the two rates using a common denominator of $6$.

$$\dfrac{1}{6}+\dfrac{1}{3}$$

$$=\dfrac{1}{6}+\dfrac{2}{6}$$

$$=\dfrac{3}{6}$$

$$=\dfrac{1}{2}$$

3. Divide $1$ whole job by the combined rate.

$$1\div\dfrac{1}{2}$$

$$=2$$

They finish in $2$ hours.

:::pair #average-work-times
Right: $\dfrac{1}{6}+\dfrac{1}{3}=\dfrac{1}{2}$ room per hour, so $t=2$ hours
Wrong: $\dfrac{6+3}{2}=4.5$ hours
Do not average solo times. The faster worker can paint the room in $3$ hours alone, so working together cannot take $4.5$ hours. Add work rates instead.
:::

### #2: Finding a Missing Solo Time

Pump A and Pump B together can fill an empty tank in $6$ hours, each keeping the same steady rate alone and together. Pump A alone can fill the tank in $10$ hours. How many hours would Pump B take to fill the tank alone?

**Solution:**

1. Write the shared rate and Pump A's rate in tanks per hour: shared $\dfrac{1}{6}$, Pump A $\dfrac{1}{10}$.
2. Subtract Pump A's rate from the shared rate using a common denominator of $30$.

$$\dfrac{1}{6}-\dfrac{1}{10}$$

$$=\dfrac{5}{30}-\dfrac{3}{30}$$

$$=\dfrac{2}{30}$$

:::try
Finish the last step: divide $1$ tank by Pump B's rate $\dfrac{2}{30}$ to find Pump B's solo time.
:::answer
The answer is $15$ hours. Dividing $1\div\dfrac{2}{30}=\dfrac{30}{2}=15$ flips the rate to give the hours.
:::

## Speed Tricks & Shortcuts

For two workers sharing $1$ whole job, let $a$ and $b$ be the hours each takes alone. If each keeps a steady rate from start to finish, use the product-over-sum shortcut:

$$t=\dfrac{ab}{a+b}$$

Find the time for Marco ($6$ hours alone) and Liza ($3$ hours alone):

$$\dfrac{6(3)}{6+3}$$

$$=\dfrac{18}{9}$$

$$=2$$

## Traps to Watch For

:::checklist
- Combining two workers: add their hourly rates, not their solo times. {#average-work-times}
- Finding a missing solo time: turn times into rates first, then subtract from the shared rate. {#subtract-solo-times}
- Finishing after finding a rate: take the reciprocal of the rate to get hours. {#rate-not-time}
:::
