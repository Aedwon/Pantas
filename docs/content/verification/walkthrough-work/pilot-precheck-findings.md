# Pilot pre-check findings (Worker 1), Math pilot, 10 lessons

Target: working tree on top of `edc956501`. Paths are under `content/lessons/mathematics/`.

Method note (honest limit): I printed each lesson file whole, so the `:::answer` text was on screen before I solved.
My solves were done from the stems by hand and match every key, but they are not strictly blind. Surface-match flags below
come from reading the visible text only. I did not scan the question bank (no grep allowed), so "unverified" items are
rule-scope concerns I could not confirm against exam questions. I used read-only `cat`, `ls` and `git show`, plus the
one allowed rule-list command.

My answers (all equal to the printed keys):
- Checks: age `c-4`, `52-c`; mixture 39%; work 1/10 per hour, 10 hours; discounts Php 480; base 216 shirts; identities -9;
  decimal 9/50; interest Php 8,600; percent change -10%; table 9,900,000 pesos.
- Tries: 11; 5 L; 15 h; Php 20,400; 87.5%; 5x^2+5x-5; 9/20; 4%; -15%; 56,000 pesos.
- Both table SVGs match the text: Operations Q3 = 27 (highlighted); Administration row 12, 15, 18, 11 (highlighted); unit title "in thousands of pesos".

Rule-list command: run for all 10 lessons (49 lines total). No printed line has a counterexample, except where noted below.

## Findings

Severity | file:line | item | problem | fix

Major | algebra/age-word-problems.md:73 | check | The check asks only for the sentence printed at line 44 ("for an age 4 years ago, subtract 4 from every person's age") with the same 4. A student can copy the printed rule without the "same shift for everyone" idea. | Use a new shift and add a step, e.g. both ages 7 years from now when father is $56-c$ and Carlo's age is $c$, then ask the gap or the sum.

Major | arithmetic-number-sense/percentage-base-and-fraction-division.md:99-123 | Example #1 | Example #1 repeats the core worked problem (40% is 72, base 180, 15% is 27) with identical numbers and a second copy of the same pair; line 157 repeats 180 and 27 a third time. Wordiness, and the example teaches nothing new. | Change Example #1 numbers and context, and drop the duplicate pair or keep it in only one place.

Major | arithmetic-number-sense/decimal-and-percent-conversions.md:63 | rule "percent to fraction: write the percent number over 100 and simplify" | Missing condition: for a decimal percent such as $12.5\%$ the result $\dfrac{12.5}{100}$ is not a fraction yet. Clear the decimal first ($12.5\%=\dfrac{125}{1,000}=\dfrac{1}{8}$). Discounted Prices uses $12.5\%$, so students meet it. | Add one sentence: if the percent has a decimal, clear it with the line 25-27 method before simplifying. Unverified against the bank.

Major | arithmetic-number-sense/simple-interest.md:45 | pair #interest-instead-of-total | The pair uses Php 50,000 and Php 3,750 with no stem or interest step visible anywhere above. The reader cannot see where 3,750 comes from (rate and time first appear at line 73). Missing connection. | Open the pair with the problem (principal, rate, time) and show $I=3,750$, or use the Php 10,000 example from line 30.

Major | data-interpretation/percentage-change.md:46 | :::why | The Why cites a drop from 100 to 80 and a rise back, but those numbers appear only in the hidden `FIGURE WANTED` comment (line 43). Nothing visible defines them. Missing connection. | State the setup in the Why itself: "A price falls from $100$ to $80$ (change $-20$), then rises back to $100$ (change $+20$)."

Major | data-interpretation/table-values-and-totals.md:127 (also line 21) | checklist rule "multiply your sum or cell reading by the stated unit before answering" | Missing condition: if the question asks for the answer in the table's own unit ("in thousands of pesos"), or for a ratio or percent, no multiplication is wanted. The lesson's examples always say "in pesos", so a student could learn "always multiply". Unverified against the bank. | Add: multiply only when the question asks for pesos (or the full amount); if it asks in the table's unit or for a ratio or percent, do not.

Minor | algebra/age-word-problems.md:62-63 | :::why | Introduces "gap between two ages" which no visible text mentions. | Open with "In the Ana example, the gap is $4a-a=3a$ at every time."

Minor | algebra/age-word-problems.md:88-91 | pair #wrong-person-or-time | The question that was asked is never printed; only the note implies "How old is Maya now?". | Add "Question: how old is Maya now?" to the pair or note.

Minor | algebra/mixture-word-problems.md:61 | pair #omit-original-volume | The equation uses 8 L at 50%, x L at 20%, target 30%, but the stem exists only in the hidden figure comment (line 44). | Add the stem in the note: "mixing x liters of $20\%$ into $8$ liters of $50\%$ to make $30\%$".

Minor | algebra/work-rate-problems.md:49-51 | pair #average-work-times | The pair never says that 6 and 3 are the solo hours; "the wall" appears only in the note. | Open the note with "Two painters take $6$ and $3$ hours alone on one wall."

Minor | algebra/work-rate-problems.md:32 | rule "same steady positive rate" | Fill-and-drain (leak or outlet) problems are a common exam type and need $r_{\text{fill}}-r_{\text{drain}}$. The lesson excludes them without saying what to do. Unverified against the bank. | If the bank has such items, add one sentence on subtracting a draining rate.

Minor | arithmetic-number-sense/percentage-base-and-fraction-division.md:113-117 | pair inside Example #1 | The pair sits between steps 2 and 3 and prints step 3's value (27) before step 3 is shown. | Move the pair after step 3.

Minor | arithmetic-number-sense/identities-and-like-terms.md:41 | pair #zero-multiplication | The Wrong line is two true equations; the error (treating 0 as the multiplicative identity) exists only in the note. | Make the Wrong line state the claim: "so $0$ is the multiplicative identity".

Minor | arithmetic-number-sense/identities-and-like-terms.md:145 | checklist rule "only matching exponents combine" | True as a necessary condition, but $3x^2$ and $2y^2$ have matching exponents and do not combine. | Say "only terms with the same letters and the same exponents combine".

Minor | arithmetic-number-sense/decimal-and-percent-conversions.md:123-124 | :::try | Line 33 already prints "35/100, divide by 5, 7/20"; the Try repeats that with 45/100. Easy to copy the pattern. | Use a fraction whose common factor differs from the printed one (e.g. $\dfrac{64}{100}$).

Minor | arithmetic-number-sense/simple-interest.md:52 | rule "time in years" | Only months are covered; day-based time (360 or 365) is not. Unverified against the bank. | Add a line if the bank has day-based items.

Minor | data-interpretation/percentage-change.md:75-76 | check | "What is the percentage change?" has two equal answers: $-10\%$ and "a 10% decrease". The key shows only the first. | Ask for "the signed percentage change", as Example #2 does, or accept both in the key.

## Per lesson

- algebra/age-word-problems.md: 0 Blockers, 1 Major, 2 Minor
- algebra/mixture-word-problems.md: 0 Blockers, 0 Major, 1 Minor
- algebra/work-rate-problems.md: 0 Blockers, 0 Major, 2 Minor
- arithmetic-number-sense/discounted-prices.md: OK
- arithmetic-number-sense/percentage-base-and-fraction-division.md: 0 Blockers, 1 Major, 1 Minor
- arithmetic-number-sense/identities-and-like-terms.md: 0 Blockers, 0 Major, 2 Minor
- arithmetic-number-sense/decimal-and-percent-conversions.md: 0 Blockers, 1 Major, 1 Minor
- arithmetic-number-sense/simple-interest.md: 0 Blockers, 1 Major, 1 Minor
- data-interpretation/percentage-change.md: 0 Blockers, 1 Major, 1 Minor
- data-interpretation/table-values-and-totals.md: 0 Blockers, 1 Major, 0 Minor

Checks and tries: every key matches my solve, no second defensible answer except the percent-change sign note above, no key printed
in a visible line, and no check is a frame clone of the example or pair above it.

PRECHECK VERDICT: PASS
(0 Blockers, 6 Majors, 11 Minors)
