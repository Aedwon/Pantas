# Visual design companion for UI brainstorming

Use the companion when brainstorming a spec that affects UI. Aedwon prefers to
see the effect before approving the spec. Show before and after for existing UI,
or different options for new UI. Nonvisual decisions can remain in conversation.
The companion supports spec approval; it does not introduce plan approval.

## Fidelity to implementation

- Read the assigned workstream's actual UI and approved design rules. Prefer a
  preview using the same components and rendering as the intended implementation.
- Show the relevant screens and states at the intended device size, with faithful
  text, typography, spacing, colors, assets, controls, and interactions. Include
  enough surrounding UI to judge the change. Identify any omitted state or behavior.
- The approved presentation must match implementation 1:1 for what it represents.
  Record the chosen proposal and its version in the spec. Keep it available for
  implementation and Aedwon's final visual check. Do not use a polished approximation
  as a promise that a different implementation will match.
- If the available tools cannot show an aspect faithfully, disclose the gap and
  resolve its representation with Aedwon before treating it as approved. A necessary
  design difference must be presented and approved before it is implemented.
- Aedwon performs visual checking. Supply instructions for opening and comparing
  the preview and implementation. Do not operate his browser or desktop, capture
  app screenshots, or claim visual verification from automated checks. He may
  supply screenshots for corroboration.

## Presentation mechanics

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
