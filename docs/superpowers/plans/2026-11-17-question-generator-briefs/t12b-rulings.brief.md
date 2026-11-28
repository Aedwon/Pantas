Task: apply plan Part 3b (adviser rulings) to the generator and checker from Tasks 1.1 and 1.2, which are merged. Read Part 3 and Part 3b first. Tests first. Run tests with `flutter test test/tool/generator --no-test-assets`; run `dart run build_runner build --delete-conflicting-outputs` once before `run_checks.dart`.

Build:
1. Model: `ProblemType.choiceKind` (`figure` or `text`, required). `Variant.ruleKey` (string) and `Variant.cosmetics` (map, may be empty). Round-trip and determinism tests extend to them.
2. Rule interface: a rule returns, with each variant, its rule-parameter set and its cosmetics separately; the generator computes `ruleKey` as sha256 of the canonical JSON of the rule-parameter set.
3. Checker additions, each with a planted bad fixture that must fail:
   - the solver recomputes the rule-parameter set from the variant independently (new solver method `Map<String, Object?> ruleParams(ProblemType, Variant)`) and its hash must equal `ruleKey`;
   - cosmetics are constant across the version: every figure in the stem figure and in every choice carries the same value for each cosmetic attribute (solver method `List<String> validateCosmetics(ProblemType, Variant)`);
   - `choiceKind: text`: no choice carries `figure`; `choiceKind: figure`: every choice carries `figure` and nonempty `text`;
   - signature canonicalizer hook accepts a per-kind "ignore" list so cube-net can ignore label permutations (tested with the test kind).
4. Capacity CLI: `dart run tool/generator/bin/capacity.dart --type <path> [--ceiling 2000]` generates up to the ceiling draws, dedupes by signature, and prints `distinct ruleKeys`, `distinct signatures`, and whether 100 is reachable. Deterministic for a fixed seed.
