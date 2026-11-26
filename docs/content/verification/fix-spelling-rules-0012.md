# Verification Record: Fix `q-vocabulary-spelling-rules-0012` (`kuwento`)

- Date: November 26, 2026
- Question: `q-vocabulary-spelling-rules-0012` (`content/questions/language-proficiency/vocabulary/spelling-rules.yaml`)
- Target lesson: `lesson-vocabulary-baybay-ng-hiram-na-salita` (`keyPoint: 1`)
- Primary sources:
  - Komisyon sa Wikang Filipino (KWF), *Ortograpiyang Pambansa* (DepEd Order No. 34, s. 2013, `DO_s2013_034.pdf`), *Kasong Kambal-Patinig*, *Unang Kataliwasan*: retain `u` and insert `w` when a vowel pair follows a consonant in the first syllable (`cuento` -> `kuwento`).
  - KWF *Diksiyonaryo ng Wikang Filipino* (`kwfdiksiyonaryo.ph`): lists `kuwento` as the official standardized Filipino spelling and treats `kwento` as an informal/superseded shortened form.

## Defect Fixed

The previous question keyed `"Kwento / kuwento"` and stated that both forms are accepted equally in KWF *Ortograpiyang Pambansa*, contradicting both the KWF *Unang Kataliwasan* rule and the linked lesson `baybay-ng-hiram-na-salita.md`.

## Independent Blind Solve (Key, Explanation, and Rationales Hidden)

| Question ID | Target Lesson | Key Point | Blind Solve | YAML Key | Verdict |
|---|---|---|---|---|---|
| `q-vocabulary-spelling-rules-0012` | `lesson-vocabulary-baybay-ng-hiram-na-salita` | 1 | `kuwento` | `kuwento` | AGREE |

- Unambiguous realistic CSE Filipino stem: verified.
- Single defensible official Filipino spelling key (`kuwento`): verified; distractors `kwento`, `kuento`, and `cuento` are each clearly wrong under KWF *Ortograpiyang Pambansa*.
- Trap-pair sync: `#isingit-ang-w` in `content/walkthrough-trap-evidence.json` cites `q-vocabulary-spelling-rules-0012` wrong choice `"kuento"`, matching `baybay-ng-hiram-na-salita.md`.

## Prod content root (CSE release lead r9, Nov 26)

Copied from `content/lesson-walkthrough-cse-r1` 15e8f6c0c into `content/cse-key-fixes-r1`: the question and its ledger entry only. The walk-through trap evidence file and lessons stay on the walk-through branch.
