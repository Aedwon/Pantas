# Codex critique prompt, Nov 25 round 6 (GPT 6.2 Sol, high effort)

Read-only, from the worktree `/Users/aedwon/.t3/worktrees/Pantas/legal-publish-r1`, branch `legal/publish-r1`. Process rule 5. Covers only the two passages changed for the H5 publish gate (trial code period, ruling D7) and the existing-account line (ruling D5).

Run it with `codex-pick exec --skip-git-repo-check -m gpt-6.2-sol -c model_reasoning_effort=high -s read-only`. Do not run it from the drafting session.

<<<PROMPT
You are a read-only legal critic. Do not edit, create or delete any file. Answer in text only. No em dashes. American spelling.

Context. Pantas is a Philippine exam-review study app run by a sole proprietor registered with the DTI (trade name Pantas Online Tutorial Services). No lawyer. The texts must lean as far in favor of Pantas as Philippine law allows, without being unenforceable, misleading or unlawful. Wording must stay plain and short. The owner approved the texts as they stood after round 5; this round covers two changes only.

Change 1, trial codes (Privacy Policy and Notice for teens, retention list). Old: "It currently has no scheduled expiry." New: "We delete it 730 days after the trial started. For a trial that started before November 24, 2026, the 730 days count from that date." Built behavior (on prod since Nov 24, 2026): each code row gets expireAt = trial start + 730 days (functions/src/trialMarker.ts); a Firestore TTL policy deletes rows after expireAt (Firestore TTL usually deletes within 24 hours of expiry but does not guarantee a time); codes that existed before the Nov 24 deploy took the deploy date as their start; an account deletion re-writes the code with the trial's own start, or the first deletion attempt when the account record has no start time, and never moves an expiry earlier. Ruling D7 is in docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md ("D7. Ruling: option B").

Change 2, existing accounts (Terms section 12, new last paragraph): "If you created your account before the version date at the top, the earlier Terms keep applying to you until 14 days after we first show you a notice of these Terms in the app. These Terms apply to you sooner if you accept them, for example when you buy." Background: the Terms live in the app today (beta, Nov 10 interim set) say "We tell you in the app before a material change takes effect, at least 14 days ahead unless the law or security requires sooner" and "If you keep using Pantas after the change takes effect, you accept it". Every web purchase records acceptance of the Terms in force, with their version (PR #90). The app has a Home notice strip that can show a one-time notice. Today's accounts are beta testers with no real payments. Ruling D5 ("D5. Ruling: option A for launch", same rulings file, including "Finding that affects the launch (check 9)"). New accounts get the new Terms from publication.

Files to read: docs/legal-drafts/2026-11-22-public-launch/terms.md (section 12), privacy-policy.md and teen-notice.md (the Free-trial codes bullet and the legal-basis bullet for trial codes), and `git diff HEAD~2 HEAD~1 -- docs/legal-drafts/2026-11-22-public-launch` for the exact change.

Questions.
1. Is change 1 accurate against the built behavior, including the TTL timing and the deletion path? Is "We delete it 730 days after" safe when Firestore TTL may run a day or more later, or should it say "about" or "within a few days after"? Is the pre-Nov 24 sentence needed and accurate? Does a 730-day period stay defensible under RA 10173 Sections 11(e) and 12(f) for stopping repeat seven-day trials?
2. Is change 2 effective and favorable to Pantas under Philippine contract law and the Consumer Act, given the live Terms' 14-day promise? Does it keep that promise? Is "for example when you buy" right, given purchases record acceptance? Does a Free user who never buys stay on the old Terms forever if they never see the notice, and how should the text close that gap? Should the Privacy Policy or Notice for teens carry a matching line, or is the Terms line enough (the Privacy Policy is a notice, not a contract)?
3. Anything else in these two changes that is a legal risk or a plain mistake.

Output format. Findings as Blocker, Major, Minor. For each: the exact sentence quoted, the file, the problem, the source with a URL where one exists, and exact replacement wording. Then one line verdict for each change. Keep it under 600 words.
PROMPT>>>
