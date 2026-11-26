# CSE General Information Lesson Walk-Through Rewrite State

- Branch: `content/lesson-walkthrough-cse-gi-r1` (branched from `content/lesson-walkthrough-cse-r1` `97fda158a`)
- Policy commit read: `origin/main` `345d20ba1` (Nov 26 connection rule, cut-pass rule, file-edit rule, save-as-you-go rule; `AGENTS.md`, `WORKFLOW.md`, `SUBAGENTS.md`, `docs/workflow/process-improvement.md`)
- Spec: `docs/superpowers/specs/2026-11-25-lesson-walkthrough-standard.md` (Pick 1a: 900 pre-tap words; Pick 2A: Show answer)
- Checks branch: `tools/walkthrough-checks-r1` (`b8640b532`)
- Velocity estimate: `E-199` (logged on `main` `ef3670e57`, timer started `2026-11-26T07:51 UTC`; Est. active `6 h`, Est. wall `8 h`)
- Scope: 170 active CSE General Information lessons only (`content/lessons/general-information/`). 23 retired parent files untouched. 0 question YAML files modified. 11 existing `ILLUSTRATION:` markers and 17 `SOURCE AUDIT:` comments preserved byte-for-byte.
- Collision-free GI evidence files:
  - `content/walkthrough-trap-evidence-gi.json`
  - `docs/content/walkthrough-figure-worklist-gi.md`
  - `docs/content/verification/walkthrough-state-gi.md`
  - `docs/content/verification/walkthrough-batch-*-gi.md`

## Batch and Chunk Plan (170 Active Lessons)

| Batch | Chunk | Topic / Scope | Lessons | Written | Verified | Committed | Audited |
|---|---|---|---:|---|---|---|---|
| 6a | 6a-1 | Philippine Constitution: Article III Bill of Rights core (ord 1-13) | 13 | 13/13 | 13/13 PASS (R2: 0B/0M/2m fixed) | Committed & pushed | Pending (manager) |
| 6a | 6a-2 | Philippine Constitution: Article III property/custody/bail & accused/trial (ord 14-24) | 11 | 11/11 | 11/11 PASS (R2: 0B/0M/0m) | Committed & pushed | Pending (manager) |
| 6a | 6a-3 | Philippine Constitution: Article III detention/punishment/double jeopardy/remedies (ord 25-35) | 11 | 11/11 | 11/11 PASS (R2: 0B/0M/0m) | Committed & pushed | Codex audit running |
| 6b | 6b-1 | Philippine Constitution: Three Branches and Powers, Arts. VI-VIII (ord 36-46) | 11 | In progress | 0/11 | Pending | Pending (manager) |
| 6b | 6b-2 | Philippine Constitution: Citizenship/Suffrage Arts. IV-V & Amending Art. XVII (ord 47-55) | 9 | 0/9 | 0/9 | Pending | Pending (manager) |
| 6b | 6b-3 | Philippine Constitution: Civil Service Commission Arts. IX-A/IX-B (ord 56-63) | 8 | 0/8 | 0/8 | Pending | Pending (manager) |
| 6b | 6b-4 | Philippine Constitution: Accountability/Impeachment Art. XI & Articles Outline (ord 64-76) | 13 | 0/13 | 0/13 | Pending | Pending (manager) |
| 7 | 7-1 | Code of Conduct RA 6713: Norms (4) & Prohibited Acts/Gifts (8) (ord 1-12) | 12 | 0/12 | 0/12 | Pending | Pending (manager) |
| 7 | 7-2 | Code of Conduct RA 6713: Duties & Prohibited Acts (ord 13-22) | 10 | 0/10 | 0/10 | Pending | Pending (manager) |
| 7 | 7-3 | Code of Conduct RA 6713: SALN & Divestment (ord 29-38) | 10 | 0/10 | 0/10 | Pending | Pending (manager) |
| 7 | 7-4 | Code of Conduct RA 6713: Corruption & Effects (RA 3019/7080/11032/RPC) (ord 23-28) | 6 | 0/6 | 0/6 | Pending | Pending (manager) |
| 7 | 7-5 | Code of Conduct RA 6713: Penalties & Enforcement Sec. 11 (ord 39-47) | 9 | 0/9 | 0/9 | Pending | Pending (manager) |
| 8 | 8-1 | Environment Management: DRRM, Climate Change, Species/Protected Areas (ord 1-13) | 13 | 0/13 | 0/13 | Pending | Pending (manager) |
| 8 | 8-2 | Environment Management: Environmental Laws (9) & Waste Concepts (3) (ord 14-25) | 12 | 0/12 | 0/12 | Pending | Pending (manager) |
| 8 | 8-3 | Peace and Human Rights: Human Rights Fundamentals, UDHR, Bill of Rights, CHR (ord 1-12) | 12 | 0/12 | 0/12 | Pending | Pending (manager) |
| 8 | 8-4 | Peace and Human Rights: HRL/IHL, Armed Conflict, ICCPR, Geneva/RA 9851/11188 (ord 13-22) | 10 | 0/10 | 0/10 | Pending | Pending (manager) |

## Resume Log

- 2026-11-26 15:53 Manila (07:53 UTC): Initialized GI lane state, logged `E-199` on `main` (`ef3670e57`), starting Chunk 6a-1 (13 active lessons, Article III Bill of Rights core).
- 2026-11-26 16:31 Manila (08:31 UTC): Chunk 6a-1 verified PASS (R2: 0 Blockers, 0 Majors, 2 Minors fixed directly), 32 pairs / 47 citations folded into `content/walkthrough-trap-evidence-gi.json`, committed & pushed; Chunk 6a-2 writer running.
- 2026-11-26 16:52 Manila (08:52 UTC): Chunk 6a-2 verified PASS (R2: 0 Blockers, 0 Majors, 0 Minors), 33 pairs / 55 citations folded into `content/walkthrough-trap-evidence-gi.json` (24/170 verified & pushed); Chunk 6a-3 verifier and Chunk 6b-1 writer running.
- 2026-11-26 17:02 Manila (09:02 UTC): Chunk 6a-3 verified PASS (R2: 0 Blockers, 0 Majors, 0 Minors), 33 pairs / 54 citations folded into `content/walkthrough-trap-evidence-gi.json`. Batch 6a complete (35/35 Article III lessons, 98 pairs, 156 citations); running locked Dart gates + Codex GPT 6.2 Sol high checkpoint audit via `codex-pick`. Chunk 6b-1 writer running.
