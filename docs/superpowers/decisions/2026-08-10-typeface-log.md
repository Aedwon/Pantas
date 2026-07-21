# The serif is retired

**10 August 2026.** Reading lessons on the device, Aedwon raised the typeface
for the first time since the identity was set.

> *"in retrospect and upon observing, the serif font doesn't look clean in the
> app. can we use something else? how about using the same font everywhere? or
> using an Apple font?"*

---

## What the survey found before any option was drawn

**The Apple option does not exist.** SF Pro and New York are licensed to Apple
platforms. Neither can ship on Android at any price.

**The serif was not only doing headlines.** It ran down to **14px bold** for
small titles and section headings. 14 to 16 is where a serif fills in on a
phone, so part of the complaint was a serif used where no serif is good, which
is a different problem from the serif being wrong.

## The three options, shown side by side in the visual companion

`type-three-ways.html`: three phones, the same screen on all three at once,
switchable between the lesson, Home and the quiz, and between paper and dark.
Real fonts, real content from the probability lesson, the app's exact type
scale and palette.

| | Option | Cost |
|---|---|---|
| **A** | **Keep the serif, stop using it small.** Serif at 18 and up, sans at 16 and under | One afternoon, no new font, no licence. **Answers nothing if he dislikes the serif itself** |
| **B** | **Literata**, a serif drawn for reading small on screens | ~300KB and a pass over every screen. Identity intact |
| **C** | **One font everywhere.** The sans, on everything | Least work of the three. **Spends the identity**: the serif is most of what makes Ink and Rule read as a printed page |

**I recommended A**, on the grounds that it isolates the real problem cheaply,
and I argued explicitly against C as the option that makes Pantas look like
every other study app.

## He chose C, and the reasoning beat mine

> *"let's go with one font everywhere. while the argument for Ink & Rule
> regarding serif use is sound, it defeats the purpose of having a clean and
> not-so-trendy look like the current flood of apps, which is that it's
> distraction free - this is because we want learners to focus on the content
> itself and have a good time learning. however, for me, the serif fonts are an
> eyesore, so that defeats an even more fundamental purpose of the app. still,
> while I chose this, I still hate vibe-coded AI slop signs, so consider that."*

**What I had wrong.** I defended the serif as the identity, treating the
identity as the end. He pointed out it was always a means: the printed page was
chosen because it is quiet, and quiet exists so a student attends to the
content. **A typeface that irritates the reader fails that test more
completely than a missing serif does.** The means cannot outrank the end it
was adopted for.

## What was done

- Every type role moves to Source Sans 3. **15 roles, 27 references, 13 files.**
- **The serif is removed from the bundle** and its files deleted, so nothing can
  silently fall back to the platform default later. A test walks every role and
  fails if one points at a family that is not there.
- **Display sizes are tracked tighter** (28px to -0.5, 24px to -0.4, 22px to
  -0.35). With one family, size and weight are the only things separating a
  heading from a paragraph, and default tracking at large sizes is most of what
  makes a screen read as typed rather than set.

## His last sentence is the standing constraint

> *"I still hate vibe-coded AI slop signs, so consider that."*

**With the serif gone, nothing about the letterforms distinguishes this app.**
What carries the identity now is everything else, and it all matters more than
it did yesterday: the hairline rules, the underlined section heads, the tabular
figures, the absence of tinted callouts, rounded cards and drop shadows. Those
were already rules; they are now the whole of it.

**Left open, and worth a look on the device before deciding:**

- **Small headings are 700 weight**, which was set when they were also a
  different family. At 14 and 15px, sans at 700 beside sans at 400 may read as
  shouting rather than as hierarchy. A 600 would give the scale three weights
  instead of two. **Not changed**: it touches every screen and he is testing.
- **Formulas will now be the only serif left on screen.** The maths renderer
  sets LaTeX in its own fonts, which are serif because that is how maths is
  typeset everywhere. It is a convention rather than a leftover, but he will
  see it and should decide whether it reads as deliberate.
