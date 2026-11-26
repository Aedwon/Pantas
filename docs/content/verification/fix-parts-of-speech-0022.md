# Verification Record: Fix `q-grammar-and-structure-parts-of-speech-0022` (`pitaka`)

- Date: November 26, 2026 (Claude lesson lead, E-198, session 3; manager ruling 4)
- Question: `q-grammar-and-structure-parts-of-speech-0022` (`content/questions/language-proficiency/grammar-and-structure/parts-of-speech.yaml`)
- Target lesson: `lesson-grammar-and-structure-pang-ukol-pangatnig-at-pandamdam` (`keyPoint: 2`)

## Defect fixed

The stem's sentence was "Naku! Naiwan ko sa bahay ang aking pagkakakilanlan." *Pagkakakilanlan* means identity or identification as an abstract noun; one does not leave it at home. The intended object was a concrete thing. The stem now reads "Naku! Naiwan ko sa bahay ang aking pitaka." (wallet). The key, choices, rationales and explanation are unchanged. The key was already correct; the defect was an unnatural sentence, not a wrong answer.

## Independent blind solve (key, explanation and rationales hidden)

| Question ID | Target Lesson | Key Point | Blind Solve | YAML Key | Verdict |
|---|---|---|---|---|---|
| `q-grammar-and-structure-parts-of-speech-0022` | `lesson-grammar-and-structure-pang-ukol-pangatnig-at-pandamdam` | 2 | Pandamdam | Pandamdam | AGREE |

- Solver: a separate Claude Sonnet 5.5 agent given only the stem and the four choices. Its verdict: "Naku" is an interjection expressing dismay; the stem is natural, clear Filipino; no other choice is defensible.
- Trap-pair sync: the lesson's pair `#pandamdam-laban-sa-pangngalan` uses its own sentence (*susi*) and cites this question's wrong choices by text (Pangngalan, Pangatnig, Pandiwa), which did not change.
