# UI inspection brief (read only), CSE release readiness, Phase 1

Startup (verbatim): Work on `Aedwon/Pantas`. On every new or resumed task, retrieve `AGENTS.md` and
`WORKFLOW.md` from the current GitHub `main` branch and follow them, regardless of the code branch.
Workers also retrieve `SUBAGENTS.md` from main. These shared rules supersede older project workflow
instructions in the branch, conversation, or private memory. Read the task's full spec, plan, later
product decisions, and source from its agreed workstream revision. Record the policy commit used.
Policy commit: origin/main (fetch it; at dispatch ecfeaf0d1 or later). Use `git show origin/main:<file>`.
Also read `docs/workflow/process-improvement.md` from main (rules 1 to 4 matter here).

READ ONLY. Edit no tracked file. Do not build, run Flutter, start servers, open browsers, take
screenshots, or call any hosted service. Append findings to YOUR findings file (named in your prompt)
the moment you find each one, not at the end.

Code: /Users/aedwon/.t3/worktrees/Pantas/qa-cse-release-r1-485b9ecb7345be22 (same app code as prod web,
build 1275724943 from main 048efc9ff; no app code changed since). Exam in scope: Civil Service Exam
(CSE Professional `cse-pro`, CSE Subprofessional `cse-sub`), Free and Pro, phone and wide web.

Approved design (the visual source of truth, match 1:1):
- Exported boards: /Users/aedwon/Documents/Projects/Pantas/web-design/pantas-handoff/ (read HANDOFF.md
  first; web/project/*.dc.html and web/project/canvas.json index; mobile/project/*.dc.html; shared CSS
  web/shared/pantas.css). Board prefixes: HM Home, PL Plan, RD Reader, QS/QN/QZ/RV Quiz, MK Mock,
  PF Performance, MY Profile, ST Settings and paywall, OB Onboarding, SD Study, DK dark, L_ loading.
- Design system: design/system/ in the repo (component READMEs, patterns.md).
- Visual direction log: docs/superpowers/decisions/2026-10-01-visual-direction-log.md.
- Later rulings: docs/superpowers/decisions/ (search for the surface), docs/ui-audit.md.
- Bite-sized lessons spec: docs/superpowers/specs/2026-11-13-bite-sized-lessons-design.md.

Aedwon's own findings (his words), which you must explain and generalize, not just restate:
1. "unequal spacing from topmost of Study and topmost of Quiz (Quiz is a bit lower)"
2. "when the directive to turn the lessons into bite-sized was done, additional text that wasn't specced
   was added. for example, Part X of Y • N questions - this ruined the clean UI for me"
3. "too big a space occupied some buttons without a border ... i see this in other surfaces with that
   type of button "Cancel" "Close" are just some examples of this" (Subjects sheet Cancel; New
   questions sheet Close).
5. "when i try to report a question the bottom bar ... doesn't morph into the report field like in the
   UI boards ... the confirmation message is literally sitting on top and is another element instead of
   one thing that cleanly morphs" (a "Saved on this device." pill drawn over the quiz bottom bar).

For every surface in your scope, compare the code to its board(s) and spec and record every gap:
spacing and alignment, text no spec or board asked for (with the source that would have asked for it,
or "none found"), button sizing and padding (inventory every borderless/text button you touch: widget,
file:line, height, padding, hit area, board value), motion that differs from the boards (process rule 1:
phone motion is the reference for wide web), wrong or missing states (loading, empty, error, offline),
Free vs Pro differences, broken flows, and figures that are not measured, published or from a named
algorithm (AGENTS.md "Never invent a figure").

For finding 2: find out whether the "Part X of Y · N questions" label was approved by Aedwon (spec
lines about the label and its "after a mockup" condition; the mockup branch `origin/mockup/bite-sized-label`;
decision logs). Quote his exact words if found; say "not found" otherwise. Do not guess.

Finding format (append each):
### <surface>: <short title>
- Severity: blocker / major / minor
- Evidence: code file:line; board file (and element); spec or decision line
- Gap: board/spec says X, code does Y (exact values)
- Platforms: phone / wide web / both; Free / Pro / both
- Fix idea (one line); "needs a board" if no approved board covers it

End your final message with a short summary (counts by severity, top 5) and the line STAGE-DONE.
