# E1: CSE exam scope (read-only)

Corpus: Pantas-wt-content-qa-r2, branch content/question-qa-r2, HEAD 765c5dc0fa5586281047bf4f7b30d09ab3707887 (matches expected).
Audit inputs: Pantas-wt-content-coverage-audit-r1 (lesson-exam-tags.json, level4/packets).
Policy: AGENTS.md, WORKFLOW.md, SUBAGENTS.md read from Aedwon/Pantas main. This task changed nothing.

## Methods
- Question counts: YAML parsed (Ruby Psych). Counted items under top-level `questions` only. Some files also have other `- id:` lists (e.g. passages); a plain regex overcounts those 13 files, so it was not used.
- Lesson front matter: 158 lessons, none has an `exams` field. Exam tags come only from lesson-exam-tags.json (lesson side) and question meta.exams (question side).
- Lesson to question file: content/lessons/S/T/slug.md maps to content/questions/S/T/slug.yaml. All 158 map to a file.

## 1. Lesson tags (lesson-exam-tags.json, 158 lessons)
- cse-professional: 64
- cse-subprofessional: 62
- both: 55
- union: 71

## 2. Question files (meta.exams, 158 files, 3163 questions)
- cse-pro: 53 files, 1060 questions
- cse-sub: 44 files, 880 questions
- both: 42 files
- union: 55 files, 1100 questions

## 3. Disagreements
A. Lesson tagged CSE, question file has no CSE tag: 21 (all have a question file).
B. Question file CSE-tagged, lesson not in lesson union: 5 (all reasoning/spatial-abstract-reasoning: figure-grouping, figure-matrices, figure-series, mental-rotation-3d-visualization, paper-folding-and-cutting). Each is tagged cse-pro only.
C. Both sides have a CSE tag, but pro or sub differ: 6 (idioms-and-figures-of-speech, spelling-rules, business-math, divisibility-rules, rates-ratios-and-percentages-in-context, tables-and-charts).
Lessons with no question file: 0.
Total rows with any tag mismatch: 32 (21 + 5 + 6).

## 4. Scope
Final union: 76 lessons (71 from lesson tags plus 5 from question tags). Per-lesson table: e1-cse-scope.tsv.
Note: question counts are whole-file totals, since files mix exam tags.

## 5. Level 4 packets
- 168 packets for 158 lessons. Ten lessons have two packets.
- A packet maps to a lesson by the `_id` in the lesson front matter inside LESSON START/END. The header only gives the packet number.
- Planted packets: 10. Each shares its `_id` with a real packet for the same lesson. The planted body differs from the corpus lesson file (changed figures, rules, or answers). The real packet matches the corpus file exactly.
- Recognize a planted packet: compare the lesson block with content/lessons/<path>. Mismatch means planted.

Planted packets (real partner in brackets):
- L4-7442 rates-ratios-and-percentages-in-context [L4-1255]
- L4-1274 layers-of-the-earth [L4-2781]
- L4-1360 speeches [L4-4180]
- L4-1575 the-civil-service-commission [L4-6251]
- L4-7332 mole-concept [L4-2786]
- L4-3807 atomic-structure [L4-7344]
- L4-8177 number-and-letter-sequences [L4-4857]
- L4-5501 order-of-operations [L4-5550]
- L4-7668 polynomials [L4-5669]
- L4-6370 sentence-completion [L4-9059]

## 6. Recommendation for the audit
Use the packet that matches the corpus file. Do not audit the planted packets as lessons. Decide how to handle disagreements A to C before the audit scope is final.
