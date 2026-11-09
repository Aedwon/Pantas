# Codebase gardening: idea

Date: 9 November 2026

**Status:** Archived idea. Revisit when Pantas is earning. Not approved scope.

Logged by the SSOT keeper at the manager thread's request. Aedwon, verbatim: "i want this idea to spring forth on a later date as the project grows and starts earning. archive this idea for now, to be discovered later when i ask for pending things. you may add your initial thoughts in the document if you will create one, but only append them, not change the things indicated."

Listed in `docs/future/README.md`. Sections 1 and 2 below are source material and must not be edited. Later notes go only in section 3 or after it.

## 1. Source material (verbatim, do not edit)

Transcribed from two screenshots Aedwon shared of posts by lauren (@poteto) on X. The images are not stored in the repository. Line breaks follow paragraph breaks in the posts.

### Screenshot 1: post of 8/21/26, quoting the post of 7/19/26

Seen in X search results ("From poteto", search "garden"). The word "garden" is highlighted by the search, not by the author.

> **lauren** @poteto · 8/21/26
>
> every team needs a gardener. someone quietly watching the stream of PRs flowing into your codebase, noticing the smells: the third isRecord this week, the lint suppressions creeping like ivy across your carefully planned garden. a steady hand tending the weeds that would engulf it in slop if left unchecked.
>
> with careful grooming it stays a garden. every weed you pull becomes a rule, so it can't grow back. without that, it's just whatever grew.
>
> > **lauren** @poteto · 7/19/26
> >
> > organic architecture
> > good codebases have always had strong foundations and constraints. these files go here. this kind of code goes there. the codebase is held together either by catering to the lowest common d...
> >
> > [Image: two tall residential towers covered in trees and plants on every balcony, against a blue sky.]

### Screenshot 2: the full post of 7/19/26

> **lauren** @poteto
>
> **organic architecture**
> good codebases have always had strong foundations and constraints. these files go here. this kind of code goes there. the codebase is held together either by catering to the lowest common denominator developer using conventional frameworks and languages, or by strict adherence to a style guide enforced by code review.
>
> the arrival of an infinite number of monkeys armed with keyboards have obsoleted the latter. codebases designed for agents need hard constraints so that even the dumbest agent (and pilot) can contribute meaningfully. the chaos must be tamed.
>
> refactoring your codebase and choosing a tech stack with strong type systems/compiler diagnostics has far greater impact than AGENTS.md and tweaking your skills. hard constraints and well thought out architecture guide agents to do the right thing by default. the best rules are in your code.
>
> invest accordingly.
>
> [Image: the same plant-covered towers, cut off at the bottom of the screenshot.]

## 2. Aedwon's note and the Gemini summary (verbatim, do not edit)

Aedwon: "theo also shared the same sentiments, i had Gemini through Youtube summarize his advice on this matter"

Gemini summary, verbatim from here to the "End of the Gemini summary" line:

<!-- Gemini summary, verbatim: start -->

In [Coding Isn't About Code Anymore](http://www.youtube.com/watch?v=GtJKFhztgdM), Theo argues that engineers must act as codebase "gardeners" [[01:29](https://www.youtube.com/watch?v=GtJKFhztgdM&t=89)]. Instead of writing every line manually, you build an environment where human and AI code thrives [[32:56](https://www.youtube.com/watch?v=GtJKFhztgdM&t=1976)].

## 1. Architect the Platform ("Prepare the Soil")

* **Make the right path easy:** Structure your codebase so good patterns are effortless and bad patterns are hard [[18:50](https://www.youtube.com/watch?v=GtJKFhztgdM&t=1130)].
* **Enforce end-to-end type safety:** Connect your database and client with Prisma and tRPC to eliminate manual API schemas [[19:50](https://www.youtube.com/watch?v=GtJKFhztgdM&t=1190)].
* **Split time 50/50:** Dedicate half your engineering effort to platform improvements and half to user-facing product features [[21:39](https://www.youtube.com/watch?v=GtJKFhztgdM&t=1299)].
* **Follow the pendulum swing:** Pause feature work when friction rises, fix the underlying platform, then resume building the feature [[22:05](https://www.youtube.com/watch?v=GtJKFhztgdM&t=1325)].
* **Eliminate single-person bottlenecks:** Replace fragile custom infrastructure with maintainable platforms so the entire team can ship independently [[28:33](https://www.youtube.com/watch?v=GtJKFhztgdM&t=1713)].
* **Dogfood in smaller repos:** Test experimental patterns in smaller internal projects before deploying them to your primary codebase [[14:31](https://www.youtube.com/watch?v=GtJKFhztgdM&t=871)].

---

## 2. Speed Up Feedback Loops ("Provide Nutrients")

* **Recognize that friction blocks agents harder:** Slow tooling stalls AI agents even more severely than it slows human developers [[36:46](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2206)].
* **Optimize dev server and type-check times:** Keep startup times under a few minutes so agents validate changes without exceeding cache TTL limits [[36:53](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2213)].
* **Reduce CI resource overhead:** Lower CPU, RAM, and runtime costs so you can run multiple agents in parallel [[37:03](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2223)].
* **Maintain a fast release pipeline:** Keep deployments quick so you can merge frequently and ship fixes without hesitation [[37:15](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2235)].

---

## 3. Add Automated Guardrails ("Plant Wooden Stakes")

* **Build fast, targeted PR checks:** Create lightweight automated actions that run in 30 to 45 seconds on every pull request [[41:29](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2489)].
* **Simulate real workloads:** Run real thread or event data through an end-to-end pipeline to catch wire-protocol size regressions [[40:46](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2446)].
* **Signal priorities to agents:** Flag regressions directly in pull requests so babysitting agents automatically detect and fix metric violations [[41:29](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2489)].
* **Scan for security blast radius:** Monitor every incoming change with automated security scanning to catch AI-generated vulnerabilities before merge [[02:11](https://www.youtube.com/watch?v=GtJKFhztgdM&t=131)].

---

## 4. Prune Bad Code and Tests ("Pull the Weeds")

* **Treat every bad PR as an environment bug:** When misleading docs or bad code examples cause mistakes, immediately rewrite the docs and refactor the code [[13:11](https://www.youtube.com/watch?v=GtJKFhztgdM&t=791)].
* **Kill slop before it multiplies:** Remove low-quality code immediately, because existing slop causes newer AI models to generate more slop [[30:16](https://www.youtube.com/watch?v=GtJKFhztgdM&t=1816)].
* **Delete useless unit tests:** Prune redundant tests—Theo deleted 250,000 lines across 11,000 tests—because bad tests encourage more pointless edge-case tests [[38:59](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2339)].
* **Interrogate agent mistakes at the root:** When an agent writes bad code, inspect the prompt thread, ask why it happened, and fix the repo guidance [[39:39](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2379)].
* **Watch for creeping code smells:** Monitor incoming pull requests for repeated workarounds or lint suppressions and remove them early [[44:12](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2652)].

---

## Gardening Metaphor to Engineering Action

| Gardening Concept | Engineering Equivalent | Concrete Action from the Video |
| --- | --- | --- |
| **Soil & Fertilizer** | Docs, examples, and repo rules | Delete misleading docs and refactor confusing reference code immediately [[13:11](https://www.youtube.com/watch?v=GtJKFhztgdM&t=791)]. |
| **Wooden Stakes** | Automated PR performance gates | Run a 30-second simulated pipeline check that flags payload regressions over 5 KB [[40:46](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2446)]. |
| **Pulling Weeds** | Pruning slop and redundant tests | Delete useless unit tests and remove lint suppressions before agents copy them [[38:33](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2313)]. |
| **Water & Sunlight** | Fast dev servers and build tools | Speed up type-checking and dev startup to unblock parallel agent workflows [[36:46](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2206)]. |
| **Garden Output** | High-velocity, stable shipping | Scale from 2–20 merged PRs per day to over 400 per day on active days [[43:33](https://www.youtube.com/watch?v=GtJKFhztgdM&t=2613)]. |

<!-- Gemini summary, verbatim: end -->

End of the Gemini summary.

## 3. Initial thoughts (appended by the manager, not decisions)

- Pantas already does part of this:
  - The DS4 guardrails plan puts rules in code: a compile-time barrel that hides raw controls, a type-aware design lint, and golden images. This is "the best rules are in your code".
  - `docs/workflow/process-improvement.md` requires a check that fails on the bad version whenever Aedwon rejects work. This is "every weed you pull becomes a rule".
  - Strict Dart analysis (strict-casts, strict-inference) gives strong type constraints.
- Gaps to revisit when earning:
  1. Feedback speed. CI takes about 26 minutes. The CI speed plan, `docs/superpowers/plans/2026-11-08-ci-speed.md`, targets 6 to 9 minutes and waits for Aedwon's approval of its plain-language section. A fast pre-merge check under a minute does not exist yet.
  2. Weed tracking. Count the suppression markers (`// ds-raw:`, `// ds-geometry:`, analyzer ignores) and the 546-finding design-lint baseline over time, and fail CI if they grow.
  3. Test pruning. The app has about 10,000 tests. An audit could find low-value or duplicate tests that slow CI and invite more of the same. Delete only with care, because many of them pin approved behavior.
  4. Flaky browser journeys, such as "last answer survives a reload" and "Home to lesson", reduce trust in CI. Fix them or quarantine them.
  5. Root-cause agent mistakes. The process-improvement log already does this. A periodic review that turns repeated findings into lint rules would close the loop.
  6. Time split. Theo's 50/50 platform and product split fits once revenue allows. Until then, use the pendulum: fix the platform when friction blocks features.
- Signals to revisit: steady revenue; agents regularly blocked by CI time; repeated review findings of the same kind; the lint baseline not shrinking.
