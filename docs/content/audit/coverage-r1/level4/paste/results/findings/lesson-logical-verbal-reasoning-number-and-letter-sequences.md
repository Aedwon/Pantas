# Number and Letter Sequences

Lesson: `lesson-logical-verbal-reasoning-number-and-letter-sequences`. Lesson version: `5e71c398b57a`. Standards: `710d7062b594`.

## Findings from the chat read

- **B03** (Blocker; one read, paste run)
  - Quote: "Find the intended next term: $4,9,14,19,\ldots$"
  - Problem: This Reasoning example has no figure or ILLUSTRATION placeholder, even though the subject-fit standard says every Reasoning example is figure-driven. The same required figure is absent from Examples #2 through #4.
- **B08** (Minor; one read, paste run)
  - Quote: "All shown consecutive differences are $+5$, so the simple arithmetic continuation gives **24**."
  - Problem: The answer number 24 appears in prose as bold text instead of inline math, violating the rule that numbers in prose must be inside $...$.
- **B08** (Minor; one read, paste run)
  - Quote: "The differences are $1,2,3,4$. Continuing that simple difference pattern with $+5$ gives **17**."
  - Problem: The answer number 17 appears in prose as bold text instead of inline math, so the number is not wrapped in $...$.
- **B08** (Minor; one read, paste run)
  - Quote: "4. Letter 16 is **P**."
  - Problem: The number 16 appears in prose outside inline math; it should be written inside $...$ under the lesson math-notation rule.
- **L02** (Major; one read, paste run)
  - Quote: "A finite list does **not** mathematically determine one unique continuation."
  - Problem: This sentence uses abstract terms such as “finite,” “mathematically determine,” and “unique continuation,” making the teaching prose harder than the required Grade 5 level.
- **L17** (Major; one read, paste run)
  - Quote: "**Start with simple transformations.** Check constant differences, ratios, alternating positions, repeated operations, and simple recurrences."
  - Problem: This content is placed in a Speed Tricks & Shortcuts section, but the subject-fit rule for Reasoning requires the reduced Core Concept → Examples → Traps layout and says to drop Speed Tricks.
- **L18** (Major; one read, paste run)
  - Quote: "Find the intended next letter: $B,D,G,K,\ldots$"
  - Problem: The worked examples cover arithmetic, geometric, changing-difference, and alphabet-position patterns, but omit distinct numerical cases taught in Core Concept: interleaved odd/even rules, alternating operations, and recurrence patterns.
- **L19** (Major if a step is skipped, otherwise Minor; one read, paste run)
  - Quote: "All shown consecutive differences are $+5$, so the simple arithmetic continuation gives **24**."
  - Problem: Example #1 gives the whole solution as prose instead of numbered steps and provides no display equation for the key computation.
- **L19** (Major if a step is skipped, otherwise Minor; one read, paste run)
  - Quote: "Each term is multiplied by $3$, so the simple geometric continuation gives"
  - Problem: Example #2 has a display equation, but the solution is not presented as a numbered step list as required.
- **L19** (Major if a step is skipped, otherwise Minor; one read, paste run)
  - Quote: "The differences are $1,2,3,4$. Continuing that simple difference pattern with $+5$ gives **17**."
  - Problem: Example #3 gives the reasoning in prose instead of numbered steps and has no display equation for the key computation.
- **L19** (Major if a step is skipped, otherwise Minor; one read, paste run)
  - Quote: "1. Convert to positions: $2,4,7,11$. 2. Differences are $2,3,4$. 3. Continuing with difference $5$ gives $16$. 4. Letter 16 is **P**."
  - Problem: Example #4 uses numbered steps, but its key conversions and difference computations remain inline instead of being shown as display equations.
- **L25** (Major; one read, paste run)
  - Quote: "- **Geometric:** constant nonzero ratio, e.g. $3,6,12,24,\ldots$."
  - Problem: The term “ratio” is needed to understand the geometric pattern, but it is used without being explained, and there is no prerequisite lesson supplying that meaning.
- **L26** (Major; one read, paste run)
  - Quote: "- **Recurrence:** later terms depend on earlier terms, as in the Fibonacci sequence."
  - Problem: The lesson names Fibonacci as the recurrence example but never explains its sum-of-the-two-previous-terms rule, so this concept is named without showing how it works.

## Findings from the script

- **B06** (Minor), line 28: em dash. Text: "| 2 | 2 | — |"
- **L22** (Major), line 26: table. Text: "| Term | Value | Difference |"
- **L22** (Major), line 27: table. Text: "| --- | ---: | ---: |"
- **L22** (Major), line 28: table. Text: "| 2 | 2 | — |"
- **L22** (Major), line 29: table. Text: "| 5 | 5 | +3 |"
- **L22** (Major), line 30: table. Text: "| 8 | 8 | +3 |"
- **L22** (Major), line 31: table. Text: "| 11 | 11 | +3 |"

## Illustration review

- missing, medium priority, concept, code. At: "Find the intended next term: $4,9,14,19,\ldots$". Draw: Show $4\to9\to14\to19\to?$ with a $+5$ arc above each jump.. Why: A repeated-jump diagram makes the constant-difference rule visible at a glance.
- missing, medium priority, concept, code. At: "Find the intended next term: $2,6,18,54,\ldots$". Draw: Show $2\to6\to18\to54\to?$ with a $\times3$ label on every arrow.. Why: The arrows make the constant-ratio transformation and its repetition easy to see.
- missing, medium priority, concept, code. At: "Find the intended next term: $2,3,5,8,12,\ldots$". Draw: Show the sequence with first-difference labels $+1,+2,+3,+4,+5$ in a second row beneath it.. Why: A difference ladder makes the changing-difference pattern clearer than prose alone.
- missing, medium priority, concept, code. At: "Find the intended next letter: $B,D,G,K,\ldots$". Draw: Show B(2) → D(4) → G(7) → K(11) → P(16) with jump labels $+2,+3,+4,+5$.. Why: Pairing letters with positions lets students see both the alphabet conversion and the growing differences.
