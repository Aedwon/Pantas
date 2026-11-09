---
_id: "lesson-mechanical-technical-reasoning-structural-stability"
title: "Structural Stability and Center of Gravity"
summary: "Learn to find the center of gravity and base of support, test when an object tips, and see why a turning vehicle needs a different explanation."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 14
isActive: true
---
## Core Concept

The **center of gravity** of an object is the point where its whole weight can be treated as acting. Near Earth's surface, gravity is almost the same over the whole object. So this point is also the **center of mass**, the balance point of the object's mass.

If the weight is spread evenly about the middle, the center of gravity is at the middle. A **uniform** object has the same material throughout. This holds for a uniform rectangle, circle, box or rod, and for a dumbbell with two equal weights.

A uniform flat triangle plate has it one-third of the way up from the base. If more weight lies on one side, like the head of a hammer, it lies nearer that side. It can even lie in empty space, like the middle of a ring.

The **base of support** is the region on the ground, or another surface, that is enclosed by the outer points where the object touches it. The region includes the empty space between those points. A table with four legs has a base shaped like the rectangle drawn through its four feet.

### Combining Parts

An object made of several parts fastened together has one center of gravity for the whole. Each part has its own mass $m$ in kilograms. Its position $x$ in meters is where its own center of gravity lies. Measure every position from the same zero point, along the same line.

For two parts, the combined position is:

$$x_{cg} = \dfrac{m_1x_1 + m_2x_2}{m_1 + m_2}$$

For three parts, add the third part's term to the top and its mass to the bottom. The result always lies between the parts' own positions. With two parts of unequal mass, it sits closer to the heavier part, and with equal masses it is the midpoint.

With more parts, the formula decides, so do not guess by the heaviest part. The same formula works for heights if you measure each position upward from the floor.

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "pyramid", "baseWidth": 3, "height": 1}, {"form": "pyramid", "baseWidth": 1, "height": 3, "tilt": 18}], "semanticsLabel": "A short wide object and a tall narrow object with center-of-gravity projections shown relative to their bases of support."} -->
### Static Tipping Test

Draw the **weight line**: a vertical line straight down from the center of gravity. Then compare it with the edge that decides whether the object tips.

On a level support (a flat, horizontal surface), compare the weight line with the base of support:

- if the weight line falls **inside** the base, gravity pulls the object back down;
- if it falls exactly on the **edge** of the base, the object is at the tipping threshold, the point where it is just about to tip;
- if it falls **outside** the edge and nothing holds the object, gravity turns it farther over and it tips.

If the object is tilted slowly, it touches the support only along the bottom edge it turns on, called the pivot edge. Compare the weight line with that pivot edge:

- if the weight line is still on the same side of the pivot edge as the object's own base, gravity turns the object back down;
- if it is exactly over the pivot edge, the object is at the tipping threshold;
- if it is past the pivot edge, on the far side from the object's base, gravity turns it farther over and it tips.

This test uses only the shape of the object and where its center of gravity sits. It does not say anything about sliding.

### How Far It Can Tilt

Tilt an object slowly about one bottom edge. Let $d$ be the sideways (horizontal) distance from the center of gravity to that edge. Let $h_c$ be the height of the center of gravity above the support. The object reaches the tipping threshold at the tilt angle $\theta$, where:

$$\tan\theta = \dfrac{d}{h_c}$$

For a uniform box with width $w$ and height $h$, $d = \dfrac{w}{2}$ and $h_c = \dfrac{h}{2}$. So $\tan\theta = \dfrac{w}{h}$. A cube tips at $45^\circ$.

A lower center of gravity gives a larger angle if the base stays the same. A wider base gives a larger angle if the center of gravity stays at the same height and in the middle of the base. A load that shifts the center of gravity toward one edge makes $d$ smaller on that side. That reduces the margin, though a wider base still widens it.

Here $\tan\theta$ (the **tangent**) is the opposite side divided by the adjacent side in a right triangle. In the triangle with legs $d$ and $h_c$, $d$ is opposite $\theta$ and $h_c$ is adjacent. To find the angle from a tangent value, press the $\tan^{-1}$ key on a calculator. The lesson Basic Trigonometric Ratios teaches the tangent.

The mass of the object does not appear in this formula. Where the mass sits does.

### Pushing an Object Over

A **torque** is the turning effect of a force about a pivot, the edge or point it turns about. Torque equals the force times the shortest distance from the pivot to the line along which the force acts. That distance is the **lever arm**, a length measured in meters. Torque is measured in newton-meters ($\text{N}\cdot\text{m}$).

Let a box rest on level ground, and push it sideways with a horizontal force $F$ at height $H$ above the ground. The bottom edge on the far side from the push is the pivot. The push turns the box over.

The weight $W$ turns it back, with the lever arm $d$ from above. The box tips when:

$$F \cdot H > W \cdot d$$

Weight is a force, the pull of gravity on the object, so it is measured in newtons (N). It is $W = mg$, where $m$ is the mass in kilograms and $g = 9.8$ m/s$^2$. The value $g = 9.8$ m/s$^2$ means that, with air ignored, a falling object's speed grows by $9.8$ meters per second each second.

This test assumes the box does not slide first. If the mass is spread the same way, an object of the same shape and size with more mass needs a bigger push to tip, even though its tilt angle is the same.

### Moving Objects

Everything above assumes the object is at rest, tilts slowly or moves at a steady speed in a straight line. A vehicle in a sharp turn is different, because its direction keeps changing. The road must push the tires sideways, toward the center of the turn. This push acts at road level, below the center of gravity.

The weight resists rolling over. The road's sideways push, acting below the center of gravity, is what tends to roll the vehicle toward the outside of the turn. More of the load moves onto the outside wheels.

If the inside wheels lift off the road, the vehicle is starting to roll over. The **track** is the distance between the left and right wheels. On a flat road, a lower center of gravity or a wider track usually lets the vehicle take a faster turn before this happens. A vertical weight line alone cannot explain it.

## Examples

### #1: Finding the Base of Support

A four-legged stool stands on a level floor. What is its base of support? What is the base if the stool is tilted until it rests on two legs only?

**Solution:**

1. The four feet touch the floor at four points.
2. The base is the whole square enclosed by those four points. It includes the floor between the legs.
3. On two legs, the only contact points are the two feet. The base shrinks to a thin strip along the line joining them.
4. The weight line must now land on that thin strip. A tiny shift of weight puts it outside, so the stool is very hard to hold.

<!-- ILLUSTRATION: a stool on a floor drawn twice, once on four legs with the square base of support shaded between the feet, and once tilted onto two legs with a thin line shaded between the two feet and the weight line marked -->
### #2: Locating the Center of Gravity

A uniform metal sheet is a rectangle $40$ cm long and $20$ cm wide. A uniform flat triangle plate has a base of $30$ cm and a height of $30$ cm. A uniform ring has an empty hole in the middle. Where is the center of gravity of each?

**Solution:**

1. The sheet has a center point. The center of gravity is $20$ cm from each short end and $10$ cm from each long side.
2. The triangle plate has it one-third of the way up from the base. That is $\dfrac{30}{3} = 10$ cm above the base, on the line from the middle of the base to the top corner.
3. The ring is the same on all sides. The center of gravity is at the middle of the ring.
4. That point is in the empty hole, so it lies outside the material.

<!-- ILLUSTRATION: three flat shapes with the center of gravity marked: a 40 cm by 20 cm rectangle with a dot 20 cm from each short end, a triangle plate with base 30 cm and height 30 cm with a dot 10 cm above the base, and a ring with a dot in the empty middle -->
### #3: Loads High or Low

A cabinet of mass $30$ kg is $1.2$ m tall. Its own center of gravity is $0.6$ m above the floor. It holds $90$ kg of books, centered side to side. The books' center of gravity is $0.2$ m up when they are on the bottom shelf, or $0.9$ m up when they are on the top shelf. Find the height of the combined center of gravity in each case. Which loading is harder to tip?

**Solution:**

1. Use the combined-position formula for heights, with the height called $y$. With the books low:

$$y = \dfrac{30(0.6) + 90(0.2)}{30 + 90} = \dfrac{36}{120} = 0.30 \text{ m}$$

2. With the books high:

$$y = \dfrac{30(0.6) + 90(0.9)}{30 + 90} = \dfrac{99}{120} = 0.825 \text{ m}$$

3. The base is the same in both cases, so $d$ is the same. A smaller $h_c$ gives a larger $\tan\theta$.
4. Books on the bottom shelf are harder to tip.

<!-- ILLUSTRATION: a tall cabinet 1.2 m high drawn twice, once with 90 kg of books on the bottom shelf and once on the top shelf, with a dot at 0.30 m and a dot at 0.825 m showing the combined center of gravity -->
### #4: A Load That Sticks Out

A crate has a base $1.0$ m wide and a mass of $40$ kg. Its center of gravity is $0.5$ m from the left edge. A $120$ kg load is fastened on top and sticks out to the right. The load's center of gravity is $1.3$ m from the left edge. Does the crate stay down?

**Solution:**

1. Measure from the left edge. The crate's base runs from $0$ to $1.0$ m.
2. Find the combined center of gravity:

$$x = \dfrac{40(0.5) + 120(1.3)}{40 + 120} = \dfrac{176}{160} = 1.1 \text{ m}$$

3. The weight line is at $1.1$ m, which is past the right edge at $1.0$ m.
4. It is outside the base, so the crate tips to the right.

<!-- ILLUSTRATION: a crate with a base 1.0 m wide from 0 to 1.0 m, a 120 kg load sticking out on the right, a dot at 1.1 m for the combined center of gravity, and a weight line landing past the right edge -->
### #5: Comparing Static Tipping

A short, wide uniform object and a tall, narrow uniform object have comparable shapes and material. Which is harder to tip slowly on a level surface?

**Solution:**

1. The short, wide object has both a lower center of gravity and a wider base.
2. So $d$ is larger and $h_c$ is smaller.
3. The tilt needed before the weight line passes the edge is larger.
4. It is **more steady** under the stated comparison.

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "pyramid", "baseWidth": 3, "height": 1}, {"form": "pyramid", "baseWidth": 1, "height": 3}], "semanticsLabel": "A short wide pyramid beside a tall narrow pyramid, each with its center of gravity marked, showing the short wide pyramid is more stable."} -->
### #6: Tipping a Box Slowly

A rectangular box is tilted slowly about one lower edge. When does it pass the tipping threshold?

**Solution:**

At the threshold, the vertical line through its center of gravity passes exactly over the pivot edge. Once the line moves past the pivot edge, gravity produces a torque that turns the box farther over.

<!-- FIGURE: {"kind": "stability-shape", "tilt": 22, "shapes": [{"form": "box", "baseWidth": 2, "height": 3}], "semanticsLabel": "A rectangular box tilted on one edge with a vertical plumb line dropped from its center of gravity, to compare with the pivot edge."} -->
### #7: Tipping Angle of a Box

A uniform box is $0.4$ m wide and $0.8$ m tall. It stands upright on a level floor. It is tilted slowly about one bottom edge. At what angle does it tip? What is the angle if it lies on its $0.8$ m side, so that it is $0.8$ m wide and $0.4$ m tall?

**Solution:**

1. Upright: $d = 0.2$ m and $h_c = 0.4$ m.
2. Use the tilt formula:

$$\tan\theta = \dfrac{0.2}{0.4} = 0.5 \quad\Rightarrow\quad \theta \approx 26.6^\circ$$

3. Lying down: $d = 0.4$ m and $h_c = 0.2$ m.

$$\tan\theta = \dfrac{0.4}{0.2} = 2 \quad\Rightarrow\quad \theta \approx 63.4^\circ$$

4. The box lying down needs a much larger tilt, so it is harder to tip.

<!-- ILLUSTRATION: a box 0.4 m wide and 0.8 m tall tilted about its bottom edge, with the angle 26.6 degrees at the edge, beside the same box lying on its side, 0.8 m wide and 0.4 m tall, with the angle 63.4 degrees -->
### #8: Where to Push a Crate

A uniform crate has a mass of $60$ kg, a width of $0.6$ m and a height of $1.2$ m. It rests on level ground. A person pushes it with a horizontal force. Find the smallest force that tips it, if the push is at the top edge, and if it is at the middle of the side. Assume the crate does not slide.

**Solution:**

1. The weight is $W = 60 \times 9.8 = 588$ N.
2. The center of gravity is in the middle of the crate, so $d = 0.3$ m. The holding torque is $W \cdot d = 588 \times 0.3 = 176.4$ N·m.
3. Push at the top, $H = 1.2$ m. The crate tips when $F \times 1.2 > 176.4$:

$$F > \dfrac{176.4}{1.2} = 147 \text{ N}$$

4. Push at the middle, $H = 0.6$ m:

$$F > \dfrac{176.4}{0.6} = 294 \text{ N}$$

5. The top push is twice as high, so it needs half the force.

<!-- ILLUSTRATION: a crate 0.6 m wide and 1.2 m tall with two arrows pointing sideways, one at the top edge at height 1.2 m labeled 147 N and one at the middle at height 0.6 m labeled 294 N -->
### #9: Cargo in a Turning Truck

The same truck carries the same mass of cargo either stacked high or secured lower in the vehicle. Which arrangement generally improves rollover resistance in a turn?

**Solution:**

The **lower cargo arrangement** improves rollover resistance.

1. It lowers the combined center of gravity.
2. In a turn, the sideways push from the road acts at road level.
3. A lower center of gravity makes the turning effect of that push on the truck smaller.
4. This is a moving case, so turning speed, track width, road slope and tire grip also matter.

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "truck", "baseWidth": 2, "height": 3}, {"form": "truck", "baseWidth": 2, "height": 1}], "semanticsLabel": "Two truck cargo profiles: one with cargo stacked tall giving a high center of gravity, and one with cargo spread low giving a low center of gravity."} -->
### #10: Wider Stance

A person stands first with feet close together, then with feet farther apart. Which stance gives a bigger base of support against a slow sideways push? Does it help against a push from the front?

**Solution:**

1. The wider stance gives a bigger base from side to side.
2. The weight line has more room to shift before it crosses the edge. So it improves steadiness against a sideways push.
3. The feet are no farther apart from front to back, so it does not help much against a push from the front.

<!-- FIGURE: {"kind": "stability-shape", "shapes": [{"form": "person", "baseWidth": 1, "height": 3}, {"form": "person", "baseWidth": 3, "height": 3}], "semanticsLabel": "Two stances comparing base of support width: feet close together with a narrow base, and feet spread wide with a wider, more stable base."} -->
## Speed Tricks & Shortcuts

**For slow problems, draw the weight line.** Drop a vertical line from the center of gravity and compare it with the edge of the base.

**Compare both center height and base width.** For similar uniform boxes, compare $\dfrac{w}{h}$: the larger ratio tips later. This works when the center of gravity stays in the middle of the base. If one factor improves and the other worsens, work out the ratio.

**Check whether the object speeds up, slows down or turns.** Turns, braking, impacts and vibration add forces that the weight line alone cannot show. Steady straight motion by itself adds none.

## Traps to Watch For

### #1: "The Center of Gravity Is Always at the Geometric Center"

> Spreading the weight evenly is one case that puts it at the geometric center.

A dumbbell with two equal weights is another. A hammer has it near the heavy head. Check how the weight is spread before you assume the middle.

### #2: "Heavier Means Harder to Tip"

> Mass alone does not change the tilt angle at which an object tips.

The angle depends on where the center of gravity is and how wide the base is. If its mass is spread the same way, an object of the same shape and size that is heavier does need a bigger push to tip. Heavy mass placed low also lowers the center of gravity.

### #3: Using the Weight Line Alone for a Turning Vehicle

> A vehicle in a turn has sideways forces from the road.

A lower center of gravity helps, but the full explanation involves those forces and the weight moving to the outside wheels.

### #4: "Lower or Wider Is Always Better"

> Each change helps only in the case it acts on.

Lowering the center of gravity makes the slow-tilt angle larger while the weight line is inside the base. It does not change the push that tips a box when the weight, the distance $d$ and the push height stay the same, and it cannot save a load whose weight line is already past the edge. A wider base widens the margin, but a fastened load that sticks out can still tip a wide crate unless the base reaches under the weight line.

### #5: Forgetting That Objects Can Slide

> The tipping tests do not predict sliding.

A smooth crate pushed low may slide before it tips. A truck on a wet road may skid before its wheels lift.
