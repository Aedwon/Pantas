---
_id: "lesson-algebra-motion-meeting-and-separation"
title: "Motion Problems (Meeting and Moving Apart)"
summary: "Use relative speed to find when objects meet or move apart."
subject: "subject-mathematics"
topic: "topic-algebra"
isActive: true
part: 2
partCount: 6
ordering: 66
keyPoints:
  - "Use distance equals rate times time with matching units."
  - "Add speeds when objects move in opposite directions, apart or toward each other."
---
## Core Concept

### Distance, Rate, and Time

**Rate** tells how much distance an object covers in each unit of time. **Kph** means kilometers per hour, and **km** means kilometers.

At a steady speed, distance equals rate times time:

$$d=rt$$

Here $d$ is distance, $r$ is rate, and $t$ is time. Divide to solve for time or rate:

$$t=\dfrac{d}{r},\qquad r=\dfrac{d}{t}$$

Keep the units matched: a rate in kph needs distance in km and time in hours. For a multi-part trip, find each part's time first. Then divide total distance by total time to get the **average speed** for the whole trip.

A van drives $60\text{ km}$ out at $30\text{ kph}$ and the same $60\text{ km}$ back at $60\text{ kph}$. Find its average speed for the round trip.

$$\dfrac{60}{30}=2\text{ hours out},\qquad \dfrac{60}{60}=1\text{ hour back}$$

$$\dfrac{60+60}{2+1}=\dfrac{120}{3}=40\text{ kph}$$

Averaging $30$ and $60$ to get $45$ kph is wrong, because the van spends more time at the slower speed.

Find the trip time. A tricycle drives $45\text{ km}$ at a steady speed of $30\text{ kph}$.

$$t=\dfrac{45}{30}=1.5$$

The trip takes $1.5$ hours.

:::pair #speed-over-distance
Right: $t=\dfrac{45}{30}=1.5$ hours
Wrong: $t=\dfrac{30}{45}\approx 0.67$ hours
The wrong line divided speed by distance. To find time, put distance on top: $\text{km}\div\text{kph}$ leaves hours.
:::

### Adding Speeds When Moving Apart or Meeting

When two objects move at steady speeds along the same straight path, **relative speed** tells how fast the gap between them changes.

Add the two speeds only when the objects move in opposite directions along the same line, in both of these cases:

1. Moving apart from the same starting spot in opposite directions.
2. Moving toward each other from opposite ends of a starting gap.

If they move the same direction, the gap changes at the faster speed minus the slower speed. For $35$ kph and $25$ kph, that is $35-25=10$ kph. The gap grows if the faster object is ahead and shrinks if it is behind.

Use the combined speed as $r$ in $d=rt$ only for the time both objects move. There are two gaps to tell apart: the gap already open when the second object starts, and the final gap. For moving apart from the same spot, $d$ is the final gap minus the gap already open. For meeting, $d$ is the gap at the moment the second object starts.

For example, two boats leave the same port in opposite directions. The $25$ kph boat starts one hour before the $35$ kph boat, so $25$ km is already open when the second boat starts. If the final gap is $85$ km, then $d=85-25=60$ km. The two boats open that $60$ km at $60$ kph, which takes $1$ shared hour.

Find when two boats are $180\text{ km}$ apart. They leave the same port at the same time in opposite directions, at $25\text{ kph}$ and $35\text{ kph}$.

$$25+35=60$$

<!-- ILLUSTRATION: two horizontal straight-road diagrams stacked. The top one, "Moving apart", has a center dot with two arrows pointing opposite ways: the left arrow is labeled "25 kph" and the right arrow "35 kph". A bracket beneath is labeled "gap grows at 25 + 35 = 60 kph". The bottom one, "Meeting", has two dots at the ends of a segment labeled "starting gap" with arrows pointing toward each other: the left arrow is labeled "speed 1" and the right arrow "speed 2". A bracket beneath is labeled "gap closes at speed 1 + speed 2". -->

Let $t$ be the hours after leaving. Use $d=rt$ with the $180$ km gap and the $60$ kph separation rate:

$$180=60t$$

$$t=\dfrac{180}{60}=3$$

The boats are $180\text{ km}$ apart after $3$ hours.

:::why
Why do the speeds add? In $1$ hour, the first boat travels $25\text{ km}$ one way and the second boat travels $35\text{ km}$ the other way. Their distance apart grows by $25+35=60\text{ km}$ every hour.
:::

:::pair #subtract-instead-of-add
Right: $25+35=60$ kph, so $t=\dfrac{180}{60}=3$ hours
Wrong: $35-25=10$ kph, so $t=\dfrac{180}{10}=18$ hours
Subtracting speeds is for objects moving the same direction. When two objects move in opposite directions along the same line, both change the gap, so add their speeds.
:::

:::pair #average-speeds-mistake
Right: combined rate $=25+35=60$ kph, so $t=\dfrac{180}{60}=3$ hours
Wrong: average rate $=\dfrac{25+35}{2}=30$ kph, so $t=\dfrac{180}{30}=6$ hours
Both boats move at the same time, so do not average their speeds. Add both speeds to get the full rate at which the gap grows.
:::

:::check
Two runners start $24\text{ km}$ apart on the same straight road at the same time and run toward each other at steady speeds of $5\text{ kph}$ and $7\text{ kph}$. How many hours until they meet?
:::answer
The answer is $2$ hours. Add their speeds to get $5+7=12$ kph, then divide $24\div 12=2$.
:::

## Examples

### #1: Moving Apart in Opposite Directions

Two cars leave the same gas station at the same time. They drive in opposite directions along a straight road at constant speeds of $60$ kph and $80$ kph. After how many hours will they be $350$ km apart?

**Solution:**

1. Add the speeds to find how fast the gap grows, in kph.

$$60+80=140$$

2. Let $t$ be the hours after departure. Use $d=rt$ with the final gap $d=350$.

$$350=140t$$

3. Divide both sides by $140$.

$$t=\dfrac{350}{140}=2.5$$

They will be $350$ km apart after $2.5$ hours.

### #2: Moving Toward Each Other

Town A and Town B are $270$ km apart on a straight road. Two buses leave the towns at the same time and travel toward each other. The bus from A goes at a constant $50$ kph and the bus from B at $40$ kph. How far from Town A do they meet?

**Solution:**

1. Add the speeds to find how fast the gap closes, in kph.

$$50+40=90$$

2. Let $t$ be the hours until they meet. They must close the full $270\text{ km}$ gap.

$$270=90t$$

3. Divide both sides by $90$.

$$t=\dfrac{270}{90}=3$$

:::try
Finish the last step: the bus from Town A drives for $t=3$ hours at $50$ kph. Find how far from Town A the buses meet.
:::answer
The answer is $150\text{ km}$. Use $d=rt$: $50\times 3=150$.
:::

## Traps to Watch For

:::checklist
- Finding time from distance and speed: divide distance by rate, so $t=\dfrac{d}{r}$. {#speed-over-distance}
- Moving apart or toward each other in opposite directions while both move: add both speeds to get the relative speed. {#subtract-instead-of-add}
- Two objects moving in opposite directions along the same line: use the sum of their speeds, not their average. {#average-speeds-mistake}
:::
