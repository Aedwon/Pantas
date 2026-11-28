# Codex critique prompt (GPT 6.2 Sol, high effort)

Run after the Codex weekly reset, from the repository root on branch `legal/public-launch-r1`, read-only. Process rule 5 (`docs/workflow/process-improvement.md`). Do not run it before then.

```sh
codex-pick exec --skip-git-repo-check -m gpt-6.2-sol -c model_reasoning_effort=high -s read-only \
  -o /tmp/public-launch-legal-critique.md "$(sed -n '/^<<<PROMPT$/,/^PROMPT$/p' docs/legal-drafts/2026-11-22-public-launch/critique-prompt.md | sed '1d;$d')" </dev/null
```

Save the answer to `docs/legal-drafts/2026-11-22-public-launch/critique-2026-11-XX-sol-high.md` and apply the must-fix items (an agent applies them; Aedwon only checks).

<<<PROMPT
You are a read-only legal critic. Do not edit, create or delete any file. Answer in text only. No em dashes. American spelling.

Context. Pantas is a Philippine exam-review study app (web and mobile) run by a sole proprietor, Aerol Dwayne Daños Balayon, trading as Pantas Online Tutorial Services. It opens to the public for the Civil Service Exam (CSE) soon, with live PayMongo payments (card and QR Ph), prepaid Weekly, Monthly and Yearly plans, a one-time Season Pass, a 7-day free trial on Monthly only, no auto-renewal, users aged 13 and older, and a guardian-confirmation flow for ages 13 to 17. There is no lawyer. The owner accepted that risk.

Task. Critique three draft public texts for Philippine law, from this angle: the texts should lean as far in favor of Pantas as Philippine law allows, without being unenforceable, misleading or unlawful. Find where they give away more than the law requires, and where a pro-Pantas clause is likely void, unenforceable or a legal risk.

Files, on branch legal/public-launch-r1:
- docs/legal-drafts/2026-11-22-public-launch/terms.md
- docs/legal-drafts/2026-11-22-public-launch/privacy-policy.md
- docs/legal-drafts/2026-11-22-public-launch/teen-notice.md
- docs/legal-drafts/2026-11-22-public-launch/README.md (read the sections "M10" and "Where the app and the text disagree")
- docs/legal-drafts/2026-11-22-public-launch/change-summary.md
Baselines: lib/features/legal/domain/legal_document.dart (the texts live today), docs/legal/research/2026-11-11-minor-label-lawful-basis.md, docs/legal/2026-11-09-publication-dependencies.md, docs/legal-drafts/2026-10-30-terms-payments-refunds-draft.md.
Facts about what the system does: verify every factual sentence in the texts against the code before you accept it. Key files: functions/src/deleteUserData.ts (what account deletion erases), functions/src/paymongoCheckout.ts, paymongoGrants.ts, paymongoWebhook.ts (payments, refunds, disputes), functions/src/webTrial.ts (trial codes), functions/src/purgeInactiveAccounts.ts (retention), functions/src/guardianConsent.ts, lib/features/onboarding/presentation/onboarding_age_gate_step.dart (the age screen), docs/OPERATIONS.md section "Manual QR Ph refund".

Questions. For each, cite primary sources (statute section, NPC issuance, court case) with URLs, and say when you are unsure.

1. Age check legal basis (most important). The Notice for teens no longer rests the on-device age check on the teen's own click. It cites NPC Advisory Opinion 2017-049 (a minor cannot give valid consent alone) and relies on Data Privacy Act Section 13(f) (legal claims) for the check and for the stored under-18 group, on Section 12(f) for related ordinary information, and on the guardian's Section 13(a) consent after confirmation. The device keeps the age group; servers never receive the typed age, but record the under-18 group when a guardian request is sent. Is this basis sound? Is there a stronger lawful basis? Could the on-device check be argued to fall outside "processing" by Pantas, and should the notice say so? Propose the strongest wording that stays true.
2. Enforceability of each pro-Pantas term in terms.md: liability cap (greater of PHP 1,000 or 12 months of payments), Norala venue, no partial refunds, 30-day refund window, forfeiture of unused time on closure for serious misuse, user indemnity for breach, force majeure, electronic acceptance, continued use as acceptance of changed Terms with 14 days notice, access suspension during bank disputes, Pro access having no cash value. Name the statute or rule each runs into: Civil Code (Arts. 1170 to 1172, 1306, 1409, 1308, 2201, 2226 to 2227 on liquidated damages and unconscionable terms), Consumer Act RA 7394, Internet Transactions Act RA 11967 and its IRR, E-Commerce Act RA 8792, DTI rules on online sellers.
3. Internet Transactions Act and DTI disclosure duties for online merchants: what must the Terms or checkout show (seller identity, address, contact, complaint channel, refund and return policy before payment, price and tax)? Are the bracketed operator facts enough? Does a town-level address ("Poblacion, Norala, South Cotabato") suffice?
4. Refunds: is "no refund for change of mind" and "no partial refund" valid for prepaid digital study access? Does any right of withdrawal or return apply? Is the QR Ph refund-by-transfer text acceptable?
5. M10, retention versus deletion. The drafts say account deletion erases the payment records held in the app database, and that the five-year tax duty is met by the business's own books, receipts and refund records kept outside the app. Confirm the five-year period and its start (National Internal Revenue Code Section 235 and BIR rules on books and receipts), whether the app database must itself retain payment records, and whether the text is accurate and safe. Is deletion with erased app-side payment records a Data Privacy Act problem or a tax problem?
6. Minors. Can a 13 to 17 year old be bound with guardian confirmation and a guardian-ticked purchase box? Voidability (Civil Code Arts. 1327, 1390 to 1391, 1399). Is the refund-and-cancel clause for a purchase ticked by a non-guardian sound?
7. Data Privacy Act coverage: rights list, retention periods (24-month inactivity deletion with 30-day warning, ten-year guardian evidence, 730-day security logs, trial codes kept as long as trials are offered), transfers outside the Philippines, processor wording (Google, Cloudflare, Resend, PayMongo, RevenueCat), breach notice, the rule that privacy changes go by email before they take effect. Anything missing that NPC rules require in a privacy notice (for example the controller's DPO contact, NPC registration, the purposes and legal basis for each processing)? Is the trial-code retention (no end date, keyed hash) defensible?
8. Accuracy. List every sentence in the three texts that states a system fact the code does not support, or that the code contradicts.

Output format. Findings ranked must-fix, should-fix, nit. For each: the exact sentence quoted, the problem, the source, and replacement wording that keeps the text as pro-Pantas as the law allows. Then a short list of clauses you checked and found fine. Finish with the single biggest legal risk in the package.
PROMPT
