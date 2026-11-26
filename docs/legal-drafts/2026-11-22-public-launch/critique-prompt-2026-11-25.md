# Codex critique prompt, Nov 25 round 5 (GPT 6.2 Sol, high effort)

Read-only, from the worktree `/Users/aedwon/.t3/worktrees/Pantas/legal-publish-r1`, branch `legal/publish-r1`. Process rule 5. Covers only the passages changed on Nov 25 for the business name, the Data Protection Officer (DPO) and option C (under-18 sign-up closed).

Run it with `codex-pick exec --skip-git-repo-check` at high effort. Do not run it from the drafting session.

<<<PROMPT
You are a read-only legal critic. Do not edit, create or delete any file. Answer in text only. No em dashes. American spelling.

Context. Pantas is a Philippine exam-review study app run by a sole proprietor registered with the DTI. Its trade name is Pantas Online Tutorial Services (DTI Business Name No. 8567107). It takes live payments through PayMongo. No lawyer. The texts must lean as far in favor of Pantas as Philippine law allows, without being unenforceable, misleading or unlawful. Wording must stay plain and short.

Since Nov 25 (option C) the app's minimum age is 18. A new student under 18 sees a blocked page and enters nothing. The server refuses every new guardian request, resend and change of email. A request already open can still be answered by the guardian until its link expires (seven days). Accounts a guardian already confirmed keep working. The owner wants his full name shown only where Philippine law needs it.

Files to read, all in the worktree:
- `docs/legal-drafts/2026-11-22-public-launch/terms.md`, `privacy-policy.md`, `teen-notice.md`
- `docs/legal-drafts/2026-11-22-public-launch/change-summary.md`, section "Nov 25: business name, DPO and option C" (it holds the DPO sources)
- `docs/legal-drafts/2026-11-22-public-launch/critique-2026-11-24c-sol-high.md` (the last round, for context)
- `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`, from "Nov 23, under-18 flag risk" to "Corrections found while framing" (about lines 883 to 955)
- `git diff origin/main -- docs/legal-drafts/2026-11-22-public-launch/terms.md docs/legal-drafts/2026-11-22-public-launch/privacy-policy.md docs/legal-drafts/2026-11-22-public-launch/teen-notice.md lib/core/config/seller_facts.dart` to see the Nov 25 changes only (the earlier rounds are already critiqued)

Scope. Critique only the changed paragraphs and anything they affect. Do not re-review the rest. The product rulings are final. If wording cannot be right under a ruling, list it as "conflicts with a ruling".

Questions.
1. Name minimization. His full name now appears only in Terms "Who we are" (contracting party) and Privacy Policy "Who runs Pantas" (personal information controller). The Notice for teens and the checkout seller line name only the business. Is his name needed anywhere else, for example the Notice for teens (it is also a privacy notice under IRR Section 34(a)), the seller line under the Internet Transactions Act (RA 11967) and its rules, or the Consumer Act? Can either remaining use go, for example by stating that Pantas Online Tutorial Services is a sole proprietorship and leaving the owner's name to the DTI record and invoices? Give the safest wording that keeps the name in the fewest places.
2. DPO by title and contact. The texts say "Data Protection Officer: dpo@pantas.study, [business phone], or by post at the address above, marked for the Data Protection Officer. We give the officer's name to you or the National Privacy Commission on request." Check this against RA 10173 Section 21(b), the IRR (Sections 26 and 34), NPC Advisory 2017-01 and NPC Circular 2022-04. Is title plus email, phone and postal address enough? Does the business phone count as "a dedicated telephone number", or should the phone go? Is the sentence about giving the name on request right and safe? Is a sole proprietor who is both controller and DPO a problem when the notice stops saying so?
3. Option C wording. Check the changed passages for accuracy against the rulings and the behavior in the context above: Terms "Use of Pantas" (age 18, false age, guardian confirmation applies only to accounts confirmed before closing), Privacy Policy "Who this is for", "Why we ask your age" and the age-check basis bullet, and the Notice for teens "Who this is for", "Why we ask your age", the open-request paragraph, "What we collect" (guardian request), "Why a guardian confirms", "What your guardian can do" and the age-check basis bullet. Is any sentence untrue, or does any still invite a student under 18 to sign up? Is "you break these Terms, and we may close your account" enforceable and favorable to Pantas for a false age? Is it right that a guardian can answer an open request after closing?
4. Rate item 3 of "What C does not remove" in the rulings file: the age check on a teen's device. The device keeps only a block (a minimum-age number) and nothing reaches Pantas. Is that processing by Pantas under the Data Privacy Act? Rate the remaining risk (none, low, medium, high) and say whether the new sentence "The check stays on the device and no record of it reaches our servers" is accurate, enough and safe.
5. Anything else in the Nov 25 changes that is a legal risk for Pantas or a plain mistake.

Output format. Findings as Blocker, Major, Minor. For each: the exact sentence quoted, the file, the problem, the source with a URL, and exact replacement wording. Then a short list of clauses found fine. Then one line each for questions 1 to 4 (the verdict). Finish with the single biggest legal risk in these changes.
PROMPT
