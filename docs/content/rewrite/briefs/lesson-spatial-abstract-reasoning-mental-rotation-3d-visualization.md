# Brief: Mental Rotation and 3D Visualization (Cube Nets and Shadows)

Lesson id: `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization`
Lesson path: `content/lessons/reasoning/spatial-abstract-reasoning/mental-rotation-3d-visualization.md`

Tagged exams: acet, dost-sei, sm-foundation, ustet, cse-professional

Rule: a rewrite may add CSE cases but never removes a case another tagged exam needs.

## Fix these

### 1. `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization|L18|0`
- Rule: L18
- Fix size: medium
- Quote:
> A cross net has one central square with four edge-neighbors and one extra square attached beyond one of those neighbors. If the center becomes the bottom, which face becomes the top?
- Problem: The example set covers cube nets and cylinder projections but never gives a worked paired-view mental-rotation comparison, leaving a distinct scenario in the recorded learning goal without an example.
- Triage reason: The title and Core Concept promise mental rotation, but no example compares two views of a turned object.

### 2. `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization|L26|0`
- Rule: L26
- Fix size: medium
- Quote:
> **For rotations, preserve handedness and adjacency.** A mirrored arrangement is not a rotation unless the object itself has the relevant symmetry.
- Problem: The lesson names invariants and a symmetry caveat but never explains how to compare or trace a concrete pair of rotated views, so the mental-rotation method is not fully taught.
- Triage reason: The method for checking whether two views are the same object after a turn is never taught or shown.

### 3. `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization|L02|0`
- Rule: L02
- Fix size: small
- Quote:
> A true rotation preserves distances, adjacency, handedness/chirality, and the relative arrangement of parts.
- Problem: This sentence packs several abstract or rare terms into one clause without simple wording, which is above the Grade 5 teaching-prose standard.
- Triage reason: Handedness/chirality and the invariants sentence are too hard; say a turn keeps the shape, not a mirror image.

### 4. `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization|L25|0`
- Rule: L25
- Fix size: small
- Quote:
> A true rotation preserves distances, adjacency, handedness/chirality, and the relative arrangement of parts.
- Problem: Handedness/chirality is necessary to the lesson's rotation test but is introduced without explaining what the term means, and there is no prerequisite lesson to supply that meaning.
- Triage reason: Handedness and chirality are used with no meaning; explain mirror image such as left and right hands.

## CSE teaching to add

None.

## Optional, fix only if editing that passage anyway

- `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization|L01|0` (L01): The recorded goal includes rotation-comparison work, but the lesson never develops a concrete paired-view comparison; it only states general invariants and the reflection distinction. Reason: No goals are recorded, so the learning-goal check is not applied.
- `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization|L17|0` (L17): This content appears under Speed Tricks & Shortcuts, but the Reasoning subject fit requires the reduced Core Concept to Examples to Traps layout and says to drop Speed Tricks. Reason: The Speed Tricks lines restate Core Concept more than they add a shortcut.
- `lesson-spatial-abstract-reasoning-mental-rotation-3d-visualization|L19|0` (L19): This multi-action fold solution is written as prose instead of numbered steps, so the required step-by-step worked-solution format is not followed. Reason: The solution has two short folding actions; numbering is optional for a three-sentence answer.

## Figures

None.

## Rules cited

| L01 | A learning goal is recorded and the lesson serves it | Major | Find the goal in the audit records; compare with the content. Not checked while no goals are recorded (Aedwon, 25 October 2026) | LSG: Learning goal |
| L02 | Teaching prose is very simple English a Grade 5 student can read, with no filler | Major | Read as a Grade 5 student; flag long or rare-word sentences | LSG: Voice |
| L17 | Subject section fit is followed; every formula appears in Core Concept before any example uses it | Major | Trace each formula in examples back to Core Concept | LSG: Per-subject section fit |
| L18 | Examples cover every distinct exam-relevant scenario, variation, and edge case within the learning goal, ramp from basic to target-exam difficulty, and avoid near-duplicates | Major | Map each distinct case to a worked example; check the difficulty progression and repeated reasoning | LSG: Examples section |
| L19 | Solutions with two or more steps show every step as a numbered list, key computations as display equations | Major if a step is skipped, otherwise Minor | Follow each solution step by step | LSG: Examples section |
| L25 | Necessary terms, symbols, and units are explained before their meanings are needed | Major | Trace needed meanings to local teaching, an identified prerequisite, or a clearly signposted later section under the shared reuse rule | LSG: Teaching completeness |
| L26 | Concepts explain their meaning and how they work, not just names or formulas | Major | Find the explanation under the shared reuse rule; confirm that the current learning goal is taught | LSG: Teaching completeness |
