# Mailbox retention sweep

Owner: Aedwon. About 5 to 10 minutes, once a month, at the monthly cost check. Required before the legal texts publish. Source: Fable ruling B3 (Nov 24, "remaining legal brackets"), in `docs/superpowers/decisions/2026-11-17-fable-backlog-rulings.md`.

## What the published texts promise

Both notices promise two limits, counted from the last email in the thread. They cover emails to and from `support@pantas.study` and `dpo@pantas.study`, and our replies.

- Emails about a payment, a refund, a purchase complaint or a privacy request: deleted within two years of the last email.
- All other emails: deleted within 90 days of the last email.

A thread held for an unanswered request, a bank dispute, a DTI or NPC complaint or a court case is kept longer. The notices allow this ("when we need them for a legal claim").

## Where the mail is

- `pantas.study` mail goes through Cloudflare Email Routing (the MX records are `route1`, `route2` and `route3.mx.cloudflare.net`, checked Nov 24). Cloudflare forwards the mail and stores none.
- The copies and your sent replies sit in the Gmail inbox that the addresses forward to, `aerol.balayon@gmail.com`. The sweep happens there. The forwarding destination and any "send as" setting are not confirmed in the repo: check them once in the Cloudflare dashboard (Email, Email Routing) and in Gmail settings.
- If `contact@pantas.study` is in use, it is covered by the same sweep.

## One-time setup (5 minutes, once)

1. In Gmail, create two labels: `pay-2y` and `hold`.
2. Send a test email to `support@pantas.study` and to `dpo@pantas.study`. Confirm both reach this inbox.
3. Settings, Inbox: leave conversation view on. The list shows the date of the newest message in each thread, and the sweep uses that date.

## When you reply to a thread (a few seconds each)

1. If the thread is about a payment, a refund, a purchase complaint or a privacy request, put the label `pay-2y` on it. This includes a parent or guardian denying a purchase, and requests to see, correct or delete data.
2. If the request is unanswered, or a bank dispute, DTI or NPC complaint or court case is open, put the label `hold` on it as well.
3. Leave every other thread unlabeled. Unlabeled means ordinary.

## The monthly sweep

Run each search in the Gmail search box. The cutoffs are 45 days and about 23 months, so the published limits still hold when a sweep runs a month late.

1. **Answer first.** Search `in:inbox is:unread to:support@pantas.study OR to:dpo@pantas.study`. Reply to anything waiting. Put `hold` on anything that needs it.
2. **Ordinary mail.** Search `older_than:45d -label:pay-2y -label:hold -in:trash`. Look at the date shown on each row: it is the newest message in that thread. Select only rows dated more than 45 days ago. A thread with a recent reply shows a recent date: leave it. Delete the selected threads.
3. **Payment, refund, complaint and privacy mail.** Search `label:pay-2y older_than:700d -label:hold`. The same rule: select only rows whose date is 700 days (about 23 months) or older. Delete them.
4. **Held mail.** Search `label:hold`. For each thread whose matter has ended, remove the `hold` label. The next sweep deals with it by its age.
5. **Sent replies.** Repeat steps 2 and 3 with `in:sent` added to each search. Replies carry the thread's label, so they follow the thread.
6. **Forwarded copies.** If any support or privacy mail also sits in another inbox, repeat steps 2 and 3 there.
7. **Empty the trash.** Open Trash and choose "Empty Trash now". Deleted mail is not gone until you do.

## Before you delete a paid refund thread

The refund record kept five years (D8) holds the minimum: date, payer name, payment reference, amount, route, transfer reference, and the last four digits of the receiving account. Check the record exists. Never copy the full account number into it. The full number leaves with the email.

## Log it

Add one line to the launch log or monthly cost check: date of the sweep, number of threads deleted, number held.

## If a host rule can do it

If the mail host can delete by age, a rule can replace steps 2 and 3. Gmail filters cannot delete by age alone, so the sweep stays manual. This was not checked for any other host.
