# Mock exam screens decision log

The round on the five mock surfaces the 28 July spec left undesigned. Chronological.
Later entries append; they never edit earlier ones.

---

## 4 August 2026: which of the five actually need drawing

**The round was told to answer this before drawing anything**, because the 28 July spec was
once treated as more open than it was and a round was lost to it. Checked against what already
exists rather than against the May sketches alone.

| Surface | Verdict | Why |
|---|---|---|
| **Mock history** | **Do not build** | Progress's "Your record" already carries a "Your mocks" panel, and that screen is already wholly Free and already about whether the student is improving. A separate history page is a second copy of it. The May sketch also wanted an emoji trend pill, and emoji are banned. |
| **Setup screen** | **Confirm, plus a copy pass** | The May sketch is already this app's shape: a heading, a short list of facts, one button. Two things changed under it: sectional timing is real now, so "sections at a glance" has content, and the existing copy uses banned punctuation. |
| **Strict forfeit** | **Mostly confirm** | What happens after a forfeit is already designed in the 28 July results screen. Only the moment itself was open. |
| **Section transition** | **Draw** | The only properly blank surface, and the one most likely to make a student feel cheated if handled badly. |
| **Warning overlays** | **Draw** | The May sketch uses a snackbar and a colored banner, and banners are not a device this app uses. Sectional timing also changes the meaning: five minutes left in this part is a different message from five minutes left in the paper. |

**So the round is two screens, one small pause state, a copy pass, and one thing struck**, not
five missing screens.

---

## 4 August 2026: strict mode decides whether a part can be ended early

### What was put to him on the plate

The section transition was drawn in two states: time called on the student, and the student
finishing early and asking to move on. **The open question was whether ending a part early
should be allowed at all.**

| Option | Cost |
|---|---|
| Allow it, forfeiting the unused minutes | Not what a real exam does. Removes dead time. |
| Forbid it, the part runs its clock | Matches the real exam exactly. A student who finishes with eight minutes left stares at a finished paper. |

**I recommended allowing it**, on the grounds that enforced waiting teaches nothing.

### What he decided, and it is better than either option

> "if in strict mode (remember this in Settings? i've mentioned this before somewhere) don't
> let them skip. and say so in the settings and the interface that they can't skip because
> they've enabled strict mode.
>
> if they don't have strict mode, then they can skip"

**Strict mode already exists** as a synced setting, and today it does exactly one thing: it
gates pause. **He is extending it to gate early advance as well**, which turns a single-purpose
toggle into a coherent promise: strict mode means the app behaves like the real room.

**Both my options were a single global rule. His is a rule the student already opted into**, so
neither group is patronised: whoever wants the real thing gets the real thing, and whoever does
not is not made to wait.

### What it obliges, and he named it himself

**It has to be said in two places, not one.** A restriction the student meets only when they hit
it is a bug from their side of the screen.

1. **In Settings**, where the toggle currently promises only that leaving the app submits the
   paper. That copy is now incomplete.
2. **In the paper**, at the moment the student would otherwise have moved on.

### Consequences recorded

- **With strict mode on, the early-finish confirmation does not exist.** Only the time-called
  transition remains.
- **The setup screen must state it before the paper starts**, alongside the sectional timing
  rule it already states.
- **The Settings row copy is now wrong by omission** and needs amending wherever that row is
  specified. It is not this spec's file, so it is an amendment rather than an edit here.

---

## 4 August 2026: two drawing faults he caught, in a row

**First.** The paper screen was drawn with three controls in the bottom bar when the spec names
five. The grid glyph and the flag were missing, and the app bar with its clock was left off the
screen entirely.

> "on the 3rd screen, i noticed you didn't add the other icons in the bottom navbar, there
> should be the flagging system and also the question grid. check the specs. is this intentional
> or did you make a mistake?"

**A mistake, not a choice.** All of it was already written down in Section 3 of the mock UI
spec, including the glyph's exact geometry, the 46px targets, and the optical correction that
gives the grid side five extra pixels of gap.

**Second, immediately after.**

> "actually make that all screens, you're just showing me part of the whole"

**Also right.** Every plate in this round had been a cropped fragment sized to its content, so
he was judging compositions without seeing where anything actually sat on a phone. A bar pinned
14px from the bottom means nothing when the device stops 40px below the content.

### What changed

All six surfaces are now drawn as complete 360 by 700 devices: Settings, setup, the paper mid
part, the paper at a part boundary, the early-finish confirmation, and the transition. Nothing
cropped, nothing omitted.

### The lesson, which is the same one as three times earlier today

**I drew from what I was thinking about rather than from what was written and from what a phone
actually is.** The bar's five controls were in the spec I had read an hour before. The cure both
times was to render the whole thing at real size instead of the part I was reasoning about.

**His standing instruction, now recorded so it binds every future plate:** *"render everything
down to the detail and how it would look as in a whole screen so i can see."*
