---
_id: "lesson-algebra-motion-chase-problems"
title: "Motion Problems (Chase)"
summary: "Use the starting gap and the speed difference to solve a chase problem."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 3
partCount: 6
ordering: 67
keyPoints:
  - "Subtract the slower speed from the faster speed in a same-direction chase."
---
## Core Concept

### Closing a Head-Start Gap

**Rate** tells how much distance an object covers in each unit of time. **Kph** means kilometers per hour, and **km** means kilometers. Distance equals rate times time:

$$d=rt$$

Keep units matched: a rate in kph needs distance in km and time in hours.

In a **chase problem**, two objects move in the same direction along the same straight path at steady speeds. The faster object starts behind and catches the slower one ahead. If the object behind is no faster, it can never close the gap.

When a problem gives a time head start instead of a distance, and both leave the same point, multiply the slower speed by the head-start time to find the starting gap $d$. Then subtract the slower speed from the faster speed to get the closing rate:

$$r_{\text{close}}=r_{\text{fast}}-r_{\text{slow}}$$

Use the starting gap as $d$ and the closing rate as $r$ in $d=rt$.

Find when the van catches up. A jeepney leaves a terminal at $40$ kph. One hour later, a van follows in the same direction at $60$ kph. How many hours after the van starts will it catch the jeepney?

First find the jeepney's $1$-hour head start:

$$40\times 1=40$$

<!-- ILLUSTRATION: horizontal straight road. A van at the 0 km mark moves right at 60 kph, and a jeepney ahead at the 40 km mark moves right at 40 kph. A bracket from 0 to 40 km is labeled "head start = 40 km". Below it a note reads "gap shrinks by 60 - 40 = 20 km each hour". -->

Next find how fast the van closes the $40\text{ km}$ gap:

$$60-40=20$$

Now divide the gap by the closing rate:

$$t=\dfrac{40}{20}=2$$

The van catches up $2$ hours after it starts.

:::why
Why do we subtract the speeds? In $1$ hour, the van drives $60$ km forward while the jeepney also drives $40$ km forward. So the gap shrinks by only $60-40=20$ km each hour.
:::

:::pair #add-speeds-in-chase
Right: $r_{\text{close}}=60-40=20$ kph, so $t=\dfrac{40}{20}=2$ hours
Wrong: $r_{\text{close}}=60+40=100$ kph, so $t=\dfrac{40}{100}=0.4$ hour
Adding speeds works when objects move toward each other. In a same-direction chase, the target keeps moving away, so subtract the speeds.
:::

:::pair #use-only-chaser-speed
Right: $r_{\text{close}}=60-40=20$ kph, so $t=\dfrac{40}{20}=2$ hours
Wrong: $r=60$ kph, so $t=\dfrac{40}{60}=\dfrac{2}{3}$ hour
Dividing by $60$ treats the jeepney as standing still. Subtract the jeepney's $40$ kph speed because it keeps moving forward.
:::

:::pair #head-start-clock
Right: the van takes $2$ hours after it starts, so the answer is $2$ hours.
Wrong: total time is $2+1=3$ hours, so the answer is $3$ hours.
Check when the question starts the clock. "After the van starts" asks for $2$ hours, while $3$ hours counts from when the jeepney left.
:::

:::check
A cyclist leaves a town at a constant $12$ kph. Two hours later, a second cyclist leaves the same town and follows on the same road at a constant $16$ kph. How many kilometers from the town does the second cyclist catch the first?
:::answer
The answer is $96$ km. The head start is $12\times 2=24$ km and the closing rate is $16-12=4$ kph, so the catch-up takes $24\div 4=6$ hours. The second cyclist rides $16\times 6=96$ km.
:::

## Examples

### #1: Catching Up After a Head Start

A motorcycle travels at a constant $70$ kph. A car behind it travels in the same direction along the same straight road at a constant $90$ kph. If the motorcycle has a $50$ km lead when the chase begins, how many hours will the car take to catch it?

**Solution:**

1. Subtract the speeds to find how fast the gap closes, in kph.

$$90-70=20$$

2. Let $t$ be the hours after the chase begins. Use $d=rt$ with the $50\text{ km}$ gap.

$$50=20t$$

:::try
Finish the last step: divide $50$ by $20$ to find how many hours the car takes.
:::answer
The answer is $2.5$ hours. Dividing $50\div 20=2.5$ gives $t=2.5$.
:::

## Speed Tricks & Shortcuts

When a chase problem asks for the **distance** from the chaser's starting point instead of the time, find the chase time $t$ first. Then multiply the chaser's speed by $t$, not by the total time including the head start.

For example, if the van drives at $60$ kph for $2$ hours to catch the jeepney, the catch-up distance from the terminal where the van started is $60\times 2=120$ km.

## Traps to Watch For

:::checklist
- Same-direction chase: subtract the slower speed from the faster speed, so $r_{\text{close}}=r_{\text{fast}}-r_{\text{slow}}$. {#add-speeds-in-chase}
- Moving target ahead: do not divide the gap by the chaser's speed alone, because the target keeps moving. {#use-only-chaser-speed}
- Starting the clock: check whether the question asks for chase time or total time since the first start. {#head-start-clock}
:::
