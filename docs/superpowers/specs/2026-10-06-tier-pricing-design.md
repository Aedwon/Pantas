# Pro by exam tier: entitlement design

Date: October 6, 2026. Status: Part A approved by Aedwon on October 6, 2026 with Civil Service
Weekly and Yearly added (decision record). Visual companion: `docs/design/proposals/cse-pro-2026-10-06.html`
(board `ST_ProCSE_v2`).
Policy revision read: origin/main 12fb353b.
Required by `docs/pricing.md` ("Not yet settled": tiers need a design spec covering entitlements,
new product IDs, upgrade handling and pass expiry before any product is created; product IDs are
permanent). Scope decision: restart log, October 6 ("1"). Prices: `docs/pricing.md` (approved Oct 4).
Screens: the approved Pro and switching boards (ST_Pro*, ST_Pass*, ST_SwitchUpgrade, ST_SwitchPassWarn).
Implemented by W3 (logic) and W4f (screens); level 3 of W3 waits for this approval.

---

## Part A. Plain-language summary for approval

### What changes

Pro is priced by the exam a student picks, as `docs/pricing.md` says. At launch only two tiers sell:
Student (UPCAT and other college entrance tests, DOST, SM) and Civil Service (CSE Professional and
Subprofessional). Licensure, academy exams, PSHS-NCE, NAPOLCOM and AFPSAT show "Coming soon" and
sell nothing.

### How it works for a student

1. **Prices follow the exam.** Student: ₱29 weekly, ₱99 monthly, ₱799 yearly. Civil Service: ₱49
   weekly, ₱149 monthly, ₱1,199 yearly, or a ₱499 pass. The CSE Pro page uses the academy-exam
   layout: three plan cards, then the pass as a wide card (ST_ProCSE_v2).
2. **A higher plan covers lower exams.** Civil Service Pro also covers every Student exam.
3. **A pass covers one exam until its next sitting.** It is paid once, never renews, and ends after
   the next published exam date. Buying another pass later starts again for the following sitting.
4. **One free trial per student.** The 7-day trial is on Monthly only. A student whose Google
   account ever had a Pantas subscription gets no trial again, on any tier. Corrected October 6
   (Aedwon chose Google Play's rule, abuse review 1, CX-19): a Season Pass or a giveaway grant alone
   does not use up the trial, and new Google accounts are an accepted risk.
5. **Switching exams.** Same or cheaper exam: Pro stays. Pricier exam: the student sees that exam's
   plans as an upgrade (no trial), or can switch on Free. Upgrading replaces the old subscription
   through Google Play, which credits the unused part, so nobody pays twice. A pass holder is warned
   that the pass stays with its exam.
6. **Exam dates on passes are published dates only.** A pass shows "Until Mar 1, 2027". If no date
   is published yet, the pass cannot be bought.

### What needs your decision

1. **Published exam dates.** Passes and the onboarding "Is this your exam day?" card need official
   exam dates. Options:
   - (a) You supply each date with its official source link, and we record both in the content.
     **Recommended.** It is the only way that meets "never invent a figure".
   - (b) No dates at launch: no passes can be bought, and onboarding always asks for the date.
2. **Price points.** Google Play must offer ₱49, ₱149, ₱1,199 and ₱499 in the Philippines. You confirm this in
   Play Console before the products are created. If a price is not offered, the work stops and you
   pick the nearest price.
3. **New product names** (permanent once created): `pantas_cs_weekly` (₱49), `pantas_cs_monthly`
   (₱149 a month, 7-day trial), `pantas_cs_yearly` (₱1,199) and `pantas_pass_cse_pro` and `pantas_pass_cse_sub` (one pass product per exam, amended Oct 10; the earlier single id was `pantas_pass_cse_pro` / `pantas_pass_cse_sub`) (₱499,
   bought again for each sitting). The existing Student
   products stay. **Recommended** as named.

### What you do in the stores (with step-by-step instructions at level 3)

Create the four products in Play Console; set the trial on Student Monthly and Civil Service Monthly
with "new customers only, across all subscriptions"; remove the trial from Yearly; mirror all of it
in RevenueCat. Nothing is created until you approve this spec.

### Cost and risk

About 4 to 6 days in W3 plus your store setup. The main risk is Play's upgrade handling between
tiers; W5's test purchases on the test track check every case before beta.

---

## Part B. Agent section

### B1. Data

- Exam catalog (W0 contract): `priceTier`, `group`, `comingSoon`, `publishedSittings[]` with
  `firstDay`, `lastDay`, `sourceUrl`. Set for every exam at launch; `comingSoon: true` for Licensure,
  academy exams, PSHS-NCE, NAPOLCOM, AFPSAT.
- Entitlement (W3 contract): subscription tier from the active product; passes as records
  `{examId, sittingLastDay, purchasedAt, transactionId}` written by the webhook on
  `NON_RENEWING_PURCHASE` and mirrored to the user's custom claims as `passes`.

### B2. Pass end date

`endsAt` is the last day of the first published sitting on or after the purchase date. If that
sitting's date later moves later, `endsAt` moves with it; if earlier, the original date stands
(D-227). Computed server-side from the Functions build's copy of `content/exams/catalog.json` (amended Oct 6), from
the same catalog the app ships; the webhook stores the result.

### B3. Products and RevenueCat

- Subscriptions: Student weekly, monthly, yearly; Civil Service weekly, monthly, yearly. Google Play
  can replace any subscription in the app; level 3 confirms the replacement mode for each pair
  against current Play Billing documentation before W3 implements it (gate N-19). RevenueCat entitlement `pro` stays; the tier is derived from the
  product id in one table (W3).
- Pass: consumable `pantas_pass_cse_pro` / `pantas_pass_cse_sub`, RevenueCat non-subscription purchase; the app sends
  the exam id as purchase metadata; the server rejects a pass for an exam with no future published
  sitting.
- Upgrade: `purchase` with a Google Play replacement mode that credits the unused part of the
  Student subscription (Part A item 5), confirmed per pair at level 3.

### B4. Trial eligibility

Play offer eligibility "new customer acquisition: never had any subscription in this app" on both
Monthly offers. The app shows the trial only when RevenueCat reports the intro offer eligible.

### B5. Tests

Tier mapping, inclusion, pass scope and end dates (including moved dates), trial eligibility display,
`switchOutcome` for every switching board, webhook pass recording, and rejection of passes without
a published sitting. Store flows are checked by W5 A03 on the test track.
