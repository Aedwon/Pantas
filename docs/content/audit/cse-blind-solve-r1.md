# CSE blind-solve mismatches (2026-10-26)

Codex GPT 6.1 Sol solved each question without the key. Each row is a question where its answer differs from the key. A mismatch is a lead to check, not proof the key is wrong.

| File | Question | Result | Solver note |
|---|---|---|---|
| general-information/code-of-conduct-ra-6713/statements-of-assets-and-divestment.yaml | q-code-of-conduct-ra-6713-statements-of-assets-and-divestment-0014 | key 2, solver 3 (high) | The statutory list assigns Supreme Court justices to the Office of the Ombudsman. |

## Result

- 61 CSE question files, 1,100 questions. Choices were shuffled per question before solving, so the key
  position gave nothing away. The solver agreed with the key on 1,099.
- A control re-run of `algebra/word-problems.yaml` from an empty folder (no repository access) also matched
  20 of 20, so the agreement is not from reading the keys.
- The one mismatch: the key ("Supreme Court clerk") is correct. RA 6713 Section 8(A) has Supreme Court
  justices file with the Clerk of Court of the Supreme Court. No key change needed.
- Limits: one solver model at low effort; easy, well-worded questions agree easily. This does not replace the
  planned Astra audit of answer keys.
