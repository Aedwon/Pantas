# Figures drawn by the app, not by hand

**Date:** 13 August 2026
**Status:** Approved by Aedwon, 13 August
**Supersedes:** nothing. It sits beside
`2026-07-20-illustration-question-figures-design.md`, which stays for the figures
that still have to be drawn by a person.

---

## The problem, measured

**155 questions are parked because their picture does not exist.** They are the
whole of `content/illustrations/questions`, and none of them has ever reached a
student: the importer marks a figure-pending question inactive on purpose.

**They are not 155 different pictures. They are ten families of about fifteen.**

| Family | Questions | What the figure is |
|---|---|---|
| `gear-rotations` | 15 | A row or train of meshed gears |
| `springs-and-weights` | 15 | A spring, a hanging weight, sometimes two springs |
| `pulleys-and-levers` | 15 | A beam on a fulcrum, or a pulley and a load |
| `structural-stability` | 15 | A shape on a base, with its centre of gravity |
| `fluid-pressure` | 14 | A vessel, a level, a piston |
| `figure-series` | 14 | Three shapes that change by a rule |
| `figure-matrices` | 14 | A three by three grid with one cell blank |
| `figure-grouping` | 14 | Four shapes, one of which does not belong |
| `paper-folding-and-cutting` | 14 | A square folded, punched, unfolded |
| `mental-rotation-3d-visualization` | 14 | A solid seen from another angle |
| Geometry diagrams | 11 | Axes, a triangle, a circle with a radius |

**Every one is geometric or abstract. Not one is organic.** There is no cell, no
plant, no scene. That is what makes drawing them in code the right answer here,
and it is not a general claim about illustration.

---

## The decision

**The app draws these figures with `CustomPainter`.** No plugin: Flutter's canvas
is already a full 2D drawing surface, and the kit uses it for the contents glyph
and the pennant mark.

**A figure is data in the question file, not an image beside it.**

```yaml
    figure: gear-rotations-01
    figureSpec:
      kind: gear-train
      gears: 3
      firstTurns: clockwise
```

**Why the spec sits in the question and not in a separate file.** The stem
already describes the figure in words: "Figure shows three gears connected in a
row". A drawing that disagrees with that sentence is the worst failure available
here, because the question becomes unanswerable and nothing tests it. Keeping
both in one place means a reviewer reads them together. **A separate figure
file makes drift silent.**

---

## What this buys, and it is not only speed

- **Nothing to store and nothing to ship.** No PNGs, no asset entries, no size.
- **Sharp at any size**, and it follows the light and dark theme, which a flat
  image cannot.
- **A figure cannot go stale.** Change the question from three gears to five and
  the drawing changes with it.

## What it costs

- **Each family is real code**, and Aedwon has to look at each family once.
  **He approves the family, not every figure.**
- **The abstract puzzles are the hard ones.** Drawing a three by three matrix is
  easy. Deciding what belongs in the blank cell is the question itself, and it
  has to match the answer key exactly.
- **`mental-rotation-3d-visualization` may not be worth it.** It needs a
  projection and a solid, and fourteen questions is a thin return for that.
  **Try it last, and hand it back if it fights.**

---

## The rules a painter follows

1. **Ink and Rule.** Hairlines, no fills except where a fill is the meaning, no
   shadows, no rounded corners, no colour used as decoration. The figure is a
   diagram in a book, not an illustration.
2. **It reads in both themes.** Draw with the theme's ink and paper colours,
   never with hardcoded black or white.
3. **It never carries a letter that must match a choice.** Choices are
   reshuffled per student. Label parts with words or with the labels the stem
   uses.
4. **It never prints a figure this project did not measure.** A drawn scale is a
   drawing, not a measurement, so no axis carries a number the question did not
   state.
5. **It fails visibly.** An unknown `kind`, or a spec missing a field, draws a
   plain box saying the figure is missing. **Never draw something plausible from
   a bad spec.**

---

## What stays hand-made

Anything organic or pictorial: a cell, a plant, a person, a scene, a photograph.
**None of the 155 parked questions is one of those**, and the lesson
illustrations in `docs/content/illustrations/worklist.tsv` mostly are. The two
pipelines do not compete: this one takes the diagrams, the studio keeps the
pictures.

---

## Order of work

1. The spec field, carried through the pipeline the way `rationale` was.
2. The painter registry and the failure box.
3. `gear-rotations`, because its rule is the simplest to check by eye.
4. `springs-and-weights`, `pulleys-and-levers`, `structural-stability`,
   `fluid-pressure`.
5. The geometry diagrams.
6. The four abstract families.
7. `mental-rotation-3d-visualization`, or hand it back.

**A family is not done until its questions are active.** The importer marks a
figure-pending question inactive, and that flag is what has kept all 155 out of
the app.
