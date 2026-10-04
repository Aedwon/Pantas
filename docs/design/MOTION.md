# Motion

Every animation on the boards was approved as drawn. This file explains how to read them and how to carry
them into Flutter without drift.

## Three kinds of boards

| Kind | How to tell | What to build |
|---|---|---|
| **Static** | `SCREENS.md` says "static". It may play a short entry animation once on open. | The entry animation as written, ending on the screen at rest. |
| **Looping** | `SCREENS.md` says "loops every Ns". There is a `Name_motion.png` with six frames. | One interaction, compressed into a loop: the finger taps, then the app reacts. Build from the start to the last change. The hold and the jump back are only there so the board replays. |
| **Step by step** | `SCREENS.md` lists "N steps". There are `Name_stepN.png` files. | A sequence of screens (a flow). Each step is a separate screen or state, and the step lengths are demo pacing, not timing to copy. The animations inside each step are real. |

On looping boards a gray circle grows and fades where a finger would tap. That is the finger, not UI.

## Reading the exact timing

```
python3 docs/design/tools/timeline.py docs/design/boards/ST_IncludedLast.html
```

prints, for every animated element, its label (its text, or its shape and the text around it), the
animation's length and curve, and each keyframe stop in absolute milliseconds:

```
■ <div>   (in: Algebra)
  STIncludedLast_n925  2400ms  linear  (loops)
          0ms  transform:none;[then ease-out]
        700ms  (holds) [then ease-out]
        760ms  transform:translateX(-5px);[then ease-out]
        820ms  transform:translateX(5px);[then ease-out]
        880ms  transform:translateX(-3px);[then ease-out]
        940ms  transform:translateX(3px);[then ease-out]
       1000ms  transform:none;[then ease-out]
```

`[then X]` is the curve used from that stop to the next. In this example the finger lands at 0–480ms, the
checkbox holds until 700ms and then shakes for 300ms. In Flutter that is a 300ms shake that starts when the tap
lands (the 700ms before it is the finger arriving in the demo). Measure timings from the tap, not from 0.

Use `--all` to print the values at holds as well.

## Curves

Map each CSS curve one to one; never swap in a named Flutter curve that looks close.

| CSS | Flutter | Used for |
|---|---|---|
| `cubic-bezier(.3,.9,.3,1)` | `Cubic(0.3, 0.9, 0.3, 1.0)` | The house ease-out: most moves, fills, rings, counters |
| `cubic-bezier(.2,.9,.3,1)` | `Cubic(0.2, 0.9, 0.3, 1.0)` | Content rising in (`fx-up`) |
| `cubic-bezier(.22,1,.36,1)`, `(.2,.8,.25,1)`, `(.2,1,.35,1)` | same values in `Cubic` | Slides and pushes |
| `cubic-bezier(.32,.72,0,1)` | `Cubic(0.32, 0.72, 0.0, 1.0)` | Bars and cards that grow or open from an edge |
| `cubic-bezier(.3,1.4,.5,1)`, `(.3,1.5,.5,1)`, `(.34,1.56,.64,1)` | same values in `Cubic` (Flutter allows y > 1) | Pops and checks with a little overshoot |
| `cubic-bezier(.6,0,.3,1)`, `(.36,.07,.19,.97)`, `(.15,.7,.35,1)` | same values in `Cubic` | Check draw, shake, confetti |
| `cubic-bezier(.45,0,.25,1)` | `Cubic(0.45, 0.0, 0.25, 1.0)` | Liquid, drains and tints (the exam switch) |
| `ease` / `ease-out` / `ease-in-out` / `linear` | `Cubic(0.25, 0.1, 0.25, 1.0)` / `Cubic(0.0, 0.0, 0.58, 1.0)` / `Cubic(0.42, 0.0, 0.58, 1.0)` / `Curves.linear` | Fades and small state changes |
| `steps(n)` | a stepped animation (`Tween<int>` over n steps) | Typing |

## Shared effects

These appear on many boards with the same meaning. Durations are the usual ones; the board is the authority.

| Name on boards | What it does | Usual timing |
|---|---|---|
| `fx-pop` | Scales in from 0.4 with a slight overshoot (checks, badges) | 400ms, `(.34,1.56,.64,1)` |
| `fx-up` | Rises 14px while fading in | 300–500ms, `(.2,.9,.3,1)` |
| `fx-gauge` | The half ring fills from empty | 1100ms, `(.3,.9,.3,1)` |
| `fx-draw` | A check mark draws on | 380ms, `(.6,0,.3,1)` |
| `fx-shake` | The "no" shake | 420ms, `(.36,.07,.19,.97)` (some boards draw their own; use theirs) |
| `fx-press` | A pressed button dips to 97% | 200ms, `ease` |
| `fx-ring` | A teal ring pulses out once from a tapped control | 700ms, `ease-out`, after 50ms |
| `fx-burst` | Confetti for a new best | 1100ms, `(.15,.7,.35,1)`, pieces staggered by up to 80ms |
| `fx-push` | A new value or page slides in from the right | 380ms, `(.2,.9,.3,1)` |
| `fx-collapse` | A row or notice closes its height and fades | 350ms, `ease` |
| `fx-fadein`, `fx-fadeout` | Plain fades | 150–300ms, `ease` |

Most motion on the boards is drawn per board rather than with these shared names, so always run
`tools/timeline.py` on the board itself.

Counting numbers (scores, percentages) count up with a cubic ease-out over the same length as their ring or
bar, and land on the final value exactly.

## Rules

1. The screen at rest is the last frame. With animations disabled (`MediaQuery.disableAnimationsOf`), jump
   straight to it.
2. Nothing loops in the app unless a board marks it as continuous (spinners, a live clock). Loops on the
   boards are for review only.
3. Keep the order and the overlaps. When one thing starts before another ends on a board, it does in the app too.
4. Show state changes in place (rings fill, checks pop, rows fold). Never fade or reload a whole screen to
   show a change.
5. Animate only what the board animates. Don't add page transitions, fades or hero moves that aren't drawn.
6. If something on a board can't be built as drawn, ask before simplifying it.
