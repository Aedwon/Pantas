# Visual direction: Ink and Rule retired

## 1 October 2026

While briefing the UI round for the roadmap, Aedwon asked to drop Ink and Rule from the brief:

> "actually can you drop the Ink and Rule look, I've abandoned that lately because it's too
> restrictive with the delight moments i envision for the app. attaching here some samples"

Then:

> "no no do not include anything about the visual direction at all"

The brief was cleaned (roadmap UI brief, commits d30e2198, 413a8c84, bac70e60). Policy was not:
`AGENTS.md` still mandated Ink and Rule and its banned list, and about 20 earlier specs carry its
visual sections. Aedwon asked whether a new session could misread this:

> "btw the ink and rule design direction has been overturned right? no chance that a new
> model/session will misinterpret? i don't want things breaking when trying to reconcile the
> underlying engine/features and the UI"

**Options offered:** retire the section in `AGENTS.md` and mark older specs' visual sections
superseded, leaving their text as history; and whether the typeface, color-carries-meaning and
component-kit rules survive.

> "okay please do the necessary changes. i don't want you to declare anything first before i
> start the connection process, because then you'll see the design direction itself. the rules
> are derived from the design in Claude Design"

**What changed:**
- `AGENTS.md`: "Visual identity: Ink and Rule" replaced by "Visual direction": Ink and Rule
  retired; no visual rules set in policy until rules derived from Aedwon's Claude Design work are
  recorded; visual decisions come from approved Claude Design screens 1:1; earlier specs keep
  behavior, content, figures and Free and Pro rules, and their visual sections are superseded.
  The typeface (Source Sans 3) and "color must carry meaning, board green for the primary
  action" rules were removed with the section, per "do not declare anything first". The
  component-kit check stays, limited to behavior and structure.
- Roadmap spec Part 2 Section 5: the gate's `FaintBars` treatment replaced by the gate's behavior
  only.
- `docs/ui-audit.md`: a note that styling findings judged against Ink and Rule are historical.
- Earlier specs are not edited; the `AGENTS.md` supersession covers them.

**Next:** when Aedwon connects Claude Design, derive the visual rules from it and record them in
`AGENTS.md` with his approval.
