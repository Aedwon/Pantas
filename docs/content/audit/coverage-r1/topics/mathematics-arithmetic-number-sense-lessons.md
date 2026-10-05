# Arithmetic and number sense structure audit

Status: DRAFT, Level 3 only, independent review pending.

Policy ac4b30da31b0bcca7e7ed1e47c930b1ac00ced6c matched live main; all nine required policy/standard blobs match the prior full read. Audit HEAD 7d5f2ed6a6d6f30e35d1b3f64467f31e7d122112. Corpus 765c5dc0fa5586281047bf4f7b30d09ab3707887 confirmed clean. Reader contract read in full. Current spec/plan, decisions, overlap and accepted requirement context remain controlling; additional CSE packets and scope note read for this assignment. Findings only; runtime unknown; practice deferred Level5.

## Machine-readable appendix

```json
{
  "level": 3,
  "status": "DRAFT",
  "subject": "mathematics",
  "topic": "arithmetic-number-sense",
  "policyCommit": "ac4b30da31b0bcca7e7ed1e47c930b1ac00ced6c",
  "corpusCommit": "765c5dc0fa5586281047bf4f7b30d09ab3707887",
  "lessons": [
    {
      "slug": "business-math",
      "goal": "Model price changes and calculate simple/compound interest with compatible rate and time periods.",
      "skills": [
        [
          "Discounts and remaining percent",
          "explained",
          14,
          20,
          "worked",
          52,
          67
        ],
        [
          "Successive discounts",
          "explained",
          155,
          159,
          "worked",
          69,
          84
        ],
        [
          "Cost-based markup",
          "explained",
          18,
          20,
          "worked",
          86,
          100
        ],
        [
          "Simple interest and unknown time",
          "explained",
          24,
          32,
          "worked",
          102,
          124
        ],
        [
          "Compound interest and frequency",
          "explained",
          34,
          38,
          "worked",
          126,
          149
        ],
        [
          "Annuities and present/future value",
          "absent",
          10,
          38,
          "none",
          50,
          149
        ],
        [
          "Loans, stocks and bonds",
          "absent",
          10,
          38,
          "none",
          50,
          149
        ],
        [
          "Commission, sales tax and payroll",
          "absent",
          10,
          38,
          "none",
          50,
          149
        ]
      ],
      "structure": {
        "verdict": "split-candidate",
        "reason": "Retail percent changes reuse a basic percent foundation; compounding/period alignment is a separate time-value task. Broader financial preparation is not supplied by these five examples.",
        "proposal": "Keep discount/markup applications with percentage preparation; create a focused interest/time-value extension that can later develop annuities/loans as required. Teach shared percent conversion once.",
        "cost": "Move two interest examples and period/rate definitions; adding annuities/loans is new authoring, not accomplished by a split."
      },
      "id": "lesson-arithmetic-number-sense-business-math",
      "path": "content/lessons/mathematics/arithmetic-number-sense/business-math.md",
      "sha256": "3250dc130a5097d2490328dd6b06298f43190964e432501e555e7538d1566b4b",
      "readLines": [
        1,
        179
      ]
    },
    {
      "slug": "divisibility-rules",
      "goal": "Test integer divisibility, constrain missing digits, and combine tests only when factors are coprime.",
      "skills": [
        [
          "Integer divisibility",
          "explained",
          12,
          14,
          "worked",
          73,
          93
        ],
        [
          "Last-digit tests 2,5,10",
          "explained",
          24,
          38,
          "thin",
          84,
          85
        ],
        [
          "Last-two/three-digit tests 4,8",
          "explained",
          25,
          26,
          "worked",
          118,
          138
        ],
        [
          "Digit sums 3,9",
          "explained",
          32,
          33,
          "worked",
          56,
          71
        ],
        [
          "Combined test 6",
          "explained",
          40,
          42,
          "worked",
          73,
          93
        ],
        [
          "Iterated test 7",
          "explained",
          44,
          48,
          "worked",
          48,
          48
        ],
        [
          "Alternating-sum test 11",
          "explained",
          50,
          52,
          "worked",
          95,
          116
        ],
        [
          "Coprime composite-divisor tests",
          "thin",
          147,
          154,
          "worked",
          118,
          138
        ]
      ],
      "structure": {
        "verdict": "reorder",
        "reason": "The basic core defines divisibility but the methods reside in mnemonics; coprimality is used in a worked combined test before its explanation.",
        "proposal": "Move digit tests and the coprime condition before applications. Keep them in one divisibility lesson with a short necessary factor foundation.",
        "cost": "Local reordering and a coprime explanation, no extra standalone lesson."
      },
      "id": "lesson-arithmetic-number-sense-divisibility-rules",
      "path": "content/lessons/mathematics/arithmetic-number-sense/divisibility-rules.md",
      "sha256": "6bfa59d54134a9aea9bef089f20c9bf73bf9f2d07fac307ce88abef2e6af783a",
      "readLines": [
        1,
        166
      ]
    }
  ],
  "requirementFacets": [],
  "sourceLedger": []
}
```
