Audited `13e4f830..4136c146`. Policy and design revision: `1aaebad9814ba7bd9404d8b43fc010281abb97cf`. No files changed or Git writes performed.

No blocker-level defect found. W1 still needs corrections before acceptance.

### Major

1. **Font notices do not ship.** [pubspec.yaml:104](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/pubspec.yaml:104)  
   The three license files exist, but neither assets nor Flutter’s additional licenses include them. The existing bundled notices omit them too. Font metadata contains license names or links, not complete notices.  
   **Fix:** Include both OFLs and the Phosphor MIT notice through Flutter’s license collection. Verify the resulting bundle.

2. **Adapters reduce contrast on existing screens.** [app_colors.dart:73](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/core/ui/theme/app_colors.dart:73)  
   Dark destructive buttons now use `#1C1C1E` text on `#D70015`: **3.160:1**. Wrong-answer text reaches only **3.900:1** on black. The existing last-minute mock timer inherits gold `#D9A400` on `#F5F5F7`: **2.083:1**. These mappings follow the plan, but regress readability.  
   **Fix:** Obtain a lead ruling for accessible destructive and warning roles. Preserve readable legacy controls until their replacements land. Normal text requires **4.5:1**. [WCAG contrast requirement](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)

3. **Enabled tab labels fail contrast.** [app_shell.dart:184](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/features/shell/presentation/app_shell.dart:184)  
   Unselected labels use `#8A8A8E` on white: **3.439:1**, below **4.5:1** for their 10px text. This faithfully reproduces a design conflict.  
   **Fix:** Obtain an accessible color ruling and test the actual foreground/background pair.

4. **Tabs lose keyboard activation.** [app_shell.dart:191](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/features/shell/presentation/app_shell.dart:191)  
   Replacing `InkWell` with `GestureDetector` removes keyboard focus and Enter/Space activation. Screen-reader tap semantics remain.  
   **Fix:** Restore focusable actions without introducing unapproved animation.

5. **Pop and shake motion differ from approved keyframes.** [pantas_effects.dart:91](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/core/ui/motion/pantas_effects.dart:91)  
   Against `HP_Free`:
   - Pop at 60%: expected scale **1.12**, actual approximately **1.057945**.
   - Shake at 18%, 36%, 54%, 72%: expected **−9, +8, −5, +3px**; actual approximately **−7.724, −3.343, +1.825, +0.603px**.

   The implementation eases the whole timeline and omits pop’s intermediate keyframe.  
   **Fix:** Preserve elapsed-time keyframes and apply easing within each interval.

### Minor

6. **Section-heading metrics differ.** [pantas_type.dart:54](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/core/ui/theme/pantas_type.dart:54)  
   `ST_Appearance` and `ST_DarkPractice` specify **−0.288px spacing, 1.35 line height** for 24/700 headings. Implementation uses **−0.528px, 1.12**.  
   **Fix:** Correct the style or provide a named variant for those boards.

7. **Two icon details differ.**
   - [app_shell.dart:205](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/features/shell/presentation/app_shell.dart:205): tab icons are **24px**; all four reference tab bars specify **23px**.
   - [own_icons.dart:249](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/core/ui/icons/own/own_icons.dart:249): Appearance’s filled semicircle omits its inherited **1.5px stroke**. Its dividing edge consequently starts **0.75px** farther right.

   **Fix:** Match the specified size and paint the semicircle’s stroke.

8. **Large tab labels can clip silently.** [app_shell.dart:211](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/features/shell/presentation/app_shell.dart:211)  
   Width allocation shrinks labels below their measured requirements, then clips them. At 320px and 3× scaling, “Settings” needs approximately **124.68px**, versus approximately **80.86px allocated**.  
   **Fix:** Define an accessible layout for insufficient width and assert complete label visibility.

9. **Tests permit the defects above.**
   - [pantas_effects_test.dart:226](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/test/core/ui/motion/pantas_effects_test.dart:226): checks endpoints, not intermediate transforms.
   - [pantas_type_test.dart:49](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/test/core/ui/theme/pantas_type_test.dart:49): pins incorrect spacing and omits line height.
   - [app_shell_test.dart:36](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/test/features/shell/app_shell_test.dart:36): stack and back-button checks use an invented router and placeholder screens.

   **Fix:** Test board keyframes, actual metrics, and production routing.

10. **Temporary text painters lack disposal.** [app_shell.dart:66](/Users/aedwon/Documents/Projects/Pantas-wt-new-design-w1-r1/lib/features/shell/presentation/app_shell.dart:66)  
    Every bar rebuild creates and lays out four painters.  
    **Fix:** Dispose each after measurement.

### Clean

- Every live route survives unchanged, including parameters and route-level gates. Retired redirects match the plan.
- Onboarding and update gates remain. The removed Pro gate protected only the retired dossier.
- Tab order, indexed stacks, re-tap behavior, and Settings telemetry are correct by inspection.
- All light/dark color constants, shape constants, named curves, date formats, and Sunday boundaries match.
- All 36 Phosphor codepoints match package 2.1.0. The bundled font is byte-identical.
- Adapter mappings follow the plan. Lesson scaling preserves nonlinear phone scaling within its subtree.
- Reduced motion supplies final progress immediately.
- No generated application files, seed changes, or AI attribution appear in the diff.

New fonts total **1,532,996 bytes**, including **488,636 bytes** for Phosphor. Theme construction adds no network work; interpolation has fixed, small scope.

I verified that recorded test evidence matches the final source patch: **3,507 tests passed**. I did not rerun Flutter tests, profile startup, or perform device checks.