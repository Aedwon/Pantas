# Handoff: link-preview image without the beta mark (E-169, board only)

Date: Nov 25, 2026. Role: UX design lead. Policy: main a64e69caf (AGENTS.md, WORKFLOW.md, SUBAGENTS.md, process-improvement.md, visual-companion.md, patterns.md read at 737c1c935, unchanged since).
Status: board published, waiting for his pick. Nothing built, no app or website change.

## Board

https://claude.ai/artifact/8emGUsKPxKrkpqd1rHi2sw ("Link Preview Image", Claude Design, version 1795598671-cc75). Private until he shares it.

- Main: the new 1200 x 630 image.
- Today: the live image (beta mark), for comparison.
- Share_Facebook (light), Share_Messenger (dark), Share_iMessage (small card, center square crop). The image in each is the Main artboard, scaled, not a copy.
- One headless render of all five frames (scratchpad sheet, local Geist fonts, Chrome for Testing with --use-mock-keychain --password-store=basic, closed after). Result matched the canvas; no fixes needed.

## Where the preview image is set today

- App (app.pantas.study): `web/og-image.png` (1200 x 630, "Pantas" + teal BETA + the welcome line), set in `web/index.html` lines 45 to 50 (`og:image`, size, `og:image:alt` "The Pantas logo with the words Pantas beta", `twitter:image`). Added Nov 6 in 725e639d0 with no board.
- Cloudflare Worker: serves the file only; `tool/cloudflare-app/headers.prod` and `headers.staging` cache `/og-image.png` for an hour. The Worker code sets no preview tags.
- Website (pantas.study, pantas-web): no `og:image` on any page (main f2d5f45; live checked). Shares of the website show text only. Not part of this brief; adding one is website work, his call.
- Wrapped share pages set their own `og:image` per share (`functions/src/renderWrappedPage.ts`); unrelated.

## Search (rule 4) and the ruling

Searched: Pantas Web and Pantas Redesign canvases (all board titles; SP_Splash, SP_WebBStill, SP_PhoneBFade, SP_Flow, QA_Splash, QA_SplashBLight, O_Launch, WR_Share boards), Splash Hand-off, Home Screen Icon, Pantas beta sign-in, Pantas Website canvases, `web-design/pantas-handoff` exports, the launch log, rulings and the CSE release checklist (G4 row 18, U55). Terms: link preview, og-image, og:image, 1200, 630, brand, lockup, wordmark, splash, share.

Found: no board draws a link preview or a 1200 x 630 frame. The approved returning splash (SP_Splash, in both canvases) draws the brand lockup: mark over the wordmark "Pantas", Geist 700, tassel #0B7A68, the rest #1D1D1F, on #F5F5F7. It fits 1200 x 630, so per the brief it is the single design, not options.

Lead calls (recorded in the rulings file, Nov 25 "Link-preview image"):
1. The splash's wide proportions (mark 120, gap 20, wordmark 42 px, letter-spacing -0.03em) at 2x: mark 240, gap 40, wordmark 84, centered. Why: at 1x the mark is about 50 px wide in a Facebook card. A `scale` tweak on Main allows 1 to 2.6.
2. No tagline. The old image's welcome line stays only as the card's description text, from the page's existing description tag.
3. Alt text follows the image: "The Pantas logo".

## Fidelity gaps (on the board)

Share cards are drawn, not captured from the apps. iMessage chooses the card size itself and usually shows the large card for a 1200 x 630 image.

## Next step after his pick

A small build for the CSE release lead (or UX lead): export Main at 1200 x 630 PNG to `web/og-image.png`, change `og:image:alt` to "The Pantas logo", ship with the gate-off build. Facebook caches previews: run the Sharing Debugger "Scrape Again" on app.pantas.study after the ship (he or an agent with his account). If he rejects it, a new look needs options drawn from the same lockup.
