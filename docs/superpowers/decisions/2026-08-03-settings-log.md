# Settings redesign, decision log

Started 3 August 2026. Brief: `docs/superpowers/2026-08-03-settings-brainstorm-brief.md`.
Written as we go. Later entries append; they never edit earlier ones.

---

## Round 1, 3 August: the whole surface, and five decisions

Put to him first in the terminal as a drawn inventory plus five questions, then, at his
request, as a visual companion plate: `settings-round-1.html`. He asked for a plate he
could select on and comment per question, with a note on the whole.

**What I got wrong before the plate went up.** The terminal draw used all-caps group
headings. `lib/core/ui/components/section_header.dart` says serif, never boxed, never
all-caps. The plate corrected it to serif sentence case.

**A tooling fact worth recording**, because it cost a round trip. The companion server
appends an event to `state/events` **only when the event carries a `choice` field**
(`server.cjs:513`). Free-text notes have no `choice`, so they exist only in
`state/server.log`. I read `events`, saw no notes, and told him his notes had not come
through. They had. Read `server.log`.

### Question 1: what is the top level for?

| Option | What it is | Cost |
|---|---|---|
| **A. One scroll** | All fourteen rows visible under four serif headings. Sub-pages only where a surface has states. | It scrolls past the fold, and "The app" is a junk drawer. |
| B. Four doors | Four navigational rows, every preference one tap down. | Every preference costs a tap, and finding the daily reminder is a guess between four doors. |
| C. Plate, then groups | Name, exam and date collapse into a ruled identity plate; everything else fits without scrolling. | One "Edit" for three fields that behave differently: a text field, a wheel sheet, and a whole sub-page. The chevron lies about where it goes. |

**He chose A.** He is the only question he moved on: A, then B, then back to A.

> please design the visual hierarchy more elegantly

### Question 2: what does a switch look like now?

Spec 8 specified an iOS oval switch, green when on. Ink & Rule bans it and nothing
replaced it, so four rows have had no control since 18 July.

| Option | What it is | Cost |
|---|---|---|
| A. The word | "On" / "Off" in the right-aligned tabular 13/600 slot `DataRowTile` already uses for figures. | Nothing to drag, and it puts a word where every other row puts a value. |
| **B. A flat switch** | A switch with the oval, the shadow and the green removed: square ends, 1.3px hairline, ink fill. | Still reads as a platform widget in our clothes, and it is new machinery. On and off are told apart by a 15px block moving 15px, the weakest state signal of the three. |
| C. A checkbox | The Quiz picker's existing box, zero new components. | A checkbox means "include this in a set". These rows mean "this behavior is on". |

**He chose B, and rejected my recommendation of A.** He also named the exact weakness I
had written into B's own cost line, which means the cost was real and he took the option
anyway on the condition that it gets fixed.

> maybe add something that better indicates on or off. maybe a non-filled box of off? or a greyer color or something. show me elegant options.

### Question 3: do the two behavior rows sit together?

"How sessions are built" arrived from the Quiz spec; "Remember how the table is sorted"
from the Progress spec a week later. Neither author saw the other's row.

| Option | What it is | Cost |
|---|---|---|
| A. One group, "How you practise" | All four rows together. | Reading a table is not practising, so the fourth row is filed under a heading that does not describe it. |
| B. One group, "How the app behaves" | A wider name. | True and limp, and wide enough to attract the theme and analytics rows too, at which point it groups nothing. |
| **C. Two groups** | "How you practise" keeps sessions, mock mode and reminders. A second heading, "What you see", takes the table row and Theme. | Five groups instead of four, and "What you see" holds two rows until skins land. |

**He chose C**, which was also my recommendation.

> copy issue. use american practice

Read as: **"practise" is British.** American English uses "practice" for both the noun
and the verb, and the Philippine market follows American spelling. This is not a one-row
fix; it is a project-wide voice rule that had never been written down.

### Question 4: how does the exam date row edit the date?

The three answers are not up for grabs. If Settings offers fewer than onboarding's day /
month / none, a student who said "October, no day" cannot say it again, editing silently
promotes them to day precision, and Home prints a day count built on an assumption, which
Section 1 of the Progress spec bans outright. The question was only where the three
answers are given.

| Option | What it is | Cost |
|---|---|---|
| A. A full page | Onboarding's step 4, lifted into `lib/core/ui/` and shared. | A pushed screen with a back arrow to change one field, half of it empty. |
| **B. A sheet** | The same wheels, the same dash, the same third answer, raised over the list. | Settings has no sheet today, so this establishes one and every future picker is measured against it. |
| C. The native picker | `showDatePicker`, free. | Three banned devices at once, and a calendar cannot express "October, no day" or "I don't know yet", so it can only return day precision. Drawn with its real radius and shadow so the cost was visible rather than described. |

**He chose B**, which was also my recommendation.

> don't forget to use the same ink wash or like the focus effect when a sheet shows up

### Question 5: does the debug screen survive?

| Option | Cost |
|---|---|
| **A. The flag alone** | Anyone on a flag build sees it, which is the people who should. |
| B. Flag plus long-press on the version row | Two gates for a screen already invisible in release, and an undocumented gesture we forget in a month. |
| C. Drop it | Loses the fastest way to see what RevenueCat thinks the entitlement is, on a device, at the moment it is wrong. |

**He chose A**, but withheld the decision pending an explanation:

> wait i don't actually understand what this is for. please explain plainly.

So A is provisional until he has the plain answer. Recorded as chosen-but-unconfirmed
rather than settled.

### No note on the whole

He left the overall box empty.

---

## Between rounds, 3 August: two rules settled in the terminal

**American spelling, everywhere.** Asked to confirm my reading of "use american practice",
he answered "yes american spelling everywhere". So this is not a one-heading fix. It is a
voice rule alongside no em dashes and Grade-5-simple English, and it makes **colour,
organise, behaviour, favour, centre, analyse, catalogue, grey** wrong across the specs and
the UI copy. It goes in `AGENTS.md` and the specs need a sweep.

**The debug screen stays.** He had chosen A but withheld it pending an explanation, so I
explained what each of its four tools is for and named the one moment it earns its keep: a
paying student says Pro is not working and you need to know, on a phone, in two seconds,
what RevenueCat thinks the entitlement is. He answered "keep debug". Question 5 is now
settled rather than provisional.

**Why he went A, B, A on question 1.** Volunteered without being asked, and it is the
whole brief for round 2:

> the reason i went A B A in question one is that I like the visual hierarchy in B more
> than in A, but you can probably improve A to the same effect. again, be elegant with it.

---

## Round 2, 3 August: hierarchy, and the state of a switch

Plate: `settings-round-2.html`. Two questions, both craft questions, drawn at real size
with the type and spacing numbers written out under each option.

**Two changes I made without being asked**, both declared on the plate and in its final
note box. The top level dropped from fourteen rows to twelve: **About absorbed "Help
improve the app" and "Send feedback"**, on the grounds that analytics consent belongs
beside the privacy policy and feedback is an outbound email rather than a setting, and
**Theme moved into "What you see"**, which his question 3 answer had created. He commented
on neither, so both stand as tacitly accepted rather than chosen.

### Question 1: which hierarchy?

All three drawings carried the same twelve rows so the hierarchy was the only variable.

| Option | What it is | Cost |
|---|---|---|
| **H1. The ledger** | Round 1's shape with its proportions repaired: serif heading 17/700 over a **full ink rule** rather than a faint one, rows sans 14.5/400, values 13/600 muted and tabular, a fixed 11px chevron column so every value lands on one right edge. | The value column takes 96px of a 290px phone, so "Remember how the table is sorted" had to shorten to "Remember table order". Every future row title competes with its own value. |
| H2. The row is the hero | B's grammar throughout, and better than B: serif 14.5/700 titles with the value beneath in plain words, so the second line gives the answer instead of describing the door. | Scrolls half a screen further, and its small sans heading **contradicts `section_header.dart`**, which says serif, never boxed, never all-caps. A second heading style existing nowhere else in the app. |
| H3. Rules only | No headings at all. Five blocks divided by hairlines. Fits on one screen with room left over. | Nothing to scan *for*. Grouping without naming asks the eye to infer what the heading would have said. |

**He chose H1, and rejected my recommendation of H2.** No note.

**This is worth reading carefully, because it reverses the premise of the round.** He asked
for round 2 because he preferred B's hierarchy to A's. Given B's grammar drawn properly, he
took the repaired ledger instead. The reading I take from it: what was wrong in round 1 was
never the grammar, it was the proportions. A heading only 1px larger than its rows, sitting
on a faint rule, was not a hierarchy at all. Fix the rank and the plain list wins.

**Consequence accepted with it.** "Remember how the table is sorted" becomes **"Remember
table order"**. The Progress spec's longer phrasing does not fit the column.

### Question 2: how does the flat switch say on and off?

| Option | What it is | Cost |
|---|---|---|
| S1. Hollow against solid | His own idea taken to its end. Off entirely hollow, on entirely solid with the knob reversed out in paper. | A solid 32x18 ink block is the heaviest mark on a page of hairlines. |
| **S2. Only the knob fills** | The track stays a hairline in both states. Off, an outlined knob at left; on, a solid ink knob at right. | Quieter, and at real size a 12px outlined square against a 12px filled one may still be the weakness he flagged. |
| S3. The word beside it | Round 1's option A and his option B together. | Two marks for one bit, and the row ends in three objects. |

He clicked S2, then S3, then settled it in the note:

> no word beside it. also make the off even more lighter

**So S2, with the off state made fainter than drawn.** "No word beside it" kills S3
explicitly. The lighter off means the off track and knob outline move from `inkMuted` to
`rule`, so off recedes and the contrast with on grows without S1's solid block. He asked
for a change rather than approving as drawn, so this returns for confirmation.

### No note on the hierarchy, and none on the whole

Both boxes left empty.

---

## Correction, 3 August: the switch was S3, not S2

**The round 2 entry above records the switch as S2. That is wrong and it is my error.**
The entry stays as written, because the mistake is part of the record.

He clicked S2, then S3, then wrote "no word beside it. also make the off even more
lighter". I read "no word beside it" as rejecting S3 and falling back to his previous
click. It meant the opposite: **S3 is the chosen concept and the word is the one part to
delete.** I built round 3's first question on the wrong base and asked him to
disambiguate S1 from S2, neither of which he had picked. He corrected it:

> i just said use the S3 one minus the text don't you get it? i like the concept just get
> rid of the text

**So the switch is S3's geometry with no word:** a hairline box, 32x18 at 1.2px with a 1px
radius, holding a **solid 12px knob** that both moves and changes weight, `inkMuted` at the
left when off and `ink` at the right when on. The box border follows: `inkMuted` off, `ink`
on. This is not S1 and not S2. The knob is filled in both states, which is what neither of
those did.

**The lesson worth keeping.** A note that modifies an option is not a note that rejects it,
and when a click and a note disagree the note is usually amending the click rather than
overruling it. I had the evidence to read it correctly and read it backwards.

Round 3's question 1 was rebuilt in place on the S3 base, offering three degrees of "even
more lighter": everything at `inkMuted` as drawn, box and knob dropping together to `rule`,
or the box dropping to `rule` while the knob holds at `inkMuted`.

---

## Second correction, 3 August: the switch is S1 after all

**Wrong again, and this time the fix was to stop guessing.** After the S3 rebuild he said
the drawings had not changed, then:

> no i meant the button type where there was a rectangle outline

Rather than infer a fourth time, I built `settings-switch-candidates.html`: every
treatment that had appeared in the session plus two that had not, drawn at 3x with off
beside on and each one described in plain words rather than by its option letter. He
clicked **A**, "the rectangle itself fills solid when on, and is entirely hollow when
off". That is round 2's **S1**, and it is his own round 1 idea, "maybe a non-filled box
of off".

**So the switch is settled as S1.** A 32x18 box at 1.2px with a 1px radius. Off, nothing
is filled: an outlined box holding a 12px outlined square at the left. On, the box fills
solid `ink` and the square reverses out in `bg` at the right.

**The "even more lighter" note is applied to S1's off outline**, which drops from
`inkMuted` to `rule`. That is my inference from a note written about a different drawing,
so it is flagged on the next plate for him to veto rather than treated as chosen.

### Two process faults worth keeping, because they cost three rounds

1. **I inferred from ambiguous words three times instead of drawing the candidates once.**
   Every inference was cheap to make and expensive to be wrong about. The candidate sheet
   that settled it took ten minutes and would have worked as the first response.
2. **Editing a plate in place does not reliably reach an open tab.** The server broadcasts
   a reload on `screen-updated` as well as `screen-added`, but if the socket has dropped,
   a silent stale page is the result and neither side can tell. The evidence: his three
   selections on round 3 question 1 carry the **pre-edit labels** ("Off in ruleFaint"),
   which proves he was clicking a stale page for the whole exchange. Those three
   selections are discarded. **A new filename is the only delivery that cannot fail
   silently**, which puts the companion guide's "never reuse filenames" rule above
   `CLAUDE.md`'s "edit rather than rewrite" whenever the content actually changes.

---

## Round 4, 3 August: the chooser and the Exam page

Plate: `settings-chooser-and-exam.html`, carrying the two questions round 3 never got a
clean answer to, with the switch redrawn as S1 throughout.

### The three-way chooser

Both "How sessions are built" and Theme need one, and the plate insisted they answer it
the same way.

| Option | What it is | Cost |
|---|---|---|
| C1. A pushed page | Back arrow, serif title, a line of lede, three ringed rows. Takes effect on tap, no Save. | A whole screen to change one of three things, and for Theme it is a screen with nine words on it. |
| **C2. A sheet** | The same rows raised over the list with the ink wash behind. Consistent with the exam date sheet. | **My stated objection:** the exam date gets a sheet because a wheel edits a value in place; three options with a reason each is *reading*, and reading in a sheet means the explanation gets cut to fit the height. |
| C3. Expands in place | The row opens downward. No new screens. | The list reflows under your finger and everything below jumps ~120px. A Material disclosure pattern wearing hairlines. |

**He chose C2, against my recommendation of C1, and answered the objection in the same
breath:**

> improve the copy here. again, make it simple enough to be understood by a 5th grader.
> make it straight to the point and concise also

**That is the right answer to my objection and I should record it as such.** I argued the
sheet was wrong because the explanations would have to be cut. He said cut them. The copy
was too long for a Grade-5 reader before it was ever too long for a sheet, so the height
constraint is not damaging the design, it is enforcing the voice rule the project already
had.

### The Exam page

| Option | Cost |
|---|---|
| E1. Roster first, settings below | Carry-over is the row you return to and it sits below the whole roster. Rare thing first, frequent thing off the bottom. |
| E2. Settings first, roster below | You tap a row called "Exam" and land on two switches, with the thing you came to change below the fold. |
| **E3. Three rows, roster one tap further** | Switching costs a third tap, and a three-row page is thin enough to ask whether it should exist. |

**He chose E3**, which was also my recommendation, and settled what sits behind "Change
exam":

> if possible just reshow the exam selection screen like in the onboarding again

So the roster is **not a new list**. "Change exam" pushes the onboarding picker screen
itself. `ExamSelectionRow` is already being lifted to `lib/core/ui/` by Task 3 of the
polish plan for exactly this, so the reuse is a layering fact rather than an aspiration.

### The lighter off switch, unvetoed

The plate asked him directly whether dropping S1's off outline from `inkMuted` to `rule`
was a step too far, since that inference came from a note written about a different
drawing. He left the box empty. **Recorded as tacit, not chosen**, like the About
absorption in round 2.

---

## Round 5, 3 August: the option names, and the theme control

### The three ordering names

I put it to him that "blocked", "interleaved tail" and "fully mixed" are the Quiz spec's
internal names and none of them is fifth-grade English, offering One topic only / Mostly
one topic / All mixed up, with the cost that the spec, the stored value and the UI would
stop sharing a vocabulary.

> as for the copy, keep interleaved tail as is any rephrase to what you recommend for others

**So: One topic only / Interleaved tail (recommended) / All mixed up.** He kept the one
term I expected him to cut. It is defensible and I said so: "interleaved" is the real
learning-science word, it is the badged default, and the badge is making an authority
claim that a plain phrase would not carry.

Sheet lede, rewritten to his brief: **"Each session has one main topic. This sets how much
comes from other topics."** Theme gets no lede.

### The theme control, which had never been drawn

He noticed it had only ever been listed:

> i didn't see the theme switcher actualy can you show me. preferably it's like a 3-option
> version of the on/off switch except with icons perhaps?

Drawn as exactly that: the switch's grammar at three positions, hairline enclosure, live
segment filled solid ink. Three versions in the real row, each with a 3x.

| Option | Width | Cost |
|---|---|---|
| T1. Words only | 132px | "Auto" does not say auto-what. |
| **T2. Icons only** | 90px | **There are no icons anywhere else in this app.** The half-filled circle is conventional only to someone who has already met it, and there is no label to teach it. |
| T3. Icon and word | 168px | Leaves 86px for the row title, and still introduces icons. |

**He chose T2, over my recommendation of T3, and named the reason:**

> icons only. this is an exception since it's a theme switcher

**This establishes a narrow rule and the spec must state it narrowly**, or it becomes the
precedent that puts icons everywhere: **icons are permitted where the control's subject is
the appearance itself.** A theme switch is the one control in the app whose meaning is
visual, so a sun and a moon are the subject rather than decoration. Nothing else in
Settings qualifies.

### One consequence, flagged and accepted

Drawing Theme as a control split it from the sheet decision of round 4. The rule is now:
**a control edits a value in place, so it sits in the row; a choice with reasons opens a
sheet with room for the reasons.** Theme is a control and lives in its row. Session
ordering is a choice and keeps its sheet. He did not object to the split.

---

## Closed, 3 August: spec and plans written

Spec at `specs/2026-08-03-settings-design.md`, approved without changes. Six plans at
`plans/2026-08-03-settings-01` through `-06`, none executed.

**Two rules from this round outlive the screen** and are written into the spec's Section 1
rather than left in this log: a control edits a value in place while a choice with reasons
is reading, and icons are permitted only where the control's subject is the appearance
itself.

**Three decisions I made on his behalf**, all declared on the plates and none objected to,
recorded here as tacit rather than chosen: About absorbed analytics consent and Send
feedback, "Remember how the table is sorted" shortened to "Remember table order" because
the longer phrasing does not fit the value column, and the off switch outline dropped to
hairline weight.

**Two of my own rules the spec was breaking on its first pass**, found in self-review and
fixed: an em dash inside the ordering sheet's UI copy, which is exactly where one gets
typed by reflex, and "centre".

**Two gaps the plan self-review caught.** The four amendments Section 10 promised to other
specs were not landing in any task, and `settings.session_ordering` had a writer and no
reader, which would have shipped a student three choices that changed nothing. Both are now
tasks in Plan 06.
