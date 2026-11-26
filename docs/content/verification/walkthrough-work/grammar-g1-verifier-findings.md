# Grammar G1 verifier findings (14 Filipino Grammar lessons, sweep commit 518404ccd)

Policy read: `origin/main` 2681b2b95 (fetched at start; the lead read a7dc213c0). AGENTS.md, WORKFLOW.md, SUBAGENTS.md read in full. Lessons checked at HEAD 900100646; they are unchanged since the sweep commit 518404ccd (git status clean for the 14 files). Nothing edited except this file.

Severity scale: Blocker = false rule, wrong or non-unique answer, answer given away. Major = P1 to P5 hit, quiz sentence in a check or try, wordiness growth of 18 or more. Minor = style, wording, quiz sentence in an example, growth of 2 to 4.

## 1. Round 4 and round 5 rows

CLOSED unless marked OPEN.

- aspekto 86-90 (Ex 2 repeats pair, re-explains twice): CLOSED. Re-explaining cut; the example still equals the pair and quiz 0022 (Minor below).
- hugnayan 76-79 (R4 check gives wrong options away): CLOSED (options are now complete sequences, one defensible).
- hugnayan 18,32-35,38,56-59 (checks ask the type named in the heading): PARTLY OPEN. Checks now ask clause counts, but the counts equal the numbers printed in the example directly above (Major below).
- hugnayan 110-120 (try accepts panghuli and sa huli): CLOSED. Choice B is the only sequence that follows the events.
- kalagayan 35-38 (check asks a formation rule never stated): CLOSED. Check 1 now asks the aspect of *tumatakbo*.
- kalagayan 77-86, 110-114: CLOSED. Ex 1 ends at "Kakain kami bukas ng tanghali." The try answer puts each label before its full sentence and keeps one short check.
- mga-anyo R4 22,32-35 (sila the only option in the printed list): CLOSED for Check 1 (siya / sila / kanila). The same defect remains in Check 2 (Blocker below).
- mga-gamit 34,114 (Minor wording): CLOSED. "Nakapokus sa layon ang kinain" in the pair note and checklist.
- mga-gamit 28 (Why says ang marks every subject): CLOSED. "Sa halimbawang ito, ang ang pananda ng paksa."
- mga-gamit 19,45 (three uses sound like the full set): CLOSED. "Tatlong gamit ... sa araling ito" for both markers.
- mga-gamit 97-104 (final Check repeats labels): CLOSED. Check now asks only "Kanino ibinigay ang gantimpala?"
- mga-pahiwatig 56,76-79 (heading supplies the aspect): OPEN. The heading "Nagpapatuloy na Kilos sa Nakaraan" is unchanged and the check now asks for the unfinished action (Blocker below).
- mga-pahiwatig 40-42,45-47 (tuwing note calls the phrase an action): CLOSED. The note says *tuwing Sabado* is the frequency and *naglilinis* shows an existing routine.
- pagbuo R4 20,47 (Why says every -um- form repeats a consonant and vowel): CLOSED. Opening is scoped to the roots shown, and the Why uses *inuulit na bahagi*.
- pagbuo 68-71 (check does not name the verb): CLOSED. "Ano ang anyong kontemplatibo ng *sumulat*?"
- pagbuo 123 (only the repeated sound remains): CLOSED. Shortcut now reads "inilalagay ang inuulit na bahagi bago ang buong ugat".
- pang-ukol R4 57-59 (generic Halimbawa): CLOSED. "Hanapin ang salitang nagpapakita ng sakit".
- pang-ukol 81-85,93-97,110-112 (chains stop at labels): CLOSED. Each chain ends at the full sentence; the Checks are a substitution and a removal test.
- pang-uri 63-66,115-119: CLOSED. *saan* asked once, places bolded, try ends at the full sentence with *sa bakuran* marked, Check is a removal test.
- pangalan R4 98-105 (kumain split over two lines): CLOSED. One step ending at the full sentence.
- pangalan 59-62 (noun follows means adjectival): CLOSED. The test is "inilalarawan nito ang pangngalang kasunod sa iisang parirala".
- payak R4 124,130 (checklist ignores dependent clause): CLOSED. Checklist carries "walang sugnay na di-makapag-iisa".
- payak 74-77,108-119 (relation unspecified): CLOSED. Check 3 names the relation; the try states "dalawang gawaing naganap". See fixer call (a).
- pokus 22-24,97-100,114-116: CLOSED. Role cue before each sentence; Ex 2 ends at full sentences; final Check is a short comparison.
- tinutukoy R4 25-28 (akin whenever owner comes first): CLOSED. "Kung ang nagsasalita ang may-ari, gamitin ang akin."
- tinutukoy 111-116 (try accepts two replacements): CLOSED. Fixed slot "Salamat po sa tulong ___", answer *ninyo* only.
- tinutukoy 81-101 (solutions end at Akin and Kami alone): CLOSED. Both end at the full sentence.
- ugnayan 105-109,117-124 (solutions end at labels): CLOSED. Role cue before the full sentence; one short follow-up each.
- ugnayan 30,134 (marker shortcut without the noun-phrase limit): CLOSED. "Sa mga pangngalan sa halimbawang ito" and "sa mga halimbawang ito".

## 2. Findings

Severity | file:line | problem | fix

### aspekto-at-paksa-sa-filipino.md
- Major | :61-65 | P3. Check 2 ("Gawing maramihan ang paksa ng 'Sumulat ng liham ang mag-aaral'") is an open rewrite. "Sumulat ang mga mag-aaral ng liham" is also correct Filipino; the answer shows one order. | Give three complete options: *Sumulat ng liham ang mga mag-aaral* / *Sumusulat ng liham ang mga mag-aaral* / *Susulat ng liham ang mga mag-aaral*, and ask which keeps the finished action.
- Major | :105 | P2. The try's Check re-lists naghanda, naghahanda and maghahanda with their times, which steps 1 and 2 and the stem already show. | One line: "*Bukas* ang oras, kaya hindi na *naghanda* o *naghahanda*."
- Minor | :78 | Ex 1 Check restates step 1 ("nagpapatuloy pa"). It also ties *pa* to ongoing action, while line 24 uses *pa* with the contemplated "Kakain pa lamang". | Cut the Check, or test the whole sentence by swapping in *kakain* and noting it no longer fits "habang hinihintay".
- Minor | :71,82 | Ex 1 and Ex 2 copy quiz 0021 and 0022 stems word for word. | Use fresh sentences, or leave as is if the lead accepts worked quiz stems.

### hugnayan-langkapan-at-ayos-ng-salaysay.md
- Major | :32-36,56-60 | P1 residual. Both checks ask for counts that equal the counts printed in the example directly above (1+1 at line 24, 2+1 at line 42), under headings naming the type. The reader can answer without reading the new sentence. | Use fresh sentences whose counts differ from the printed ones (for example one independent and two dependent clauses), or ask which word opens the dependent clause.
- Major | wordiness +42 | See cut list.
- Minor | :102,114 | P2. Ex 1 and Ex 2 Checks restate step 2 and step 3. | Cut (in the cut list).
- Minor | :94 | Ex 1 equals quiz 0011 stem; pair lines equal 0011, 0012, 0021. | As above.

### kalagayan-ng-kilos.md
- Major | :99 | P2. Ex 2 Check re-prints the sentence from step 4 and repeats steps 1 and 3. | One line that tests it: "Kapag *kalilinis lang* ang gamit, *ni Mila* ang kailangan, hindi *si Mila*."
- Minor | :86 | "hindi pa tapos ang kilos bukas" reads as ongoing action. | "hindi pa nangyayari ang kilos bukas".
- Minor | :77,90 | Ex 1 mirrors quiz 0008 to 0010 (the four forms of *kain* with *Kainin*); Ex 2 equals quiz 0001 word for word. | Fresh root and sentence.

### mga-anyo-ng-panghalip-panao.md
- Blocker | :51-54 | P1. Check 2 sits under "Anyong Ng" and the ng list printed just above; of *(sila / nila / kanila)* only *nila* is in that list (the same defect the R4 Blocker named for Check 1). | Offer *(niya / nila / kanila)*: two printed ng forms, so the reader must use "Sina Ana at Ben" (plural) to decide.
- Major | :83-93 | P2. Ex 1 has no source sentence and ends at "Piliin ang **siya**." The finished sentence appears only in the Check. | Start from "Si Ana ang dumating" and end step 3 with "Siya ang dumating."
- Major | :75-79 | P1/5a. Check 3 repeats the example printed at line 61 (*kay Ana* to *sa kaniya*) with a new name; the answer string is already on the page. | Make Lito the one spoken to, so the answer is *sa iyo* (taught in the sa list), or use a different role.
- Minor | :72 | The pair note introduces *tagaganap (actor)* for the ng role the lesson calls *gumawa*. Two words for one meaning. | "gumagawang *nila*".
- Minor | :126 | "*ang* kung siya ang paksa (*siya, sila*)" uses *siya* as both example and pronoun. | "*ang* kung paksa ang tinutukoy (*siya, sila*)".
- Minor | :85,97 | Ex 1 and Ex 2 equal quiz 0013 and 0012 (Ex 2 word for word). | Fresh sentences.

### mga-gamit-ng-pananda.md
- Minor | wordiness +4 | See cut list.
- Minor | :49,54,81 | The core sa example and the pair Right line equal quiz 0023; Ex 2 equals quiz 0019 word for word. | Fresh sentences.
- Minor | :104 | P2. The try Check repeats the "Kanino?" already in its answer. | Replace with a swap test or cut.

### mga-pahiwatig-ng-oras.md
- Blocker | :56,76-80 | P1. Check 4 sits under the heading "Nagpapatuloy na Kilos sa Nakaraan" and asks which action is "hindi pa tapos", the same idea the heading names. With two events, the answer is the other one. The sentence repeats the core skeleton at line 62. | Rename the heading neutrally (for example "Kahapon at Isa Pang Pangyayari") and ask what Ana was doing, in a frame unlike line 62.
- Major | wordiness +18 | See cut list.
- Minor | :106 | P2. Ex 2 Check restates step 3 and the pair note. | In the cut list.
- Minor | :86,98 | Ex 1 and Ex 2 equal quiz 0005 and 0004 word for word; the core Luis sentence equals quiz 0010. | Fresh sentences.

### pagbuo-ng-anyo-ng-pandiwa.md
- Major | :102 | P2. Ex 2 Check "walang *-um-* ang *kakain*, at inuulit ang *ka*" repeats step 3 almost word for word. | Cut, or test: "Kung may *-um-* pa, *kumakain* na iyon, hindi *kakain*."
- Minor | :92 | Ex 2 equals quiz 0009 word for word. | Fresh root.

### pang-ukol-pangatnig-at-pandamdam.md
- Major | :49-53 | P1. The Why block just above (line 46) names *para sa mga bisita* as the pang-ukol example, and Check 2 offers *para sa* against *kaya*. The reader rejects *para sa* from the text above. | Use two words neither named above (for example *hinggil sa* against *kaya*).
- Minor | :27 | The pair note ends "hindi ito kilos o ang pangngalan mismo", but the Wrong line lists pangatnig, pang-abay and pangngalan; no verb choice, and no word on pangatnig or pang-abay. | "Hindi ito nagdurugtong ng dalawang sugnay at hindi ito pangngalan." (shorter)
- Minor | :30-34,67-71 | Distractors in Checks 1 and 3 are an obvious verb and noun, so the item is trivial. | Add a fellow function word as a distractor.
- Minor | :77 | Ex 1 equals quiz 0021 word for word. | Fresh sentence.
- Minor | wordiness +2 | See cut list.

### pang-uri-at-pang-abay.md
- Minor | :91 | "Ano ang matapang?" for a person. | "Sino ang matapang?"
- Minor | :84,95 | Ex 1 and Ex 2 equal quiz 0012 and 0016 word for word. | Fresh sentences.

### pangalan-kilos-at-pandiwari.md
- Minor | :94 | Ex 1 Check: swapping *ang guro* for *siya* "kaya panghalip ito" proves nothing alone; any noun phrase fits. | Cut (also cuts +4 words).
- Minor | wordiness +4 | See cut list.
- Minor | :71,131 | P4/P5. The pair 3 Right line and checklist 3 drop "sa tradisyonal na pag-uuri", which line 59 and Ex 3 carry. | Add "sa tradisyonal na pag-uuri".
- Minor | :98,106-119 | Ex 2 equals quiz 0015 word for word; Ex 3 is a re-skin of pair 3 (*hatid*, *sa klinika/istasyon*, *ang nahimatay/nahuli*). | Use a different verb in Ex 3.

### payak-at-tambalang-pangungusap.md
- Major | wordiness +34 | See cut list.
- Minor | :74-77 | Fixer call (a), judged below. | None required.
- Minor | :24,66,96 | The core independent-clause example equals quiz 0022; the pangatnig-o sentence (core and pair) equals quiz 0023; Ex 2 equals quiz 0010. | Fresh sentences where the lead wants it.

### pokus-at-papel-ng-paksa.md
- Minor | :71-75,111-116 | Check 3 and the try need *tinimpla* and *binili* (-in- forms of new roots). The lesson shows -in- only for *sinulat* and *niluto*. One answer each, by analogy. | Accept, or add one more -in- model before Check 3.
- Minor | :52,93 | Ex 2 reuses the Check 2 sentence "Nagluto ang kusinero ng sopas". | Another verb in Ex 2.
- Minor | :21,126 | *pangngalan* is never glossed in this lesson. | Gloss once at line 21.
- Minor | :81 | Ex 1 equals quiz 0018 word for word. | Fresh sentence.

### tinutukoy-at-pagmamay-ari-sa-panghalip.md
- Minor | wordiness +4 | See cut list.
- Minor | :81,93 | Ex 1 and Ex 2 equal quiz 0022 and 0023 word for word. | Fresh sentences.

### ugnayan-ng-pandiwa-at-paksa.md
- Major | :34-37 | Check 1 copies quiz 0027 ("Naglilinis (pa) ng bulwagan sina Liza at Omar ...") and its answer "pokus sa tagaganap". | A fresh sentence and names.
- Major | wordiness +22 | See cut list.
- Minor | :34,55,79 | P1. Each check sits under a heading that lists the candidate answers; Check 2 (*pinagdausan*) copies the *pinagtaniman* pattern. One answer each, but easy to guess. | Neutral heading wording where cheap.
- Minor | :129 | P4. The Speed Tricks list of seven roles is not marked as examples. | "tulad ng".
- Minor | :43,65,66,88,101 | Core examples equal quiz 0006, 0007; Ex 1 equals 0013; Ex 2 equals 0012. | Fresh sentences where wanted.

## 3. Fixer calls

(a) payak first check names the relation ("salungat"). It does not name the conjunction, but line 65 pairs "ngunit" with "salungat na diwa", so the item becomes a lookup. Without the label, *at* stays defensible (the round 5 Blocker), and quiz 0023 also names its relation. Judgment: acceptable as written; Minor, no change required. The try is also acceptable: "dalawang gawaing naganap" is stated and *at* is the only defensible choice.

(b) ugnayan Check 2 ("Ano ang pokus sa 'Pinagdausan ng pulong ang kantina'?"), open. It has exactly one defensible answer, *ganapan*: the canteen is the subject and the place where the meeting was held. The answer block says so. Direksiyon is wrong because nobody goes to the canteen. Judgment: PASS. Only the P1 Minor above applies.

## 4. Pairs against content/walkthrough-trap-evidence.json

Every pair checked. Each cited choice exists exactly in the cited question, is not the correct choice, and that question's `lesson:` is this lesson (verified in the YAML). Every Wrong line shows the cited mistake. No citation problem.

- aspekto: 0021 (Kumain, Kakain, Kakakain lamang), 0022 (two plural-with-wrong-aspect sentences). OK.
- hugnayan: 0011 (Tambalan, Payak), 0012 (Tambalan, Hugnayan), 0021 (both marker orders). OK.
- kalagayan: 0001 (Naglilinis, Maglilinis), 0011 (two statements, paraphrased in the Wrong line), 0002 (Imperpektibo, "Perpektibo na walang pahiwatig..."). OK.
- mga-anyo: 0013 (Niya, Kaniya), 0012 (Nila, Namin, Ninyo), 0021 (sila, nila, para sa kaniya). OK.
- mga-gamit (note changed): 0019 (Ang, Sa), 0023 (two wrong roles). OK; the new note answers *kanino*, not *saan*.
- mga-pahiwatig (note changed): 0005 (two kahapon sentences), 0004 (two sapagkat reasons), 0010 (two wrong aspects). OK.
- pagbuo: 0009 (mag- claim; kumakain, kumain), tenses-and-voice-0025 (Imperpektibo ang una; kontemplatibo ang ikalawa; its `lesson:` is pagbuo, in the Filipino file). OK.
- pang-ukol: 0021, 0022. Note on the first pair: see Minor.
- pang-uri: 0012, 0016, 0023. OK.
- pangalan: 0013, 0015, 0024. OK.
- payak: 0022, 0010, 0023. OK.
- pokus: 0018 (Ng), 0024 (Sinusulat, Susulatin). OK.
- tinutukoy (note changed): 0022 (Ako, Ko), 0023 (Tayo, Sila), 0011 (three wrong claims). OK.
- ugnayan (note changed): tenses-and-voice-0011 and 0003 (both lesson ugnayan), 0012, 0006 and tenses-and-voice-0026 (wrong choices match the Wrong line). OK.

Pair count is at most 3 and checklist items at most 3 in every lesson; every checklist slug names a pair.

## 5. Wordiness cuts (lessons that grew)

Counts are my own hand counts of words outside :::answer, :::why and HTML comments.

- hugnayan (+42). Cut: Speed Tricks first sentence "Bilangin ang sugnay ... di-makapag-iisa." (22); Ex 1 Check line (12); Ex 2 Check line (10); "Hindi ito tambalan o payak." at line 20 (5). Total 49. Ex 1 and Ex 2 Checks repeat steps 2 and 3, and the pairs already say the rest.
- payak (+34). Cut: Ex 1 Check "Kapag inalis ang *at nag-aayos* ..." (17); Ex 2 Check "Kapag inalis ang *ngunit* ..." (10); the stem sentence "Pagsamahin ang dalawang gawaing naganap." in Ex 3, since step 1 says it (5); the labels "(1 sugnay)" and "(2 sugnay)" in line 43-44 (4). Total 36. The Speed Tricks line carries the same test.
- ugnayan (+22). Cut: Ex 1 Check "Isa lamang ang may *ang* ..." (10); core line 41 "Huwag ibatay ang sagot sa salitang lugar lamang." (8); Ex 2 step 1 "Pareho ang paksa: *ang bakuran*." (5). Total 23. The stem and the pair already say each.
- mga-pahiwatig (+18). Cut: line 58 "Suriin din ang iba pang pahiwatig gaya ng *habang* o *nang* ..." (16), which the Speed Tricks repeat; Ex 2 Check "Umuulit linggo-linggo ..." (11). Total 27.
- mga-gamit (+4). Cut: Ex 2 step 2 "Ang bata ang kumain, ngunit hindi siya ang paksa." (9), which step 1 and the pair already say.
- pangalan (+4). Cut: Ex 1 Check "Palitan ng *ang guro* ang *siya* ..." (15). It also proves nothing alone.
- tinutukoy (+4). Cut: Ex 2 Check "Kapag *tayo* ang ginamit ..." (10), which repeats step 2.
- pang-ukol (+2). Cut: the pair note tail "hindi ito kilos o ang pangngalan mismo" (7). It is also inaccurate (see Minor).

None of these cuts undoes a round 4 or round 5 fix: the cut lines are Check lines or repeats that the fixes did not touch.

## 6. Pattern line per lesson (P1 to P5)

- aspekto: P1 ok. P2 try Check repeats the steps. P3 Check 2 open. P4 ok. P5 ok.
- hugnayan: P1 counts equal printed numbers. P2 Example Checks repeat steps. P3 ok. P4 ok. P5 ok.
- kalagayan: P1 ok. P2 Ex 2 Check repeats. P3 ok. P4 ok. P5 ok.
- mga-anyo: P1 Check 2 (Blocker), Check 3 (Major). P2 Ex 1 ends at a word. P3 ok. P4 ok. P5 ok.
- mga-gamit: all ok except P2 Minor on the try Check.
- mga-pahiwatig: P1 Check 4 heading (Blocker). P2 Ex 2 Check repeats. P3 ok. P4 ok. P5 ok.
- pagbuo: P2 Ex 2 Check repeats. Others ok.
- pang-ukol: P1 Check 2. Others ok.
- pang-uri: all ok.
- pangalan: P4/P5 tradition scope missing from pair 3 and checklist 3 (Minor). Others ok.
- payak: all ok.
- pokus: all ok (Minor notes above).
- tinutukoy: all ok.
- ugnayan: P1 Minor on headings. P4 Minor on the shortcut list. Others ok.

Taglish, glosses, spelling: no Taglish found in teaching prose. First-use glosses are present for the hard terms in all 14 lessons (exceptions: *pangngalan* in pokus, *pang-abay* in pangalan and pang-ukol appears only in Wrong or checklist lines, which the rule excludes). No em or en dashes, no trailing double spaces, no ALL-CAPS emphasis.

VERDICT: FAIL (2 Blockers, 13 Majors, 36 Minors)
