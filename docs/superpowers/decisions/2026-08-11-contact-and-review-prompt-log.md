# Contact details, the feedback destination and the review prompt

**11 August 2026.** Opened by Aedwon asking what the situation was with `url_launcher`
and `in_app_review`, the two packages Part 0 still listed as blocked on him.

---

## Round 1: what was actually blocked

**`url_launcher` was not blocked.** It was approved on 10 August and shipped with the
force-update button. `2026-08-04-execution-dispatch-log.md`, "The `url_launcher`
decision, closed 10 August", has that round. Part 0 of the execution pipeline still
listed it as blocking a task. That line was stale and I said so.

**What was still open was the destination, not the package.** The "Send feedback" row
in About has an empty `onTap`. So does "Contact our DPO".

**A thing nobody had noticed.** The contact details in the app were still the old
product's: `privacy@csecetreviewer.ph`, `support@csecetreviewer.ph`, and
"CSE Reviewer, Metro Manila, Philippines". The privacy and terms text names
"CSE Reviewer" as well. The app was renamed to Pantas on 11 August and this was
missed. A student reading the privacy page would see another product's name.

**Aedwon:** *"so what decisions are needed from me and what are my options?"*

---

## Round 2: the three decisions put to him

| | Options and cost |
|---|---|
| **Contact details** | No options. The real addresses were needed. |
| **What "Send feedback" does** | **Mail app**: works today, no setup, feedback arrives as unsorted email. **Google Form**: he has to build the form, answers come back structured. **Remove the row**: a student has no way to reach him. |
| **`in_app_review`** | **Add it now**, or **leave it out of the beta** as planned. Nothing was blocked on it either way. My recommendation was to leave it out, because a rating prompt during beta asks the wrong people. |

**His answers**, verbatim: *"1. dpo@pantas.app 2. yes open the mail app 3. it should be
tested in beta as well"*

Then, on my asking for the support address and the postal address separately:
*"1. dpo@pantas.app 2. contact@pantas.app 3. no office yet. can you not include it?"*

**The postal address comes out.** He has no office. I removed the field rather than
leaving a placeholder for someone to fill in later. I told him the Play Console asks
for an address when a developer account is verified, that a home address is allowed
there, and that I was not certain of the current rule so he should read what the
console asks.

**He reversed my recommendation on the review prompt.** He wants the popup in the beta
so it gets tested with everything else. `in_app_review` goes into `pubspec.yaml`.

---

## Round 3: the mail app answer was a reversal, and I did not tell him

**This is my mistake and it is the reason this round exists.**

I put the feedback destination to him as an open question with three options. It was
not open. **It was decided on 3 August: the row opens a community group, not a mail
composer.** That is in Section 8 of
`specs/2026-08-03-platform-foundations-design.md` and in Task 2 of
`plans/2026-08-03-foundations-03-l10n-feedback-and-review.md`. His reasoning then was
that Facebook is ubiquitous in the Philippines, so a group is where students already
are, and it keeps feedback in one place instead of scattering it across a hundred
one-to-one threads. Discord was the alternative he was weighing.

I found it only when I opened the plan to implement his answer. I stopped and put the
conflict to him before writing any code.

**Aedwon:** *"oh yeah i forgot about that. let's go for the fb one
https://www.facebook.com/groups/1760794271928040 i just created it"*

**So the 3 August decision stands and the mail-app answer is withdrawn.** The group
exists now, which it did not on 3 August.

| | Cost |
|---|---|
| **Facebook group** (chosen) | He has to moderate it. A public group is a place a student can post something identifying about themselves. Nothing is collected and nothing is sent, so no prefill and no build number reaches him. |
| **Mail app** | No moderation. Feedback arrives one thread at a time and none of it is visible to other students. |

**`contact@pantas.app` is still recorded**, because Play requires a developer contact
email on the listing and a group does not satisfy that. It is not wired to a row.

**The DPO row opens the mail app** to `dpo@pantas.app`. That one was never a group
question. A privacy request is one-to-one by nature.

---

## What went in

- `dpo@pantas.app`, `contact@pantas.app`, no postal address.
- Every "CSE Reviewer" in the app becomes "Pantas", including the privacy and terms
  text and the About page heading.
- "Send feedback" opens the Facebook group externally, and the row names where it goes.
- "Contact our DPO" opens the mail app.
- `in_app_review` is approved and the prompt is built for the beta.

**One more stale thing found while doing it.** The force-update button pointed at
`play.google.com/store/apps/details?id=com.pantas.app`. The application ID is
`com.aedwon.pantas`, set on 11 August. The one button on the one screen a student
cannot dismiss would have opened a listing that does not exist. Fixed here.
