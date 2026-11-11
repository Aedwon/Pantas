# Shared state patterns for screen families

Contract: W4h Task 1, L3 lead rulings October 11. Import
`package:pantas/core/error/state_patterns.dart`. Use W1 themes and W2 components.
Do not copy a state into a feature folder. These helpers contain no data writes,
subscription decisions or raw diagnostic strings.

## Load a section

```dart
value.when(
  data: (data) => buildContent(data),
  loading: () => loadingFor(value),
  error: (error, stack) => errorFor(
    'topics',
    () => ref.invalidate(topicsProvider),
    error: error,
  ),
)
```

`loadingFor<T>(AsyncValue<T>)` returns LoadingShapes only while loading. Shapes
appear after 300 ms, pulse at W2's existing 1,300 ms period, and stay still with
reduced motion. The helper announces Loading immediately. Removing it on success
or failure cancels its delay and controller. It renders nothing for data or error;
it is not an error handler. Keep existing data during a background refresh when
that screen's contract calls for it.

`errorFor(String what, VoidCallback onRetry, {Object? error})` renders
“Could not load your <what>.” with Try Again. Supply a student-facing noun such as
“topics”, “plan” or “progress”. Keep exceptions and stack traces in diagnostics.
The optional error is never rendered. A failed section shows this state instead
of silently disappearing. Keep the screen title and unaffected sections.

## Save a change

`saveFailureLine(VoidCallback onRetry)` renders “Could not save your progress.”
with a text Try Again action. Put it next to the failed operation. Retain the
student's input and retry that operation. Do not clear the input or navigate away.
The line wraps at large text and announces its appearance.

## No active exam

`chooseExamFallback(BuildContext context)` renders the ST_NoExam prompt. Put it in
the tab's remaining content area, usually Expanded, beneath that tab's title.
It includes the faint study icon, detail and Choose Exam action. It pushes
`/settings/exam/change`, the existing exam-picker route, preserving the return
route. W4a/W4f replace the picker behind that same navigation contract.

## Assessment unavailable

`assessmentNotReady()` preserves the current copy:
“Assessment isn't ready yet” and “We're still adding questions for this exam.
You can use the rest of Pantas for now.” Its Back to Quiz action returns to the
Quiz tab root. Use it when the exam has no assessment questions, not on a failed
load. A failed load uses errorFor and can be retried.

## Other empty states

Use the existing W2 StateView with approved copy. Its optional detail paragraph,
actionLabel and primaryAction support prompts with ST_NoExam's metrics. Omit
onRetry when there is no action; no hidden button remains focusable. Do not
invent empty-state copy or turn a failed section into an empty state. Existing
inline error callers retain their faint mark and tinted retry.

If another approved board needs a shared component extension, extend that
component in its own file and test it beside W2's tests. Record the board,
metrics and changed interface in that family's evidence. Do not create a local
copy. Product/design contradictions still go to the lead.
