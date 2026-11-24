# Codex critique prompt, Nov 23 pass (GPT 6.2 Sol, high effort)

Run read-only from the worktree on branch `legal/public-launch-r1`. Process rule 5 (`docs/workflow/process-improvement.md`). This pass covers only the passages changed on Nov 23. The first pass is `critique-prompt.md`.

<<<PROMPT
You are a read-only legal critic. Do not edit, create or delete any file. Answer in text only. No em dashes. American spelling.

Context. Pantas is a Philippine exam-review study app (web and mobile) run by a sole proprietor, Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services. It opens to the public for the Civil Service Exam soon, with live PayMongo payments (card and QR Ph), prepaid plans, no auto-renewal, users aged 13 and older, and a guardian-confirmation flow for ages 13 to 17. There is no lawyer. The owner accepted that risk.

Angle. The texts should lean as far in favor of Pantas as Philippine law allows, without being unenforceable, misleading or unlawful. Find where a passage gives away more than the law requires, and where a pro-Pantas passage is likely void, unenforceable or a legal risk. Every wording must be short enough for a checkbox label or one line beside a button: the app's style is no wordy UI.

Scope. Critique only the passages below. Do not re-review the rest of the package.

Files, in docs/legal-drafts/2026-11-22-public-launch/ on this branch: terms.md, privacy-policy.md, teen-notice.md, README.md (section "Nov 23 pass").

Changed passages:
A. The two checkout declarations (README "Final checkout declaration"; terms.md "Declaration at checkout" and "Students under 18"; teen-notice.md "Payments for minors"). A required tick beside the Pay button on every web purchase. The server refuses checkout without it and records it with the date, time and Terms version. Adult text: "I am 18 or older and may use the payment method I will pay with. I accept the Terms and refund policy." Guardian text, used when the server holds a confirmed guardian for the account: "I am this student's parent or guardian, 18 or older, and may use the payment method I will pay with. I accept the Terms and refund policy." "Terms and refund policy" links to the Terms. Backdrop: Philippine cases on contracts with minors turn on whether the minor actively claimed to be of age (Mercado v. Espiritu, 1917; Braganza v. Villa Abrille, 1959; verify and cite them with URLs if you can, and say if you cannot).
B. The seller line beside the Pay button and in the website footer (README "Seller line"; terms.md section 4 "Price"). Template: "Sold by [registered business name], [full place of business]. Phone [business phone]. Email support@pantas.study."
C. The recording of the declaration (privacy-policy.md "Payments", "How long we keep data", "Why we may use your data"; teen-notice.md the same sections).
D. Question reports as stored user text (privacy-policy.md and teen-notice.md: "Question reports" in the collection, retention, legal basis and deletion passages; README "Data Protection Officer export procedure"). Facts, verified in the code on the branch qa/report-send-r1 (functions/src/questionReports.ts, functions/src/deleteUserData.ts, firestore.rules): the report holds a message of up to 1,000 characters, the question ID and version, the exam ID, the app build, the time and the account ID. No client can read it. No expiry is set. Account deletion, including inactive-account deletion, removes it. A device keeps an unsent report until it sends.

Questions.
1. Are the two declaration wordings legally sound, as short as they can be, and as protective of Pantas as the law allows? Does "may use the payment method" do the work, or does the sentence need "in my own name"? Does "I accept the Terms and refund policy" make valid electronic assent (E-Commerce Act RA 8792; Internet Transactions Act RA 11967)? Should the guardian version say "this student" or something else? Propose better wording that stays checkbox-short.
2. Does the seller line meet the Internet Transactions Act and DTI disclosure duties for the point of payment (seller name, place of business, contact)? Is anything required that it leaves out and that can still be short? Is the footer template enough?
3. Are the passages in A and C accurate and sufficient: lawful basis, retention, deletion? Is recording the declaration for every buyer proportionate (Data Privacy Act Sections 11 and 18)? Is keeping a copy only for under-18 accounts after deletion consistent with the text?
4. Question reports: is the Privacy Policy and Notice for teens wording enough under Data Privacy Act Sections 12 and 16, and NPC Circular 2023-04 and Advisory 2024-03? Is legitimate interest the right basis? Is a bracketed retention period acceptable until set, and what period would you defend? Is the "do not put personal details" line useful or harmful? Is the export procedure sound?
5. Accuracy. List every sentence in the changed passages that states a system fact the code does not support.

Output format. Findings ranked must-fix, should-fix, nit. For each: the exact sentence quoted, the problem, the source with URL, and replacement wording that keeps the text as pro-Pantas as the law allows. Then a short list of clauses you checked and found fine. Finish with the single biggest legal risk in these passages.
PROMPT
