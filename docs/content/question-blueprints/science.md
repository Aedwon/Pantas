# Science — Question Blueprint

Applies to Biology, Chemistry, Physics, Earth Science & Astronomy. Follow
[question-style-guide.md](../question-style-guide.md) for format and voice.

## Difficulty ramp

recall → understanding → application → analysis. A subtopic's easiest
question should be answerable from a single fact; its hardest should require
combining two ideas from the lesson or a short calculation.

## Archetypes

Cover every archetype below that fits the subtopic; skip ones that genuinely
don't apply (e.g. `simple-quantitative` for a purely descriptive topic like
cell theory). 2–3 variants per archetype used.

### `identify-organelle` (Biology-specific naming pattern; generalize to `identify` for other subjects)
Name or pick the structure/substance/phenomenon that matches a description.

```yaml
stem: |
  Which organelle is the site of photosynthesis in a plant cell?
choices:
  - text: Chloroplast
    correct: true
  - text: Mitochondrion
  - text: Ribosome
  - text: Golgi apparatus
explanation: |
  Chloroplasts hold chlorophyll, the green pigment that captures light to
  make food. Mitochondria release energy but do not make food.
```

### `structure-function`
Match a structure/organ/part to the function it performs, or vice versa.

```yaml
stem: |
  The cell part that controls what substances enter and leave the cell is the
choices:
  - text: cell membrane
    correct: true
  - text: cell wall
  - text: cytoplasm
  - text: nucleolus
explanation: |
  The cell membrane is the gatekeeper. It lets some things in and keeps
  others out. The cell wall only gives support; it does not choose what
  passes through.
```

### `cause-effect`
Given a cause (a change in condition, a stimulus, a reaction), pick the
correct effect.

```yaml
stem: |
  A weight is added to one pan of a balanced lever at rest. What happens?
choices:
  - text: The side with the added weight goes down.
    correct: true
  - text: The lever stays balanced.
  - text: The side with the added weight goes up.
  - text: The lever spins continuously.
explanation: |
  More weight on one side means more downward force there. The heavier
  side moves down until something stops it.
```

### `classify`
Sort an item into the category it belongs to, or pick the one that does not
belong (odd-one-out by category).

```yaml
stem: |
  Which of these is NOT a vertebrate?
choices:
  - text: Earthworm
    correct: true
  - text: Frog
  - text: Snake
  - text: Sparrow
explanation: |
  Vertebrates have a backbone. Frogs, snakes, and sparrows all have one.
  An earthworm does not — it is an invertebrate.
```

### `predict-outcome`
Given a setup, predict what a change will produce (a result, a product, a
reading).

```yaml
stem: |
  If the volume of a fixed amount of gas is halved at constant temperature,
  what happens to its pressure?
choices:
  - text: It doubles.
    correct: true
  - text: It is cut in half.
  - text: It stays the same.
  - text: It becomes zero.
explanation: |
  Boyle's Law says pressure and volume move in opposite directions when
  temperature stays the same. Squeeze the gas into half the space, and its
  pressure doubles.
```

### `compare-contrast`
Ask which statement correctly distinguishes two related concepts.

```yaml
stem: |
  Which statement correctly tells apart mitosis and meiosis?
choices:
  - text: Mitosis produces two identical cells; meiosis produces four genetically varied cells.
    correct: true
  - text: Mitosis produces four cells; meiosis produces two identical cells.
  - text: Both always produce four identical cells.
  - text: Meiosis only happens in plant cells.
explanation: |
  Mitosis makes two copies for growth and repair. Meiosis makes four
  different sex cells for reproduction.
```

### `process-ordering`
Put steps of a process (a cycle, a reaction sequence, a method) in the
correct order.

```yaml
stem: |
  Put these steps of the water cycle in the correct order.
  1. Condensation  2. Evaporation  3. Precipitation
choices:
  - text: 2, 1, 3
    correct: true
  - text: 1, 2, 3
  - text: 3, 2, 1
  - text: 1, 3, 2
explanation: |
  Water first evaporates into the air, then condenses into clouds, then
  falls back down as precipitation.
```

### `simple-quantitative` (Physics/Chemistry)
A short calculation using a formula taught in the lesson.

```yaml
stem: |
  A 2 kg object accelerates at 3 m/s^2. What net force acts on it?
choices:
  - text: 6 N
    correct: true
  - text: 1.5 N
  - text: 5 N
  - text: 0.67 N
explanation: |
  Force equals mass times acceleration: $F = ma$. Here, $2 \times 3 = 6$
  newtons.
```

## Figure-dependent subtopics

Per the content audit, many Physics word problems (free-body, projectile,
vector-resolution, circuit setups) and Earth Science topics (eclipse
geometry, moon phases, rock cycle, Earth layers) genuinely need a drawn
figure. Author these now with a `figure:` slug (see the style guide) rather
than skipping them — the wording exists; the image and display come later.

## Notation and YAML

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
