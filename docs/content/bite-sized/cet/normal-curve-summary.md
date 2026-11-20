# Normal curve lesson

FAIL on the shipping pool gate. DepEd coverage, lesson size, nothing-dropped, the authored pool, and importer validation pass.
Main policy revision `4fe2f090fde67fc574a6583e6f2217e36027b00e`.

- DepEd SHS Core Statistics and Probability curriculum guide, Grade 11/12, pp. 1–2. M11/12SP-IIIa-4 “illustrates a probability distribution for a discrete random variable and its properties.” M11/12SP-IIIc-1 “illustrates a normal random variable and its characteristics.” https://www.deped.gov.ph/wp-content/uploads/2022/02/SHS-Core_Statistics-and-Probability-CG.pdf
- M11/12SP-IIIc-3 “identifies regions under the normal curve corresponding to different standard normal values.” M11/12SP-IIIc-d-1 “computes probabilities and percentiles using the standard normal table.” DepEd also lists both in its essential competencies. https://www.deped.gov.ph/wp-content/uploads/2020/06/DO_s2020_012-1.pdf
- M11/12SP-IIIc-4 “Converts a normal random variable to a standard normal variable and vice versa.” https://lrmds.deped.gov.ph/detail/14521

Created `content/lessons/mathematics/statistics-and-probability/normal-distribution-areas.md`, `content/questions/mathematics/statistics-and-probability/normal-distribution-areas.yaml`, and `content/illustrations/mathematics/statistics-and-probability/normal-distribution-areas/01-area-to-the-left.svg`.
Updated `tools/lesson_author/outline.json` and `content/lesson-prerequisites.json`. The prerequisite is Population Variance and Standard Deviation.

Question IDs use the prefix `q-statistics-and-probability-normal-distribution-areas-`.

1. Cumulative area and probability: `0001`, `0005`, `0009`.
2. Normal curve shape and the 68-95-99.7 rule: `0002`, `0006`.
3. Convert between a value and its z-score: `0003`, `0007`.
4. Read and use standard normal table areas: `0004`, `0008`, `0010`.

DCAT uses `meta.exams: [dlsucet]`. Exam membership comes from linked questions. No separate exam map or roadmap edit was needed.
The lesson has 417 teaching words, two worked examples, and one trap. The authored pool has 10 questions for a quiz size of 6, split 4 easy, 4 medium, and 2 hard. All 10 keys checked two ways.
Both `dart run` commands hit a sandbox lock. With the existing package config, the importer exited 0 with 4,384 question records and empty stderr.
Direct `lesson_checks.dart` exited 1. Size and nothing-dropped had no findings for this lesson. The shipping pool had zero eligible questions for each key point and 0 of 6 overall. All 10 questions have `approved: false`.
SVG preflight passed (one file, zero failures). The legacy corpus audit exited 1 and flagged the requested illustration marker. The lesson had zero writing-pattern findings in the AI-tell sweep.
