---
_id: "lesson-mechanical-technical-reasoning-pulleys-and-levers"
title: "Pulleys and Levers (Mechanical Advantage, Balance, Fulcrums)"
summary: "Learn how pulleys and levers make work easier and how to determine balance points and force requirements."
subject: "subject-reasoning"
topic: "topic-mechanical-technical-reasoning"
estimatedMinutes: 11
isActive: true
---
## Core Concept

**Pulleys** and **levers** are simple machines that provide **mechanical advantage**: they let you apply less force to move or lift a load, usually by trading that reduced force for moving a greater distance (you rarely get something for nothing: you save force but must pull or push farther).

### Pulleys

A single fixed pulley (attached to a stationary point, like a ceiling beam) simply changes the direction of your pulling force (pull down to lift up), without reducing the force needed: you still need to pull with a force equal to the load's weight.

A movable pulley (attached directly to the load itself, moving along with it) does reduce the force needed: with one movable pulley, you only need half the force of the load's weight to lift it, though you must pull the rope twice as far. Adding more movable pulleys further reduces the required force: with $2$ movable pulleys working together, you need only one-quarter the load's weight in pulling force (but must pull four times the distance).

<!-- FIGURE: {"kind": "pulley-system", "fixed": 1, "movable": 1, "semanticsLabel": "Two pulley setups side by side: a single fixed pulley requiring full force, and a movable pulley requiring half the force but twice the rope length."} -->

### Levers and Fulcrums

A **lever** is a rigid bar that pivots around a fixed point called the **fulcrum**. Levers balance according to a simple rule: the force needed on one side times its distance from the fulcrum must equal the load's weight times its distance from the fulcrum.

$$\text{effort} \times \text{effort distance} = \text{load} \times \text{load distance}$$

This means moving the fulcrum closer to the load (making the load's distance shorter, and the effort's distance longer) requires less effort force to lift the same load: this is why longer levers (or fulcrums placed closer to the heavy end) make lifting easier.

## Examples

### #1: Fixed Pulley Force

A fixed pulley is used to lift a $50 \text{ kg}$ load. How much pulling force is required, and does the direction of pulling matter?

<!-- FIGURE: {"kind": "pulley-system", "fixed": 1, "movable": 0, "semanticsLabel": "A single fixed pulley attached to an overhead beam, lifting a 50 kg load with a downward pulling force of 50 kg."} -->


**Solution:**
1. A fixed pulley only changes the direction of the force; it does not reduce the amount of force needed.
2. The pulling force required still equals the load's weight: $50 \text{ kg}$ worth of force (or its equivalent in newtons).
3. Yes, the direction changes (you can pull down to lift the load up), but the force magnitude needed stays the same as the load's weight.

### #2: Movable Pulley Force Reduction

A movable pulley is used to lift a $60 \text{ kg}$ load. How much pulling force is required, and how far must the rope be pulled to lift the load by $2$ meters?

<!-- FIGURE: {"kind": "pulley-system", "fixed": 1, "movable": 1, "semanticsLabel": "A movable pulley attached to a 60 kg load supported by two strands, requiring 30 kg of pull force and 4 meters of rope pulled for a 2-meter lift."} -->


**Solution:**
1. A single movable pulley halves the force needed compared to the load's weight.
2. Required force: $60 \div 2 = 30 \text{ kg}$ worth of force.
3. Since force is halved, the rope must be pulled twice as far as the load actually moves: to lift the load $2$ meters, you must pull $2 \times 2 = 4$ meters of rope.

### #3: Lever Balance Problem

A lever has a load of $100 \text{ kg}$ placed $2$ meters from the fulcrum. How much effort force is needed if applied $5$ meters from the fulcrum on the other side?

<!-- FIGURE: {"kind": "lever-balance", "loadDistance": 2, "effortDistance": 5, "semanticsLabel": "A lever on a triangular fulcrum with a 100 kg load 2 meters from the fulcrum on the left and 40 kg effort applied 5 meters on the right."} -->


**Solution:**
1. Apply the lever balance formula: effort $\times$ effort distance = load $\times$ load distance.

$$\text{effort} \times 5 = 100 \times 2$$

2. Compute the right side.

$$\text{effort} \times 5 = 200$$

3. Divide both sides by $5$.

$$\text{effort} = 40 \text{ kg}$$

4. Only $40 \text{ kg}$ of effort force is needed to balance the $100 \text{ kg}$ load, since the effort is applied farther from the fulcrum.

### #4: Moving the Fulcrum to Reduce Effort

Using the same $100 \text{ kg}$ load, if the fulcrum is moved so the load is now only $1$ meter from the fulcrum (while the effort distance stays at $5$ meters), how does the required effort change compared to Example 3?

<!-- FIGURE: {"kind": "lever-balance", "loadDistance": 1, "effortDistance": 5, "semanticsLabel": "A lever on a triangular fulcrum with a 100 kg load moved to 1 meter from the fulcrum and effort applied 5 meters away, requiring 20 kg of effort."} -->


**Solution:**
1. Reapply the balance formula with the new load distance.

$$\text{effort} \times 5 = 100 \times 1$$

2. Compute the right side.

$$\text{effort} \times 5 = 100$$

3. Divide by $5$.

$$\text{effort} = 20 \text{ kg}$$

4. Moving the fulcrum closer to the load (reducing its distance from $2$ meters to $1$ meter) reduced the required effort from $40 \text{ kg}$ down to $20 \text{ kg}$, confirming that a fulcrum positioned closer to the load makes lifting easier.

## Speed Tricks & Shortcuts

**For pulleys, count the number of movable pulleys (not fixed ones) to determine the force reduction.** Each movable pulley halves the required force again: $1$ movable pulley needs half the force, $2$ movable pulleys need a quarter, and so on, but the rope-pulling distance increases by that same multiplying factor.

**For levers, remember the balance equation works like a seesaw: bigger distance needs smaller force, and smaller distance needs bigger force**, for the same balancing effect. Cross-multiply the given values directly using the effort-times-distance formula.

**A fulcrum moved closer to the load makes lifting easier (less effort needed); moved farther from the load makes lifting harder (more effort needed).**

## Traps to Watch For

### #1: Assuming All Pulleys Reduce Force

> Only movable pulleys (attached to the load) reduce the required force. Fixed pulleys (attached to a stationary point) only change the direction of the force, not its magnitude.

Assuming a single fixed pulley "makes lifting easier" in terms of force is incorrect: it only makes lifting more convenient by letting you pull in a different direction, while still requiring the full weight's worth of force.

### #2: Forgetting the Trade-Off Between Force and Distance

> Simple machines like pulleys and levers reduce the force needed but always require moving (or pulling) a correspondingly greater distance: you cannot reduce force without some distance trade-off.

A movable pulley halving the required force also doubles the rope distance you must pull; forgetting this trade-off leads to an incomplete understanding of the mechanical advantage being gained.

### #3: Mixing Up Which Side of the Lever Equation Gets Multiplied

> Keep effort paired with its own distance, and load paired with its own distance: do not cross-pair effort's force with the load's distance (or vice versa) when setting up the balance equation.

Writing "effort $\times$ load distance = load $\times$ effort distance" (reversing the pairings) produces an entirely different, incorrect equation compared to the correct "effort $\times$ effort distance = load $\times$ load distance."
