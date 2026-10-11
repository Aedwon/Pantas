Audited `3f0863ab..d2edde76` on `web/new-design-w2-r1`. Policy, plans, and boards came from `origin/main` revision `a0f915f397ec940acae6e4e29b42b695955e92c4`. No Git writes or source changes. Close-out excluded.

### Blocker

None confirmed.

### Major

1. **Math expressions are corrupted by Markdown parsing.** `lib/core/ui/components/content_renderer.dart:32`  
   `$x_1+x_2$` is split into emphasis runs before math parsing. This removes underscores and separates the dollar delimiters.  
   **Fix:** Protect math spans before parsing Markdown. Test subscripts alongside emphasis.

2. **Failed images hide their recovery action from screen readers.** `lib/core/ui/components/content_renderer.dart:438`  
   `excludeSemantics: true` covers the image’s error subtree, including its failure message and Retry button.  
   **Fix:** Apply image semantics only to successful images. Expose the error message and Retry separately.

3. **Search Cancel cannot reliably receive keyboard activation.** `lib/core/ui/components/search_field.dart:85`  
   Cancel depends on the text field retaining focus. Tabbing to Cancel blurs the field, which hides and excludes Cancel.  
   **Fix:** Track focus across the field and Cancel, or keep an explicit editing state until cancellation.

4. **Hidden toast actions remain keyboard-accessible.** `lib/core/ui/components/toast.dart:30`  
   Hiding the toast excludes pointers and semantics but leaves Undo focusable. Keyboard users can activate an invisible action.  
   **Fix:** Exclude focus while hidden. Test Tab and Enter after dismissal.

5. **Answer results lack required visual and spoken states.** `lib/core/ui/components/choice_row.dart:43` and `:100`  
   Correct and wrong choices retain their letters. `QV_MissPro` shows a check and cross. Semantics only identify the picked state.  
   **Fix:** Render the approved result marks and announce correct, wrong, and selected states.

6. **Question-grid states are not announced.** `lib/core/ui/components/new_design/question_grid_sheet.dart:140`  
   Cells expose their number without identifying current, correct, wrong, answered, or flagged states.  
   **Fix:** Give each cell an explicit label, interaction role, current state, and relevant result or flag state.

7. **Non-exempt contrast pairs fail the binding rule.**
   - `lib/core/ui/components/content_renderer.dart:481`: credit text `#8E8E93` on white measures **3.26:1**, below **4.5:1**.
   - `lib/core/ui/components/list_row.dart:83` and `lib/core/ui/components/scope_picker.dart:120`: unchecked selection outlines measure **1.68:1** in light and **1.86:1** in dark, below **3:1**.
   
   **Fix:** Use compliant named tokens and test these actual pairs. These are not the exempt decorative chevrons or empty progress marks.

8. **The required horizontal wheel variant is missing.** `lib/core/ui/components/value_wheel.dart:113`  
   The implementation provides a vertical wheel with selected text **20/500**. `QZE_Short` requires horizontal **56px cells**, selected **19/700**, and other values **16/500**.  
   **Fix:** Add the board-specific horizontal variant, retaining invalid-value strikethrough.

9. **Completed progress skips the ring-to-check sequence.** `lib/core/ui/components/progress_ring.dart:22`  
   A fraction of 1 immediately replaces the ring. `HP_Day` requires the **600ms fill** and delayed, overlapping check pop.  
   **Fix:** Preserve the ring through completion and sequence the check from the board timeline.

10. **Scope-picker motion differs from the approved board.** `lib/core/ui/components/scope_picker.dart:213` and `:281`  
    Expansion takes **300ms**, versus **600ms** on `QZ_Picker`. The caret rotates **90° linearly**, versus **180° over 300ms with house-out**. Selection marks appear instantly instead of the **220ms opacity and .5→1 scale** transition.  
    **Fix:** Implement the board’s separate transitions and test intermediate values.

### Minor

11. **Avatar fallback accepts nonletters.** `lib/core/ui/components/avatar.dart:11`  
    Names such as `123` or `@me` produce character avatars. `ST_Avatars` requires the plain person on gray.  
    **Fix:** Distinguish letters, emoji, and other characters before choosing the fallback.

12. **Question spacing is too large.** `lib/core/ui/components/new_design/question_card.dart:26`  
    Subject-to-stem spacing is **20px**, versus **8px** on the question boards.  
    **Fix:** Use 8px and assert the rendered gap.

13. **Dialog spacing differs from the boards.** `lib/core/ui/components/centered_dialog.dart:50`  
    Horizontal inset is **32px**, versus **28px**. Button gap is **10px**, versus **8px**. Message-to-buttons spacing is **16px**, versus **18px standard / 20px destructive**.  
    **Fix:** Match each variant’s board measurements.

14. **Upcoming mock parts are insufficiently dimmed.** `lib/core/ui/components/new_design/question_grid_sheet.dart:143`  
    Opacity is **.5**, versus **.32** on `MK_Sheet`.  
    **Fix:** Pin the board’s disabled-state opacity.

15. **Scope-picker layout differs from `QZ_Picker`.** `lib/core/ui/components/scope_picker.dart:146`  
    Lesson inset is **44px**, versus **42px**. Background is **#F5F5F7**, versus **#FBFBFC**. The **.5px separators** are missing. Unread and No questions yet appear below titles instead of trailing them.  
    **Fix:** Restore the board layout and approved token values.

16. **Components introduce colors outside the permitted token contract.** `lib/core/ui/components/scope_picker.dart:193`  
    Examples include local `#B25000`, the choice outline, and figure-credit color. They are neither W1 tokens nor October 10 additions.  
    **Fix:** Obtain named token rulings for necessary board colors, then consume those tokens.

17. **Keyboard tests can pass without working activation.**
    - `test/core/ui/components/inputs_completion_test.dart:194`: sends keys without asserting a resulting selection change.
    - `test/core/ui/components/containers_completion_test.dart:168`: preserves `picked` across modes, so the mock assertion at line 210 can reuse the quiz result.
    
    **Fix:** Reset state per case and assert the exact callback result after keyboard activation.

18. **The release-gallery test does not test release configuration.** `test/core/ui/components/gallery_test.dart:33`  
    It disables the gallery through an argument. It would still pass if the production debug guard disappeared.  
    **Fix:** Verify route absence with the actual release-mode condition.

19. **Animated painters allocate every frame.** `lib/core/ui/components/progress_ring.dart:33` and `lib/core/ui/components/half_ring_gauge.dart:39`  
    Animation builders recreate painters and widget subtrees. Both painters also create `Paint` objects during painting.  
    **Fix:** Cache paints, drive repaint directly, and retain static children.

### Clean areas and verification limits

- All named component contracts exist.
- No feature imports or business-service dependencies found in the changed components.
- The actual gallery route has a correct `kDebugMode` guard.
- Reviewed controllers are disposed.
- No generated files, seed assets, or AI attribution found in the scoped changes or commit messages.
- October 10 exemptions and Aedwon’s decided pairs were excluded from contrast findings.
- Four focused test files completed: **`00:01 +28: All tests passed!`**
- Final Git status was clean. HEAD remained `d2edde76`.

Full 200% text-scaling coverage, every intermediate animation state, and device accessibility remain unverified. The passing tests do not establish those areas as clean.