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
  - "Add speeds when objects move apart or toward each other."
---
## Core Concept

### Distance, Rate, and Time

**Rate** tells how much distance an object covers in each unit of time. **Kph** means kilometers per hour, and **km** means kilometers.

Distance equals rate times time:

$$d=rt$$

Here $d$ is distance, $r$ is rate, and $t$ is time. Divide to solve for time or rate:

$$t=\dfrac{d}{r},\qquad r=\dfrac{d}{t}$$

Keep the units matched: a rate in kph needs distance in km and time in hours. For a multi-part trip, find total distance and total time first, then divide total distance by total time to get the constant speed for the whole trip.

Try this example. A tricycle drives $45\text{ km}$ at a steady speed of $30\text{ kph}$.

$$t=\dfrac{45}{30}=1.5$$

The trip takes $1.5$ hours.

:::pair #speed-over-distance
Right: $t=\dfrac{45}{30}=1.5$ hours
Wrong: $t=\dfrac{30}{45}\approx 0.67$ hours
The wrong line divided speed by distance. Always put distance on top: $\text{km}\div\text{kph}$ leaves hours.
:::

:::check
A bus travels at a steady speed of $40\text{ kph}$ for $3.5$ hours. How many kilometers does it cover?
:::answer
The answer is $140\text{ km}$. Multiply speed by time: $d=40\times 3.5=140$.

**Check:** Divide back: $\dfrac{140}{40}=3.5$ hours.
:::

### Adding Speeds When Moving Apart or Meeting

When two objects move at steady speeds along the same straight path, **relative speed** tells how fast the gap between them changes.

Add the two speeds in both of these cases:

1. Moving apart from the same starting spot in opposite directions.
2. Moving toward each other from opposite ends of a starting gap.

<!-- FIGURE WANTED: two horizontal straight-road diagrams stacked. Top labeled "Moving apart": a center dot with two arrows pointing opposite ways, left arrow labeled "25 kph", right arrow labeled "35 kph", bracket beneath labeled "gap grows at 25 + 35 = 60 kph". Bottom labeled "Meeting": two dots at ends of a 270 km segment with arrows pointing inward, left arrow "50 kph", right arrow "40 kph", bracket labeled "gap closes at 50 + 40 = 90 kph" -->

Use that combined speed as $r$ in $d=rt$. For moving apart, $d$ is the final gap. For meeting, $d$ is the starting gap.

Try this example. Two boats leave the same port at the same time in opposite directions at $25\text{ kph}$ and $35\text{ kph}$. How many hours until they are $180\text{ km}$ apart?

$$25+35=60$$

$$180=60t$$

$$t=\dfrac{180}{60}=3$$

They are $180\text{ km}$ apart after $3$ hours.

:::why
Why do the speeds add? In $1$ hour, the first boat travels $25\text{ km}$ one way and the second boat travels $35\text{ km}$ the other way. Their distance apart grows by $25+35=60\text{ km}$ every hour.
:::

:::pair #subtract-instead-of-add
Right: $25+35=60$ kph, so $t=\dfrac{180}{60}=3$ hours
Wrong: $35-25=10$ kph, so $t=\dfrac{180}{10}=18$ hours
Subtracting speeds is for a same-direction chase. When objects move apart or toward each other, both contribute to changing the gap, so add their speeds.
:::

:::pair #average-speeds-mistake
Right: combined rate $=25+35=60$ kph, so $t=\dfrac{180}{60}=3$ hours
Wrong: average rate $=\dfrac{25+35}{2}=30$ kph, so $t=\dfrac{180}{30}=6$ hours
Both boats move at the same time, so do not average their speeds. Add both speeds to get the full rate at which the gap grows.
:::

:::check
Two runners start $24\text{ km}$ apart and run toward each other at $5\text{ kph}$ and $7\text{ kph}$. How many hours until they meet?
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

**Check:** In $2.5$ hours, the first car drives $60\times 2.5=150$ km and the second drives $80\times 2.5=200$ km. In opposite directions, $150+200=350$ km.

### #2: Moving Toward Each Other

Two towns are $270$ km apart on a straight road. Two buses leave the towns at the same time and travel toward each other at constant speeds of $50$ kph and $40$ kph. After how many hours will they meet?

**Solution:**

1. Add the speeds to find how fast the gap closes, in kph.

$$50+40=90$$

2. Let $t$ be the hours until they meet. They must close the full $270\text{ km}$ gap.

$$270=90t$$

:::try
Finish the last step: divide $270$ by $90$ to find $t$.
:::answer
The answer is $3$ hours. Dividing $270\div 90=3$ gives $t=3$.

**Check:** In $3$ hours, the buses travel $50\times 3=150$ km and $40\times 3=120$ km. Together they cover $150+120=270$ km.
:::

## Traps to Watch For

:::checklist
- Finding time from distance and speed: divide distance by rate, so $t=\dfrac{d}{r}$. {#speed-over-distance}
- Moving apart or toward each other: add both speeds to get the relative speed. {#subtract-instead-of-add}
- Two objects changing the same gap: use the sum of their speeds, never their average. {#average-speeds-mistake}
:::
