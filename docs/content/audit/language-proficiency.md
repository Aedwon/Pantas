# Language Proficiency — Audit Findings

Lessons read: 19 across vocabulary (6), grammar-and-structure (10),
language-application (3). This subject holds the systemic "underline"
defect you flagged.

## The underline / emphasis defect (systemic — needs one rendering decision)

Markdown has no native underline, so questions written for underlined
target words either got their emphasis silently swapped (to bold or
italic, which now contradicts the word "underlined") or lost their marking
entirely. This blocks the student: the instruction refers to a cue that
isn't visually there or doesn't match.

### LANG-APP-001 [blocker] error-identification.md:40 — "underlined portion" is actually italic
Evidence: "Choose the best correction for the underlined portion: '… *along
with their supervisor* …'" — the portion is italicized, not underlined.
Fix: change "underlined" to match the chosen convention (see decision).

### LANG-VOC-001 [blocker] context-clues.md:32 — "underlined word" is actually bold
Evidence: `vocabulary/context-clues.md:32` "the underlined word" but
**edict** is bold.

### LANG-VOC-002 [blocker] context-clues.md:81 — "underlined term" is actually bold
Evidence: `vocabulary/context-clues.md:81` "the underlined term" but
**platitudes** is bold.

### LANG-VOC-003 [blocker] spelling-rules.md:24 — four "underlined words" are not marked at all
Evidence: `vocabulary/spelling-rules.md:24` "the $4$ underlined words in
this sentence: 'The chief of police could not concieve why the strange
neighbor would seize the stolen goods.'" — none of chief / concieve /
neighbor / seize is underlined or otherwise marked; the reader cannot tell
which four words are the candidates except by reading the A–D list.
Fix: mark the four candidate words with the chosen convention.

**Decision needed (drives style guide v2):** pick ONE rendering for a
"target word" in a question. Options: (a) **bold** consistently, and change
every "underlined" to "in bold"; (b) `<u>…</u>` HTML if the Flutter
markdown renderer passes it through (must verify — the style guide
currently forbids raw HTML except ILLUSTRATION comments); (c) a fixed
delimiter like «angle-quotes». Recommend (a) bold + reword, since it needs
no renderer change and the corpus already bolds these words in three of
four cases.

## Answer-leaking questions

### LANG-VOC-004 [important] context-clues.md:32 — the question defines its own answer
Evidence: "The king's **edict**, *or official command*, forced all
citizens…" The appositive "or official command" hands over the meaning;
the correct choice is C) law. A vocabulary item that glosses its own target
word tests nothing.
Fix: remove the appositive so the surrounding context (taxes, citizens,
crown, "forced") is what signals the meaning — that is the actual
context-clue skill.

## Filipino coverage

### LANG-GRA-001 [important] grammar lessons are largely English-only
Evidence: 7 of 10 `grammar-and-structure/` lessons contain no Filipino
content (modifiers, parallelism, phrases-and-clauses, pronoun-antecedent,
punctuation, redundancy/double-negatives, sentence-structure,
tenses-and-voice). UPCAT and USTET test Language Proficiency in Filipino;
the outline names Filipino counterparts (Bahagi ng Pananalita, Wastong
Gamit ng Salita). Vocabulary coverage is fine (idioms include Sawikain at
Tayutay; confusing-words covers Nang vs. Ng).
Fix: add a short Filipino counterpart note or example to the grammar
lessons where a Filipino analogue is tested (subject-verb agreement /
wastong gamit, pronoun use, punctuation). Confirms OUTLINE-001.

## Structure / extra sections (keep)
- LANG-VOC-005 [polish] extra sections "Important Filipino Terms"
  (idioms), "Must-Know Word Parts" (root-words), "Using Context Clues"
  (synonyms-antonyms) are legitimate topical sections — keep. Logged so
  the STRUCT sweep lines are accounted for.

## Template fit — proposal for Language Proficiency
The five-section template fits, but vocabulary/grammar lessons rarely have
"Speed Tricks" worth the name; several already replace it with a topical
section. Recommend the style guide explicitly allow a **"Common
Confusions"** or **"Usage Notes"** section in place of Speed Tricks for
language lessons.

## Dismissed sweep lines
- `FORMULA … spelling-rules.md:22 [c,e,f,i,n,o,v]` — the letters are from
  the "I before E except after C" rule, not a math formula. False positive.
- `DEVICE … root-words-prefixes-suffixes.md`, `synonyms-and-antonyms.md`,
  `spelling-rules.md:49` choice-format lines — resolved: these use inline
  "A. … B. …" choices the final device sweep accepts. No action.
