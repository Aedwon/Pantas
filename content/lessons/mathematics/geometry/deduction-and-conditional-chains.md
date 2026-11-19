---
_id: "lesson-geometry-deduction-and-conditional-chains"
title: "Deduction and Conditional Chains"
summary: "Use detachment or chain conditionals to draw a valid conclusion."
subject: "subject-mathematics"
topic: "topic-geometry"
isActive: true
part: 5
partCount: 5
ordering: 10
keyPoints:
  - "Use detachment or chain conditionals to draw a valid conclusion."
---
## Core Concept

### Drawing Conclusions

For these rules, accept the given statements as true. A **deduction** is a conclusion that must follow from them.

The arrow ($\Rightarrow$) means "if ... then." The symbol $\therefore$ means "therefore." The **Law of Detachment** needs a true conditional and its true hypothesis:

$$p \Rightarrow q,\quad p\quad\therefore q$$

If "If $p$, then $q$" is true and $p$ is true, you may conclude $q$. Knowing only that $q$ is true does not let you conclude $p$. There may be another reason for $q$ to be true.

The **Law of Syllogism**, also called hypothetical syllogism, joins two true conditionals. Here, $r$ stands for a third statement:

$$p \Rightarrow q,\quad q \Rightarrow r$$

$$\therefore p \Rightarrow r$$

The first conclusion must match the next hypothesis. This gives a new conditional. To conclude that $r$ actually happens, you also need the fact $p$.

## Examples

### #1: Chaining Statements and Using a Fact

Assume these statements are true: "If an application is complete, then it is sent for review." "If an application is sent for review, then a tracking number is assigned." Rico's application is complete. What must follow?

**Solution:**

1. The first conclusion matches the second hypothesis: the application is sent for review.
2. Use the Law of Syllogism. If an application is complete, then a tracking number is assigned.
3. Rico's application is complete. Use the Law of Detachment with that fact and the new conditional.
4. A tracking number is assigned to Rico's application.

<!-- ILLUSTRATION: Statement chain with arrows from application complete to sent for review to tracking number assigned; show Rico's complete application at the start. -->

## Speed Tricks & Shortcuts

For a chain, match each conclusion to the next hypothesis. Keep the final answer as an if-then statement unless a given fact lets you use detachment.

## Traps to Watch For

### #1: Starting from the Conclusion

> Detachment starts with a true hypothesis, not just a true conclusion.

"If it rains, then the ground is wet" and "the ground is wet" do not prove that it rains. A sprinkler could have wet the ground. The wet ground alone does not tell you its cause.
