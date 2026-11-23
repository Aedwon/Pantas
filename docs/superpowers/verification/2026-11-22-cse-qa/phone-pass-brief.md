# Phone pass brief (read only), CSE release, Nov 23

Startup: Aedwon/Pantas. Policy from origin/main (`git show origin/main:AGENTS.md`, WORKFLOW.md,
docs/workflow/process-improvement.md). Edit no tracked file. No builds, no browsers, no network.
Do not start subagents. Write ONE file, appending as you go: build/audit/phone-pass.md.

Code: this worktree (same app code as prod web build 2026318751, main 47ac60058 or later).
Reference: every phone board of the approved Pantas Redesign canvas, exported at
/Users/aedwon/Documents/Projects/Pantas/web-design/pantas-handoff/mobile/project/ (canvas.json lists
all 288 boards; HANDOFF.md one level up, including Motion). Wrapped boards (WR_, YR_, YO_ and other
Wrapped screens) are deferred: mark them "deferred" and skip.
Already reviewed (do not redo, but do map them): docs/superpowers/verification/2026-11-22-cse-qa/
ui-1-findings.md and ui-2-findings.md and consolidated.md.

Aedwon's guidance, verbatim: "i do not like wordy UI. if you can compress text, do it. I like clean,
intuitive, elegant, and satisfying (in terms of motion and animations) UI/UX".

For EVERY phone board, one table row: board | screen/state | code file(s) that build it | status |
note. Status is one of: match; BUILD WORSE (the build is below the board: say exactly what, with
values); BUILD BETTER (the build improved on the board: say what and why it is better); UNSURE (say
both versions in one line each); not built (the board's screen does not exist in the app; say whether
the app has an equivalent); deferred; already in consolidated.md (give its id).
Compare layout, spacing, type, color, copy, states, and motion (duration, easing, what animates),
phone first. Note wordy copy anywhere as a separate column: a shorter version with the same meaning.

End with: counts per status, counts per board prefix, the top 15 BUILD WORSE items by student impact,
and STAGE-DONE.
