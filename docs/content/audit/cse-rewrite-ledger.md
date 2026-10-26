# CSE rewrite source ledger

One row per fact a CSE rewrite changes or adds, in the `docs/content/source-policy.md` row format.
Writers add rows in the same commit as the lesson change; the reader checks them.

| Item | Issue | Original content / claim | Disposition | Source | Verification note |
|---|---|---|---|---|---|

## 2026-10-26 lead rulings at the end of the lesson loop

- `lesson-philippine-constitution-citizenship-and-suffrage`: the form check classed this English lesson as Filipino
  because it quotes Filipino terms, which made L08 (teach in Filipino) and L10 (examples in Filipino) apply. The two
  resulting Major findings in RD-128 are void. L11 was set to needs_source_check by the lead so the form would pass.
  Remaining: two Minors (L19 unnumbered Example 9 solution, L22a four-sentence paragraph in Example 8). Not rewritten
  further; the loop parked it after 5 rounds on the void findings.
- `lesson-code-of-conduct-ra-6713-penalties-and-enforcement`: Article 20 family exemption removed (Aedwon's decision);
  accessory escape conditions cut; Section 11(c) quoted instead of defining conspiracy. Clean in RD-089.
- Final state: 79 clean, 11 minor-only (including the lesson above), 0 Blocker or Major.

## 2026-10-26 Astra audit and final state (ready for Aedwon's review)

- Astra (GPT 6 Astra, web search) audited the 23 General Information lessons and their questions: 27 findings.
  Codex (GPT 6.1 Sol, high, web search) verified 26 against primary sources and fixed them in 15 lessons; verdicts with
  sources are in the scratchpad file `astra-verdicts.md` (copy kept with the session's content reports).
- Re-reads after those fixes and five lead-directed fixes. Final: 72 clean, 14 minor-only, 4 with open items for review:
  - corruption-and-its-effects: reader could not confirm an added judicial proof requirement (B01, unverified, not
    shown wrong); one dense teaching bullet (L02).
  - penalties-and-enforcement: Example 7 names a level of proof that the lesson no longer explains (L18, L25).
  - accountability-and-impeachment: "forthwith" needs a plain meaning (L25).
  - citizenship-and-suffrage: reader could not confirm one categorical citizenship rule (B01, unverified); L08/L10 are
    the void Filipino classification.
- Readers have no web access, so "not confirmed by the supplied sources" findings are leads, not errors. These four
  are left for Aedwon rather than another automated round.

## 2026-10-26 last round (source-verified fixes, then reads)

- Codex with web search verified the two unconfirmed rules (RA 3019 Section 3(e) case law; citizenship Section 40(d))
  and added citations; defined forthwith, level of proof, substantial evidence and beyond reasonable doubt; split the
  dense bullet. Final: 72 clean, 15 minor-only, 3 with items for Aedwon:
  - corruption-and-its-effects: reader could not see a source for the direct-bribery definition (RPC Article 210);
    unverified by the reader, not shown wrong.
  - penalties-and-enforcement: Example 5 applies Section 11(c) to an accomplice without showing an agreement, while
    11(c) says "participate in conspiracy". This is the statute's own wording tension; decide how to frame accomplices.
  - accountability-and-impeachment: Example 14 repeats Example 2's reasoning (L18); replace with a distinct case.

## 2026-10-26 closing state

73 clean, 15 minor-only, 2 for Aedwon:
- corruption-and-its-effects: the reader cannot see the source for the RA 3019 Section 3(e) case it cites
  (G.R. 231530-33, 2021; Codex verified it on lawphil.net). A "cannot confirm" lead, not a shown error.
- penalties-and-enforcement: Section 11(c) says private persons "participate in conspiracy as co-principals,
  accomplices or accessories", but under the Revised Penal Code everyone in a conspiracy is a principal. Every
  automated framing of the accomplice and accessory examples trips one side of that tension. Recommended: teach the
  statute's wording and the same-liability rule, and drop the worked role-classification examples. Needs Aedwon.
