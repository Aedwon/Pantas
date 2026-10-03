# Exam content coverage audit

Date: October 3, 2026
Status: Draft for Aedwon's review. Not approved.

## For Aedwon to approve

### What this audit should answer

Ensure full coverage of all mentioned exams: verify that Pantas teaches and provides practice for every required subject and topic, and identify everything missing before full coverage can be claimed. Check where coverage is too thin, misplaced, or combined in a way that makes exam preparation less focused.

Start with what each exam requires. Compare that with the app's subjects, topics, and lesson names first. Only then check the lessons and questions. The previous question audit supplies findings to investigate later; it does not define what the app should teach.

### Exams included

- UPCAT, DCAT, ACET, USTET, and PUPCET.
- DOST undergraduate scholarship examination and SM Foundation scholarship examination.
- CSE Professional and CSE Subprofessional, assessed separately.

For other CETs, identify the common content this corpus supports. Claim full coverage of an additional exam only when it is named and checked separately.

Check language requirements and differences between exam versions where they affect content. Shared subjects do not mean the exams require the same topics or depth. If an exam listed here is not yet offered by the app, assess the corpus against its requirements and report that separately.

### The order of the audit

1. **Establish exam requirements.** Find reliable, current sources for each exam's subjects and topics. Prefer the exam organizer's information. Separate confirmed requirements from reasonable supporting evidence and things that remain unknown. An unpublished topic list cannot become a claim of complete coverage.
2. **Check the corpus outline.** Compare those requirements with every subject, topic, and lesson name in the app's content. Produce a first coverage finding for every exam before reading lessons for depth or investigating individual questions. Identify apparent gaps, unclear names, and content whose relevance needs checking. A matching name is only a lead, not proof that the topic is taught.
3. **Check what the lessons teach.** Read all lessons to confirm the apparent coverage. Check whether required ideas, basic knowledge needed beforehand, and examples are present. Identify topics that are named but barely explained, lessons that combine too much, and missing teaching hidden inside broad lesson names.
4. **Check the practice against the teaching.** Check the topics and skills tested across all question sets. Investigate the previous audit's unresolved teaching and placement findings. For each mismatch, determine whether teaching is missing, another lesson already teaches it, earlier knowledge is reasonably needed, the question is misplaced, or the question's relevance is unsupported. Missing teaching alone is not a reason to remove a question.
5. **Recommend a clearer shared structure.** Propose additions, expansions, moves, and focused lesson splits. State which exams need each part and what remains shared. Teach a shared idea once, with exam-specific additions where needed. Recommend a split only when it improves focus or learning; do not split every concept into a separate lesson.

### What you will receive

- A short conclusion for each exam: what is covered, what is missing or weak, and what cannot be confirmed.
- A comparison showing each required topic, the lessons that teach it, and the available practice.
- A prioritized list of gaps and question mismatches, with evidence and recommended actions.
- A proposed subject, topic, and lesson outline showing useful splits and shared content.
- Additional quality improvements supported by what the audit finds, with their costs and priorities.

Keep topic relevance separate from teaching quality and practice quality. A topic may be relevant and taught, but still lack useful practice. Likewise, content may exist in the corpus but be unavailable to students preparing for the relevant exam. Report both cases.

### Boundaries and approval

This is a coverage and alignment audit. It does not repeat a full review of every answer key or rewrite every lesson. Record accuracy concerns encountered, including unresolved concerns from the previous audit, without claiming a complete correctness review.

The audit produces findings and recommendations. Adding, changing, splitting, moving, or removing app content requires separate approval. No app changes, content publication, or release work are included.

The proposed scope is balanced: complete coverage checking, followed by lesson scope and practice alignment. The earlier 2–4 hour audit estimate is provisional; the implementation plan will refine effort after the scope is approved. No new ongoing audit service is proposed.

This draft is complete when it is saved and available for your review. After you approve it, write the implementation plan based on this spec. This request does not authorize starting the audit. Stop after the plan unless you authorize execution.

### What counts as a finished audit

Every named exam has a source-backed coverage conclusion. Every subject, topic, lesson, and question set in the chosen corpus has been accounted for. Every required topic has a teaching and practice finding, or an explicit uncertainty. The prior audit's relevant unresolved findings have an evidence-backed recommendation or a clearly stated remaining question. Recommendations identify the affected exams and preserve shared content without duplication.

## Agent reference, not the approval section

### Source and policy identity

- Repository: `Aedwon/Pantas`.
- Current policy read from `main`, commit `218b61232a4d8b8761dd141a30abaa8bd3947659`: `AGENTS.md` and `WORKFLOW.md`.
- Proposed audit input: `content/question-qa-r2`, commit `765c5dc0fa5586281047bf4f7b30d09ab3707887`, matching the clean local worktree and fetched remote on October 3, 2026.
- Existing audit: `docs/content/audit/question-qa-r2/summary.md` at that input revision. It reports 158 audited question-source lessons and 134 unresolved questions. Its exclusions and protected pending questions must remain visible. These counts do not establish the complete lesson inventory or exam coverage.
- Current task status and exact conversation decisions: `docs/superpowers/decisions/2026-10-01-question-explanations-log.md`, appended coverage-spec checkpoint.
- Historical context read: `2026-07-18-content-audit-design.md` and `2026-08-04-cse-content-coverage-design.md`. Their old completeness claims and source-path assumptions are not current findings.

### Constraints for the later plan

Confirm the agreed input revision before execution and record any deliberate change. Recover the actual lesson, question, outline, exam, and delivery sources from that revision. Include placeholders, missing pairs, passages, and embedded practice where present; do not let the previous audit's exclusions silently narrow this one. Account for existing exam names and aliases without treating aliases as different exams.

Save the outline comparison before starting the lesson-depth pass, and save that pass before investigating question mismatches. Later discoveries may revise the earlier findings with an explanation. Do not begin from the pending-question list and work upward.

Preserve source links, dates, the requirement supported, and the distinction between official coverage and inferred preparation needs. An organizer's silence does not prove a topic is irrelevant. No invented topic weights or completeness percentages.

Use existing repository audit and decision records. Record the input revision and progress so a resumed task can recover the current stage. Preserve application freezes, protected questions, and signing and publication boundaries. Recommendations do not resolve or edit the previous audit's protected questions.

The implementation plan must specify coverage accounting and checks for unsupported conclusions. Tooling and assignments belong in that plan, not this approval section. Complexity selection remains proposed, not accepted, until Aedwon approves the scope. No implementation plan or audit findings have been produced by this drafting task.
