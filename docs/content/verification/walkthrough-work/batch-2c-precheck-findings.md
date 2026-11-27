# Blind pre-check, Math batch 2c (Worker 1)

Target: working tree of the content-lesson-walkthrough worktree at commit `5a1526ea0` (Math batch 2c: pre-check brief).
Method: pilot brief steps 1 to 7 on each `:::check` and `:::try`; broad-rule list run per lesson from the main tools
checkout (main `8ed6a0b4f`) and every printed line read; every ILLUSTRATION marker read with its SVG (8 pictures) and the
code figure in `real-number-sets.md` read through its JSON and the renderer. The three linked question files
(`divisibility-rules.yaml`, `prime-factorization-gcf-lcm.yaml`, `real-imaginary-numbers.yaml`) were read to find rules a quiz
needs. Paths below are under `content/lessons/mathematics/arithmetic-number-sense/`.

My solves of the 11 checks and 11 tries all matched the printed keys, and no item has a second defensible answer.
Checks: no (6 and 10 do not give 60); d = 2, 5 or 8; yes (1,386); 8; 30; 120; 31; 28; 25; -5+12i; 1-2i.
Tries: 13; B (36,420); 354,211; no for 8 (yes for 4); 42; 80; 2^3 x 3^2 x 5; 61; B; -1/2 + 5/2 i; 6i.
No picture shows or makes copyable the key of a check or try. No picture contradicts its lesson text. Picture numbers match
the beside text; the drawn scales are right (timelines 70 px per 15 min and 93.3 px per 20 min; number line 3.5 px per unit
with marks at 2, 38, 74; bracket spans cover the last 1, 2 and 3 digits of 48,672; cycle arrows run clockwise).

## Findings

Format: `Severity | file:line | item | problem | fix`

Blocker | prime-factors-and-powers.md:27 | rule sentence | "To test a number below $49$, such as $29$, check whether $2, 3, 5$ divide it evenly. None of them divides $29$, so $29$ is prime." As a rule it is false for $2$, $3$, $5$ (each is divisible by itself yet prime) and for $1$ (not prime). Line 42 repeats the same test. | Say "For a number from $7$ to $48$, check whether $2$, $3$ or $5$ divides it. If none does, it is prime."

Major | coprime-divisibility-tests.md:83 | pair pass-only-one-test | The pair says to check both $9$ and $11$ for $99$ but nothing in the lesson works a number with $9$ and $11$. Quiz 0010 ($3a4{,}5b2$) needs: no last-digit factor, so the $11$ difference $b-a$ lies from $-9$ to $9$ and must be $0$, then the digit sum $14+2a$ must be $18$. | Add one short worked line with numbers no quiz uses, showing the $11$ difference forcing $a=b$ and then the $9$ sum.
Major | coprime-divisibility-tests.md:170 | Common Coprime Splits ($88=8\times11$) | The split is listed with no worked numbers. Quiz 0013 ($5x3{,}4y6$) needs an unknown inside the last three digits for $8$ (a hundreds or tens digit, not the last digit; both examples above put the unknown last) and the $11$ difference $y-x-2$. | Add one worked line for an $8$-and-$11$ number with the unknown in the middle of the ending, with new numbers.
Major | coprime-divisibility-tests.md:65 | digit-sum ranges (lines 65, 75, 109, 135, 147) | Every example has exactly one multiple of $9$ in the range. Quiz 0012 ($72x4y$) needs a range holding two multiples ($18+x$ gives $x=0$ or $9$). The lesson never shows a case with two values of $x$. | Add a line or a case where the range holds two multiples of $9$ and both digits are kept (the pair at line 89 is the place).
Major | coprime-divisibility-tests.md:59 | display lines | Each digit-sum display ends at a partial expression ($6+x$, $11+x$, $16+x$, $20+x$) that the next display repeats after a line of prose (lines 62 to 68, 71 to 79, 107 to 113, 131 to 139, 143 to 150). | Merge into one chain per case ($3+2+x+1+0=6+x$, then $6+x=9$ with the range sentence before the chain) or end each display at a value.
Major | digit-sums-and-six.md:91 | Example 1 | The display $4+7+x+8+1=20+x$ ends at a partial expression, a sentence follows, and the next display ($20+x=27$) repeats it. | Put the range sentence before the display and carry the chain to $20+x=27$.
Major | divisibility-by-seven-and-eleven.md:128 | Example 2 steps 2 to 4 | $3+4+b=7+b$ and $5+2+1=8$ carry no label saying which is the odd-position group and which the even-position group. $(7+b)-8=b-1$ ends at a partial expression, a sentence follows, and $b-1=0$ repeats it. | Name each group in the lead-in ("odd positions: $3+4+b$, even positions: $5+2+1$") and carry the chain to $b-1=0$.
Major | last-digit-divisibility.md:33 | pair add-digits-for-four | The Wrong line adds the digits of $4{,}516$ and gets $16$, which is divisible by $4$, so the wrong method gives the right verdict here. The note only asserts that adding digits does not test $4$. A student sees both methods pass. | Add one case where the digit sum passes but the number fails, for example $1{,}326$ (sum $12$, but $26\div4$ leaves $2$), or use that number in the pair.
Major | greatest-common-factor.md:54 | pair note | "That gives the LCM ($720$)" uses LCM, which part 3 of this series defines. A student at part 2 has not met it. | Say "That is a multiple of both numbers ($720$), which does not divide $48$."
Major | least-common-multiple.md:66 | schedule rule | "Check the time window carefully to see whether the starting time counts" has no worked numbers. Quizzes 0009 (count shared departures in a window, end time included), 0012 (first shared pass after a later time) and 0015 (round trips each vehicle completes by the first shared return, LCM divided by interval) all need later meeting times, which the lesson never shows. | Add one worked line: meetings at $0$, $L$, $2L$, and how many fall in a window; use numbers no quiz uses.
Major | imaginary-unit-and-powers.md:164 | speed trick | "Any four consecutive powers of $i$ add to $0$" has no worked sum. Quiz 0012 ($i+i^2+\dots+i^{99}$) needs the leftover terms after the full blocks ($99=4(24)+3$, so $i^{97}+i^{98}+i^{99}$ remain). | Add one worked sum with a leftover, using a different top exponent.
Major | real-number-sets.md:55 | rule sentence and Example 1 | The step $\sqrt{2}\times\sqrt{8}=\sqrt{16}$ (and the try's $\sqrt{12}\times\sqrt{3}=\sqrt{36}$) rests on $\sqrt{a}\times\sqrt{b}=\sqrt{ab}$, which this lesson never states. Only the imaginary-unit lesson states it, and that one comes later. | Add "For positive numbers, $\sqrt{a}\times\sqrt{b}=\sqrt{ab}$" before the line at 57.

Minor | coprime-divisibility-tests.md:45 | `:::check` | Two-way answer. The rule at line 29 and the pair at line 35 already say shared factors fail, so "no" is predictable; only the $30$ counterexample needs a solve. | Accept, or ask for the number that passes both but not $60$.
Minor | coprime-divisibility-tests.md:84 | pair | $a$ and $b$ are not introduced (the section above names only $x$ and $y$). | Say "digits $a$ and $b$".
Minor | coprime-divisibility-tests.md:135 | Example 2 steps 3 and 4 | "The only multiple of $9$ from $16$ to $25$" gives the range without saying $x$ is a digit (Example 1 says it). The step $16+x=18$ to $x=2$ shows no subtraction. | Add "since $x$ is a digit" and a $x=18-16$ line.
Minor | digit-sums-and-six.md:19 | rule sentence | Scope not stated (positive integers; negatives are handled only in the last-digit lesson). | Add "For a negative integer, test its positive value."
Minor | divisibility-by-seven-and-eleven.md:43 | why | $a$ is not defined (the number made by the digits left after removing $b$). | Say "where $b$ is the last digit and $a$ is the number the other digits make".
Minor | divisibility-by-seven-and-eleven.md:60 | pair total-sum-for-eleven | $1{,}234$ fails under both the right and the wrong method, so the pair never shows the wrong method changing a verdict. | Use a number the wrong method would accept, for example $1{,}221$-style check, or note that both fail here.
Minor | divisibility-by-seven-and-eleven.md:19 | rule sentence | Tests for $7$ and $11$ do not state they are for positive integers or how a one-digit number is handled. | Add the scope in one sentence.
Minor | last-digit-divisibility.md:58 | why | "Every $10$ is divisible by $2$, every $100$ is divisible by $4$" reads as if each ten were a number to test. | Say "every multiple of $10$ ... of $100$ ... of $1{,}000$".
Minor | greatest-common-factor.md:63 | `:::check` | Same frame as the $48$ and $180$ example (factor, keep shared primes, smaller powers) with new numbers. | Accept under the same-kind rule.
Minor | greatest-common-factor.md:45 | picture | The label "only in 180" sits under the $5$ only; the second $3$ in the $180$ row is also not shared, and the extra $2$s in the $48$ row are unlabeled. Outlines make it readable. | Optional: widen the label or add "not shared" under the unoutlined tiles.
Minor | least-common-multiple.md:161 | checklist | "multiply GCF times LCM before dividing by the known number" omits that the rule holds for two numbers only (line 78 says so). | Say "for two numbers".
Minor | least-common-multiple.md:140 | Example 2 | The step $\dfrac{16\times20}{4}$ to $4\times20$ shows no line for $16\div4=4$. | Add the division or show cancelling.
Minor | prime-factors-and-powers.md:42 | check answer | "so it is prime, and $30$ is not" is loose (the question already excludes $30$), and $31$ is the first number above $30$, so a guess works. | Cut "and $30$ is not".
Minor | prime-factors-and-powers.md:61 | rule sentence | "An exponent tells how many times a factor repeats" holds for whole-number exponents only. | Say "A whole-number exponent".
Minor | same-remainder-numbers.md:23 | rule sentence | "a valid remainder $r$" is not defined here (Example 1 says $r$ is smaller than every divisor). | Say "a remainder $r$ smaller than every divisor".
Minor | same-remainder-numbers.md:99 | pair forget-remainder | The Right line gives $L=120$ and $r=3$ with no divisors; they appear only in the note ($6$, $8$, $10$). | Put the divisors in the Right and Wrong lines.
Minor | real-number-sets.md:39 | rule sentence | "square roots of integers that are not perfect squares" is false for negative integers ($\sqrt{-7}$ is not real). | Say "positive integers".
Minor | real-number-sets.md:110 | `:::try` | Statements A and C are shown true, and D matches the core line at 37, so B is reachable by elimination. | Accept.
Minor | complex-products-and-quotients.md:55 | `:::check` | Quiz 0015 solves $(4+3i)z=23-14i$ by dividing both sides by $4+3i$; the lesson shows only the quotient form. | Optional: one line "if $(c+di)z=w$, then $z=\dfrac{w}{c+di}$".
Minor | complex-products-and-quotients.md:37 | display | $12-7i-10(-1)$ goes to $12-7i+10$ with no line removing the parentheses; each display also ends at a partial expression the next repeats (accepted as the lesson's uniform style). | Optional.
Minor | imaginary-unit-and-powers.md:93 | pair Right line | $\dfrac{-3}{i}=3i$ uses $\dfrac{1}{i}=-i$, which appears only in Speed Tricks at line 164. | Move the $\dfrac{1}{i}$ line above the pair or add "multiply top and bottom by $i$".
Minor | imaginary-unit-and-powers.md:69 | pair note | "Because $10$ does not divide evenly by $4$, the tens digit changes the remainder" is loose; $100$ divides by $4$, so the last two digits decide. | Say "The last two digits decide the remainder, not the last digit alone."
Minor | imaginary-unit-and-powers.md:72 | `:::check` | Same frame as the $i^{57}$ example (divide the exponent by $4$, read the cycle) with numbers swapped, plus a coefficient and a $+1$. | Accept under the same-kind rule.

Notes (no rating): raw word counts of the files are coprime 1,059, last-digit 1,022 and digit-sums 909 (they include front matter,
LaTeX and hidden blocks, so the visible count before a tap was not measured). Broad-rule lines were all read; the only false rule
is the Blocker above.

## Per lesson

- coprime-divisibility-tests.md: 0 Blockers, 4 Majors, 3 Minors
- digit-sums-and-six.md: 0 Blockers, 1 Major, 1 Minor
- divisibility-by-seven-and-eleven.md: 0 Blockers, 1 Major, 3 Minors
- last-digit-divisibility.md: 0 Blockers, 1 Major, 1 Minor
- greatest-common-factor.md: 0 Blockers, 1 Major, 2 Minors (one on the picture)
- least-common-multiple.md: 0 Blockers, 1 Major, 2 Minors
- prime-factors-and-powers.md: 1 Blocker, 0 Majors, 2 Minors
- same-remainder-numbers.md: 0 Blockers, 0 Majors, 2 Minors
- real-number-sets.md: 0 Blockers, 1 Major, 2 Minors
- complex-products-and-quotients.md: 0 Blockers, 0 Majors, 2 Minors
- imaginary-unit-and-powers.md: 0 Blockers, 1 Major, 3 Minors

## Per picture

- coprime-divisibility-tests 01 (prime tiles for 4 and 6): OK
- divisibility-by-seven-and-eleven 01 (alternating digit groups): OK
- last-digit-divisibility 01 (ending digits of 48,672): OK
- greatest-common-factor 01 (shared prime tiles): 1 Minor (label)
- least-common-multiple 01 (jeepney timelines): OK
- prime-factors-and-powers 01 (factor tree for 60): OK
- same-remainder-numbers 01 (number line of 36k+2): OK
- imaginary-unit-and-powers 01 (cycle of powers of i): OK
- real-number-sets code figure (nested boxes): OK (the renderer draws a fixed nesting: Real outermost, Irrational beside Rational, then Integers, Whole, Natural inside Rational; the `boxes` list does not change it)

PRECHECK VERDICT: FAIL (1 Blocker, 11 Majors)
