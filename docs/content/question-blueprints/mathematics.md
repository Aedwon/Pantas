# Mathematics — Question Blueprint

Applies to Arithmetic & Number Sense, Algebra, Geometry, Trigonometry,
Statistics & Probability, and Pre-Calculus & Basic Calculus. Follow
[question-style-guide.md](../question-style-guide.md) for format and voice.

**Written 3 August 2026.** Mathematics was going to be produced by a template
engine, which is deferred to a later version. These questions are authored
statically, exactly as science, language and reasoning were.

## The rule that governs every item here

**Every number in a stem, a choice or an explanation must be one you put there
on purpose and can defend.** Mathematics is the subject where a plausible
constant is easiest to slip in and hardest to notice. If an item needs a figure
the lesson does not supply, invent the scenario, not the mathematics: a train
may travel any distance you like, but the arithmetic on it must be exact.

**Check your own answer before writing the explanation.** Work the item, then
write the working out. An explanation reverse-engineered from a chosen letter is
how a wrong key ships.

## Difficulty ramp

recall a rule → apply it once → apply it under a disguise. Mathematics ramps by
how far the item is from the bare statement of its rule, not by how large the
numbers are. **Ugly numbers are not difficulty**, they are arithmetic tax, and
under exam timing they punish care rather than reward it.

## Notation

LaTeX renders through `flutter_math_fork`. Inline maths is `$...$`, display is
`$$...$$`. **Use it for anything that is not plain prose**: fractions, exponents,
radicals, and every equation.

Write `$\frac{3}{4}$`, never `3/4`. Write `$x^2$`, never `x^2`.

**Never put LaTeX inside double-quoted YAML.** A backslash is an escape character there, so
`"$\frac{5}{3}$"` fails the parse with "Unknown escape character" and names no line. Use
single quotes, or a block scalar:

```yaml
      - text: '$\frac{5}{3}$'
      - text: |
          $\dots$
```

This broke a file on 3 August and it will break more, because every file in this subject
carries LaTeX.

## Figures

**Prefer prose. A triangle described in words is answerable and should be
described in words.**

**Where the item genuinely needs a diagram, describe it accurately in the stem
AND reserve the illustration.** Both, not either. Aedwon's ruling, 3 August, and
it matches what the reasoning questions already do:

```yaml
    figure: geometry-triangles-04
    stem: |
      Figure shows triangle ABC with a right angle at B. Side AB is 6 cm and
      side BC is 8 cm. What is the length of side AC?
```

**The description carries exact measurements and the item is answerable without
the image.** That is the whole point of the convention: the question ships
today and gains a picture later, rather than waiting in a queue.

**Log every slug** in `docs/content/question-figures/worklist.tsv`, one row per
figure, columns `subject, topic, subtopic, slug, question_id, target_file,
status`, with `status` as `todo`.

**Never generate an image.** Figures are hand-made, and the described stem is
what makes that queue non-blocking.

---

## Universal archetypes (any topic)

### `direct-computation`
State the rule's conditions, ask for the value. The floor of the ramp.

```yaml
stem: |
  What is the value of $3x + 7$ when $x = 4$?
choices:
  - text: $19$
    correct: true
  - text: $14$
  - text: $21$
  - text: $12$
explanation: |
  Put 4 in place of $x$: $3 \times 4 = 12$, then $12 + 7 = 19$.
```

**Distractors carry the mistake, not a random miss.** $14$ is $3 + 7 + 4$, the
student who added instead of multiplying. $21$ is $(3 + 4) \times 3$. Each wrong
choice is a real slip.

### `error-spotting`
Show worked steps with one wrong, ask which step broke.

```yaml
stem: |
  A student solves $2(x + 3) = 14$ like this.

  Step 1: $2x + 3 = 14$
  Step 2: $2x = 11$
  Step 3: $x = 5.5$

  Which step is the first wrong one?
choices:
  - text: Step 1
    correct: true
  - text: Step 2
  - text: Step 3
  - text: No step is wrong.
explanation: |
  Step 1 multiplied only the $x$ by 2 and left the 3 alone. Both terms inside
  the bracket get multiplied, so it should read $2x + 6 = 14$.
```

**This archetype is the most valuable one in the subject** and it is the one
exams use most. It tests whether a student can see a mistake, which is what they
must do to their own work under time.

### `word-problem`
Prose to equation to answer. Translation is the tested skill.

```yaml
stem: |
  A jeepney fare is $\text{P}13$ for the first 4 kilometers and $\text{P}1.80$
  for every kilometer after that. How much is a 9-kilometer ride?
choices:
  - text: $\text{P}22.00$
    correct: true
  - text: $\text{P}16.20$
  - text: $\text{P}29.20$
  - text: $\text{P}13.00$
explanation: |
  The first 4 kilometers cost $\text{P}13$. That leaves $9 - 4 = 5$ kilometers
  at $\text{P}1.80$ each, which is $\text{P}9.00$. Together
  $\text{P}13 + \text{P}9 = \text{P}22$.
```

**Set word problems in the student's own world.** Jeepney fares, load, rice by
the kilo, a sari-sari store. Not baseball statistics.

### `which-is-true`
Four statements, one holds. Tests the rule's edges rather than its middle.

```yaml
stem: |
  Which statement about the number $0$ is true?
choices:
  - text: $0$ is an even number.
    correct: true
  - text: $0$ is a positive number.
  - text: Dividing by $0$ gives $0$.
  - text: $0$ is a prime number.
explanation: |
  An even number can be divided by 2 with nothing left over, and
  $0 \div 2 = 0$. Zero is neither positive nor negative, dividing by zero has
  no answer at all, and a prime must be greater than 1.
```

### `estimate-first`
Ask for the reasonable answer, not the exact one.

```yaml
stem: |
  About how much is $\sqrt{50}$?
choices:
  - text: A little more than $7$
    correct: true
  - text: A little less than $7$
  - text: About $25$
  - text: About $10$
explanation: |
  $7 \times 7 = 49$, which is just under 50, so $\sqrt{50}$ is just over 7.
```

**Under exam timing an estimate often beats a computation**, and this archetype
teaches that. Use it where the exact working is long and the choices are far
apart.

---

## Topic notes

### Arithmetic & Number Sense
`direct-computation` and `word-problem` carry this topic. **Business math is
where Filipino context matters most**: discounts, commission, simple interest,
markup. Sequences and series suit `which-is-true` for their definitions.

### Algebra
The heaviest topic and the one exams weight most. `error-spotting` fits it
better than any other topic: sign errors, distributing over a bracket, and
squaring a sum are the three mistakes worth building items around. Word problems
about age, mixture, work and motion are the exam's standards.

### Geometry
**Describe the figure in words wherever the item survives it.** Angle chasing,
the triangle inequality, and area or perimeter of a compound shape all work as
prose. Reserve `figure:` for coordinate geometry and for anything with more than
one intersecting line.

### Trigonometry
The unit circle and the identities reward `which-is-true`. Right-triangle
solving is `direct-computation`. **State the angle unit in every stem**, degrees
or radians, and never leave it to be inferred.

### Statistics & Probability
`word-problem` throughout. **Mean, median and mode confusion is the single most
productive distractor source in the subject.** Combinatorics items must say
plainly whether order matters, because the exam does.

### Pre-Calculus & Basic Calculus
The lightest topic, 4 lessons. Limits and continuity suit `which-is-true`.
Derivatives and integrals suit `direct-computation` at the level of the power
rule and nothing beyond it. **Do not exceed the lesson.** This topic appears on
UPCAT and not on the others, and inventing depth it does not test wastes the
student's time.

---

## Distractor sources, ranked

1. **The lesson's own "Traps to Watch For" section.** Always read it first.
2. **Sign errors.** Dropping a negative is the most common real mistake there is.
3. **The right operation, one step short.** The student who stops before the
   final subtraction.
4. **The other formula from the same lesson.** Area where perimeter was asked.
5. **The transposed answer.** $\frac{3}{4}$ where $\frac{4}{3}$ was correct.

**A distractor nobody would pick teaches elimination rather than knowledge.**
Every wrong choice on every item must be a mistake a real student makes.
