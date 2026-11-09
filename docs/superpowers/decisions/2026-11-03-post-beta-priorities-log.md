# Post-beta priorities: decision log

Policy read from `origin/main` at 875d78dd.

## November 3, 2026: what to do beyond the beta

Aedwon's exact request: "i feel like I'm heavily under-utilizing my Claude Max plan. I want to do things beyond the beta. what do you suggest? check the SSOT, the roadmaps or something. i think the SSOT is also stale"

Findings given first:

- The SSOT was stale. The readiness tab stopped on October 6, its top checkpoint was September 7, and neither it nor the Home tab mentioned the PWA or PayMongo. The Home tab also omitted the Civil Service weekly and yearly plans, and the beta tab still described Google Play.
- The limit is Aedwon's approval time, not Claude capacity. Nine previews were waiting on him, and nothing was deployed for the November 9 beta (audit of November 2).
- This session's usage tool reported a Pro plan at 29% weekly use, not Max, so Max usage could not be read from it.

Options offered, in the lead's recommended order, with costs. None is approved for build:

1. Question generator with abstract reasoning: unlocks PSHS-NCE and the four academy exams and reduces repeats in thin CSE pools. Cost: a large build, and generated questions need an independent audit.
2. Smarter roadmap with knowledge map and readiness forecast: the clearest reason to buy Pro. Cost: a large build with heavy design input from Aedwon; forecasts must follow the rule against invented figures.
3. Founder app: four tabs already chosen. Cost: a medium build; saves weekly time but adds no students.
4. Next-exam brief: ranks exams by candidates, dates, overlap and price. Cost: low; runs without him.
5. Funding brief: checks grants and credits. Cost: low; the SSOT listed no deadlines.

Advised to skip for now: store releases (waiting on funds) and review center deals (parked). Timing advised: refresh the SSOT and run briefs 4 and 5 this week, and choose a build after November 15 using beta data.

Question: "Should I refresh the SSOT and write the two post-beta briefs now?" Options: "Yes, start both" or "SSOT only".

Aedwon's answer: "Yes, start both"

Result:

- SSOT refreshed: a Current status section and corrected Civil Service prices on Home, a new top checkpoint and a dated catch-up entry on the readiness tab, and a status note on the beta tab. The September 7 checkpoint's title now says SUPERSEDED; its text and all earlier entries are unchanged.
- Briefs written: `docs/future/2026-11-03-next-exam-brief.md` and `docs/future/2026-11-03-funding-brief.md`. Neither is approved scope.

Corrections made during lead review, before publishing:

- The next-exam draft called UPCAT the largest official pool. PUPCET's official count is larger (181,598 against 147,437); both figures were rechecked on the official pages.
- The next-exam draft said Student products are live, which holds only for store products. They have no web price, and Civil Service does. The draft also missed the rewrite of 98 non-CSE UPCAT sets, the required lesson links, and the deferred finales. UPCAT stayed first, as a judgment, with these costs stated.
- The next-exam draft's NAPOLCOM "about 80,000 seats" was replaced by the registrations it cites, about 89,000 including promotional takers.
- The funding draft said "take no equity" where the pages only do not mention equity. It told Aedwon to start BIR registration, which is already pending. It missed Google's exclusions (educational institutions, consultancies, agencies) and its funding-stage wording, which may affect Pantas.

## November 3, 2026: UPCAT with other CETs, and official sites

Aedwon's exact comment: "upcat, and other CETs also? also official sites you can check in the browser here. you are the max account, and in claude app rn in macos"

Result, as a recommendation only (he has not approved it):

- The next-exam brief now recommends UPCAT, DCAT, USTET and ACET together. The four use 137 sets, and the 98 not shared with CSE are the same 98 UPCAT alone needs. The current cycle is too soon, so the target is the next one, from March 2027 by past pattern.
- PUPCET and DOST-SEI stay in a second wave. PUP has no published schedule or format.
- Aedwon's comment was taken as permission to read official pages in the built-in browser for this research, an exception to the computer-control rule in `WORKFLOW.md`, which is unchanged. UP, DLSU, UST, Ateneo, PUP, PSHS, CSC, PRC, QBO, Microsoft and startup.gov.ph were read. This resolved the ACET date conflict and gave official USTET and PSHS dates.
- PCIEERD's security check was not bypassed. DOST's scholarship site showed no readable text. Those items stay marked as unverified.
- On the account: this session's usage tool still reported "Pro" at 31% weekly after his comment. Aedwon says this is the Max account; the reason for the difference is unknown.

## November 3, 2026: which audit covered the other exams

Aedwon's exact comment: "the last content audit i think included exams other than CSE, it was only after level 4 (or at the start of level 4) that I decided to narrow down to only CSE. can you check which that was? there should be an outline of subjects/topics/lessons already in the SSOT"

Finding: it was the exam content coverage audit, coverage-r1, approved October 4 for nine exams. Levels 1 to 3 covered all nine (Level 3 approved October 9). Level 4 was built for all 158 lessons on October 10 and 11, and Aedwon narrowed it to CSE on October 19, before any lesson read ran. The outline is the SSOT tab Pantas Audited Corpus r1.

Mistake corrected: the brief's "98 sets" came from older tags on question files and assumed that only sets tagged CSE were rewritten. By the accepted audit tags and the files actually changed, the four CETs use 132 lessons, 63 rewritten and 69 not. UPCAT alone is 65, so the bundle adds 4 lessons, not zero. The recommendation stays.

## November 3, 2026: how to continue Levels 4 and 5 for the other exams

Aedwon's exact question: "would you recommend I continue the rest of the exams for Level 4 and Level 5? i'd like the same process we did for CSE where, lessons were written/rewritten first and then the questions adjusted to the lessons. or would  you propose a better way?"

Options offered, with costs:

1. Repeat the CSE process: audit, triage, rewrite, then questions. Familiar, but about 132 lessons read and triaged before any fix; 233 of 866 CSE findings were judgment calls, and the rewrite got its own read anyway.
2. Combine audit and rewrite (recommended): rewrite from the standards and Level 3 gaps, a different model reads, loop until clean, then questions, an Astra audit and Aedwon's review. Risk: writers may miss what a separate audit would catch; a pilot tests it.
3. Ship the CET lessons as they are: least cost, but 69 lessons never checked against the standards.

Aedwon's question on involvement: "is it possible to keep me out of this loop only until the end?"

Answer given: yes, apart from approving the spec at the start. Tradeoff stated: a bad ruling could spread before he sees it, which costs rework at the end, not a bad release.

Aedwon's answer: "okay, write the spec for option 2. codex for 6.1 Sol will reset in ~19h so i think we could use that eventually. if not, sonnet 5.5 would be good i think? let me know what's best here"

Result: spec `docs/superpowers/specs/2026-11-03-cet-content-design.md` written, awaiting approval of Part A and a complexity level. Recommendation on models: Sonnet 5.5 writes and Codex GPT 6.1 Sol reads, with 5 of the 15 pilot lessons swapped to compare first reads. A tie goes to Sonnet. Checked at writing: Codex accounts at 100%, 95% and 96% weekly, resetting November 4 at 14:45, 18:20 and 14:51.

## November 3, 2026: spec approved; work moves to another account

Question: "Do you approve Part A at balanced complexity?"

Aedwon's answer: "balanced is approved but i want this done on another account. can I do that? it's Pro but I don't want to waste its usage"

Result: Part A is approved at balanced. The work can resume on any account, because the spec, records and branch are in the repository. Nothing has started. Part A recommends Sonnet as the writer, which would spend the Pro account's usage, so the model split is put back to him as a specific revision.

Aedwon's follow-up: "oh wait you can do the pilot now before the actual, final run that i can set as /goal. keep sonnet writer"

Result: the 15-lesson pilot runs in this session on the Part A model split. The final run waits for the pilot verdict, and Aedwon starts it as a `/goal` on another account. Plan: `docs/superpowers/plans/2026-11-03-cet-content-pilot.md`. Sonnet writes 10 lessons now; Sol's reads and its 5 lessons wait for the Codex reset.

## November 3, 2026: pilot results and changes for the cloud run

Aedwon's constraints, in order: "for full disclosure i'm planning, after this pilot and things are settled, to use the remaining $100 i have in cloud sessions for hill climbing this goal as much work as it can do. i think that should be plenty"; "also to add, when Claude models have finish their job we can use the resetted claude accounts to audit. is this fair for you or do you have a better way"; "i think for now we can only afford a 6.1 Sol high audit. 5% weekly is about 30% of 1 5-hour session in codex"; "the /goal using the cloud session has to run tonight or tomorrow because it expires Nov 5"; "nah let's not wait for codex"; "what why fable, you can read it yourself can't you? or another opus 5.5 agent".

Mistake: the lead chose Fable readers without asking. Aedwon objected, and they were stopped with their partial output discarded.

Mistake: the lead set a 1,700-word limit taken from a CSE pilot note and an outline tripwire. It is not in the style guide. 37 of the 90 rewritten CSE lessons exceed it, with a median of 1,611 and a maximum of 4,047. It forced writers to cut correct teaching and caused many findings.

Result: all 15 first reads had a Blocker or Major (6 Blockers, 83 Majors, 52 Minors). Round 2 on 5 lessons cut Blockers and Majors from 35 to 10, with new findings still appearing. Measured cost at API prices per lesson: write $0.40, read $0.71, fix $0.64, re-read $0.76. The lead told him $100 would not be plenty: about 25 to 40 lessons and no questions.

Options offered as one approval: skip the audit fallback; replace the 1,700 limit with a split note over about 3,000 words; spend the $100 in order, pilot lessons, then science, mathematics, reasoning and reading, with questions and any remainder moved to reset accounts.

Aedwon's answer: "Approve all three"

## November 4: after the CET final run (cloud session)

The final run finished on `content/cet-rewrite-r1`: 69 of 69 lessons are clean (7), minor (41) or open after three reads (21). Report: `docs/content/rewrite/cet/final-run-report.md` on that branch. The lead proposed next steps: a cross-vendor Sol pass on the 21 open lessons, then questions, exam tags, the Astra audit and figures. Two choices were put to Aedwon.

1. Split candidates: 11 lessons passed about 3,000 words and were not split. Options: split them (cost: new lesson ids, questions reassigned to the new lessons, new tags and prerequisite links, and more reads); trim them (cost: risk of cutting needed teaching, which the pilot showed); leave them.
2. Parent-chain naming in basic organic chemistry: the older rule most school texts teach (the chain must include the double or triple bond) or IUPAC 2013 (chain length first). Cost of IUPAC: students may meet the older rule in school books and exam keys.

Aedwon: "do you recommend splitting them? i think it would be good to avoid having 1 lesson be so long"

Aedwon: "also yes please use IUPAC since it's an international standard right?"

Aedwon: "proceed just before the astra audit since it's yet to reset in 1 hour 20 min"

Lead response: IUPAC is the international authority on chemical names, and its 2013 recommendations are current. The lead recommended teaching IUPAC 2013 with one sentence noting the older rule, so a student who meets it in a school book is not confused. On splits, the lead recommended splitting the lessons clearly over the line and trimming the borderline ones (about 3,000 to 3,100 words) instead. The cloud session has no Codex and no Dart, so the Sol and Astra steps and the question import check must run on Aedwon's Mac.

## November 5: open-lesson pass without Codex

Mac session. The Dart question import check and the content export build both exit 0 on `content/cet-rewrite-r1`, with all 16 split lessons in the export. The lead planned a Sol (Codex) read of the 18 open lessons after Sonnet fixes. Another session used up all three Codex accounts first. The lead offered: wait for the reset and share Codex with that session, or use fresh Opus readers now (the final run's loop), with Astra as the later cross-vendor check. The lead recommended one read round, not two.

Aedwon: "no codex use. possible? and why is codex essential here"; "please don't parallelize so much because you have limited usage"; "is your recommendation what we've been doing before?"; "why two more rounds this time?"; "okay proceed".

Result: one Opus read per lesson, one at a time. All 18 stay open: the round-3 fixes held in 17, but each read found new Blockers or Majors, six of them added by the fixes (one from the lead's own wording). Counts unchanged: 9 clean, 50 minor, 18 open. Details and options for the final review: `docs/content/rewrite/cet/final-run-report.md` on the branch (head 4b3a6f7b5).

## November 5: rework of the open CET lessons

After round 4 left all 18 open, the lead offered: one careful rework per lesson then one read (recommended), leave them for the Astra audit, or leave them for the final review. Aedwon: "proceed as you recommend. wdym by that other question?" The other question was about moving on to exam tags (P4); his November 4 instruction ("proceed just before the astra audit") already covers it.

Result: 6 of 18 closed (2 clean, 4 minor); 12 stay open with round-5 findings, mostly narrow exceptions to general statements, about half introduced by the rework's own wording. Counts: 11 clean, 54 minor, 12 open. Branch head bd1c8cc10. Next: exam tags.

## November 9: CET round 6 closes the open lessons

Manager thread relayed Aedwon: "for the rest of items, please finish them". Order given: close the 12 open lessons, then exam tags, then the Astra audit, then figures. Aedwon's earlier limit still applies: "please don't parallelize so much because you have limited usage".

Lead ruling: round 6 changed only the sentences each round-5 finding named, because in about half the open lessons the wider round-5 rework had added the next false absolute. Each changed sentence used a stated condition, the lead boundary-tested it, and one fresh Opus read per lesson checked the round-5 findings and every changed sentence. Outside changed text, the reader reported only Blockers and wrong or answer-revealing worked steps.

Result: all 12 closed, 6 clean and 6 minor. Counts: 77 lessons, 17 clean, 60 minor, 0 open. The lead sent two points back (an unlimited "do not follow this rule" in earths-motions, a duplicate figure marker). Two of four fixer runs skipped some required reads, and both said so; the lead checked their sentences. One cost: the earths-motions sidereal-day figure, approved August 25, was removed because its renderer prints "a few extra degrees" for about 1 degree; the figure phase must redraw it. Exam tags re-checked: all 86 files match. Branch `content/cet-finish-r1` at fa936f9ed; details in `docs/content/rewrite/cet/round-6.md` there.
