# Handoff: CSE lesson walk-through rewrite, Claude lesson lead session 1 (E-198)

Date: November 26, 2026, 3:31 to 5:30 PM Manila. Lead: Claude Opus 5.5 lesson lead (took the lane over from the Gemini lead, whose weekly quota ran out). Policy read: `origin/main` `650eda378` (later `ef3670e57` only changed the lanes table and added E-199). Reason for handoff: long session (about 2 hours, heavy context); the manager restarts the lead fresh.

## Controlling documents

- Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` on main (Part B authoring rules and markup). Approved by Aedwon Nov 25 ("i am approving the lesson walkthrough standard").
- Samples: `docs/content/walkthrough-samples/` on `tools/walkthrough-checks-r1` (`b8640b532`).
- Process entries on main `docs/workflow/process-improvement.md`: "Walk-through examples still show math without saying where it comes from" (connection, not more words), the Nov 26 cut-pass line, the file-edit rule.
- Aedwon's example rule (verbatim, Nov 26): "notice what's missing here? there was not enough context given here. where's the expression from? ... the lessons should be clearly assisting the user to understand logic" / "for example: you could say, Let's substitute x=-2 to the terms 3x x^2 and 12/x, and that would be clearer" / "no that's too wordy now, you just made it wordy. i wanted you to connect things better, not explain with more words. those are entirely different asks" / on the approved target: "yes that's it!".
- Lane state: `docs/content/verification/walkthrough-state.md` (takeover notes, audit ruling, fresh-instance rule).
- Working files (briefs, audits, evidence held for merge, importer runner): `docs/content/verification/walkthrough-work/`.

## Scope and permissions

- This lane: Grammar, Vocabulary, Math recheck, Language Application, Reading Comprehension, on `content/lesson-walkthrough-cse-r1`. General Information moved to a separate Gemini lead on `content/lesson-walkthrough-cse-gi-r1` (E-199); do not touch `content/lessons/general-information/`.
- Only CSE lessons. Never touch non-CSE CET lessons, retired files (`status: retired`), or question files.
- Commit each finished chunk as "WIP, not yet audited: ..." and push. No AI attribution lines.
- Nothing goes to the integrator until the UX lead's renderer lands; the manager says when.
- Up to 2 Claude Sonnet workers at a time, disjoint lessons; each told "Do not start subagents; do the work yourself" and to change files only with Edit or Write.
- Audits (manager ruling, Nov 26 about 5:10 PM): Codex account b only; a and c have no subscription. b is now at 94% weekly and 100% of its 5-hour window, so **no Codex runs until Monday Nov 30, 6:06 AM**. Use a Claude Fable 5.2 high read-only audit with the same brief for every batch from now on, commit as "Batch N audited: PASS (Fable)", and add the batch to the list in the state file. After Monday's reset, Codex re-audits every Fable-passed batch before it goes live.

## Verified state at `7477af8ea` (plus this handoff commit)

Checks: the renderer branch's parser (`walkthrough-work/importer/run.dart`, copied from `ux/walkthrough-renderer-r1` `222010878`) passes all 207 walk-through lessons. `lesson_checks.dart` from `tools/walkthrough-checks-r1` (run from that worktree through `flutter-locked.sh`, `--root <this worktree>/content`) reports 0 violations outside Language Application; Language Application fails only on missing trap evidence (held in `walkthrough-work/`, see below).

- **Math (55)**: pre-rule Codex PASS (`25842f38e`). Post-rule: an independent Sonnet verifier rechecked the 26 lessons changed since then: PASS, no wrong number; growth only in the 3 lessons that match the approved samples. Not post-rule audited: needs a Fable audit. Not yet swept for the fresh-instance rule (see Risks).
- **Reasoning (47)**: Codex PASS (`128cf0359`). Not swept for the fresh-instance rule.
- **Grammar (52)**: Codex round 2 FAIL and round 3 FAIL (13 Blockers, 22 Majors) were fixed; two Sonnet sweeps then found reused Quick Check and try instances, elimination giveaways and overbroad rules in nearly every lesson; all fixed (`e46c0f4ae`, `6bec7b522`, `fabe161e7`). The round 4 Codex audit (`walkthrough-work/codex-grammar-vocab-r4-partial.md`) stopped partway when b hit its limit. It covered the English Grammar lessons through `joining-words-phrases-and-clauses` and part of the Filipino ones, and lists **many new Blockers and Majors, none fixed yet** (rules about clauses, finite verbs, subjects and connectors stated too narrowly or broadly; displays ending in narrated diagnoses; several check answers wrong, for example `english-word-jobs.md:94`, `dangling-modifiers-and-their-subjects.md:40`). Grammar is NOT audited.
- **Vocabulary (29)**: verified line by line by four independent Sonnet verifiers; all findings fixed (`366a3e175`, `16b1f3414`, `b3c9331a2`, `fabe161e7`). Trap evidence for all 29 merged into `content/walkthrough-trap-evidence.json`. Never audited (the round 4 Codex run did not reach it).
- **Language Application (24 active, 3 retired parents)**: all 24 now in walk-through form. The 8 from the Gemini lead (`e3a91b4e2`) are unchecked against the current rules and have no trap evidence. The 11 English lessons written this session (`30e0f8882`) were verified: FAIL, 0 Blockers, findings in `walkthrough-work/la-en11-verifier-findings.md` (not fixed). The 5 Filipino lessons (`7477af8ea`) are not verified. Citations: `walkthrough-work/la-evidence-en11.json` (verified exact) and `la-evidence-fil5.json` (unverified) wait to be merged into `content/walkthrough-trap-evidence.json` (merge with the Edit tool; the 8 earlier lessons still need their citations extracted).
- **Reading Comprehension (40)**: not started. Quiz packets from the Gemini lead were in its scratch folder only (`batch5/`); regenerate from the question YAMLs.

## Decisions and rules made this session (lead)

1. Filipino first-use English glosses restored. The earlier Codex round 1 asked to delete every gloss; that contradicts Aedwon's Oct 4 decision (option 1, `2026-10-01-question-explanations-log.md`) and the style guide. Cognate-only glosses (aspekto (aspect)) are dropped; meaning glosses stay.
2. Fresh-instance rule (rule 5a in `walkthrough-work/worker-rules.md`): every `:::check` and `:::try` tests a taught rule on a word or sentence not already worked earlier in the lesson, as the approved sample does ("The dog barks" taught, "My sister (teach / teaches)" checked). Neutral example headings (5b). Rules scoped to what holds, lists marked as examples (7).
3. The importer runner was added as a per-chunk check because the UX lead's parser enforces rules the lane's sweep did not (no checklist item without `{#slug}`, at most 3 pairs).
4. A stray `.dart_tool/` folder left by a worker inside `content/questions/` crashed `lesson_checks.dart` with a YAML cast error. Briefs now forbid running any tool with its working directory inside `content/`.

## Next actions, in order

1. Grammar: fix every finding in `codex-grammar-vocab-r4-partial.md` (2 Sonnet fixers on disjoint lessons, `walkthrough-work/fixer-brief.md`); independent Sonnet re-verify; then a Fable 5.2 high audit of all 52 lessons with `codex-grammar-vocab-r4.brief.md` adapted (it is the same standard); commit "Batch 3 audited: PASS (Fable)" when it passes.
2. Vocabulary: Fable audit with the same brief; fix; commit "Batch 4a audited: PASS (Fable)".
3. Language Application: fix `la-en11-verifier-findings.md`; verify the 5 Filipino lessons and the 8 earlier lessons (extract their citations); merge all citations; run both checks; Fable audit.
4. Math: Fable audit (post-rule), including the fresh-instance rule.
5. Reading Comprehension: write in chunks with `walkthrough-work/writer-brief.md`, verify each chunk, Fable audit.
6. After Monday 6:06 AM: Codex re-audits of every Fable-passed batch, one at a time, checking `codex-pick --status` first.

The briefs in `walkthrough-work/` name scratchpad paths from this session for the rules file and the importer; point them at the `walkthrough-work/` copies.

## Manager rulings after the handoff (Nov 26, about 5:40 PM Manila; rule 4, searched the spec's Quick Check section and the four samples)

1. Audits: as above. Codex b is this lane's first (the GI Gemini lead runs none); b is already past 90%, so Fable 5.2 high audits from here, Codex re-audits after Monday's reset before anything goes live.
2. Fresh-instance sweep approved: sweep all this lane's batches (Math, Reasoning, Grammar, Vocabulary, and the new ones) and fix every Quick Check or try that repeats the exact item just taught, as the approved samples do. If a check can catch it (a Quick Check stem or answer matching an example sentence in the same lesson), add it to `tools/walkthrough-checks-r1` with a failing case first, wired into `lesson_checks.dart`. The GI lead was told the rule in one line (done Nov 26).

3. Later ruling (manager, relaying Aedwon verbatim: "86% in weekly is plenty. exhaust it"): the 90% stop is lifted. Use Codex b for every batch audit until it refuses for its weekly limit (Grammar, Vocabulary, Math post-rule, then Language Application and Reading Comprehension), one run at a time; Fable only after that. The GI lead also uses b: if `codex-pick` refuses because another run is active (exit 76), wait and retry; do not switch tools. At handoff b was at 94% weekly and 100% of its 5-hour window, which resets Nov 26, 6:52 PM Manila. When b's window was full, `codex-pick` failed over to a and c, which errored ("model is not supported when using Codex with a ChatGPT account"); treat that error as b being out, check `codex-pick --status`, and wait for b's reset.

Updated next actions: add the fresh-instance check first (it also finds the remaining Math and Reasoning cases), then the order above, with Math and Reasoning sweeps added before their Fable audits.

## Risks and open questions for the manager

- The fresh-instance and scoping problems were found in nearly every Grammar and Vocabulary lesson. Math and Reasoning passed audits before anyone checked for them, so they likely have the same reused Quick Checks. Sweep approved (above).
- Each Codex round on Grammar found a new layer of rule-precision problems. Fable audits may find the same; expect two or three rounds per batch.
- Velocity: E-198 timer paused at handoff (reason other). Its estimate row has not been written on main yet; the manager or the next session should add it (estimate given to the manager: about 22 h, before General Information moved out of the lane; now about 12 h for this scope).
