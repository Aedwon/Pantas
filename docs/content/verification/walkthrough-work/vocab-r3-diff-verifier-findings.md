# Vocabulary round 3 diff verifier findings

Target: `git diff 9785415c0 HEAD -- content/lessons/language-proficiency/vocabulary/` (21 files). Read-only check against codex-vocab-r3-delta.md.

## 1. Codex delta rows

17 OPEN rows:
- prefix-clues-in-context:35: CLOSED (scoped to un- meaning not; see Minor)
- affect-and-effect:105 (107): CLOSED
- comparisons-and-human-actions:59: CLOSED (pair matches q-...-0003 "An explicit comparison"; note matches evidence)
- contrast-and-inference-clues:23 (62): CLOSED (wary chain ends at the full "cautious about" sentence)
- doubling-final-consonants:117: CLOSED (both Checks test a wrong spelling)
- english-word-elements:74: CLOSED (Minor below)
- feeling-strength-and-formality:83: CLOSED for snap up, but the replacement stem opens a new Major (below)
- feeling-strength-and-formality:104: CLOSED
- idioms-and-literal-meanings:23 (27, 48): CLOSED for full sentences, but the English chain lost its clue step (Major below)
- idioms-and-literal-meanings:92 (100): CLOSED
- its-and-it-is-or-it-has:25: CLOSED
- letters-sounds-and-vowel-order:45: CLOSED
- meaning-and-grammar-in-context:21: CLOSED
- ng-at-nang:98 (143): CLOSED
- paghahambing...:21: OPEN. Lead-ins now say "Sa bawat halimbawa" but still name no sentence and walk to no result. The clue notes added for the round 2 lead-in row were trimmed out, so the row is not closed.
- paghahambing...:79: CLOSED (Check 1 compares milyon-milyon with kakaunti; Check 4 swaps the verb)
- similar-and-opposite-meanings:109: CLOSED (make an effort replaces strong coffee; no longer modeled in the core)

2 new Blockers: its-and-it-is:107 CLOSED (gotten colder, fresh); similar-and-opposite:40 CLOSED (strong traffic replaces thick traffic).

11 new Majors: checking-longer-spellings:87 CLOSED; english-word-elements:21 CLOSED; letters:91 CLOSED; meaning-and-grammar:117 CLOSED; opposite-roles:75 CLOSED; paghahambing:169 CLOSED (rule, note, shortcut and checklist all carry "matalinghagang"); sila-at-sina:116 CLOSED (core, shortcut and checklist agree); sound-and-opposing:102 CLOSED; suffixes-and-word-jobs:96 CLOSED; suffixes-for-qualities:23 CLOSED; word-partners:100 CLOSED (clues in chain, note, checklist).

## 2. Findings in changed lines

Severity | file:line | problem | fix
--- | --- | --- | ---
Major | paghahambing-pagbibigay-katauhan-at-pagmamalabis.md:21, 40 | Still open from round 2: the lead-ins ("Sa bawat halimbawa, ...") name no sentence and do not mark the clue in it. The lists still print each label first. | Name the examples: "Sa 'parang banayad na agos' at 'ilaw ng silid-aralan', hanapin ang salitang panulad:" and the same for ngumiti/sumasayaw and bundok. Cut a line elsewhere for words.
Major | paghahambing-pagbibigay-katauhan-at-pagmamalabis.md:138 | Two steps run together on one line: "1. Ang pagyakap ay kilos ng tao.2. Binigyan ...". Step 2 will not render as its own step, and the line "Hindi literal na yumayakap ang gabi" was cut. | Put step 2 on its own line, with a blank-free numbered list as in the other examples.
Major | feeling-strength-and-formality.md:83-85 | "Which fits a formal notice: purchase or buy?" has two defensible answers. "Staff may buy supplies" is acceptable in a notice, and the core calls neutral words usable. | Ask "Which is the more formal word: purchase or buy?" and make the answer "purchase is more formal; buy is neutral."
Major | idioms-and-literal-meanings.md:25-26 | The trim removed the "Restart shows what happens" step. The meaning "start over" now follows the sentence with no clue named, unlike the Filipino chain, which keeps its clue line. | Restore one short clue line, for example "- *Restart her review* shows the meaning." and cut a word elsewhere.
Minor | similar-and-opposite-meanings.md:31-32 | The blank line before `:::pair #heavy-rain` was removed. Every other lesson has one. | Restore the blank line.
Minor | english-word-elements.md:76 | The Check is a phrase ("Pseudoscientific claims"), not a sentence. | "The pseudoscientific claims only looked scientific, so *false* fits."
Minor | prefix-clues-in-context.md:35 | The Why now uses "free-standing word" after "real base word" in the same block: two terms for one idea. | Use "real base word" in both.
Minor | ng-at-nang.md:143 | The Check repeats the solution line above it (bahagi ng araw, kaya ng). | Test the swap: "Alas-tres nang hapon" would need an action after *nang*.

Checked and fine: affect, checking-longer-spellings, comparisons, contrast, doubling, english-word-elements (omnivorous gloss), its (all three), letters (sleigh, niece, perceive), meaning-and-grammar, opposite-roles, sila-at-sina, sound-and-opposing, suffixes-and-word-jobs, suffixes-for-qualities, word-partners. Pair citations: only comparisons (as-if-personification) changed its Right/Wrong lines; it matches content/walkthrough-trap-evidence.json and the quiz bank. Other pair edits changed notes only.

VERDICT: FAIL (0 Blockers, 4 Majors, 4 Minors)
