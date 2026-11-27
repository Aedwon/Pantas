# Batch 2a blind pre-check findings (Worker 1)

Target: worktree `content-lesson-walkthro-85719f9d9f054ca1`, commit `ddc80213e`. Method: read each lesson top down with
`:::answer` hidden, solved every `:::check` and `:::try` first, then opened the answers. Ran the rule-list tool on all 12
lessons. Read the text of all 19 SVGs (11 in batch 2a, 8 in pilot lessons) and checked rect widths against stated values.
All 23 of my own answers equal the printed keys. No second defensible answer found.

Format: `Severity | file:line | item | problem | fix`

## Findings

Major | arithmetic-number-sense/markup-on-cost.md:60 | Quick Check | Same frame as the example at lines 51-57 (listed price after a cost-based markup, divide by 1 plus the rate): "Php 900, 20%" became "Php 650, 30%". The student repeats the printed steps. The format note allows new numbers, flagged because the wording is identical | Change the frame, e.g. give the markup in pesos and ask for the markup rate on cost, or add selling expenses and ask for profit
Major | arithmetic-number-sense/markup-on-cost.md:173 | checklist, profit line | "subtract expenses from the markup" is true only when the item sells at the listed price. Line 19 defines listed price as before any discount, so a discounted sale breaks the rule | Add the condition: "when it sells at the listed price, subtract expenses from the markup"
Major | algebra/motion-chase-problems.md:73 | Quick Check | Same story and steps as the van and jeepney example (lines 34-48): head start in hours, subtract speeds, divide the gap. Only names and numbers changed | Change the frame, e.g. give the gap in km and ask the chaser's distance, or give the catch-up time and ask the chaser's speed
Major | algebra/coin-and-digit-problems.md:44 | Quick Check | Same frame as the Lito example (lines 23-35): count plus value, two coin types, asks the 5-peso count. Only coin values and totals changed | Ask for a different quantity, e.g. the total value of the 20-peso coins, or use three coin types
Minor | arithmetic-number-sense/compound-interest.md:80 | Quick Check | Near clone of the quarterly example (lines 61-71): swaps quarterly for semi-annual, 1 year each | Optional: use 1.5 years or a stated factor
Minor | algebra/motion-chase-problems.md:26 | picture marker | The picture shows 60 kph, 40 kph and a 40 km mark before any text names the van or jeepney. Those numbers first appear in the example at lines 34-48 | Move the marker to after line 39
Minor | data-interpretation/percentage-change.md:43 | picture marker | Picture values 100, 80, 100 appear only in the hidden Why (line 46), not in visible text. The picture is self-explaining, so no Blocker | Accept, or add one visible sentence naming the 100 to 80 to 100 case
Minor | algebra/motion-meeting-and-separation.md:29 | text | The multi-part-trip average-speed sentence is not used in this lesson | Cut it
Minor | algebra/motion-meeting-and-separation.md:47 | rule | "Add the two speeds" is stated without "both start at the same moment"; every example does | Add the condition to line 47
Minor | data-interpretation/unit-rates-and-direct-proportion.md:62 | Quick Check | Needs per hour to per minute (divide by 60). The lesson teaches only per minute to per hour (lines 47-53) | Add one line for the reverse direction
Minor | data-interpretation/unit-rates-and-direct-proportion.md:38 | Why | "Why does pesos go on top" has a grammar slip | "Why do pesos go on top"
Minor | arithmetic-number-sense/partitive-proportion-and-differences.md:145 | Speed Trick | The visible 2:3:4 split sits right below a Quick Check that uses 2:3:4. It does not give the key | Use another ratio in the trick
Minor | arithmetic-number-sense/simple-interest.md:22 | rule | "fixed principal" reads against lines 42-50, where a payment reduces the principal | Say "fixed principal for the period"

## Rule scope (rule-list tool, all 12 lessons)

Every printed line was read. No counterexample found for any "only", "never", "every", "all" or "means" sentence. The only
missing conditions are the two above (markup line 173, meeting line 47). Tiered commission (commission line 49) is stated
as a definition, so "each rate only on its band" holds.

## Pictures (19 SVGs read as visible text)

All OK: no picture shows a Quick Check or Try key, none contradicts the text beside it, none only repeats it. Scale checks
agree (simple interest 1,080/4,000 and 2,920/18,000, compound Year 2 at 110/100, commission 40/40/30 of 110, markup 200/800
and 20/25, successive 200:240:440, remaining work 40:80, partitive 4 boxes and 3:5, age 4a with equal +6 pieces).

| Picture | Result |
|---|---|
| simple-interest 01 | OK |
| compound-interest 01 | OK |
| commission-and-sales-tax 01 | OK |
| markup-on-cost 01, 02 | OK, OK |
| successive-percentages 01 | OK |
| inverse-proportion 01 | OK |
| partitive 01, 02 | OK, OK |
| motion-chase 01 | OK, 1 Minor (marker spot) |
| motion-meeting 01 | OK |
| pilot: percentage-base 01, 02; discounted-prices 01; mixture 01; age 01; work-rate 01; decimal 01 | OK |
| pilot: percentage-change 01 | OK, 1 Minor |

## Per lesson (Blocker / Major / Minor)

- simple-interest: 0 / 0 / 1
- compound-interest: 0 / 0 / 1
- commission-and-sales-tax: OK
- markup-on-cost: 0 / 2 / 0
- successive-percentages-and-increases: OK
- direct-proportion-and-travel: OK
- inverse-proportion-and-remaining-work: OK
- partitive-proportion-and-differences: 0 / 0 / 1
- unit-rates-and-direct-proportion: 0 / 0 / 2
- coin-and-digit-problems: 0 / 1 / 0
- motion-chase-problems: 0 / 1 / 1
- motion-meeting-and-separation: 0 / 0 / 2
- pilot picture lines: percentage-change 0 / 0 / 1; the other six OK

PRECHECK VERDICT: PASS (0 Blockers, 4 Majors)
