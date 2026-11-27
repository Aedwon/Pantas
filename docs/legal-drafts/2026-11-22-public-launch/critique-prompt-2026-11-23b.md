# Codex critique prompt, Nov 23 round 3 (GPT 6.2 Sol, high effort)

Read-only, from the worktree on branch `legal/public-launch-r1`. Process rule 5. Covers only the passages changed for the Nov 23 rulings R1 to R7.

<<<PROMPT
You are a read-only legal critic. Do not edit, create or delete any file. Answer in text only. No em dashes. American spelling.

Context. Pantas is a Philippine exam-review study app run by a sole proprietor, with live PayMongo payments, users aged 13 and older, and a guardian-confirmation flow for ages 13 to 17. No lawyer. The texts should lean as far in favor of Pantas as Philippine law allows, without being unenforceable, misleading or unlawful. Wording must stay plain and short.

Scope. Read `git diff HEAD -- docs/legal-drafts/2026-11-22-public-launch/terms.md privacy-policy.md teen-notice.md` in the worktree. Critique only those changed passages. Do not re-review the rest. Product rulings are final and you must not propose changing them; if wording cannot be right under a ruling, say so as a separate item "conflicts with a ruling". The rulings:
- Under-18 record: a request that expires, or is declined (deleted 7 days after), is deleted whole, including the under-18 flag. The record remains only while a request is open and after a guardian confirms.
- Question reports: deleted within 90 days of receipt by a Firestore TTL policy, sooner on account deletion. No "when we finish reviewing" clause.
- Guardian evidence after account deletion: kept 3,653 days from its newest record if it holds a confirmation, withdrawal or guardian purchase declaration; 1,461 days if it holds only declines. The server never learns the student's age. No legal-hold exception (the cleanup cannot honor one). Only declarations made by a parent or guardian are copied, with date, time, Terms version, wording version, payment reference and product. Adult declarations are never copied.
- A purchase that a parent or guardian says they did not allow is refunded in full, without contest.
- The tick is a declaration. The texts must never state as fact that the buyer is the guardian.

Questions.
1. Confirm or correct each Civil Code article behind the two periods, with the actual text or a close paraphrase and a URL (Lawphil, Chan Robles or an official source): Article 1108 (prescription against minors), Article 1144 (ten years, written contract), Article 1146 (four years, injury to rights), Article 1391 (four years to annul a voidable contract, and from when it runs for minors). Say if you cannot verify one. Is the reasoning in the Teen Notice "Guardian evidence" bullet accurate and defensible, including the claim that ten years covers a written contract claim and that a decline-only record needs only four years? Is Article 1391 even the right article to cite for the longest-case reasoning (note that a minor's contract under Philippine law is voidable under Article 1390(1))?
2. Do the rewritten flag paragraphs (Teen Notice "Why we ask your age", "How long we keep data" request paragraph, and the "Under-18 group record and guardian evidence" basis bullet) match the ruled behavior, with a lawful basis for each stage (open request, confirmed, declined, expired)? Is the guardian answer record, including a decline, adequately based on Section 13(f)?
3. Are the deletion passages exact and consistent across Privacy Policy and Teen Notice (what is deleted, what stays, adult declarations never copied)? Is the sentence "If the law requires it, or we need specific records for a legal claim, we may keep those records longer" in the Teen Notice retention list consistent with "no legal hold" for guardian evidence? Is it risky or misleading?
4. Is the 90-day report period wording accurate for a TTL delay, and consistent in both notices?
5. Refund of a guardian-denied purchase: are the Terms paragraph "Purchases a parent or guardian denies", the Terms "Students under 18" addition and the Teen Notice sentence consistent, not too broad (can anyone abuse it?), and not an admission? Keep the ruling: refunded without contest.
6. Accuracy. Any sentence in the changed passages that states a system fact beyond the rulings above, or that says as fact the buyer is the guardian.

Output format. Findings ranked must-fix, should-fix, nit. For each: the exact sentence quoted, the problem, the source with URL, and replacement wording. Then a short list of clauses found fine. Then a section "Civil Code verdicts" with one line per article: held, corrected, or not verified. Finish with the single biggest legal risk in these passages.
PROMPT
