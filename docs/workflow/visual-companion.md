# Optional visual design companion

This is tool-use guidance for the shared workflow, not a separate approval policy.
Use a companion only when it helps Aedwon evaluate a visual decision. Its absence
does not change the spec approval process in `WORKFLOW.md`.

- Show enough of the whole screen to explain the proposed choice. Check existing
  specs and the component kit first.
- Keep the companion page dark. Start the device preview on paper. A theme toggle
  changes only the preview, not the surrounding page.
- Reuse existing presentation content where suitable. Give changed proposals new
  filenames so old option labels cannot silently remain in a disconnected tab.
- Do not use a document-wide theme attribute as both the page state and a click
  target. Keep note-box clicks from activating the surrounding choice.
- Keep tall preview columns scrollable so controls remain reachable.
- If the server stops with its owning session, reuse its project directory when
  restarting so the existing page can reconnect.
- Verify where the current server writes user events. Earlier server versions used
  different output locations. A foreground server running in a background command
  may write events to that command's output file. Do not assume an empty events
  file means the user supplied no answer.
- Copy each decision, every offered option and cost, and verbatim comments into
  the repository decision log immediately. The page is a view of the spec, not a
  separate decision authority. Preserve the source event when resolving ambiguity.
