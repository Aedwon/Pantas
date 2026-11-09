# Flashcards mode in the Study tab: idea

Date: 9 November 2026
Status: IDEA. Not approved scope. No spec, plan or build.
Logged by: the SSOT keeper, at the manager thread's request.
Policy commit: `c2e26f28a` (`origin/main`, AGENTS.md, WORKFLOW.md)

## The idea, in Aedwon's words

Aedwon, verbatim: "i had an idea again: add a flashcards mode to the Study tab. potentially there might need to be changes/insertions in the content to make this work. this idea is still cloudy in my head but log it anyway, maybe you can add your own initial insights"

## Initial insights (not decisions)

These come from the manager thread. None is approved, and none limits what Aedwon wants from the idea.

1. **Evidence.** Flashcards are retrieval practice. Spaced retrieval is among the best-supported study methods: Roediger and Karpicke (2006); Cepeda et al. (2006); Dunlosky et al. (2013), which rates practice testing and distributed practice as high utility. Verify these citations against the sources before relying on them. They were not checked against the papers when this note was written.
2. **Naming conflict.** AGENTS.md says "Questions", never "cards". A feature called Flashcards needs either a ruling that it is a distinct thing, or another name, such as "Recall" or "Quick Recall". This is Aedwon's call on look and feel.
3. **Content.** This needs a new content type: short front and back recall items, such as key terms, formulas, grammar rules, Filipino vocabulary and General Information facts. Each item is tagged to a lesson, topic and exam, as questions are. The back follows the Grade 5 plain-language rule (simple Filipino for Filipino items). Items need the same accuracy checks as answer keys. Lessons' key points, notes and traps may be a source, but each item must be authored and checked, not generated unchecked.
4. **Scheduling.** Reuse the existing spaced-repetition scheduler with self-rating. Self-rating is less reliable than a graded answer, so keep its data separate from question accuracy. Never print a figure from it unless it is measured (AGENTS.md, "Never invent a figure"). The scheduler's terms stay out of user-facing text, per AGENTS.md.
5. **Product questions to settle later.** Whether it joins the Today plan or stays optional; the Free and Pro split; overlap with the existing Reviews queue; how it works offline.
6. **UI.** Design system 4.0 has no flip-card component. It needs a system component and a visual-companion board before any spec.
7. **Timing.** After the beta, informed by tester feedback, with a spec through the normal process.

## Next step

None until Aedwon picks it up. When he does: clarify what he wants from it, then settle the name (insight 2) and the product questions (insight 5) before any spec.
