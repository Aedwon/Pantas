Task: plan Task 1.1, "model, generator core and CLI". Build exactly what that task lists, using the formats and Dart interfaces in plan Part 3.

Notes:
- First check how tool/content/*.dart is run (root package or its own pubspec) and follow the same layout for tool/generator.
- Write no real rules yet. For the tests, add one tiny test-only rule in tool/generator/test/ (for example a math rule "a + b") so generation, seeding, duplicate-signature retry and refill can be tested end to end.
- The variant list YAML must round-trip: parse(write(list)) == list, and writing is deterministic (stable key order) so refills diff cleanly.
- Exact rationals for math values: use BigInt-based fractions; check whether the repo already has a rational type before writing one.
