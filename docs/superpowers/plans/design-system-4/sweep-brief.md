# Raw-control sweep (design system 4.0 follow-up)

Why this sweep exists: Aedwon found the lesson reader's "< Study" back control drawing Flutter's default
gray pill hover. The system calls for a rounded rectangle with a teal wash. The drift check only bans
hand-typed values. A raw Material control (TextButton, IconButton, InkWell, TextField, SnackBar, Tooltip,
ListTile, progress indicators...) has no literal, so it passed the check while drawing framework
defaults. Your job is to replace every raw Material control in your scope with the system component.

Startup: follow the rules in the shared brief, then this file:
docs/superpowers/plans/design-system-4/builder-brief.md on origin/main
(read the policy from origin/main, work only in your own worktree, never commit, no browsers or servers,
look only, and the same tests and verification). Your worktree starts at f49b99300.

Find every use in your scope:
grep -rnE "\b(TextButton|ElevatedButton|OutlinedButton|FilledButton|IconButton|FloatingActionButton|InkWell|InkResponse|TextField|TextFormField|SnackBar|ScaffoldMessenger|Tooltip|ListTile|Chip|ChoiceChip|FilterChip|Checkbox|Radio|Switch|Slider|DropdownButton|PopupMenuButton|AlertDialog|SimpleDialog|showDialog|showModalBottomSheet|LinearProgressIndicator|CircularProgressIndicator)(\.[a-zA-Z]+)?\(" <your folders>

Replace each with the system component. Read its README in design/system/components/<Name>/README.md
and match its look and states (hover, pressed, focus, disabled):
- A text or ghost button: PantasButton or WebButton with the right kind and tone (Button README).
- A text link: WebTextLink (TextLink README). A back control: WebBackLink (BackLink README, Variant A:
  radius-back 11 rounded rectangle, never a pill, accent wash at opacity-hover, label accent-hover,
  chevron nudges 2px left).
- An icon-only button: PantasIconButton (IconButton README: rounded rectangle radius-md or radius-sm,
  never a circle, hover wash opacity-hover of the icon color).
- A tap area on custom content (InkWell/InkResponse): the shared hover or press wrapper the
  components use (WebHover, the press-scale wrapper, or the Card or ListRow component that owns the
  surface), with the README's hover and focus.
- Text input: PantasField. Toast: the shared toast/snackbar helper the system uses (Toast README).
  Tooltip: PantasTooltip. List rows: ListRow/WebRow. Progress: PantasProgressBar or PantasSpinner.
If no system component fits, or switching would change behavior (callbacks, focus, keyboard, semantics,
validation, input formatting, autofill), keep the raw control and give it a trailing
`// ds-raw: <reason>` comment on the same line. A new check will accept the marker only with a
non-empty reason. List every marker in your report. Use as few as possible.

Special case for whoever owns lib/features/lesson: the reader top bar back
(`WebReaderBackControl` in `web_reader_layout.dart`). Per the ReaderTopBar README, back is an
IconButton with a chevron, named "Back to Study" (use the actual back label in the name), with
IconButton hover. Use PantasIconButton (44, radius-md) with that semantics label and a PantasTooltip if
the README pairs one. Remove the visible label and the Esc key hint from the bar. Esc must keep working
exactly as before (the key handler is elsewhere; check it). The loading and error bars use the same
control, so they change too.

Tests: update tests that found controls by raw type (find.byType(TextButton) and the like) to find the
system component or the text. Never weaken a behavior assertion. Add one test per replaced control
type in your scope, proving the hover shape is a rounded rectangle and not a stadium. The matrix
tests must stay green.

Verification (all must pass): the commands in the shared brief. Then rerun the grep above: every hit
left must carry a `// ds-raw:` reason.

Report in under 200 words: counts replaced per control type, every ds-raw marker with its reason, test
counts, doubts, and files. End with STAGE-DONE.
