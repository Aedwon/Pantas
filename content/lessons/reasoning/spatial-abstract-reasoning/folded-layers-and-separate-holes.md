---
_id: "lesson-spatial-abstract-reasoning-folded-layers-and-separate-holes"
title: "Folded Layers and Separate Holes"
summary: "Count separate holes only when the punch reaches all doubled layers."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
isActive: true
part: 3
partCount: 4
ordering: 13
keyPoints:
  - "Count separate holes only when the punch reaches all doubled layers."
---
## Core Concept

### Doubling Layers with Complete Half-Folds

A **layer** is one thickness of paper. Each complete half-fold folds the whole packet in two, so it **doubles** the number of layers at every spot:

- $1$ half-fold: $2$ layers
- $2$ half-folds: $2\times2=4$ layers
- $3$ half-folds: $2\times2\times2=8$ layers
- $n$ half-folds: $2^n$ layers

<!-- ILLUSTRATION: square folded left half onto right half, then bottom half onto top half; show an interior punch away from both folded edges and arrows opening the horizontal fold first, then the vertical fold, ending with four mirror-position holes -->

1. Look at the $2$-fold square above: $2$ half-folds make $2\times2=4$ layers.
2. Punch $1$ small interior hole through all $4$ layers, away from both creases.
3. Open the horizontal fold ($1\times2=2$ holes), then open the vertical fold ($2\times2=4$ holes).

:::why
Why do $3$ half-folds make $8$ layers instead of $6$? Each fold doubles all layers already in the stack, so the count goes $1 \to 2 \to 4 \to 8$, not $2+2+2$.
:::

:::pair #multiply-folds-by-two
Right: $3$ complete half-folds with an interior punch through all layers make $2\times2\times2=8$ (**Eight holes**).
Wrong: pick **Six holes** by multiplying $3\times2$.
Half-folds multiply the layer count by $2$ at every fold, rather than adding $2$ each time. Multiply $2\times2\times2$, not $3\times2$.
:::

:::check
A rectangular sheet is folded completely in half $4$ times and punched once through all layers, away from every crease and edge. How many separate holes appear when opened?
:::answer
The answer is **$16$ holes**. Four complete half-folds double the layers four times: $2\times2\times2\times2=16$.
:::

### Checking the Two Conditions and Partial Unfolding

Before using $2^n$ for separate holes, verify **both** conditions:

1. The punch goes all the way through **all** $2^n$ layers (not just the top layer).
2. The punch stays **away from every crease** and outer edge (otherwise copies join into fewer openings).

Also read carefully if a question asks you to open **only the last fold**. Opening $1$ fold from a $4$-layer packet doubles the $1$ punch into **$2$ visible hole locations** in the still-folded sheet, not $4$.

:::pair #count-uncut-layers
Right: an $8$-layer packet gives $8$ separate openings only when **All layers cut; no crease touched**.
Wrong: pick **It cuts only the uppermost layer** because the folded packet has $8$ layers.
An uncut lower layer cannot gain a hole when unfolded. Check both cut depth and crease clearance before multiplying.
:::

:::pair #open-all-folds-early
Right: after opening only the horizontal fold of a $2$-fold paper, there are **Two locations** visible.
Wrong: pick **Four locations** by unfolding the whole sheet mentally.
Stopping after $1$ fold reflects the punch across only that $1$ crease. Count visible spots for the exact step asked.
:::

:::check
A square has $2$ complete half-folds ($4$ layers) and an interior punch through all $4$ layers away from every crease. If you open only the last fold and keep the first fold closed, how many holes do you see?
:::answer
The answer is **$2$ holes**. Opening only the last fold doubles the single punch once across that crease, while the first fold still holds $2$ layers together at each spot.
:::

## Examples

### #1: Interior Hole Away from Two Fold Lines

A square is folded vertically in half, then horizontally in half. A small circular hole is punched through all $4$ layers, away from both folds and all outside edges. How many separate holes appear after unfolding?

<!-- ILLUSTRATION: square folded left onto right, then bottom onto top; small circular punch inside packet away from every edge; opening horizontal fold gives two holes, opening vertical fold gives four holes in mirror positions -->

**Solution:**

1. Check the two conditions: the punch pierces all $4$ layers and touches neither fold line nor any outside edge.
2. Open the horizontal fold first: $1$ punch reflects to **$2$ separate holes**.
3. Open the vertical fold second: those $2$ holes reflect across the vertical crease to **$4$ separate holes**.

The open sheet has **$4$ separate holes**.

**Check:** Two complete half-folds make $2^2=4$ layers, and since no crease is touched, all $4$ pierced layers stay separate holes.

### #2: Three Folds, Interior Punch

A rectangular sheet is folded in half $3$ times: left onto right, bottom onto top, then left onto right again. A small circular punch passes through all $8$ layers, away from every fold and outside edge. How many separate holes appear?

<!-- ILLUSTRATION: rectangle folded left onto right, bottom onto top, then left onto right; small circular interior punch through all eight layers away from all edges; unfold in reverse order to show eight holes in mirror positions, without implying equal spacing -->

**Solution:**

1. Check both conditions: the punch crosses all $8$ layers made by $3$ complete half-folds, and it touches no crease or outside edge.
2. Since every fold doubles the separate copies when opened, multiply $2$ by itself $3$ times.

:::try
Finish the last step: compute $2^3$ to find how many separate holes appear on the fully opened rectangle.
:::answer
The answer is **$8$ separate holes**. Three doublings give $2^3=2\times2\times2=8$ holes.

**Check:** Do not multiply $3\times2=6$; opening the last vertical fold gives $2$ holes, opening the horizontal fold doubles $2$ to $4$, and opening the first vertical fold doubles $4$ to $8$.
:::

## Speed Tricks & Shortcuts

When a sheet has $n$ complete half-folds and an interior punch away from every fold, skip drawing each reflection step: check that all $2^n$ layers are cut, then compute $2^n$ directly. For $4$ folds, $2^4=16$ holes.

## Traps to Watch For

:::checklist
- Three or more complete half-folds: multiply $2$ for each fold ($2^3=8$), never folds times $2$. {#multiply-folds-by-two}
- Using the $2^n$ shortcut: confirm all layers are cut and no crease is touched before multiplying. {#count-uncut-layers}
- Partial unfolding questions: double once per opened fold instead of jumping to all layers. {#open-all-folds-early}
:::
