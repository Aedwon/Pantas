# Batch 3 Grammar and Structure Round 2 audit

Audit target `a5dea5097`, compared with Round 1 at `257b7042c`. Policy and baseline references are pinned to the commits in the brief. Repository reads use commit snapshots. The lead supplied the locked Dart gate result of zero Grammar and Structure violations.

## Full-batch regression sweep

- All 52 active lessons are within 150 to 900 pre-tap whitespace tokens. Counts run from 606 to 851. Against `1d846e4ba`, 27 of the 51 non-board lessons are shorter and 24 are unchanged. The board lesson matches the approved `b8640b532` sample byte-for-byte.
- The 14 active Filipino lessons have zero English parenthetical glosses and zero instances of `nasa bold`. The style sweep found zero em or en dashes, inline backticks, `\frac` commands, British spelling hits, or AI attribution and vendor strings across the 52 active lessons.
- All 30 figure comments match the worklist verbatim by lesson path. All 11 retired parents and 11 Grammar question YAMLs are byte-identical to `a7cc22b6b`. All 52 active `keyPoints` match that base.
- All 142 pair blocks and 279 citations are present. Every citation matches an exact non-correct choice in the same lesson's question YAML. All 52 checklists and 144 links resolve. Each of the 52 final `:::try` blocks has one `**Check:**` inside its `:::answer`.

## Remaining findings

- **Major** | `past-perfect-earlier-completion.md:26,54,103-104` | The wording still reads as a ban on past perfect in the later event. The checklist also tells learners to use it whenever one event finished first, then accepts simple past in the next item. State the earlier-reference rule affirmatively. Limit the checklist instruction to prompts asking for past perfect or explicit earlier completion. [British Council](https://learnenglish.britishcouncil.org/free-resources/grammar/b1-b2/past-perfect)
- **Major** | `changing-voice-and-get-passives.md:19,23` | The active source supplies the direct or prepositional object. Line 23 incorrectly assigns that requirement to the passive clause. The promoted object is now the subject in the lesson's own example. [Cambridge Grammar](https://dictionary.cambridge.org/grammar/british-grammar/passive-forms)
- **Major** | `dangling-modifiers-and-their-subjects.md:52` | The revised rule says a subjectless *while* or *after* opening still dangles. It works when the main subject is its implied doer, as in “While crossing the bridge, Marco lost his hat.” [Purdue OWL](https://owl.purdue.edu/owl/general_writing/mechanics/dangling_modifiers_and_how_to_correct_them.html)
- **Major** | `dangling-modifiers-and-their-subjects.md:97-111` | The new sentences are fresh. Visible step 2 still gives away the diagnosis by naming the mismatch with *the strong wind* and supplying the criterion that singles out (B). Ask who crossed the bridge in each version and leave the diagnosis to the hidden answer.
- **Major** | `qualified-negatives-and-near-negatives.md:46,51,133,139` | The rule still makes *any* mandatory whenever a determiner is needed. “Hardly a sound” also works. Scope the warning about *not* and *no* to doubling the same negative, consistent with the lesson's key point. Drop the blanket “not zero” claim and let each worked sentence establish its outcome. [Cambridge on *hardly*](https://dictionary.cambridge.org/grammar/british-grammar/hardly), [Cambridge on *scarcely*](https://dictionary.cambridge.org/us/grammar/british-grammar/scarcely)
- **Major** | `qualified-negatives-and-near-negatives.md:116-128` | Submitting unspecified forms on time does not confirm the audit was finished. Visible step 2 also gives “with great difficulty,” completing the first answer with step 1. State the completion in the stem and leave the meaning of *scarcely* for the try. The *seldom* check already verifies *rarely* directly.
- **Major** | `pokus-at-papel-ng-paksa.md:104-116` | The visible phrase *bagay na binili* gives the exact verb the learner must supply. Use “Gawing *ang aklat* ang *ng aklat*.”
- **Major** | `ugnayan-ng-pandiwa-at-paksa.md:27-30` | The pair now shows Rosa and the mango as the respective subjects. Its Wrong line drops the cited `q-grammar-and-structure-tenses-and-voice-0026` direction of calling both verbs actor-focused because Mara did both actions. Restore that direction and tie each of the three Wrong readings to its own sentence.
- **Major** | `hugnayan-langkapan-at-ayos-ng-salaysay.md:110-122` | The prompt lists the three markers in answer order. The visible steps supply the first two again, leaving the learner to copy *panghuli*. Name the three events in natural Filipino and ask the learner to supply the last marker without an ordered list.

- **Minor** | `changing-voice-and-get-passives.md:40-50` | The first sentence of the lead-in repeats the previous section. Keep one line asking the reader to change voice while preserving tense and aspect. This lesson gained five pre-tap tokens from Round 1 and still meets the locked baseline.
- **Minor** | `dangling-modifiers-and-their-subjects.md:47-50,55,59` | The paired examples now show both faulty openings. The second repair drops the fact that the barking startled Liza. Keep the original main clause and remove the parentheticals that narrate changes already shown by the arrows.
- **Minor** | `commas-with-openings-and-extra-information.md:19-21,41,118,123-124` | The shortcut and checklist blur the lesson's distinction between introductory dependent clauses and short introductory words or phrases. State where the exception applies. Extra detail can also describe an identified thing, so widen “someone already known.”
- **Minor** | `pokus-at-papel-ng-paksa.md:42,100,126` | The explanation says *ang* or *si* moves. The example changes *si Mara* to *ni Mara* and *ng liham* to *ang liham*. Say the markers change with the subject. Use *pandiwang nakapokus sa tagaganap* in the checklist. Ask “Sino ang nagluto?” and “Ano ang niluto?” directly in the check.
- **Minor** | `mga-anyo-ng-panghalip-panao.md:111,115` | The new first sentence repeats the recipient role that step 1 is meant to establish. Start with the instruction to replace *sa mga magulang*. The new sentence and hidden check already support that task.
- **Minor** | `hugnayan-langkapan-at-ayos-ng-salaysay.md:40-44` | The revised lead-in asks the reader to count the clauses joined by *at* and introduced by *dahil*. The worked line leaves the boundaries and count in the figure comment. Bracket the clauses and add “2 makapag-iisa + 1 di-makapag-iisa” on that line.

## Round 1 follow-up

All ten final try stems use fresh sentences. The sampled review covered 28 pairs and 55 cited choices. The pair issue in `ugnayan-ng-pandiwa-at-paksa.md` is listed above.

| Lesson | Round 1 disposition |
| --- | --- |
| Groups and Indefinite Pronouns | The pronoun substitution check uses complete replacements. The lead-in ties the matching task to the examples. The pair covers both the many-people reading of *everybody* and attraction to *files*. |
| Past Perfect | Both checks verify the given sentences directly. The rule and checklist still need the scope correction above. |
| Changing Voice | The tense and aspect rule now preserves the source form. The prepositional passive correction still assigns the object to the wrong clause. |
| Dangling Modifiers | Both original openings now appear, and the diagnosis check tests *the exam* directly. The second repair and the visible try cue still need the changes above. |
| Commas | The relative-clause rule handles *that* and limits the two-comma instruction to mid-sentence detail. The final choice prompt is neutral. The shortcut and checklist still need the exception scoped. |
| Qualified Negatives | The lead-in connects each adverb to its sentence. *Not uncommon* now reads *fairly common*. Worklist #70 separates frequency, completion, and judgment. The general near-negative rule and final audit example still need the fixes above. |
| Pokus | The glosses are gone. The contrast uses the same root and participants. The worked diagnosis asks who ate, and it uses *nakapokus sa tagaganap*. The visible try step and the remaining marker and phrasing issues are listed above. |
| Mga Anyo | The gloss is gone. One referent is now possible across all three forms. The example uses *kailangan ng tagaganap*, its check drops the distractor recap, and the pair distinguishes *namin* from *ninyo*. The try stem still repeats step 1. |
| Ugnayan | The glosses are gone. The lead-in links the paksa to the verbal focus, and the Dina example explicitly changes *ng sopas* to *ang sopas*. Rosa's corrected Right line resolves the original omission. The shared-actor distractor still needs coverage in that pair. |
| Hugnayan at Langkapan | The glosses are gone and the minimum dependent-clause count is restored. Worklist #78 labels the counts as examples. *Pang-simula* and *pang-gitna* are gone. The visible count and ordered try choices still need the changes above. |

VERDICT: FAIL (0 Blockers, 9 Majors, 6 Minors)
STAGE-DONE
