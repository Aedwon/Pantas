# Grammar round 6 Filipino verifier findings (14 lessons at 9677e2b30)

Verifier: Claude Sonnet 5.5, read-only. Path prefix: content/lessons/language-proficiency/grammar-and-structure/. Delta checked with git diff 81f4db5bc 9677e2b30.

## 1. Round 6 rows (codex-grammar-r6.md, .yaml rows skipped)
All rows below are closed in the text at 9677e2b30. Rows marked (new defect) are closed but the fix introduced the finding named in section 3.
- aspekto-at-paksa: Example 2 repeat (:48-58,86-91) CLOSED; missing Checks Ex 1 and 2 (:82,91) CLOSED; verb definition scope (:19) CLOSED; third blank (:95-107) CLOSED (new defect: try Check restates stem; Example 1 still reuses the pair sentence).
- hugnayan-langkapan: printed event order (:76-85,114-129) CLOSED (new defect: Example 3 two defensible orders); missing Checks (:100,110) CLOSED; Example 1 repeat CLOSED; dahil note (:29) CLOSED; pananda gloss (:64) CLOSED.
- kalagayan-ng-kilos: label in heading and pair (:41,61-70) CLOSED; Example 2 Check CLOSED; repeated kain/Mila sets CLOSED; stem gloss CLOSED.
- mga-anyo-ng-panghalip-panao: repeated *sa kanila* try CLOSED; open *sa iyo* slot CLOSED; Example 2 Check CLOSED; Example 1 repeat CLOSED (new defect: Check restates step); *tagaganap* gloss CLOSED (word removed).
- mga-gamit-ng-pananda: final try Check CLOSED; *sa* shortcut scope CLOSED; Example 1 and 2 repeats CLOSED; *nakapokus* CLOSED.
- mga-pahiwatig-ng-oras: Quick Check pattern (:58-79) CLOSED; Example 2 Check CLOSED; Examples 1 and 2 repeats CLOSED; try answer sentence CLOSED.
- pagbuo-ng-anyo-ng-pandiwa: *kakakain*/checklist recipe (:59,98,129) CLOSED; visible *mag-* and *bukas* step (:104-116) CLOSED; example repeats CLOSED; gloss and *unlapi* minors CLOSED; *kalilinis* scope (:30) CLOSED.
- pang-ukol-pangatnig-at-pandamdam: Example 1 repeat CLOSED; *ngunit* removal test (:95) CLOSED; *Hay!* try repeat (:103-108) CLOSED (new defect: *Salamat* contested).
- pang-uri-at-pang-abay: Examples 1 and 2 repeats (:25-27,50-52,84-102) CLOSED.
- pangalan-kilos-at-pandiwari: try target mismatch CLOSED; Example 1 Check CLOSED; Example 2 repeat CLOSED; Example 1 labels CLOSED; pandiwari definition (:59-62) CLOSED; gloss in pair note CLOSED.
- payak-at-tambalang-pangungusap: try ambiguity (:104-115) CLOSED; missing Checks CLOSED; example repeats CLOSED; *o* scope (:71) CLOSED.
- pokus-at-papel-ng-paksa: Example 2 Check and labels CLOSED; open Check and try (:71-74,102-112) CLOSED; Example 1 repeat CLOSED; checklist plural markers CLOSED.
- tinutukoy-at-pagmamay-ari-sa-panghalip: formal *inyong* slot (:42,103-112) CLOSED; Example 2 Check CLOSED; Examples 1 and 2 repeats CLOSED; heading scope and gender check CLOSED.
- ugnayan-ng-pandiwa-at-paksa: Example 2 labels (:103-106) CLOSED; Example 1 Check CLOSED; Example 1 and 2 repeats CLOSED; try repeat (:62-75,110-121) CLOSED (new defect: *ikinatuwa* reused).

## 2. Pairs against content/walkthrough-trap-evidence.json
All 38 pairs in the 14 lessons checked: each cited wrong choice exists word for word in a question whose lesson field is that lesson, and each pair's Wrong line shows that mistake. No mismatches. Details are in each lesson block below.

## 3. Per-lesson findings (delta check plus neighbors)

### aspekto-at-paksa-sa-filipino
Pairs: aspekto-ayon-sa-kalagayan cites 0021 (Kumain, Kakain, Kakakain lamang): exact choices exist, lesson matches. bilang-ng-paksa-at-pandiwa cites 0022 (Kumain na ng tanghalian ang mga kawani. / Kakain pa lamang ng tanghalian ang mga kawani.): exact, matches. Both OK.
P1 to P5: P1 weak at the try (see Major 2), P2 ok, P3 ok, P4 ok (line 19 scoped), P5 ok.
- Major | aspekto-at-paksa-sa-filipino.md:77-84 | Example 1 is still the same Nena sentence as the first pair and the core line 31, and the quiz stem word for word. The R6 row named only Example 2, but the reuse remains. | Use a new person and action (for example a different verb with *pa* and *habang*), and keep the Check.
- Major | aspekto-at-paksa-sa-filipino.md:106-112 | The new try gives only *naglinis* (already the answer of step 1) against *maglilinis*, and says "Hindi pa nagsisimula si Ben", which is the core's own label for kontemplatibo. Its Check repeats that same stem line, so it is not a second method. The old Check used the time word *bukas*. | Keep the stem to the sentence; Check: "*Bukas* ang oras, kaya hindi ito *naglinis*." Offer a form not yet printed as the wrong option (for example *naglilinis*).

### hugnayan-langkapan-at-ayos-ng-salaysay
Pairs: hugnayan-laban-sa-tambalan cites 0011 (Tambalan, Payak): exact, lesson matches. langkapan-bilangin-ang-bawat-sugnay cites 0012 (Tambalan, Hugnayan): exact, matches. ayos-ng-pananda-sa-salaysay cites 0021 (Una, sa huli, pagkatapos / Sa huli, pagkatapos nito, una): exact, matches. All OK.
P1 to P5: P1 ok after rewrite, P2 ok, P3 see Major, P4 ok, P5 ok.
- Major | hugnayan-langkapan-at-ayos-ng-salaysay.md:117-134 | Two defensible answers. Nothing in the stem fixes whether the receipt comes before or after the papers are passed. A reader can defend option C (get the receipt for a payment, then pass the papers). The Check states "Nauna ang pagpasa ng papel sa pagkuha ng resibo" as fact, but the scene never says so. | Add one cue to the lead-in, for example "ang resibo ang patunay na natanggap ang mga papel", or choose events with a fixed order.
- Minor | hugnayan-langkapan-at-ayos-ng-salaysay.md:29 | The new pair note does not say why *tambalan* and *payak* are wrong. | Add: "Kaya hindi tambalan ang dalawang sugnay, at hindi payak dahil may dalawang sugnay."
- Minor | hugnayan-langkapan-at-ayos-ng-salaysay.md:139 | The shortcut lost "may" and now reads as a clipped list ("Isang makapag-iisa at di-makapag-iisa: hugnayan"). | Restore "Isang makapag-iisa na may di-makapag-iisa: hugnayan; ..." if the word budget allows.
- Minor | hugnayan-langkapan-at-ayos-ng-salaysay.md:145 | Checklist names *kapag*, which the lesson never teaches (unchanged line). | Say "*dahil* o *sapagkat*".

### kalagayan-ng-kilos
Pairs: piliin-ayon-sa-kalagayan cites 0001 (Naglilinis, Maglilinis); tapos-laban-sa-katatapos cites 0011 (Parehong perpektibong katatapos dahil parehong natapos ang kilos. / Kontemplatibo ang ikalawa dahil may salitang lang.); kadarating-ay-katatapos cites 0002 (Imperpektibo / Perpektibo na walang pahiwatig na katatapos lamang). All choice texts exist exactly, lessons match. Wrong lines show those mistakes. OK.
P1 to P5: ok. Forms checked: kalilinis, kadarating, kaluluto, kasusulat, kalalaba all follow ka- + repeated first syllable (Schachter and Otanes recent perfective).
- Minor | kalagayan-ng-kilos.md:67-72 | The new Check still sits under the heading and next to the pair that give the same contrast (a dated *naglinis* versus *kalilinis lang*). The reader can match the *lang* cue by copying. Acceptable, but a distractor with no time word and no *lang* would test the form more. | Optional: make A a past form with no date, for example "Nagluto si Ana ng sopas."

### mga-anyo-ng-panghalip-panao
Pairs: pangkat-ng-ang cites 0013 (Niya, Kaniya); bilang-at-gumawa-sa-ng cites 0012 (Nila, Namin, Ninyo); anyong-sa-para-sa-tatanggap cites 0021 (sila, nila, para sa kaniya). All exist, lessons match, Wrong lines match. OK.
P1 to P5: ok. No *tagaganap* left (P5 clean). Fixed slot "buong anyo" closes the *sa iyo* / *sa 'yo* issue.
- Major | mga-anyo-ng-panghalip-panao.md:93 | Example 1 Check ("Paksa ang *si Ben* sa orihinal, kaya paksa rin ang kapalit nito") restates step 1. It is not a second method. | Read the result back against the original: "*Siya ang umalis* ay kapalit ng *Si Ben ang umalis*; hindi ito *Niya ang umalis*."
- Minor | mga-anyo-ng-panghalip-panao.md:105 | Example 2 Check restates step 2 (one worker). | Test the swap: "*Iniwan nila ang walis* ay para sa maraming kawani, kaya hindi ito."
- Minor | mga-anyo-ng-panghalip-panao.md:109 | Lea quotes a sentence that names herself, which sounds odd. The answer *sa akin* is the only correct one, so no ambiguity. | Optional: "Sabi ni Lea tungkol sa paanyaya: ..."

### mga-gamit-ng-pananda
Pairs: ng-para-sa-gumagawa cites 0019 (Ang, Sa); sa-para-sa-tagatanggap cites 0023 (Lugar na ginanapan ng paghahatid; Gumagawa ng paghahatid ng katibayan). Exact choices exist, lessons match, Wrong lines match. OK.
P1 to P5: ok. Rule scoped ("tatlong gamit ng sa dito") in core, shortcut; checklist line 114 is consistent. The *nakapokus* wording is gone from pair note and checklist.
- Minor | mga-gamit-ng-pananda.md:103 | Example 3 Check ("Kung *sa kaibigan* ang ipalit... tagatanggap pa rin") only repeats the answer for a new noun. It does not read the full sentence. | "Basahin: *Ibinigay ng guro ang gantimpala sa kaibigan.* Si *kaibigan* ang binigyan, kaya *kanino*."

### mga-pahiwatig-ng-oras
Pairs: panatilihin-ang-oras-at-aspekto cites 0005 (Magsusumite si Elena ng ulat kahapon. / Nagsumite si Elena ng ulat kahapon.); tuwing-paulit-ulit-na-kilos cites 0004 (Sapagkat natapos na ang lahat ng paglilinis. / Sapagkat katatapos lamang nilang maglinis.); nagpapatuloy-sa-nakaraan cites 0010 (Perpektibo, dahil kahapon naganap ang pangyayari. / Kontemplatibo, dahil hindi pa tapos ang ulat.). All exact, lessons match. OK.
P1 to P5: ok. The new Check (which of two actions was in progress) no longer repeats the pair pattern.
- Minor | mga-pahiwatig-ng-oras.md:125 | Shortcut names *habang*, which the lesson never teaches or uses in an example (unchanged text). | Drop "*habang*" or replace with "*pa*".
- Minor | mga-pahiwatig-ng-oras.md:60 | "nananatili sa imperpektibo ang kilos na nagpapatuloy" is awkward Filipino and repeats "nagpapatuloy" twice. | "Kapag may kilos na hindi pa tapos nang pumasok ang isa pang pangyayari sa nakaraan, imperpektibo pa rin ang kilos na iyon."

### pagbuo-ng-anyo-ng-pandiwa
Pairs: huwag-ilipat-ang-mag cites 0009 (Panatilihin ang magkakain dahil lahat ng kontemplatibo ay may mag-.); kumain-kontemplatibo-walang-um cites 0009 (Palitan ang magkakain ng kumakain. / ... ng kumain.); basahin-ang-buong-pandiwa cites tenses-and-voice-0025 (Imperpektibo ang una; kontemplatibo ang ikalawa.). All exact; lessons match (0009 and 0025 both carry this lesson). OK.
Truth: kalilinis, kadarating (d to r), kasasara, magluluto, sasayaw, tatakbo, tumatakbo, susulat all follow the stated recipe. Remove-mag- only for *magkakain*, remove -um- then add *ka* for *kumain*: correct in pair note, checklist, shortcut.
P1 to P5: ok.
- Minor | pagbuo-ng-anyo-ng-pandiwa.md:88 | Example 1 Check restates both answers (*magluluto*, *sasayaw*) after giving the now-forms. Acceptable contrast, but the last clause repeats the Sagot line. | Cut "para sa bukas, *magluluto* at *sasayaw*" to save words.
- Note (not counted) | pagbuo-ng-anyo-ng-pandiwa.md:104-112 | Example 3 keeps the pair's frame (katatapos, then kontemplatibo with *bukas*). The try now asks for the repeated part, which is a real second step, so I count the row closed.

### pang-ukol-pangatnig-at-pandamdam
Pairs: pang-ukol-laban-sa-pangatnig cites 0021 (Pangatnig, Pang-abay, Pangngalan); pandamdam-laban-sa-pangngalan cites 0022 (Pangngalan, Pangatnig, Pandiwa). Exact choices exist, lessons match, Wrong lines match. OK.
P1 to P5: P1 ok (step 1 of Example 3 names a test, not the label), P2 ok, P3 ok, P4 ok, P5 ok.
- Major | pang-ukol-pangatnig-at-pandamdam.md:99-108 | *Salamat* is a contested choice for a try. Dictionaries list it as a noun (*maraming salamat*, where *maraming* describes it), and the lesson's own pair note says an interjection does not name a feeling "tulad ng *kaba*". A reader can defend *pangngalan*. The answer's "walang pinapangalanan" is not safe. | Use an unambiguous interjection not already printed, for example *Yehey!*, with the same steps and Check.

### pang-uri-at-pang-abay
Pairs: matapang-pang-uri-hindi-pang-abay cites 0012 (Pang-abay); mabilis-pang-abay-hindi-pang-uri cites 0016 (Pang-uri); pangkat-na-panlunan cites 0023 (ng mga kawani, ang mga kahon). All exact, lessons match, Wrong lines match. OK.
P1 to P5: ok. Examples 1 and 2 now use fresh words (*tahimik*, *maingat*); Checks are question tests, not restatements. Example 3 untouched and fresh (*bakuran*).
No findings.

### pangalan-kilos-at-pandiwari
Pairs: bata-pangngalan-hindi-pang-uri cites 0013 (Pang-uri, Panghalip); pandiwa-kilos-hindi-pangngalan cites 0015 (Pangngalan, Pang-abay); pandiwari-bilang-pangngalan cites 0024 (Pandiwang nagsasaad ng ginawa ng kawani; Pang-abay na nagsasaad ng lugar ng kilos). All exact, lessons match, Wrong lines match. OK.
Truth: pandiwari definition now requires the whole phrase to name a person or thing; scoped to "tradisyonal na balarila". First-use gloss of *pang-uri* now in teaching prose (line 57).
P1 to P5: P5 see Minor 1; others ok.
- Minor | pangalan-kilos-at-pandiwari.md:120 | The shortcut tests only "tao o bagay ang tinutukoy", and drops the condition that no noun follows. Applied to *ang nahimatay na lalaki* it would call a describing form a noun. The core (line 57) and checklist (line 127) keep the condition. | "...at kung walang pangngalang kasunod, tingnan kung tao o bagay ang tinutukoy ng anyong mula sa pandiwa."
- Minor | pangalan-kilos-at-pandiwari.md:84 | Example 1 reuses *guro* and *masipag* from the core line 21 ("Masipag ang guro"). Not a check or try, so only a style note. | Optional: use another noun.

### payak-at-tambalang-pangungusap
Pairs: sugnay-na-makapag-iisa cites 0022 (Dahil inayos ng kawani ang pila. / Kapag inayos ng kawani ang pila.); payak-laban-sa-tambalan cites 0010 (Payak, Hugnayan); pangatnig-sa-pagpipilian cites 0023 (at, ngunit, dahil). All exact, lessons match, Wrong lines match. OK.
P1 to P5: P1 see Major; P4 ok (*o* note scoped "Sa pangungusap na ito", checklist "humihingi ng pagpipilian"); P5 ok.
- Major | payak-at-tambalang-pangungusap.md:75 | Quick Check stem says "para sa salungat na diwa", and the core bullet two screens up reads "ngunit: salungat na diwa". The stem names the category, so the check tests matching, not the new sentence (P1). Unchanged line, neighbor of the delta. | Ask without the label: "Gusto niyang sumama, *(at / ngunit / o)* masama ang pakiramdam niya. Alin ang angkop?"
- Minor | payak-at-tambalang-pangungusap.md:106 | The Example 3 lead-in now says the writer is "adding" Ben's action. That fixes the three-answer problem the row named, but it also restates the core bullet "at: dagdag na diwa", so the try is easy. Accepted as the row asked. | Optional: fixed options with one added-action sentence and no label word.
- Minor | payak-at-tambalang-pangungusap.md:71 | The pair note no longer says why *at*, *ngunit* and *dahil* are wrong. It only restates the Right line. | "Dagdag ang *at*, salungat ang *ngunit*, dahilan ang *dahil*; pagpipilian dito ang hinihingi."
- Minor | payak-at-tambalang-pangungusap.md:102 | "sa halip ng *ngunit*" is not standard. | "kapalit ng *ngunit*".

### pokus-at-papel-ng-paksa
Pairs: paksa-may-ang-o-si cites 0018 (Ng); panatilihin-ang-aspekto cites 0024 (Sinusulat ni Mara ang mahalagang liham. / Susulatin ni Mara ang mahalagang liham.). Exact, lessons match, Wrong lines match. OK.
P1 to P5: ok. The Check and try now use fixed verb-aspect options (one defensible answer each). Checklist line 125 now lists *ang mga* and *sina* like the core (P5 closed).
- Minor | pokus-at-papel-ng-paksa.md:99 | Example 2 Check lists the same two *ang* phrases already bolded in steps 1 and 2. It is the row's suggestion, but it adds little. | Optional: "Palitan ang *ang guro* ng *ng guro*: hindi na ito paksa."

### tinutukoy-at-pagmamay-ari-sa-panghalip
Pairs: ayos-ng-pagmamay-ari cites 0022 (Ako, Ko); tayo-laban-sa-kami cites 0023 (Tayo, Sila); walang-kasarian-ang-siya cites 0011 (Tumutukoy lamang sa babae / lalaki; Ginagamit lamang para sa mga bagay). All exact, lessons match, Wrong lines match. OK.
P1 to P5: ok. Heading now names *siya, niya, kaniya* (scope fixed). Check uses two genders with one role. Formal *ninyo* is now asked as the full, uncontracted *ng* form.
- Minor | tinutukoy-at-pagmamay-ari-sa-panghalip.md:85 | "Hindi *rin* maaaring gamitin ang *ako* o *ko*": the cut removed the earlier step that rejected *kanila*, so "rin" has nothing to refer to. | Drop "rin".
- Minor | tinutukoy-at-pagmamay-ari-sa-panghalip.md:59-60 | The blank line before `:::why` was deleted, so the fence now follows a paragraph line directly. May be harmless, but the lead's importer run should confirm. Pair note line 67 also still mentions *ito* for objects, which the core no longer teaches. | Restore the blank line; cut "Maaaring gamitin ang *ito* para sa bagay."
- Minor | tinutukoy-at-pagmamay-ari-sa-panghalip.md:110 | The try stem says "buong magalang na anyong *ng*", which points at *ninyo* (the only polite *ng* form taught). Fixed slot gives one defensible answer, so this is only easy. | Optional: "...na anyong *ng* para sa guro (hindi pinaikli)".

### ugnayan-ng-pandiwa-at-paksa
Pairs: hanapin-ang-may-ang-o-si cites tenses-and-voice-0011 (Pokus sa tagaganap (ang bata)) and 0003 (Ang pagkain ang paksa; pokus sa layon.); ganapan-laban-sa-direksiyon cites 0012 (Parehong ganapan dahil parehong lugar ang bakuran. / Direksiyon ang una; ganapan ang ikalawa.); tagatanggap-kagamitan-at-sanhi cites 0006 and tenses-and-voice-0026 (Kagamitan ang una dahil ginamit ang mga bisita...; Parehong tagaganap dahil si Mara ang gumagawa ng mga kilos.). All exact, lessons match; the pair's Wrong lines match the 0026 choices. OK.
P1 to P5: P1 ok (Example 3 step names no category); P2 ok; others ok.
- Major | ugnayan-ng-pandiwa-at-paksa.md:112-121 | The try reuses *ikinatuwa*, the sanhi verb printed in the core (line 66, "Ikinatuwa ng mga kawani ang balita") and the sanhi check frame (line 79). Rule 5a bans a word already stated earlier in a try. | Use a sanhi verb printed nowhere in the lesson (for example *Ikinabahala ni Carlo ang ulat*), or pair the kagamitan sentence with a different role.
- Minor | ugnayan-ng-pandiwa-at-paksa.md:97 | Example 1 Check ("si Lito sa una, ni Lito sa ikalawa") repeats step 1 (*ni Lito* ang *si Lito*). | "Basahin: *Binili ni Lito ang gulay*. Sino ang bumili? Si Lito."

## Counts per lesson (Blocker / Major / Minor)
- aspekto-at-paksa-sa-filipino: 0 / 2 / 0
- hugnayan-langkapan-at-ayos-ng-salaysay: 0 / 1 / 3
- kalagayan-ng-kilos: 0 / 0 / 1
- mga-anyo-ng-panghalip-panao: 0 / 1 / 2
- mga-gamit-ng-pananda: 0 / 0 / 1
- mga-pahiwatig-ng-oras: 0 / 0 / 2
- pagbuo-ng-anyo-ng-pandiwa: 0 / 0 / 1
- pang-ukol-pangatnig-at-pandamdam: 0 / 1 / 0
- pang-uri-at-pang-abay: 0 / 0 / 0
- pangalan-kilos-at-pandiwari: 0 / 0 / 2
- payak-at-tambalang-pangungusap: 0 / 1 / 3
- pokus-at-papel-ng-paksa: 0 / 0 / 1
- tinutukoy-at-pagmamay-ari-sa-panghalip: 0 / 0 / 3
- ugnayan-ng-pandiwa-at-paksa: 0 / 1 / 1

VERDICT: FAIL (0 Blockers, 7 Majors, 20 Minors)
