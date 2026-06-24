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
