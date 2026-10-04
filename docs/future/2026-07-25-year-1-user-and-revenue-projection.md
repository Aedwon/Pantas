# Year-1 user and revenue projection (Pantas / CSE-CET Reviewer)

> **Pricing superseded (4 October 2026).** Prices, plans, and products in this file are historical. The only current prices are in `docs/pricing.md`. Do not quote or implement a price from this file.

**Prepared:** 2026-07-25
**Window:** 12 months from public launch. Calendar-anchored to **Sept 2026 – Aug 2027**.
**Content assumption (given):** complete content for CSE Professional, all five CET/scholarship benchmarks (UPCAT, ACET, DLSUCET/DCAT, USTET, DOST-SEI).
**Platform:** Android / Google Play only — iOS is an explicit non-goal in Spec 7.
**Pricing:** Weekly ₱29 · Monthly ₱99 · Yearly ₱499 (7-day trial) · Lifetime ₱1,499 (Spec 7 + 2026-07-18 amendment).
**Basis:** cash collections inside the window, net of VAT and Play service fee.

---

## 1. Headline figures

| Metric (12 months) | Bear | **Base** | Bull |
|---|---:|---:|---:|
| Installs | 10,000 | **25,000** | 75,000 |
| Activated users (onboarding done) | 7,200 | **18,000** | 54,000 |
| MAU at month 12 (Aug 2027 peak) | ~1,650 | **~4,100** | ~12,300 |
| — of which **free** | ~1,610 | **~3,920** | ~11,300 |
| — of which **paid (active Pro)** | ~40 | **~180** | ~1,000 |
| Free-trial starts (cumulative) | 48 | **217** | 998 |
| **Unique payers (cumulative)** | **100** | **450** | **2,250** |
| Install→payer rate | 1.0% | **1.8%** | 3.0% |
| **Net revenue (₱, to developer)** | **₱17,000** | **₱84,000** | **₱448,000** |
| Net revenue (USD @ ₱58) | ~$300 | ~$1,450 | ~$7,700 |
| Gross consumer billings (₱) | ₱22,400 | ₱110,300 | ₱590,300 |
| Net revenue per install | ₱1.70 | **₱3.36** | ₱5.97 |
| Net revenue per payer | ₱170 | **₱187** | ₱199 |

Compact model: **Net Y1 ₱ ≈ installs × conversion% × ₱187.**

External sanity check: RevenueCat's 2026 cohort of new subscription apps — 57.7% earn $1–1,000 in year one, 22.4% earn $1,001–10,000, only 7.9% ever cross $100k/yr. Bear lands in the modal band, Base in the second band (top ~40%), Bull near the top of it. No scenario here is a hockey stick, and none should be.

---

## 2. Market size (top-down grounding)

| Exam in scope | Annual candidates | Latest hard figure |
|---|---:|---|
| CSE-PPT Professional | ~295,000/sitting × 2 sittings | 302,028 (Aug 2025); 287,250 (Mar 2025) |
| CSE-PPT Subprofessional | ~30,000/sitting × 2 | 29,647 (Aug 2025) |
| CSE total | **~640,000 sittings/yr** | 307,000+ took the Mar 2026 sitting |
| UPCAT | **147,437** | AY 2026–27 applicants (+9% YoY from 135,236) |
| DOST-SEI undergraduate scholarship | **97,617** | 2026 examinees (up 15.5% from 84,518 in 2025); 8,500 qualified |
| USTET | **~36,700** | AY 2025–26 undergraduate applicants |
| DCAT (DLSU) | ~25,000–30,000 *(estimate — not published)* | admits ~4–5k/yr |
| ACET (Ateneo) | ~15,000–20,000 *(estimate — not published)* | admits ~2.5–3k/yr |
| **Total sittings** | **~967,000/yr** | |
| *(adjacent, not in stated scope)* PSHS-NCE | **20,232** | 2026 examinees from 27,965 applicants; 1,920 slots |

Deduplicated: CET/scholarship candidates overlap heavily (one Grade 12 student typically sits UPCAT *and* DOST-SEI *and* one or two private CETs), so unique CET/scholarship candidates ≈ **200,000–250,000**. CSE repeat-takers are common, so unique CSE candidates ≈ **450,000–500,000**. **Unique addressable candidates ≈ 650,000–750,000/yr.**

Context: SHS enrolment is 3.6M across Grades 11–12 (SY 2025–26, down from 3.9M) — roughly 1.7–1.8M per year level, of whom only ~200–250k sit a competitive CET.

Base-case penetration: **3.6% of unique candidates install, 0.064% pay.** That is the honest scale of the base case.

---

## 3. The binding constraint: nobody has won this category on Play

Install tiers pulled live from Google Play (2026-07-25, PH storefront):

| App | Installs | Ratings |
|---|---:|---:|
| Civil Service Reviewer 2026 (Dodo Corp) — self-described "#1" | **10K+** | 224 |
| Civil Service Exam Reviewer (EmergeDevs) | 10K+ | 19 |
| Civil Service Reviewer 2025 (Cesar Apps) | 10K+ | 19 |
| C.S. Exam Reviewer – PH (CodaTech) | 100+ | — |
| PassPH: Exam Reviewer (multi-exam: UPCAT, DOST-SEI, CSE, LET) | 1K+ | 17 |
| *Adjacent benchmark:* LTO Exam Reviewer (Derasaty) — well-executed PH reviewer | **100K+** | 1,430 |

Thirty-plus CSE reviewer apps exist and the leader sits at 10K–50K lifetime installs against ~640,000 exam sittings a year. Two readings, both true:

1. **Opportunity.** There is no incumbent to displace. Pantas is materially better built than anything on the shelf (FSRS scheduling, lessons, blueprint-sampled mocks, offline-first, six exams).
2. **Demand warning.** The gap between 640,000 candidates and 10K-install leaders is not purely an execution gap. Most candidates review from free PDFs, Facebook groups, and printed reviewers. App installs are *not* the default behaviour of this market. The LTO app proves 100K+ is reachable with good execution in a high-volume PH reviewer category — that is the ceiling the Bull case is calibrated against, not a million-install fantasy.

**This is why the base case is 25,000 installs and not 100,000.** Note what it implies competitively: 25,000 installs in twelve months would make Pantas the **category leader on Play by year end**, exceeding the current leader's lifetime total. The base case is conservative in absolute pesos, not in competitive terms.

---

## 4. Unit economics per SKU

Google Play in the Philippines uses **tax-inclusive pricing**, so the 12% VAT (RA 12023, effective 2025-06-01) comes out of the listed price. The Play service fee is 15% on the first $1M of annual earnings (subscriptions at 15% from day one). Google's June 2026 restructure (10% service + 5% billing fee = same 15% effective when using Play Billing) launched in US/EEA/UK first and has not reached PH — either way the effective take is 15%.

| SKU | List | Less 12% VAT | Less 15% Play | **Net to you** |
|---|---:|---:|---:|---:|
| Weekly | ₱29 | ₱25.89 | −₱3.88 | **₱22.01** |
| Monthly | ₱99 | ₱88.39 | −₱13.26 | **₱75.13** |
| Yearly | ₱499 | ₱445.54 | −₱66.83 | **₱378.70** |
| Lifetime | ₱1,499 | ₱1,338.39 | −₱200.76 | **₱1,137.63** |

Effective net factor: **0.759 × list price.**

---

## 5. Funnel assumptions and where each comes from

| Assumption | Bear | Base | Bull | Basis |
|---|---:|---:|---:|---|
| Install → activated (onboarding complete) | 72% | 72% | 72% | Standard install-to-open for PH low-end Android |
| Install → payer (cumulative, 12 mo) | 1.0% | **1.8%** | 3.0% | RevenueCat 2026: D35 download-to-paid median **0.7%** for Education in IN/SEA (top quartile 1.9%); all-category IN/SEA **1.37%**. Education converts late — 23.5% of trials start 31+ days post-install — so cumulative-year conversion runs ~1.5–2× the D35 figure. Base = roughly D35 1.1% → above IN/SEA Education median, below top quartile. |
| First-SKU mix (Weekly/Monthly/Yearly/Lifetime) | 35/40/22/3 | 35/40/22/3 | 35/40/22/3 | Derived from Spec 7 §6 recommendation buckets: most users install 1–3 months out (→ Monthly), late crammers ≤21 days (→ Weekly), early/no-date (→ Yearly). Deliberately *not* the global Education mix (59% annual) — Pantas recommends by exam date, and PH wallets budget weekly. |
| Weekly renewals per buyer | 2.2 | **2.6** | 3.0 | Exam-bounded by design; weekly cohorts retain worst globally (Day-380 retention ~5.5%) |
| Monthly renewals per buyer | 1.8 | **2.1** | 2.5 | Global first-renewal retention 59.2%; exam deadline caps the tail |
| Yearly starts taking the trial | 85% | 85% | 85% | Play enforces one trial per account; remainder buy direct |
| Trial → paid | 22% | **28%** | 32% | Education global trial→paid ~25.6%; 7-day trials sit at the low end of the 25.5–42.5% range. Base is set slightly above median for a deadline-motivated audience, then held down by Spec 7 D10's three honest trial-end warnings (transparency costs conversion — accepted). |
| Refunds / involuntary churn leakage | 5% | 4% | 4% | GCash/prepaid billing failures on weekly charges (spec §6 accepts this) |
| Renewals spilling past the window | — | ~4% | ~4% | Monthly subs bought in M11–M12 collect part of their revenue in M13–M14 |

Retention curve used for MAU (share of an activated cohort still active, by month age): 1.00, 0.30, 0.16, 0.10, 0.07, 0.05, 0.04, 0.03, 0.025, 0.02, 0.02, 0.015. Steeper than a habit app, flatter than a one-shot utility — users leave after their exam.

---

## 6. Seasonality: the exam calendar drives everything

| Month | Live exam demand | Install share |
|---|---|---:|
| Sep 2026 | Launch. ACET + USTET application/testing season | 4.2% |
| Oct 2026 | ACET test (~Oct); USTET testing | 5.4% |
| Nov 2026 | DCAT tests (Nov 8/15); CSE-March filing (Nov) | 6.6% |
| Dec 2026 | DCAT Laguna (Dec 6); DOST-SEI + CSE-March prep; holidays | 5.8% |
| Jan 2027 | CSE-March + DOST-SEI crunch | 8.0% |
| Feb 2027 | **DOST-SEI exam (~Feb 20–21)**; CSE-March crunch | 10.0% |
| Mar 2027 | **CSE-PPT exam (2nd Sunday, ~Mar 14)** | 10.4% |
| Apr 2027 | Post-exam trough; UPCAT applications open | 6.6% |
| May 2027 | CSE-August filing opens (~May 14) | 7.2% |
| Jun 2027 | CSE-August filing closes; UPCAT prep | 9.6% |
| Jul 2027 | UPCAT + CSE-August crunch | 11.2% |
| Aug 2027 | **UPCAT exam (~Aug 1) + CSE-PPT exam (~Aug 8)** — double peak | 15.0% |

Anchors: CSE-PPT runs 8 Mar and 9 Aug in 2026 (first sitting moved to the 2nd Sunday of March from 2026 onward); UPCAT 2027 was administered 1–2 Aug 2026 with applications closed 30 Mar 2026; DCAT AY2027–28 applications ran 15 Jul–30 Sep 2026 with tests 8/15 Nov and 6 Dec 2026; DOST-SEI's 2026 exam was 21–22 Feb 2026.

**Timing consequence:** launching in September 2026 catches the ACET/DCAT/USTET application season with the app's weakest asset base (no ratings, no word of mouth) and its strongest month (Aug 2027) at full maturity. Launching in November instead would forfeit the entire private-CET season and cost roughly 15% of Year-1 installs. Launching after March 2027 would forfeit the CSE-March peak as well — closer to 30%.

---

## 7. Base case, month by month

| Month | Installs | Cum. installs | MAU | Active Pro | Cum. payers | Net rev (₱) |
|---|---:|---:|---:|---:|---:|---:|
| M1 Sep 2026 | 1,050 | 1,050 | 756 | 8 | 19 | 3,060 |
| M2 Oct 2026 | 1,350 | 2,400 | 1,199 | 26 | 43 | 4,160 |
| M3 Nov 2026 | 1,650 | 4,050 | 1,601 | 47 | 73 | 5,510 |
| M4 Dec 2026 | 1,450 | 5,500 | 1,632 | 52 | 99 | 5,040 |
| M5 Jan 2027 | 2,000 | 7,500 | 2,093 | 68 | 135 | 6,680 |
| M6 Feb 2027 | 2,500 | 10,000 | 2,624 | 88 | 180 | 8,220 |
| M7 Mar 2027 | 2,600 | 12,600 | 2,909 | 105 | 227 | 8,840 |
| M8 Apr 2027 | 1,650 | 14,250 | 2,376 | 103 | 257 | 6,280 |
| M9 May 2027 | 1,800 | 16,050 | 2,381 | 106 | 289 | 6,370 |
| M10 Jun 2027 | 2,400 | 18,450 | 2,809 | 128 | 332 | 7,900 |
| M11 Jul 2027 | 2,800 | 21,250 | 3,235 | 152 | 382 | 9,230 |
| M12 Aug 2027 | 3,750 | 25,000 | 4,084 | 176 | 450 | 12,410 |
| **Total** | **25,000** | **25,000** | — | **176** | **450** | **₱83,700** |

MAU dips in Apr–May: the March CSE cohort has passed its exam and left, and the UPCAT cohort has not yet ramped. Expect that trough every year; it is not a churn regression.

### Revenue mix, base case

| SKU | Payers | % of payers | Net revenue | % of revenue |
|---|---:|---:|---:|---:|
| Weekly ₱29 | 157 | 35% | ₱8,985 | 10% |
| Monthly ₱99 | 180 | 40% | ₱26,170 | 30% |
| Yearly ₱499 | 99 | 22% | ₱37,490 | 43% |
| Lifetime ₱1,499 | 14 | 3% | ₱15,930 | 18% |

Two things to notice. **Lifetime is 18% of revenue from 3% of payers** — the spec calls it a rarely-selling anchor SKU, but at these volumes those ~14 buyers matter more than all 157 weekly buyers combined. And **Weekly delivers 10% of revenue for 35% of payers, plus the highest support and billing-failure load.** Weekly is doing exactly the job §1 of the amendment assigned it — access, not ARPU — so this is designed behaviour, not a leak.

---

## 8. Sensitivity

Net Y1 revenue (₱ thousands), installs × install→payer rate:

| Installs ↓ / Conversion → | 0.7% | 1.0% | 1.4% | **1.8%** | 2.5% | 3.0% |
|---|---:|---:|---:|---:|---:|---:|
| 10,000 | 13 | 19 | 26 | 34 | 47 | 56 |
| 15,000 | 20 | 28 | 39 | 50 | 70 | 84 |
| **25,000** | 33 | 47 | 65 | **84** | 117 | 140 |
| 40,000 | 52 | 75 | 105 | 134 | 187 | 224 |
| 75,000 | 98 | 140 | 196 | 252 | 350 | 420 |
| 150,000 | 196 | 280 | 392 | 504 | 700 | 841 |

Reaching **₱1M net in a year needs ~300,000 installs at base conversion** — three times the best PH reviewer app on the store. Consumer freemium at peso price points does not get there in year one by any realistic combination of these two dials.

---

## 9. Three findings that matter more than the projection

### 9.1 Paid user acquisition can never pay back

An install is worth **₱3.36 net** in the base case (₱5.97 even in Bull). Philippine Android CPI benchmarks sit around **$0.73 ≈ ₱42**. Paid acquisition is **7–12× underwater** — and no plausible conversion improvement closes a 12× gap.

Every scenario above must therefore be delivered **organically**: ASO on high-intent queries ("civil service reviewer", "UPCAT reviewer", "DOST-SEI exam"), the exam-results and reviewer-content SEO play that Topnotcher.ph already runs well, Facebook exam-taker groups, TikTok study content, school and guidance-office partnerships, and the Wrapped landing page as a shareable loop. Budget belongs in content and school relationships, not in Google/Meta install campaigns.

### 9.2 The pricing scheme's own §10.3 finding is the biggest revenue item

Spec 7's pricing amendment already identified it: **one price, two wallets.** The CSE user self-funds against free reviewers and a ₱500 filing fee. The CET/scholarship user's payer is a parent anchored to ₱12,000–45,000 review centres.

Quantified against the base case: if ~40% of payers are CET-track (180 payers) and a quarter of them (45) take a parent-facing tier at **₱1,499/yr** (net ₱1,137.63) instead of blended Pro (net ₱187), that is **+₱42,800 — a 51% increase in Year-1 net revenue from one SKU and some parent-facing reporting.** No conversion-rate optimisation available anywhere else in this model comes close.

### 9.3 B2B seat licensing outranks the entire consumer funnel

Six private schools × 120 seats × ₱250/seat/yr = ₱180,000 gross, invoiced directly with no Play fee → **~₱160,000 net, about 1.9× the whole base-case consumer business.** Same for LGU/agency CSE cohorts. This needs the multi-seat account model and per-learner reports that `docs/future/post-launch-revenue-and-telemetry.md` already parks for v2 — and it needs the event taxonomy in place *before* launch, because impact data cannot be reconstructed retroactively.

---

## 10. Costs and contribution (base case)

| Item | Year 1 |
|---|---:|
| Firebase Blaze (asia-southeast1, offline-first app, ~4k MAU) | ₱7,000–17,000 |
| RevenueCat | **₱0** — free below $2,500 monthly tracked revenue; base peaks near $180/mo |
| Sanity | ₱0 on free tier at this content volume |
| Play Console (one-time) | ₱1,450 |
| Codemagic CI | ₱0–ish on free minutes |
| **Total infrastructure** | **₱15,000–25,000** |
| **Contribution (base)** | **₱60,000–70,000** |

Static question pipeline means no per-user inference cost, so gross margin stays near 76% of list price regardless of scale. Not modelled: NPC registration, DTI, legal review of Privacy/Terms, and the week-6 pentest — one-time compliance costs that will exceed Year-1 revenue in the Bear case and roughly match it in Base.

At base case the app clears its own infrastructure by about month 3 and reaches roughly **₱7,000–12,000/month by month 12**. It covers hosting. It does not yet pay anyone.

---

## 11. What would move these numbers most

Ranked by peso impact per unit of work:

1. **Parent-facing CET tier at ₱1,499–2,999/yr** (+50% or more; content already complete under the stated assumption).
2. **B2B seat licensing to private schools and LGUs** (~2× consumer revenue at six accounts; needs multi-seat model).
3. **Event taxonomy shipped before launch** — gates #2, and cheap now versus impossible retroactively.
4. **Trial surfaced more widely.** Download-to-trial here is ~0.9% against a 6.5% Education median, because Spec 7 D2 deliberately never offers the trial unsolicited and the trial lives only on Yearly. Offering it on Monthly, or once at the post-mock dossier moment, is the largest untapped conversion lever inside the current SKU set — and it can be done without dark patterns.
5. **iOS.** Android is ~89% of PH mobile OS, but the missing ~11% concentrates precisely in the ACET/DLSU/USTET private-school segment with the parent payer. Rough uplift: +12–18% installs, +20–30% revenue, because those users skew high-ARPU.
6. **Ratings velocity.** The current leader has 224 ratings. Two hundred honest ratings in the first quarter would make Pantas the highest-credibility listing in the category, which is the cheapest organic install lever available.

## 12. Figures to verify before treating this as a plan

- **Play Console tax setting for PH** — this model assumes VAT-inclusive listed prices (12% out of the ₱99, not added on top). Confirm in Console; if PH prices turn out VAT-exclusive, net revenue rises ~12%.
- **ACET and DCAT applicant counts** are estimates; neither university publishes them. They affect TAM, not the base case (which is install-anchored, not TAM-anchored).
- **Actual launch month.** Everything here assumes September 2026. Slipping past March 2027 costs roughly 30% of Year-1 installs by forfeiting both the private-CET season and the CSE-March peak.
- **Install→payer at 1.8%** is the single most load-bearing assumption. The first mock-exam dossier cohort will measure it within about six weeks of launch; re-run §8 with the real number rather than defending this one.

---

---

# Part II — The credibility-led case (added 2026-07-25)

§1–12 model Pantas as an anonymous app competing on product quality. That is the wrong frame if the founder's credentials are used as distribution. **Philippine Science High School graduate · UP Diliman · DOST Merit Scholar** is not a nice-to-have bio line in this market — it is the exact signal review centres charge ₱12,000–45,000 to imply.

## 13. What credibility changes, and what it cannot

**Cannot change (hard constraints, unchanged from Part I):**
- Net revenue per SKU. VAT 12% + Play 15% = ×0.759, regardless of who built the app.
- Paid-install arithmetic at current prices. ₱42 CPI against ₱3–6 net per install stays underwater. Credibility only fixes this by raising price, not by raising conversion.
- Play install behaviour. 150,000 installs is 1.5× the best-performing PH reviewer app on the store. Credibility raises the ceiling; it does not remove it.

**Changes materially:**
1. **Trust-gated conversion.** §10.4 of the pricing amendment already identified the real risk: "the threat is not price level; it is differentiation from free." Credibility is the fastest available differentiation, applied precisely at the paywall moment. Install→payer 1.8% → **3.0–4.0%**.
2. **Organic reach.** Founder-led content plus three warm networks replaces a marketing budget that does not exist.
3. **Pricing power.** This is the largest single effect. A PSHS/UP/DOST-scholar founder can credibly sell a **parent-facing tier at ₱1,999/yr** — the exact move §10.3 parked for v2. Anonymous test-bank apps cannot.
4. **B2B doors.** PSHS National Alumni Association (holds a seat on the PSHS Board of Trustees), DOST-SEI regional offices, UP student organisations, private-school guidance offices. Warm intros instead of cold procurement.
5. **A new exam track he is maximally credible for: PSHS-NCE.**

### 13.1 The reach assets, quantified

| Network | Size | Why it converts |
|---|---:|---|
| DOST-SEI active scholars | **54,307** (48,520 undergrad) | He is one. Peer scholars are exactly who SHS students ask for scholarship-exam advice |
| DOST-SEI examinees/yr | **97,617** | Grew 15.5% in one year; 91% fail and retake or pivot |
| PSHS system students | ~8,400 across 16 campuses | Alumni-chapter access; 10 new campuses planned under the Expanded PSHS Act |
| PSHS-NCE examinees/yr | **20,232** (from 27,965 applicants) | Grade 6 exam → **100% parent-payer**; 8.5% pass rate; review centres already sell one-on-one NCE prep |
| UP Diliman students | ~25,000 | Org partnerships; UP orgs already run free UPCAT outreach reviews |
| UPCAT official FB page | 631,289 followers | Indicates the size of the annual UPCAT conversation |

**Precedent for the ceiling:** Team Lyqa (Lyqa Maravilla) topped the 2013 CSE and turned that single credential into millions of followers across YouTube/TikTok/FB plus books, an Online Review Program, and a paid Digital Pass. Creator-led exam coaching in the Philippines is a proven business, not a hypothesis. It is also the competitive warning — she took roughly a decade to build it.

### 13.2 New SKU assumed in Part II

| SKU | List | Net (×0.759) |
|---|---:|---:|
| `pro_parent_yearly` (CET/NCE, parent-facing: progress reports, coverage guarantee) | **₱1,999/yr** | **₱1,517.10** |

Still 4–13% of a mid-tier review centre, so the honesty framing in §10 holds.

## 14. Credibility-led scenarios

Payer mix shifts toward CET/scholarship/NCE, because that is where the credentials land: Weekly 22–25% · Monthly 33–35% · Yearly ₱499 22% · **Parent ₱1,999 13–16%** · Lifetime 5–7%. Renewals improve on trust (weekly 3.0, monthly 2.5, trial→paid 33%).

| Metric (12 months) | Part I Base | **C1 Credibility-led** | **C2 + parent tier + NCE** | **C3 Stretch + B2B** |
|---|---:|---:|---:|---:|
| Installs | 25,000 | **60,000** | **90,000** | **150,000** |
| Activated users | 18,000 | 43,200 | 64,800 | 108,000 |
| MAU at M12 | 4,100 | **9,800** | **14,700** | **24,500** |
| — free | 3,920 | 8,900 | 13,060 | 21,400 |
| — **paid (active Pro)** | 180 | **900** | **1,640** | **3,100** |
| Unique payers (cumulative) | 450 | **1,800** | **3,150** | **6,000** |
| Install→payer | 1.8% | 3.0% | 3.5% | 4.0% |
| Net revenue — consumer | ₱84k | **₱708,000** | **₱1,431,000** | **₱2,724,000** |
| Net revenue — B2B | — | — | — | **₱500,000** |
| **Total net revenue** | **₱84k** | **₱708,000** | **₱1,431,000** | **₱3,224,000** |
| USD @ ₱58 | ~$1,450 | **~$12,200** | **~$24,700** | **~$55,600** |
| Net per payer | ₱187 | ₱393 | ₱454 | ₱454 |
| **Net per install** | **₱3.36** | **₱11.80** | **₱15.90** | **₱18.15** |

C1 revenue build (60,000 installs, 1,800 payers):

| SKU | Payers | Net revenue | % of revenue |
|---|---:|---:|---:|
| Weekly ₱29 (×3.0 renewals) | 450 | ₱29,714 | 4% |
| Monthly ₱99 (×2.5) | 630 | ₱118,333 | 17% |
| Yearly ₱499 | 396 | ₱149,965 | 21% |
| **Parent ₱1,999** | **234** | **₱355,001** | **50%** |
| Lifetime ₱1,499 | 90 | ₱102,387 | 14% |

**Read that table twice.** 13% of payers produce 50% of revenue. The parent tier is worth more than every other SKU combined, and it exists only because of who built the app. This is the whole answer to "the numbers are grim": the grimness in Part I comes from selling a ₱99 product to a self-funding adult, not from the market being small.

C3 also crosses the RevenueCat billing threshold (~₱36k/yr at 1% of MTR above $2,500/mo) and roughly ₱60–90k in Firebase — still >95% gross margin. Play stays at 15% until $1M in annual earnings, which none of these scenarios approach.

## 15. Where credibility does *not* transfer — and the strategy inversion

PSHS/UP/DOST credentials read as authority to a Grade 6 parent, an SHS student, and a scholarship applicant. To a 32-year-old jobseeker in Cebu taking the CSE, they read as *impressive but irrelevant* — that audience wants "topped the CSE" (Lyqa's actual credential), or a published pass rate.

So the credibility-led plan **inverts the launch scope in the design doc.** Spec §1.2 leads with CSE Professional + UPCAT. Credibility-led sequencing is:

1. **UPCAT + DOST-SEI** — highest credential fit, and DOST-SEI's pool grew 15.5% YoY to 97,617.
2. **PSHS-NCE** — 20,232 examinees, 100% parent-paid, smallest content lift (Grade 6 scope), maximal credential fit. Not in the stated content-complete set; roughly 600–900 items via the existing static pipeline.
3. **ACET / DCAT / USTET** — parent-payer private-school segment (also where the missing iOS 11% concentrates).
4. **CSE last**, monetised on the mass ₱99 tier and carried by published user pass rates rather than by the founder's résumé.

**Compliance note:** "DOST Merit Scholar", "PSHS graduate", and "UP Diliman" are personal credentials and safe to state. Using DOST/PSHS/UP *logos or names as endorsement* of the app is not — those are government institutions and it would misrepresent an institutional relationship. Keep it first-person ("built by a DOST Merit Scholar and PSHS alum"), never institutional.

## 16. What C1 actually costs in effort

None of the Part II numbers are passive. C1 (₱708k) requires, over twelve months:

- **2–3 founder-led videos per week**, on camera, for the full year. This is the single largest line item and it is unpaid labour, not spend.
- **500+ Play ratings by month 6** — the current category leader has 224. Ratings are the cheapest install lever available and the most neglected.
- **Parent tier shipped before the Oct–Dec CET season**: one SKU, one parent progress report, ~2 weeks of work. Highest ROI item in the entire roadmap.
- **Event taxonomy before launch** (`post-launch-revenue-and-telemetry.md`) — gates all B2B in C3, and cannot be reconstructed retroactively.
- **Three named partnerships**: one PSHS alumni chapter, one UP org, one private-school guidance office.
- **NCE content pack** for C2.

Honest confidence: C1 is achievable and I would plan against it. C2 requires the parent tier to actually convert at 13%+ — unproven, and the assumption most likely to be wrong. C3 requires a working content flywheel *and* landed B2B accounts; treat it as an upside case, not a forecast. The first parent-tier cohort and the first 200 ratings will tell you within about eight weeks of launch which column you are in.

---

## Sources

Market size and calendar:
- CSC — Over 307K took the March 2026 CSE-PPT: https://www.csc.gov.ph/over-307k-take-civil-service-exam-results-to-be-released-on-11-may-2026
- CSC — August 2025 CSE-PPT results (302,028 Professional / 29,647 Subprofessional): https://www.csc.gov.ph/50-096-successfully-pass-10-august-2025-career-service-exam
- CSC — 2026 exam schedule and application timelines: https://www.csc.gov.ph/2026-civil-service-exam-schedule-and-application-timelines-released
- UP — UPCAT 2026 results, 147,437 applicants: https://up.edu.ph/more-than-18000-qualify-for-2026-admission-to-up-qualifiers-from-public-schools-rise-to-57-1-from-55-last-year/
- Rappler — UPCAT 2026 breakdown (+9% applicants YoY): https://www.rappler.com/philippines/upcat-2026-results-breakdown/
- UPCAT 2027 application and exam dates (1–2 Aug 2026): https://www.thesummitexpress.com/2026/01/upcat-2027-application-schedule-requirements-exam-dates.html
- DOST-SEI 2025 scholarship exam — 84,518 examinees: https://www.sei.dost.gov.ph/sei-today/articles/dost-sei-scholarship-exam-results-2025
- DOST-CAR — 2026 DOST-SEI exam held 21–22 Feb 2026: https://car.dost.gov.ph/the-2026-dost-science-education-institute-dost-sei-undergraduate-scholarship-examination-was-successfully-held-on-february-21-22-2026/
- The Varsitarian — UST draws 46,700 applicants for AY 2025–26: https://varsitarian.net/ust-draws-46700-applicants-for-ay-2025-2026/
- DLSU undergraduate admissions (DCAT AY2027–28 dates): https://www.dlsu.edu.ph/admission/admissions-undergraduate-first-year-college-application/
- Philstar — SHS enrolment 3.6M, SY 2025–26: https://www.philstar.com/headlines/2025/09/05/2470606/deped-bares-12-million-enrollment-drop-sy-2025-2026

Conversion, retention and monetisation benchmarks:
- RevenueCat, State of Subscription Apps 2026 — Education: https://www.revenuecat.com/state-of-subscription-apps-2026-education/
- RevenueCat, State of Subscription Apps 2026 (regional D35 conversion, Y1 RLTV by region): https://www.revenuecat.com/state-of-subscription-apps
- Adapty — Education app subscription benchmarks (trial→paid, retention by plan duration, new-app revenue distribution): https://adapty.io/blog/education-app-subscription-benchmarks/
- Business of Apps — Education app benchmarks 2026: https://www.businessofapps.com/data/education-app-benchmarks/

Fees, tax and acquisition cost:
- Google Play service fees: https://support.google.com/googleplay/android-developer/answer/112622
- Android Developers Blog — expanded billing choice and lower fees (June 2026, US/EEA/UK first): https://android-developers.googleblog.com/2026/06/play-expanded-billing.html
- Play Console — tax rates and VAT (tax-inclusive pricing in PH): https://support.google.com/googleplay/android-developer/answer/138000
- PwC PH — 12% VAT on digital services, effective 2025-06-01: https://www.pwc.com/ph/en/tax/tax-publications/taxwise-or-otherwise/2025/soon-taking-effect-the-12-vat-on-digital-services.html
- Linkrunner — CPI benchmarks by country (PH ≈ $0.73): https://linkrunner.io/tools/cost-per-install-benchmark
- RevenueCat pricing (free below $2,500 MTR): https://www.revenuecat.com/docs/welcome/set-up-revenuecat/account-management

Competitive install tiers (read live from the PH Play storefront, 2026-07-25):
- Civil Service Reviewer 2026 — 10K+ installs, 224 ratings: https://play.google.com/store/apps/details?id=com.dodocorp.civilservicereviewer
- Civil Service Exam Reviewer (EmergeDevs) — 10K+: https://play.google.com/store/apps/details?id=com.emergedevs.csereviewer
- Civil Service Reviewer 2025 (Cesar Apps) — 10K+: https://play.google.com/store/apps/details?id=com.rmnbacolod.csc.cscexam
- C.S. Exam Reviewer – PH — 100+: https://play.google.com/store/apps/details?id=com.civilservicereviewer.app
- PassPH: Exam Reviewer — 1K+: https://play.google.com/store/apps/details?id=com.passph.app
- LTO Exam Reviewer (adjacent PH benchmark) — 100K+, 1,430 ratings: https://play.google.com/store/apps/details?id=com.msaya.lto.reviewer

Part II — credibility, networks and precedent:
- PSHS-NCE 2026: 20,232 examinees from 27,965 applicants, 1,738 qualifiers, 1,920 slots: https://tribune.net.ph/2026/03/30/1738-qualify-for-pshs-in-nationwide-exam
- PSHS System — 16 campuses, ~8,358 enrolment (SY 2018–19), alumni association seat on the Board of Trustees: https://en.wikipedia.org/wiki/Philippine_Science_High_School_System
- Expanded PSHS Act / 10 new campuses planned: https://pco.gov.ph/news_releases/pbbm-signs-expanded-philippine-science-high-school-act-to-strengthen-stem-education/
- DOST-SEI 2026 — 97,617 examinees, 8,500 qualifiers, 54,307 total scholars (48,520 undergraduate): https://www.prcboard.com/dost-sei-scholarship-results-2026-list-of-passers · https://car.dost.gov.ph/the-2026-dost-science-education-institute-dost-sei-undergraduate-scholarship-examination-was-successfully-held-on-february-21-22-2026/
- Team Lyqa / Lyqa Maravilla — creator-led PH exam coaching precedent (2013 CSE topnotcher → books, Online Review Program, Digital Pass): https://lyqamaravilla.com/
- UPCAT UP System official page reach (631,289 followers): https://www.facebook.com/UPSystemOfficeOfAdmissions/
- Ahead Tutorial & Review — existing paid PSHS one-on-one review programme (parent-payer precedent): https://www.review.ahead.edu.ph/philippine-science-high-school-one-on-one-review-program/

Internal:
- `docs/superpowers/specs/2026-05-21-paywall-entitlement-design.md` (Spec 7)
- `docs/superpowers/specs/2026-07-18-weekly-sku-pricing-amendment-design.md` (§10 pricing rationale)
- `docs/superpowers/specs/2026-05-07-cse-cet-reviewer-app-design.md` (launch scope, free-tier gates)
- `docs/superpowers/specs/2026-05-17-mock-exam-design.md` (free tier: 1 mock / 14 days / track)
- `docs/future/post-launch-revenue-and-telemetry.md` (B2B streams, telemetry gap)
