---
_id: "lesson-spatial-abstract-reasoning-paper-folding-and-cutting"
title: "Paper Folding and Cutting Rules"
summary: "Learn how to predict the pattern of holes that appear when a folded piece of paper is cut and then unfolded."
subject: "subject-reasoning"
topic: "topic-spatial-abstract-reasoning"
estimatedMinutes: 10
isActive: true
---
## Core Concept

**Paper folding and cutting** questions show a piece of paper being folded one or more times, then a hole (or notch) is cut somewhere on the folded shape. Your task is to predict what the paper looks like once unfolded back to its original flat shape.

The core rule: each fold creates a mirror line (a line of symmetry). When you cut through several layers of folded paper at once, unfolding reflects that cut across every fold line it passed through, multiplying the single cut into a symmetric pattern of holes.

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "notch", "at": "corner", "showUnfolded": true, "semanticsLabel": "A square of paper folded twice with a triangular notch cut near the corner, then unfolded to show four symmetric notches."} -->

**Counting the holes**: each fold doubles the number of layers the cut passes through. If the paper is folded $2$ times before cutting, the cut passes through $4$ layers, so unfolding reveals $4$ copies of that same cut, positioned symmetrically according to each fold. In general, folding $n$ times (where each fold is a distinct fold onto a new layer) creates $2^n$ layers, and one cut anywhere through all the layers produces $2^n$ holes when fully unfolded (as long as the cut passes through every layer).

**Predicting hole position, not just count**: each hole's position is the mirror image of the cut, reflected across each fold line it crosses. Work backwards one fold at a time: start from the cut on the folded paper, then "undo" the last fold made (reflecting the cut across that fold line to get two marks), then undo the fold before that (reflecting each of those two marks again, doubling to four marks), continuing until every fold has been undone.

## Examples

### #1: One Fold, One Cut

A square paper is folded exactly in half (vertically, left side onto right side). A small triangular notch is cut out of the folded edge, at the midpoint of the folded (right) edge. When unfolded, how many notches appear, and where?

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical"], "cut": "notch", "at": "on-fold", "showUnfolded": true, "semanticsLabel": "A square folded vertically with a notch cut on the folded edge, then opened to show one diamond-shaped hole on the fold line."} -->


**Solution:**
1. One fold means the cut passes through $2$ layers, so unfolding reveals $2^1 = 2$ notches.
2. The notch was cut at the fold's edge (the vertical center line of the original square), at the vertical midpoint.
3. Unfolding reflects the notch across the fold line: the two notches appear symmetrically on the left and right sides of the fold line, both at the same vertical midpoint height, forming a shape that straddles the center line.

### #2: Two Folds, One Cut

A square paper is folded in half vertically, then folded in half again horizontally (so it is now folded into a smaller quarter-square). A small circular hole is cut near the corner where all the folded edges meet (the very center of the original square, once unfolded). How many holes appear when fully unfolded, and where?

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "hole", "at": "fold-corner", "showUnfolded": true, "semanticsLabel": "A square folded twice with a hole cut at the all-folds corner, then opened to show one hole at the exact center."} -->


**Solution:**
1. Two folds mean the cut passes through $2^2 = 4$ layers, so unfolding reveals $4$ holes.
2. Since the cut is positioned at the center corner (where all folds meet), each of the $4$ layers corresponds to one of the $4$ quadrants of the original square.
3. Unfolding reveals $4$ small holes, one in each of the four quadrants, all positioned near the center of the original square (each hole mirrored close to the center point in its own quadrant).

### #3: Predicting Position with a Non-Central Cut

Using the same two-fold setup as Example 2 (folded into a quarter-square), a notch is cut this time along the outer edge of the folded paper (far from the center), rather than near the center corner. Where will the resulting holes appear when unfolded?

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal"], "cut": "notch", "at": "edge", "showUnfolded": true, "semanticsLabel": "A square folded twice with a notch cut on the outer edge, then opened to show four symmetric notches along the outside."} -->


**Solution:**
1. Since the cut is on the outer edge (far from the fold-meeting corner), reflecting it across both fold lines places the four resulting holes near the four outer edges of the original square, not near the center.
2. Specifically, each hole appears mirrored into its own quadrant, positioned along the edge that was farthest from the folds in that quadrant (matching the original outer-edge position of the cut).
3. This differs from Example 2 specifically in location (edges vs. center), even though both use the same $4$-hole count from two folds.

### #4: Counting Layers with Three Folds

A rectangular paper is folded in half three separate times (each fold halving it again). A cut is made through all the layers at once. How many holes appear when fully unfolded?

<!-- FIGURE: {"kind": "paper-fold", "folds": ["vertical", "horizontal", "vertical"], "cut": "hole", "at": "interior", "sheet": "rectangle", "showUnfolded": true, "semanticsLabel": "A rectangle folded three times with one cut through all eight layers, then opened to show eight evenly spaced holes."} -->


**Solution:**
1. Three folds mean $2^3 = 8$ layers are cut through simultaneously.
2. Unfolding reveals $8$ separate holes, one from each layer, each mirrored across the respective fold lines.

## Speed Tricks & Shortcuts

**Count the number of folds first, then compute $2^{\text{folds}}$ to predict the total number of holes**: this number check alone can eliminate answer choices with the wrong hole count before you even work out their exact positions.

**Work backwards one fold at a time, reflecting the cut across the most recent fold first**, then the fold before that, and so on: undoing folds in reverse order (last fold undone first) keeps the reflection steps organized and prevents mixing up which mirror line applies at each stage.

**Remember that a cut positioned exactly on a fold line typically becomes a single connected shape straddling that line once unfolded** (as in Example 1), while a cut positioned away from all fold lines becomes multiple separate holes, one per layer (as in Examples 2–4).

## Traps to Watch For

### #1: Forgetting That Layer Count Doubles with Each Additional Fold

> Each new fold doubles the number of layers a single cut passes through: the total hole count follows $2^{\text{folds}}$, not simply "one hole per fold."

Assuming $3$ folds produce only $3$ holes (instead of correctly calculating $2^3 = 8$) is a common miscounting error; always use the doubling relationship, not a simple one-to-one count.

### #2: Predicting the Wrong Number of Holes by Ignoring Where the Cut Is Positioned

> If the cut crosses a fold line directly (rather than sitting entirely within one folded layer's interior), unfolding may connect what would otherwise be separate holes into one continuous shape.

A cut placed precisely on a fold line (as in Example 1) does not simply create the "expected" number of fully separate holes: reflection across that specific fold line merges the cut into a single connected shape spanning both sides.

### #3: Reflecting the Cut's Position Incorrectly When Working Backwards

> Each "undo fold" step must reflect the cut's position across the correct fold line for that specific step: using the wrong fold line, or reflecting in the wrong order, produces holes in the wrong location even if the count is correct.

Getting the hole count right (matching $2^{\text{folds}}$) does not guarantee the positions are correct; always carefully re-trace which specific fold line governs each reflection step, working from the last fold made back to the first.
