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

When two workers work together on the same job at steady rates from start to finish, add their rates:

$$r_{\text{together}}=r_1+r_2$$

To find the hours for $1$ whole job, divide $1$ by the combined rate, which flips the fraction (its **reciprocal**):

$$t=\dfrac{1}{r}$$

Both workers must keep the same steady positive rate when working alone and when working together for the whole time. If one starts late or stops early, find the work done in each part separately.

Try this example. Pipe A fills a tank in $4$ hours, and Pipe B fills the same tank in $12$ hours. How long do both pipes take together?

$$r_1=\dfrac{1}{4},\qquad r_2=\dfrac{1}{12}$$

$$r_{\text{together}}=\dfrac{1}{4}+\dfrac{1}{12}$$

$$r_{\text{together}}=\dfrac{3}{12}+\dfrac{1}{12}=\dfrac{4}{12}=\dfrac{1}{3}$$

$$t=1\div\dfrac{1}{3}=3$$

Both pipes together fill the tank in $3$ hours.

:::why
Why must the shared time be less than $4$ hours? Pipe A alone takes $4$ hours, and Pipe B adds extra water every hour. Working together always finishes faster than the fastest worker alone.
:::

:::pair #average-work-times
Right: $\dfrac{1}{6}+\dfrac{1}{3}=\dfrac{1}{2}$ wall per hour, so $t=2$ hours
Wrong: $\dfrac{6+3}{2}=4.5$ hours
Never average solo times. The faster worker can paint the wall in $3$ hours alone, so working together cannot take $4.5$ hours. Add work rates instead.
:::

:::check
Worker A can build a fence in $6$ hours, and Worker B can build the same fence in $6$ hours. What is their combined rate, and how many hours will they take together?
:::answer
The answer is $\dfrac{1}{3}$ fence per hour, and $3$ hours. Add $\dfrac{1}{6}+\dfrac{1}{6}=\dfrac{2}{6}=\dfrac{1}{3}$, then flip it: $1\div\dfrac{1}{3}=3$.
:::

### Finding a Missing Solo Time

Sometimes you know the shared time and one worker's solo time, and need the second worker's solo time. Subtract the known rate from the shared rate:

$$r_2=r_{\text{together}}-r_1$$

Try this example. Ana and Bea finish a report together in $3$ hours. Ana alone takes $8$ hours. How long would Bea take alone?

$$r_{\text{together}}=\dfrac{1}{3},\qquad r_1=\dfrac{1}{8}$$

$$r_2=\dfrac{1}{3}-\dfrac{1}{8}=\dfrac{8}{24}-\dfrac{3}{24}=\dfrac{5}{24}$$

Flip Bea's rate to find her hours for $1$ whole report:

$$t=1\div\dfrac{5}{24}=\dfrac{24}{5}=4.8$$

Bea takes $4.8$ hours alone.

:::pair #rate-not-time
Right: $r_2=\dfrac{5}{24}$ report per hour, so $t=\dfrac{24}{5}=4.8$ hours
Wrong: $t=\dfrac{5}{24}$ hour
$\dfrac{5}{24}$ is the fraction of the report Bea finishes in $1$ hour, not her total time. Always flip the rate (divide $1$ by the rate) to get hours.
:::

:::pair #subtract-solo-times
Right: $\dfrac{1}{3}-\dfrac{1}{8}=\dfrac{5}{24}$, so $t=4.8$ hours
Wrong: $8-3=5$ hours
Solo times cannot be subtracted directly. Turn both times into hourly rates first, then subtract.
:::

:::check
Two printers complete a job together in $2$ hours. Printer X alone takes $6$ hours. How many hours would Printer Y take alone?
:::answer
The answer is $3$ hours. Subtract rates: $\dfrac{1}{2}-\dfrac{1}{6}=\dfrac{3}{6}-\dfrac{1}{6}=\dfrac{1}{3}$, so Printer Y takes $3$ hours.
:::

## Examples

### #1: Working Together From Start to Finish

Marco can paint a room in $6$ hours. Liza can paint the same room in $3$ hours. They work together from start to finish, each keeping the same steady rate alone and together. How long will they take?

**Solution:**

1. Write each worker's hourly rate in rooms per hour.

$$r_1=\dfrac{1}{6},\qquad r_2=\dfrac{1}{3}$$

2. Add the two rates using a common denominator of $6$.

$$r_{\text{together}}=\dfrac{1}{6}+\dfrac{1}{3}$$

$$r_{\text{together}}=\dfrac{1}{6}+\dfrac{2}{6}$$

$$r_{\text{together}}=\dfrac{3}{6}=\dfrac{1}{2}$$

3. Divide $1$ whole job by the combined rate.

$$t=1\div\dfrac{1}{2}=2$$

They finish in $2$ hours.

**Check:** In $2$ hours, Marco paints $2\times\dfrac{1}{6}=\dfrac{1}{3}$ of the room and Liza paints $2\times\dfrac{1}{3}=\dfrac{2}{3}$ of the room. Together they finish $\dfrac{1}{3}+\dfrac{2}{3}=1$ whole room.

### #2: Finding a Missing Solo Time

Pump A and Pump B together can fill an empty tank in $6$ hours, each keeping the same steady rate alone and together. Pump A alone can fill the tank in $10$ hours. How many hours would Pump B take to fill the tank alone?

**Solution:**

1. Write the shared rate and Pump A's rate in tanks per hour.

$$r_{\text{together}}=\dfrac{1}{6},\qquad r_1=\dfrac{1}{10}$$

2. Subtract Pump A's rate from the shared rate using a common denominator of $30$.

$$r_2=\dfrac{1}{6}-\dfrac{1}{10}$$

$$r_2=\dfrac{5}{30}-\dfrac{3}{30}$$

$$r_2=\dfrac{2}{30}=\dfrac{1}{15}$$

:::try
Finish the last step: divide $1$ job by Pump B's rate $\dfrac{1}{15}$ to find Pump B's solo time.
:::answer
The answer is $15$ hours. Dividing $1\div\dfrac{1}{15}=15$ flips the rate to give $15$ hours.

**Check:** In $6$ hours, Pump A fills $6\times\dfrac{1}{10}=\dfrac{3}{5}$ of the tank and Pump B fills $6\times\dfrac{1}{15}=\dfrac{2}{5}$ of the tank. Together they fill $\dfrac{3}{5}+\dfrac{2}{5}=1$ whole tank.
:::

## Speed Tricks & Shortcuts

For two workers sharing $1$ whole job from start to finish in solo times $a$ and $b$, you can use the product-over-sum shortcut:

$$t=\dfrac{ab}{a+b}$$

For Marco ($6$ hours) and Liza ($3$ hours):

$$t=\dfrac{6(3)}{6+3}=\dfrac{18}{9}=2$$

## Traps to Watch For

:::checklist
- Combining two workers: add their hourly rates, never average or add their solo times. {#average-work-times}
- Finding a missing solo time: turn times into rates first, then subtract from the shared rate. {#subtract-solo-times}
- Finishing after finding a rate: take the reciprocal of the rate to get hours. {#rate-not-time}
:::
