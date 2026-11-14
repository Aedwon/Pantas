# Philippine Constitution answer verification (bite-sized pilot)

Date: Nov 15, 2026. Content: `content/bite-sized-pilot` at fafbc6bf3. 239 questions (200 existing, 39 new).
All checks were separate Codex jobs (GPT 6.1 Sol, medium), never the writers.

1. Independent re-solve (read-only, stem and choices first): 239 of 239 agree, 0 disagree
   (parts 1 and 2 below).
2. 63 questions were then edited by a separate writer job to fix tells (the correct answer was the
   single longest choice) and stiff wording; keys, ids and tags unchanged. A second re-solve on the
   edited text: 63 of 63 agree.
3. Law text, 1987 Constitution (LawPhil edition): 187 key OK, 0 key wrong, 1 explanation wrong
   (citizenship-and-suffrage-0020 said "over eighteen"; fixed by the lead to "at least eighteen",
   Article V, Section 1), 51 ambiguous because they test rules outside the Constitution's text.
4. The 51 ambiguous items, checked against the Rules of Court, RA 9346, Act 4103 and Supreme Court
   decisions (LawPhil, Supreme Court E-Library): 51 source OK, 0 key wrong, 0 explanation wrong.
   The lead opened two cited sources and confirmed the quoted text.
Approved by the lead with `tool/content/approve.dart`.

## Re-solve, part 1
| q-philippine-constitution-bill-of-rights-0001 | 22 sections | 22 sections | AGREE | Art. III runs from Sec. 1 through Sec. 22. | None |
| q-philippine-constitution-bill-of-rights-0002 | Due process | Due process | AGREE | Art. III Sec. 1 requires due process before deprivation. | None |
| q-philippine-constitution-bill-of-rights-0003 | Article III | Article III | AGREE | Art. III Sec. 4 protects speech, expression, and press. | None |
| q-philippine-constitution-bill-of-rights-0014 | Judge determines probable cause | Judge determines probable cause | AGREE | Art. III Sec. 2 requires the judge's personal determination. | None |
| q-philippine-constitution-bill-of-rights-0018 | Lawful-purpose association | Lawful-purpose association | AGREE | Art. III Sec. 8 protects associations for lawful purposes. | U |
| q-philippine-constitution-bill-of-rights-0019 | Petition for redress | Petition for redress | AGREE | Art. III Sec. 4 protects petitions seeking government relief. | L |
| q-philippine-constitution-bill-of-rights-0020 | No religious tests | No religious tests | AGREE | Art. III Sec. 5 bars religious tests for political rights. | L |
| q-philippine-constitution-bill-of-rights-0021 | Just compensation | Just compensation | AGREE | Art. III Sec. 9 requires compensation for public taking. | None |
| q-philippine-constitution-bill-of-rights-0022 | Check legal access limits | Check legal access limits | AGREE | Art. III Sec. 7 permits limitations provided by law. | L |
| q-philippine-constitution-bill-of-rights-0023 | Irrelevant group distinction | Irrelevant group distinction | AGREE | Art. III Sec. 1 protects equal treatment under the laws. | L |
| q-philippine-constitution-bill-of-rights-0024 | Letters inadmissible | Letters inadmissible | AGREE | Art. III Sec. 3(2) excludes such evidence in any proceeding. | None |
| q-philippine-constitution-bill-of-rights-0025 | Obedience is insufficient consent | Obedience is insufficient consent | AGREE | Art. III Sec. 2: coerced acquiescence is not free consent. | L |
| q-philippine-constitution-bill-of-rights-0026 | Abode requires lawful court order | Abode requires lawful court order | AGREE | Art. III Sec. 6 distinguishes abode from travel restrictions. | L |
| q-philippine-constitution-bill-of-rights-0027 | Personal evidence review suffices | Personal evidence review suffices | AGREE | Art. III Sec. 2 permits this arrest-warrant procedure under case law. | L, U |
| q-philippine-constitution-bill-of-rights-0028 | Hot pursuit requirements absent | Hot pursuit requirements absent | AGREE | Art. III Sec. 2; Rule 113 Sec. 5(b) requires immediacy and personal knowledge. | L |
| q-philippine-constitution-bill-of-rights-0029 | Waiver lacks counsel | Waiver lacks counsel | AGREE | Art. III Sec. 12(1) requires writing and counsel's presence. | L |
| q-philippine-constitution-bill-of-rights-0030 | Bail exception not met | Bail exception not met | AGREE | Art. III Sec. 13 also requires strong evidence of guilt. | L |
| q-philippine-constitution-bill-of-rights-0031 | Bail remains protected | Bail remains protected | AGREE | Art. III Secs. 13 and 15 preserve bail during valid suspension. | L |
| q-philippine-constitution-bill-of-rights-0032 | Acquittal bars second prosecution | Acquittal bars second prosecution | AGREE | Art. III Sec. 21 covers the same act under law and ordinance. | L |
| q-philippine-constitution-bill-of-rights-0033 | Ex post facto; attainder | Ex post facto; attainder | AGREE | Art. III Sec. 22 bars retroactive punishment and legislative punishment without trial. | None |
| q-philippine-constitution-bill-of-rights-0034 | Both warrant exceptions apply | Both warrant exceptions apply | AGREE | Art. III Sec. 2; Rules 113 Sec. 5(a) and 126 Sec. 13 allow these acts. | None |
| q-philippine-constitution-bill-of-rights-0036 | Search arrested person | Search arrested person | AGREE | Art. III Sec. 2; Rule 126 Sec. 13 permits this limited search. | U |
| q-philippine-constitution-bill-of-rights-0037 | Personally known facts | Personally known facts | AGREE | Art. III Sec. 2; Rule 113 Sec. 5(b) requires personal knowledge. | None |
| q-philippine-constitution-bill-of-rights-0038 | Legal help separately protected | Legal help separately protected | AGREE | Art. III Sec. 11 protects access and adequate legal assistance. | None |
| q-philippine-constitution-bill-of-rights-0039 | Administrative bodies included | Administrative bodies included | AGREE | Art. III Sec. 16 expressly includes administrative bodies. | None |
| q-philippine-constitution-bill-of-rights-0040 | No compelled self-incrimination | No compelled self-incrimination | AGREE | Art. III Sec. 17 bars compelled testimony against oneself. | None |
| q-philippine-constitution-bill-of-rights-0041 | Poll-tax nonpayment protected | Poll-tax nonpayment protected | AGREE | Art. III Sec. 20 expressly bars imprisonment for unpaid poll tax. | None |
| q-philippine-constitution-bill-of-rights-0042 | No due conviction | No due conviction | AGREE | Art. III Sec. 18(2) requires due conviction for the exception. | None |
| q-philippine-constitution-bill-of-rights-0043 | Complaint alone insufficient | Complaint alone insufficient | AGREE | Art. III Sec. 21; Rule 117 Sec. 7 requires a valid plea. | None |
| q-philippine-constitution-bill-of-rights-0044 | Both prohibitions apply | Both prohibitions apply | AGREE | Art. III Sec. 22 bars both retroactive criminalization and attainder. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0001 | Three | Three | AGREE | Art. XVII Secs. 1–2 provide Congress, convention, and initiative routes. | L |
| q-philippine-constitution-amending-and-revising-the-constitution-0002 | Specific change; principles intact | Specific change; principles intact | AGREE | Art. XVII Secs. 1–2; Lambino distinguishes amendment from structural revision. | L, U |
| q-philippine-constitution-amending-and-revising-the-constitution-0003 | Revision | Revision | AGREE | Art. XVII Secs. 1–2; changing the basic governmental plan is revision. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0004 | Three-fourths of all Members | Three-fourths of all Members | AGREE | Art. XVII Sec. 1 fixes this congressional proposal threshold. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0005 | Two-thirds of all Members | Two-thirds of all Members | AGREE | Art. XVII Sec. 3 fixes the direct convention-call threshold. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0006 | Majority of all Members | Majority of all Members | AGREE | Art. XVII Sec. 3 permits referral to voters at this threshold. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0007 | 12% | 12% | AGREE | Art. XVII Sec. 2 requires 12% of registered voters nationwide. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0008 | 3% in every district | 3% in every district | AGREE | Art. XVII Sec. 2 requires every district's representation at 3%. | L |
| q-philippine-constitution-amending-and-revising-the-constitution-0009 | Initiative: amendments only | Initiative: amendments only | AGREE | Art. XVII Secs. 1–2 reserve initiative to amendments. | L |
| q-philippine-constitution-amending-and-revising-the-constitution-0010 | Voters through plebiscite | Voters through plebiscite | AGREE | Art. XVII Sec. 4 requires voter ratification. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0011 | Initial five-year bar; five-year intervals | Initial five-year bar; five-year intervals | AGREE | Art. XVII Sec. 2 imposes both limits. | L |
| q-philippine-constitution-amending-and-revising-the-constitution-0012 | 1,200 | 1,200 | AGREE | Art. XVII Sec. 2: 3% × 40,000 = 1,200. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0013 | 301 | 301 | AGREE | Art. XVII Sec. 4: a majority of 600 votes requires 301. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0014 | Sixtieth day | Sixtieth day | AGREE | Art. XVII Sec. 4 sets sixty days as the earliest date. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0015 | Ninetieth day | Ninetieth day | AGREE | Art. XVII Sec. 4 sets ninety days as the latest date. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0016 | COMELEC sufficiency certification | COMELEC sufficiency certification | AGREE | Art. XVII Sec. 4 starts the initiative clock at certification. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0017 | 180 | 180 | AGREE | Art. XVII Sec. 1: three-fourths × 240 = 180. | U |
| q-philippine-constitution-amending-and-revising-the-constitution-0018 | Sections 1; 2; 3; 4 | Sections 1; 2; 3; 4 | AGREE | Art. XVII Secs. 1–4 address those topics in that order. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0019 | Proper proposal and ratification required | Proper proposal and ratification required | AGREE | Art. XVII Secs. 1–4 require both steps. | L |
| q-philippine-constitution-amending-and-revising-the-constitution-0020 | Convention; majority at seventy days | Convention; majority at seventy days | AGREE | Art. XVII Secs. 1 and 4 permit that revision process. | None |
| q-philippine-constitution-bill-of-rights-0008 | Double jeopardy | Double jeopardy | AGREE | Art. III Sec. 21 prohibits repeated jeopardy for the same offense. | None |
| q-philippine-constitution-bill-of-rights-0009 | Ex post facto law | Ex post facto law | AGREE | Art. III Sec. 22 bars retroactive criminalization. | None |
| q-philippine-constitution-bill-of-rights-0010 | Bill of attainder | Bill of attainder | AGREE | Art. III Sec. 22 bars legislative punishment without judicial trial. | None |
| q-philippine-constitution-bill-of-rights-0011 | Debt or unpaid poll tax | Debt or unpaid poll tax | AGREE | Art. III Sec. 20 expressly names both grounds. | None |
| q-philippine-constitution-bill-of-rights-0013 | Cruel or degrading punishment | Cruel or degrading punishment | AGREE | Art. III Sec. 19(1) prohibits these punishments. | U |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0001 | Beliefs protected; conviction exception | Beliefs protected; conviction exception | AGREE | Art. III Sec. 18 states both rules. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0002 | Habeas corpus petition | Habeas corpus petition | AGREE | Art. III Sec. 15 protects the privilege concerning unlawful detention. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0003 | Investigate violation | Investigate violation | AGREE | Art. XIII Sec. 18(1) authorizes CHR investigations. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0004 | Reclusion perpetua; life imprisonment | Reclusion perpetua; life imprisonment | AGREE | Art. III Sec. 19(1); RA 9346 Sec. 2 supplies replacements. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0005 | Parole barred | Parole barred | AGREE | Art. III Sec. 19(1); RA 9346 Sec. 3 bars parole here. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0006 | Debt remains; no jail for nonpayment | Debt remains; no jail for nonpayment | AGREE | Art. III Sec. 20 bars imprisonment, not debt collection. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0007 | Filing alone insufficient | Filing alone insufficient | AGREE | Art. III Sec. 21; Rule 117 Sec. 7 requires a plea. | L |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0008 | Homicide trial barred | Homicide trial barred | AGREE | Art. III Sec. 21; Rule 117 Sec. 7 covers included offenses. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0009 | National prosecution barred | National prosecution barred | AGREE | Art. III Sec. 21 expressly covers law and ordinance. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0010 | Later prosecution may proceed | Later prosecution may proceed | AGREE | Art. III Sec. 21; Rule 117 Sec. 7(a) permits supervening offenses. | L |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0011 | Ex post facto violation | Ex post facto violation | AGREE | Art. III Sec. 22 covers retroactively lowered proof requirements. | L |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0012 | Reprosecution not automatically barred | Reprosecution not automatically barred | AGREE | Art. III Sec. 21; requested procedural dismissal generally permits retrial. | L |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0013 | Retrial barred | Retrial barred | AGREE | Art. III Sec. 21: granted merits demurrer is an acquittal. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0014 | Speedy-trial dismissal bars retrial | Speedy-trial dismissal bars retrial | AGREE | Art. III Secs. 14(2) and 21 protect this dismissal. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0015 | Neither label established | Neither label established | AGREE | Art. III Sec. 22: prospective law with judicial trial fits neither. | L |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0016 | Due-conviction exception applies | Due-conviction exception applies | AGREE | Art. III Sec. 18(2) expressly permits this punishment. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0017 | Act prohibits death | Act prohibits death | AGREE | Art. III Sec. 19(1); RA 9346 Sec. 1 prohibits imposition. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0018 | Attempted; frustrated | Attempted; frustrated | AGREE | RPC Art. 6 distinguishes incomplete acts from completed acts; no constitutional section defines stages. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0019 | Check evidence against right | Check evidence against right | AGREE | Art. III Sec. 19 supplies the protection; evidence must establish the facts. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0020 | Lost liberty; daily-expense difficulty | Lost liberty; daily-expense difficulty | AGREE | Art. III Sec. 18(1) bars this detention; both effects are stated. | None |
| q-philippine-constitution-bill-of-rights-0004 | Just compensation | Just compensation | AGREE | Art. III Sec. 9 requires compensation for public taking. | None |
| q-philippine-constitution-bill-of-rights-0005 | Non-impairment | Non-impairment | AGREE | Art. III Sec. 10 protects contractual obligations. | None |
| q-philippine-constitution-bill-of-rights-0012 | Miranda rights | Miranda rights | AGREE | Art. III Sec. 12(1) requires notice of silence and counsel rights. | None |
| q-philippine-constitution-bill-of-rights-0016 | Reclusion perpetua; strong evidence | Reclusion perpetua; strong evidence | AGREE | Art. III Sec. 13 combines these conditions for the exception. | U |
| q-philippine-constitution-bill-of-rights-0017 | Poverty cannot justify denial | Poverty cannot justify denial | AGREE | Art. III Sec. 11 expressly prohibits poverty-based denial. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0001 | Full and fair property value | Full and fair property value | AGREE | Art. III Sec. 9 requires just compensation for the taking. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0002 | Appearance as required | Appearance as required | AGREE | Art. III Sec. 13; Rule 114 Sec. 1 defines bail's appearance purpose. | L |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0003 | Release on recognizance | Release on recognizance | AGREE | Art. III Sec. 13 expressly permits recognizance provided by law. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0004 | Quasi-judicial access protected | Quasi-judicial access protected | AGREE | Art. III Sec. 11 includes quasi-judicial bodies. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0005 | Separate access and legal-help rights | Separate access and legal-help rights | AGREE | Art. III Sec. 11 protects both. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0006 | Significant restraint during questioning | Significant restraint during questioning | AGREE | Art. III Sec. 12(1) safeguards custodial investigation. | L |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0007 | Independent counsel missing | Independent counsel missing | AGREE | Art. III Sec. 12(1) requires competent and independent counsel. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0008 | Written waiver also required | Written waiver also required | AGREE | Art. III Sec. 12(1) requires writing and counsel's presence. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0009 | Secret/incommunicado detention barred | Secret/incommunicado detention barred | AGREE | Art. III Sec. 12(2) expressly prohibits both. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0010 | Examine effect and welfare basis | Examine effect and welfare basis | AGREE | Art. III Sec. 10 protection is subject to valid police power. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0011 | Taking rule is not every regulation | Taking rule is not every regulation | AGREE | Art. III Sec. 9 addresses taking for public use. | L |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0012 | Threat-induced admission excluded | Threat-induced admission excluded | AGREE | Art. III Sec. 12(2)–(3) covers admissions as well as confessions. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0013 | Incriminating testimony protected | Incriminating testimony protected | AGREE | Art. III Sec. 17 covers testimony tending to establish guilt. | L |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0014 | Strong-evidence condition absent | Strong-evidence condition absent | AGREE | Art. III Sec. 13 requires strong evidence for this exception. | L |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0015 | Bail intact; excessive bail barred | Bail intact; excessive bail barred | AGREE | Art. III Sec. 13 expressly states both rules. | None |
| q-philippine-constitution-bill-of-rights-0006 | Liberty against unlawful detention | Liberty against unlawful detention | AGREE | Art. III Sec. 15 protects the habeas corpus privilege. | None |
| q-philippine-constitution-bill-of-rights-0007 | Presumption of innocence | Presumption of innocence | AGREE | Art. III Sec. 14(2) expressly guarantees this presumption. | None |
| q-philippine-constitution-bill-of-rights-0015 | No compelled self-incrimination | No compelled self-incrimination | AGREE | Art. III Sec. 17 bars being compelled to testify against oneself. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0001 | Administrative body | Administrative body | AGREE | Art. III Sec. 16 expressly includes administrative bodies. | U |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0002 | Know nature and cause of charge | Know nature and cause of charge | AGREE | Art. III Sec. 14(2) guarantees notice of the accusation. | L |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0003 | Be heard personally and by counsel | Be heard personally and by counsel | AGREE | Art. III Sec. 14(2) protects both forms of defense. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0004 | Compulsory process | Compulsory process | AGREE | Art. III Sec. 14(2) secures defense witnesses and evidence. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0005 | Public observation with lawful limits | Public observation with lawful limits | AGREE | Art. III Sec. 14(2); Rule 119 Sec. 21 permits limits. | U |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0006 | Impartiality | Impartiality | AGREE | Art. III Sec. 14(2) requires an impartial trial. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0007 | Confront and question witnesses | Confront and question witnesses | AGREE | Art. III Sec. 14(2) protects confrontation of witnesses. | L |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0008 | No trial in absence without notice | No trial in absence without notice | AGREE | Art. III Sec. 14(2) requires due notification. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0009 | Trial may proceed; guilt not proved | Trial may proceed; guilt not proved | AGREE | Art. III Sec. 14(2) permits trial but preserves innocence. | L |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0010 | Public-safety requirement absent | Public-safety requirement absent | AGREE | Art. III Sec. 15 requires public safety to demand suspension. | L, U |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0011 | Emergency label insufficient | Emergency label insufficient | AGREE | Art. III Sec. 15 requires invasion or rebellion. | U |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0012 | Examine four delay factors | Examine four delay factors | AGREE | Art. III Sec. 14(2): case law applies a balancing test. | L, U |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0013 | Trial versus broader disposition | Trial versus broader disposition | AGREE | Art. III Secs. 14(2) and 16 establish these scopes. | L, U |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0014 | Examine delay circumstances | Examine delay circumstances | AGREE | Art. III Sec. 16 includes quasi-judicial bodies; delay needs assessment. | L |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0015 | Incriminating answer protected | Incriminating answer protected | AGREE | Art. III Sec. 17 protects persons beyond criminal defendants. | L |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0016 | Written account is compelled testimony | Written account is compelled testimony | AGREE | Art. III Sec. 17 also protects compelled written testimony. | L |
| q-philippine-constitution-bill-of-rights-0035 | Suspension does not legalize all detention | Suspension does not legalize all detention | AGREE | Art. III Sec. 15 and Art. VII Sec. 18 limit suspension. | U |

## Re-solve, part 2
| q-philippine-constitution-the-three-branches-and-their-powers-0001 | 24 nationwide; 6 years; 2 consecutive | 24 nationwide; 6 years; 2 consecutive | AGREE | Art VI Secs 2,4 set composition and term limits. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0002 | 3 years; 3 consecutive | 3 years; 3 consecutive | AGREE | Art VI Sec 7 sets House terms and consecutive-term limits. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0003 | House origin; Senate may amend | House origin; Senate may amend | AGREE | Art VI Sec 24 requires House origin for revenue bills. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0004 | VP succeeds; later election barred | VP succeeds; later election barred | AGREE | Art VII Secs 4,8: succession exceeding four years bars election. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0005 | Final judgment; amnesty concurrence | Final judgment; amnesty concurrence | AGREE | Art VII Sec 19 requires final conviction and majority concurrence, respectively. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0006 | Fails one-year district residence | Fails one-year district residence | AGREE | Art VI Sec 6 requires one year of district residence. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0007 | Natural-born citizenship | Natural-born citizenship | AGREE | Art VI Sec 3 requires natural-born senators. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0008 | Fails ten-year residence | Fails ten-year residence | AGREE | Art VII Secs 2,3 give President and VP identical qualifications. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0009 | Ambassador: CA; judge: JBC list | Ambassador: CA; judge: JBC list | AGREE | Art VII Sec 16; Art VIII Sec 9 distinguish appointment routes. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0010 | Natural-born; 42; 15 years | Natural-born; 42; 15 years | AGREE | Art VIII Sec 7(1) requires natural-born status, age 40 and 15 years. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0011 | Chair must join lawyer majority | Chair must join lawyer majority | AGREE | Art IX-C Sec 1(1) includes the Chair in the lawyer majority. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0012 | Lawyer; eleven years; not CPA | Lawyer; eleven years; not CPA | AGREE | Art IX-D Sec 1(1) requires ten years and professional diversity. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0013 | Prior candidacy bars appointment | Prior candidacy bars appointment | AGREE | Art XI Sec 8 bars candidates in the immediately preceding election. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0014 | 15 Members; en banc | 15 Members; en banc | AGREE | Art VIII Sec 4(1)-(2) sets membership and constitutional-case hearing. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0015 | 60 days; report within 48 hours | 60 days; report within 48 hours | AGREE | Art VII Sec 18 states both initial limits. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0016 | SC review; joint majority revokes | SC review; joint majority revokes | AGREE | Art VII Sec 18 provides judicial review and congressional revocation. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0017 | No; sixteen votes required | No; sixteen votes required | AGREE | Art VII Sec 21 requires two-thirds of all Senators: 16 of 24. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0018 | Override fails; Senate needs 16 | Override fails; Senate needs 16 | AGREE | Art VI Sec 27(1) requires two-thirds separately in each House. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0019 | President commands; Congress declares | President commands; Congress declares | AGREE | Art VII Sec 18; Art VI Sec 23(1): war votes are separate. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0020 | Respect rights; no budget increase | Respect rights; no budget increase | AGREE | Art VI Secs 21,25(1) govern inquiries and recommended appropriations. | L |
| q-philippine-constitution-the-three-branches-and-their-powers-0021 | President executes; courts decide | President executes; courts decide | AGREE | Art VII Sec 17; Art VIII Sec 1 allocate these functions. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0022 | Veto and veto override | Veto and veto override | AGREE | Art VI Sec 27(1) establishes both checks. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0023 | Courts may examine grave abuse | Courts may examine grave abuse | AGREE | Art VIII Sec 1 expressly includes review of government grave abuse. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0024 | Collegiate judges: natural-born | Collegiate judges: natural-born | AGREE | Art VIII Sec 7(1) expressly covers lower collegiate courts. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0025 | No confirmation required | No confirmation required | AGREE | Art VII Sec 3 expressly exempts the VP’s Cabinet appointment. | None |
| q-philippine-constitution-the-civil-service-commission-0001 | Chair and two commissioners | Chair and two commissioners | AGREE | Art IX-B Sec 1(1) sets this composition. | None |
| q-philippine-constitution-the-civil-service-commission-0002 | Natural-born citizenship | Natural-born citizenship | AGREE | Art IX-B Sec 1(1) requires natural-born members. | None |
| q-philippine-constitution-the-civil-service-commission-0003 | 35 years | 35 years | AGREE | Art IX-B Sec 1(1) sets minimum appointment age at 35. | None |
| q-philippine-constitution-the-civil-service-commission-0004 | President with CA consent | President with CA consent | AGREE | Art IX-B Sec 1(2) prescribes this appointment route. | None |
| q-philippine-constitution-the-civil-service-commission-0005 | Seven years; no reappointment | Seven years; no reappointment | AGREE | Art IX-B Sec 1(2) states both rules. | None |
| q-philippine-constitution-the-civil-service-commission-0006 | No immediately prior candidacy | No immediately prior candidacy | AGREE | Art IX-B Sec 1(1) bars candidacy in the preceding election. | None |
| q-philippine-constitution-the-civil-service-commission-0007 | Article IX-B | Article IX-B | AGREE | Art IX-B Sec 1 establishes and governs the CSC. | None |
| q-philippine-constitution-the-civil-service-commission-0008 | No reappointment | No reappointment | AGREE | Art IX-B Sec 1(2) prohibits reappointment after a full term. | None |
| q-philippine-constitution-the-civil-service-commission-0009 | Public administration | Public administration | AGREE | Art IX-B Sec 1(1) requires proven capacity in public administration. | None |
| q-philippine-constitution-the-civil-service-commission-0010 | Personnel agency | Personnel agency | AGREE | Art IX-B Sec 3 names CSC the central personnel agency. | None |
| q-philippine-constitution-the-civil-service-commission-0011 | Staggered terms | Staggered terms | AGREE | Art IX-B Sec 1(2) assigns initial terms of seven, five and three years. | None |
| q-philippine-constitution-the-civil-service-commission-0012 | Automatic, regular funding release | Automatic, regular funding release | AGREE | Art IX-A Sec 5 protects release of approved annual appropriations. | L |
| q-philippine-constitution-the-civil-service-commission-0013 | Obtain CA consent | Obtain CA consent | AGREE | Art IX-B Sec 1(2) requires Commission on Appointments consent. | None |
| q-philippine-constitution-the-civil-service-commission-0014 | At appointment | At appointment | AGREE | Art IX-B Sec 1(1) fixes the age requirement at appointment. | None |
| q-philippine-constitution-the-civil-service-commission-0015 | CSC | CSC | AGREE | Art IX-A Sec 1 expressly lists the CSC. | None |
| q-philippine-constitution-the-civil-service-commission-0016 | Three | Three | AGREE | Art IX-B Sec 1(1): one Chair plus two Commissioners. | None |
| q-philippine-constitution-the-civil-service-commission-0017 | Candidacy restriction still applies | Candidacy restriction still applies | AGREE | Art IX-B Sec 1(1) provides no age or expertise waiver. | None |
| q-philippine-constitution-the-civil-service-commission-0018 | Age requirement not met | Age requirement not met | AGREE | Art IX-B Sec 1(1) requires age 35 at appointment. | U: “from the lesson” |
| q-philippine-constitution-the-civil-service-commission-0019 | Proven administration capacity | Proven administration capacity | AGREE | Art IX-B Sec 1(1) lists this as one of several qualifications. | None |
| q-philippine-constitution-the-civil-service-commission-0020 | Claim exceeds personnel role | Claim exceeds personnel role | AGREE | Art IX-B Sec 3 grants personnel functions, not all government powers. | U: lesson-based phrasing |
| q-philippine-constitution-the-civil-service-commission-0021 | Original charter | Original charter | AGREE | Art IX-B Sec 2(1) limits its corporation clause to GOCCs with original charters. | None |
| q-philippine-constitution-the-civil-service-commission-0022 | All branches and agencies | All branches and agencies | AGREE | Art IX-B Sec 2(1) expressly includes all government branches. | None |
| q-philippine-constitution-the-civil-service-commission-0023 | Private practice barred | Private practice barred | AGREE | Art IX-A Sec 2 bars professional practice during tenure. | None |
| q-philippine-constitution-the-civil-service-commission-0024 | Merit and fitness | Merit and fitness | AGREE | Art IX-B Sec 2(2) makes merit and fitness the appointment principle. | None |
| q-philippine-constitution-the-civil-service-commission-0025 | Policy-determining | Policy-determining | AGREE | Art IX-B Sec 2(2) excepts policy-determining posts from competitive examinations. | None |
| q-philippine-constitution-the-civil-service-commission-0026 | Suspension for lawful cause | Suspension for lawful cause | AGREE | Art IX-B Sec 2(3) permits suspension for a cause provided by law. | None |
| q-philippine-constitution-the-civil-service-commission-0027 | Voting differs from campaigning | Voting differs from campaigning | AGREE | Art IX-B Sec 2(4) bans campaigning; Art V Sec 1 protects suffrage. | None |
| q-philippine-constitution-accountability-and-impeachment-0001 | Article XI | Article XI | AGREE | Art XI Secs 1-2 address public accountability and impeachment. | None |
| q-philippine-constitution-accountability-and-impeachment-0002 | Public trust | Public trust | AGREE | Art XI Sec 1 expressly declares public office a public trust. | None |
| q-philippine-constitution-accountability-and-impeachment-0003 | Ombudsman | Ombudsman | AGREE | Art XI Sec 2 expressly includes the Ombudsman. | None |
| q-philippine-constitution-accountability-and-impeachment-0004 | Senator | Senator | AGREE | Art XI Sec 2 excludes senators from its impeachment list. | None |
| q-philippine-constitution-accountability-and-impeachment-0005 | Betrayal of public trust | Betrayal of public trust | AGREE | Art XI Sec 2 expressly names this ground. | None |
| q-philippine-constitution-accountability-and-impeachment-0006 | Inefficiency in office | Inefficiency in office | AGREE | Art XI Sec 2 does not expressly list inefficiency. | None |
| q-philippine-constitution-accountability-and-impeachment-0007 | Yes, commission members | Yes, commission members | AGREE | Art XI Sec 2 includes Constitutional Commission members. | None |
| q-philippine-constitution-accountability-and-impeachment-0008 | No; Supreme Court members only | No; Supreme Court members only | AGREE | Art XI Sec 2 does not include Regional Trial Court judges. | None |
| q-philippine-constitution-accountability-and-impeachment-0009 | Service for public benefit | Service for public benefit | AGREE | Art XI Sec 1 requires accountability and responsible public service. | None |
| q-philippine-constitution-accountability-and-impeachment-0010 | Bribery | Bribery | AGREE | Art XI Sec 2 names bribery, the closest ground for paid official favors. | None |
| q-philippine-constitution-accountability-and-impeachment-0011 | Treason | Treason | AGREE | Art XI Sec 2 names treason; Revised Penal Code Art 114 supplies its definition. | None |
| q-philippine-constitution-accountability-and-impeachment-0012 | Five | Five | AGREE | Art XI Sec 2 lists President, VP, Supreme Court, commissions and Ombudsman. | None |
| q-philippine-constitution-accountability-and-impeachment-0013 | Six | Six | AGREE | Art XI Sec 2 lists six grounds, counting graft and corruption together. | None |
| q-philippine-constitution-accountability-and-impeachment-0014 | Yes, expressly included | Yes, expressly included | AGREE | Art XI Sec 2 names Supreme Court members. | None |
| q-philippine-constitution-accountability-and-impeachment-0015 | Intentional constitutional violation | Intentional constitutional violation | AGREE | Art XI Sec 2 names culpable constitutional violation, not a minor clerical mistake. | U: lesson reference |
| q-philippine-constitution-accountability-and-impeachment-0016 | Other lawful removal remains | Other lawful removal remains | AGREE | Art XI Sec 2 expressly permits removal of other officers as provided by law. | None |
| q-philippine-constitution-accountability-and-impeachment-0017 | Unpopularity automatically qualifies | Unpopularity automatically qualifies | AGREE | Art XI Sec 2 does not list mere unpopularity as a ground. | None |
| q-philippine-constitution-accountability-and-impeachment-0018 | Check whether office is listed | Check whether office is listed | AGREE | Art XI Sec 2 excludes Court of Appeals justices from the list. | U: lesson/distractor wording |
| q-philippine-constitution-accountability-and-impeachment-0019 | Responsible service; modest living | Responsible service; modest living | AGREE | Art XI Sec 1 expressly requires both. | None |
| q-philippine-constitution-accountability-and-impeachment-0020 | Separate office and ground limits | Separate office and ground limits | AGREE | Art XI Sec 2 requires both a listed office and a listed ground. | None |
| q-philippine-constitution-accountability-and-impeachment-0021 | Proof and decision still needed | Proof and decision still needed | AGREE | Art XI Sec 3(6) assigns trial and conviction to the Senate. | None |
| q-philippine-constitution-accountability-and-impeachment-0022 | Graft and corruption | Graft and corruption | AGREE | Art XI Sec 2 names the ground most directly fitting improper contract benefits. | None |
| q-philippine-constitution-accountability-and-impeachment-0023 | Becomes Articles of Impeachment | Becomes Articles of Impeachment | AGREE | Art XI Sec 3(4) gives one-third filings this direct effect. | None |
| q-philippine-constitution-accountability-and-impeachment-0024 | Committee review and House action | Committee review and House action | AGREE | Art XI Sec 3(2)-(3) prescribes this complaint route. | None |
| q-philippine-constitution-accountability-and-impeachment-0025 | Presides without voting | Presides without voting | AGREE | Art XI Sec 3(6) expressly limits the Chief Justice’s role. | None |
| q-philippine-constitution-accountability-and-impeachment-0026 | Criminal prosecution may follow | Criminal prosecution may follow | AGREE | Art XI Sec 3(7) preserves prosecution, trial and punishment under law. | None |
| q-philippine-constitution-accountability-and-impeachment-0027 | Yes, on own initiative | Yes, on own initiative | AGREE | Art XI Sec 13(1) authorizes investigation without a complaint. | None |
| q-philippine-constitution-accountability-and-impeachment-0028 | Direct and expedite performance | Direct and expedite performance | AGREE | Art XI Sec 13(2) covers duties required by law. | None |
| q-philippine-constitution-citizenship-and-suffrage-0001 | Persons lawfully naturalized | Persons lawfully naturalized | AGREE | Art IV Sec 1(4) expressly includes them as citizens. | None |
| q-philippine-constitution-citizenship-and-suffrage-0002 | Citizen from birth; no act needed | Citizen from birth; no act needed | AGREE | Art IV Sec 2 defines natural-born citizenship this way. | L |
| q-philippine-constitution-citizenship-and-suffrage-0003 | Citizenship retained | Citizenship retained | AGREE | Art IV Sec 4 preserves citizenship absent legally recognized renunciation. | None |
| q-philippine-constitution-citizenship-and-suffrage-0004 | Eighteen | Eighteen | AGREE | Art V Sec 1 sets the minimum voting age at eighteen. | None |
| q-philippine-constitution-citizenship-and-suffrage-0005 | Land ownership requirement | Land ownership requirement | AGREE | Art V Sec 1 forbids property qualifications for suffrage. | None |
| q-philippine-constitution-citizenship-and-suffrage-0006 | Natural-born citizen from birth | Natural-born citizen from birth | AGREE | Art IV Secs 1(2),2 apply through his Filipino father. | None |
| q-philippine-constitution-citizenship-and-suffrage-0007 | Natural-born Philippine citizen | Natural-born Philippine citizen | AGREE | Art IV Sec 2 deems proper Sec 1(3) electors natural-born. | None |
| q-philippine-constitution-citizenship-and-suffrage-0008 | No; natural-born required | No; natural-born required | AGREE | Art IX-B Sec 1(1) requires natural-born CSC members. | None |
| q-philippine-constitution-citizenship-and-suffrage-0009 | Both governed by law | Both governed by law | AGREE | Art IV Sec 3 places loss and reacquisition under law. | None |
| q-philippine-constitution-citizenship-and-suffrage-0010 | Prescribed oath of allegiance | Prescribed oath of allegiance | AGREE | Art IV Sec 3; RA 9225 Sec 3 provides this reacquisition act. | L |
| q-philippine-constitution-citizenship-and-suffrage-0011 | Yes; minimums met | Yes; minimums met | AGREE | Art V Sec 1 requires age 18, one national year and six local months. | None |
| q-philippine-constitution-citizenship-and-suffrage-0012 | Fails six-month local residence | Fails six-month local residence | AGREE | Art V Sec 1 requires six months in the voting place. | None |
| q-philippine-constitution-citizenship-and-suffrage-0013 | Ballot secrecy and sanctity | Ballot secrecy and sanctity | AGREE | Art V Sec 2 requires protection of both. | None |
| q-philippine-constitution-citizenship-and-suffrage-0014 | Overseas eligibility and registration | Overseas eligibility and registration | AGREE | Art V Sec 2 provides overseas voting; RA 9189 Secs 4,6 govern participation. | L |
| q-philippine-constitution-citizenship-and-suffrage-0015 | Woman losing citizenship by marriage | Woman losing citizenship by marriage | AGREE | Art IV Sec 3; RA 8171 Sec 1 expressly covers this class. | None |
| q-philippine-constitution-citizenship-and-suffrage-0016 | Dual citizenship, not proven allegiance | Dual citizenship, not proven allegiance | AGREE | Art IV Sec 5 concerns allegiance; Mercado distinguishes involuntary citizenship. | None |
| q-philippine-constitution-citizenship-and-suffrage-0017 | Design access; existing rules meanwhile | Design access; existing rules meanwhile | AGREE | Art V Sec 2 states both duties for voters unable to read. | L |
| q-philippine-constitution-citizenship-and-suffrage-0018 | Personal sworn foreign renunciation | Personal sworn foreign renunciation | AGREE | Art IV Sec 3; RA 9225 Sec 5(2) requires it when filing candidacy. | L |
| q-philippine-constitution-citizenship-and-suffrage-0019 | Registration may proceed | Registration may proceed | AGREE | Art V Sec 1; RA 8189 Sec 9 permits election-day qualifications. | None |
| q-philippine-constitution-citizenship-and-suffrage-0020 | Natural-born; eligible if 18+ | Natural-born; eligible | AGREE | Art IV Secs 1(2),2; Art V Sec 1 requires age 18. | F: election date/age absent |
| q-philippine-constitution-citizenship-and-suffrage-0021 | RA 9139: eighteen at filing | RA 9139: eighteen at filing | AGREE | Art IV Sec 3; RA 9139 Sec 3(b) sets this minimum. | None |
| q-philippine-constitution-the-articles-in-outline-0001 | Eighteen | Eighteen | AGREE | Art XVIII Sec 27 closes the eighteen articles; Preamble is unnumbered. | None |
| q-philippine-constitution-the-articles-in-outline-0002 | Move to Article III | Move to Article III | AGREE | Art III Sec 1 begins the Bill of Rights. | None |
| q-philippine-constitution-the-articles-in-outline-0003 | Article IV | Article IV | AGREE | Art IV Sec 1 identifies Philippine citizens. | None |
| q-philippine-constitution-the-articles-in-outline-0004 | Suffrage | Suffrage | AGREE | Art V Secs 1-2 govern suffrage. | None |
| q-philippine-constitution-the-articles-in-outline-0005 | Article VII | Article VII | AGREE | Art VII Sec 1 vests executive power in the President. | None |
| q-philippine-constitution-the-articles-in-outline-0006 | Constitutional Commissions | Constitutional Commissions | AGREE | Art IX-A Sec 1 identifies the three Constitutional Commissions. | None |
| q-philippine-constitution-the-articles-in-outline-0007 | Article X | Article X | AGREE | Art X Sec 1 begins the local-government provisions. | None |
| q-philippine-constitution-the-articles-in-outline-0008 | Article XI for accountability | Article XI for accountability | AGREE | Art XI Secs 1-2 address public-officer accountability. | U: “correct correction” |
| q-philippine-constitution-the-articles-in-outline-0009 | Article XIV | Article XIV | AGREE | Art XIV Secs 1,10,14,19 cover education, science, culture and sports. | None |
| q-philippine-constitution-the-articles-in-outline-0010 | Article XVII | Article XVII | AGREE | Art XVII Secs 1-4 govern amendments and revisions. | None |
| q-philippine-constitution-the-articles-in-outline-0011 | Article VIII | Article VIII | AGREE | Art VIII Sec 1 vests judicial power in the courts. | None |
| q-philippine-constitution-the-articles-in-outline-0012 | National Economy and Patrimony | National Economy and Patrimony | AGREE | Art XII’s heading and Sec 1 concern the national economy. | None |
| q-philippine-constitution-the-articles-in-outline-0013 | Article XV | Article XV | AGREE | Art XV Sec 1 recognizes the family as the nation’s foundation. | None |
| q-philippine-constitution-the-articles-in-outline-0014 | National Territory | National Territory | AGREE | Art I defines national territory; it has no numbered section. | None |
| q-philippine-constitution-the-articles-in-outline-0015 | Article VI | Article VI | AGREE | Art VI Sec 1 vests legislative power in Congress. | None |
| q-philippine-constitution-the-articles-in-outline-0016 | Common Provisions | Common Provisions | AGREE | Art IX-A Secs 1-8 contain common commission provisions. | None |
| q-philippine-constitution-the-articles-in-outline-0017 | Purposes and aspirations | Purposes and aspirations | AGREE | Preamble states purposes; it has no Article or Section. | None |
| q-philippine-constitution-the-articles-in-outline-0018 | Legislative, executive, judicial | Legislative, executive, judicial | AGREE | Art VI Sec 1; Art VII Sec 1; Art VIII Sec 1 allocate these powers. | None |
| q-philippine-constitution-the-articles-in-outline-0019 | Article XVIII | Article XVIII | AGREE | Art XVIII Sec 1 begins Transitory Provisions. | None |
| q-philippine-constitution-the-articles-in-outline-0020 | Locate topics; read exact rules | Locate topics; read exact rules | AGREE | Art VI Sec 24 illustrates rules that a heading alone cannot establish. | U: study-method question |
| q-philippine-constitution-the-articles-in-outline-0021 | Policy is not complete procedure | Policy is not complete procedure | AGREE | Art II Sec 15 states a health policy, not operating steps. | None |
| q-philippine-constitution-the-articles-in-outline-0022 | Article XIII | Article XIII | AGREE | Art XIII Sec 18(1) grants CHR the specified investigative power. | None |
| q-philippine-constitution-the-articles-in-outline-0023 | Article XVI: General Provisions | Article XVI: General Provisions | AGREE | Art XVI Sec 1 describes the Philippine flag. | None |

## Re-solve of the 63 edited questions
| q-philippine-constitution-accountability-and-impeachment-0015 | Intentional violation | Intentional violation | AGREE | Art XI §2: culpable violation is an impeachment ground. | LANG: padded memo choice |
| q-philippine-constitution-accountability-and-impeachment-0018 | Office listed in XI §2 | Office listed in XI §2 | AGREE | Art XI §2: only listed officers face impeachment. | LANG: shared impeachment |
| q-philippine-constitution-amending-and-revising-the-constitution-0001 | 3 | 3 | AGREE | Art XVII §§1–2: Congress, convention, and initiative. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0002 | Specific change | Specific change | AGREE | Art XVII §§1–2: amendment preserves the basic framework. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0008 | 3% in every district | 3% in every district | AGREE | Art XVII §2: each district needs 3% of registered voters. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0009 | Initiative: amendments only | Initiative: amendments only | AGREE | Art XVII §§1–2: initiative cannot propose revisions. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0011 | Five-year limits | Five-year limits | AGREE | Art XVII §2: initial five-year ban, then five-year intervals. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0017 | 180 | 180 | AGREE | Art XVII §1: three-fourths of 240 is 180. | None |
| q-philippine-constitution-amending-and-revising-the-constitution-0019 | Proposal and ratification | Proposal and ratification | AGREE | Art XVII §§1–4: proposal and popular ratification are required. | None |
| q-philippine-constitution-bill-of-rights-0016 | Strong guilt evidence | Strong guilt evidence | AGREE | Art III §13: the exception requires strong evidence of guilt. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0002 | Appearance as required | Appearance as required | AGREE | Art III §13: bail secures appearance, not innocence. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0006 | Restricted liberty | Restricted liberty | AGREE | Art III §12(1): custodial questioning triggers safeguards. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0011 | Taking for public use | Taking for public use | AGREE | Art III §9: compensation requires a taking for public use. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0013 | Self-incriminating testimony | Self-incriminating testimony | AGREE | Art III §17: compelled incriminating testimony is protected. | None |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0014 | Strong evidence absent | Strong evidence absent | AGREE | Art III §13: the exception needs strong evidence. | None |
| q-philippine-constitution-bill-of-rights-0013 | Cruel or degrading punishment | Cruel or degrading punishment | AGREE | Art III §19(1): both are forbidden. | LANG: personal dislike |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0007 | Arraignment and plea | Arraignment and plea | AGREE | Art III §21: filing alone creates no jeopardy. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0010 | Later prosecution allowed | Later prosecution allowed | AGREE | Art III §21: later death is a supervening fact. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0011 | Ex post facto violation | Ex post facto violation | AGREE | Art III §22: retroactive proof reduction is barred. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0012 | Reprosecution allowed | Reprosecution allowed | AGREE | Art III §21: requested dismissal generally permits retrial. | None |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0015 | Neither ban applies | Neither ban applies | AGREE | Art III §22: prospective law with judicial trial fits neither ban. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0001 | Administrative body | Administrative body | AGREE | Art III §16: administrative bodies are expressly covered. | LANG: private-club filler |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0002 | Notice of accusation | Notice of accusation | AGREE | Art III §14(2): accused must know its nature and cause. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0005 | Public, with lawful limits | Public, with lawful limits | AGREE | Art III §14(2): public trial allows lawful attendance limits. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0007 | Confront witnesses | Confront witnesses | AGREE | Art III §14(2): confrontation includes cross-examination. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0009 | Trial may proceed | Trial may proceed | AGREE | Art III §14(2): notified, unjustified absence permits trial. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0010 | Public safety required | Public safety required | AGREE | Art III §15: public safety must require suspension. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0011 | Invasion or rebellion needed | Invasion or rebellion needed | AGREE | Art III §15: an emergency label is insufficient. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0012 | Delay, reasons, assertion, harm | Delay, reasons, assertion, harm | AGREE | Art III §14(2): apply the balancing test. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0013 | Disposition covers both | Disposition covers both | AGREE | Art III §§14(2),16: disposition protects both proceedings. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0014 | Review delay circumstances | Review delay circumstances | AGREE | Art III §16: quasi-judicial cases also receive protection. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0015 | Refuse incriminating answer | Refuse incriminating answer | AGREE | Art III §17: witnesses may refuse self-incriminating answers. | None |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0016 | Compelled testimony | Compelled testimony | AGREE | Art III §17: forced written admissions are testimonial. | None |
| q-philippine-constitution-bill-of-rights-0035 | Suspension has limits | Suspension has limits | AGREE | Art VII §18: suspension limits covered offenses and detention. | None |
| q-philippine-constitution-bill-of-rights-0018 | Lawful association | Lawful association | AGREE | Art III §8: lawful associations are protected. | LANG: surrender all rights |
| q-philippine-constitution-bill-of-rights-0019 | Petition for redress | Petition for redress | AGREE | Art III §4: petition for redress is protected. | None |
| q-philippine-constitution-bill-of-rights-0020 | No religious test | No religious test | AGREE | Art III §5: political rights require no religious test. | None |
| q-philippine-constitution-bill-of-rights-0022 | Check legal limits | Check legal limits | AGREE | Art III §7: access is subject to lawful limitations. | None |
| q-philippine-constitution-bill-of-rights-0023 | Unrelated distinction | Unrelated distinction | AGREE | Art III §1: arbitrary classifications violate equal protection. | None |
| q-philippine-constitution-bill-of-rights-0025 | No free consent shown | No free consent shown | AGREE | Art III §2: coerced submission does not establish consent. | None |
| q-philippine-constitution-bill-of-rights-0026 | Lawful court order | Lawful court order | AGREE | Art III §6: abode restrictions need a lawful court order. | None |
| q-philippine-constitution-bill-of-rights-0027 | Personal evidence review | Personal evidence review | AGREE | Art III §2: personal determination need not mean personal questioning. | None |
| q-philippine-constitution-bill-of-rights-0028 | No immediate offense/knowledge | No immediate offense/knowledge | AGREE | Art III §2: hot pursuit needs immediacy and personal knowledge. | None |
| q-philippine-constitution-bill-of-rights-0029 | Waiver invalid | Waiver invalid | AGREE | Art III §12(1): waiver requires writing and counsel's presence. | None |
| q-philippine-constitution-bill-of-rights-0030 | Strong evidence required | Strong evidence required | AGREE | Art III §13: penalty alone does not satisfy the exception. | None |
| q-philippine-constitution-bill-of-rights-0031 | Bail remains protected | Bail remains protected | AGREE | Art III §§13,15: valid writ suspension leaves bail intact. | None |
| q-philippine-constitution-bill-of-rights-0032 | Same-act prosecution barred | Same-act prosecution barred | AGREE | Art III §21: ordinance acquittal bars prosecution for the same act. | None |
| q-philippine-constitution-bill-of-rights-0036 | Limited person search | Limited person search | AGREE | Art III §2: lawful arrest permits a limited incidental search. | None |
| q-philippine-constitution-citizenship-and-suffrage-0002 | Citizen from birth | Citizen from birth | AGREE | Art IV §2: natural-born citizenship needs no acquisition act. | None |
| q-philippine-constitution-citizenship-and-suffrage-0010 | Prescribed allegiance oath | Prescribed allegiance oath | AGREE | Art IV §3; RA 9225 §3: reacquisition requires the oath. | None |
| q-philippine-constitution-citizenship-and-suffrage-0014 | Eligibility and registration | Eligibility and registration | AGREE | Art V §§1–2: overseas voting requires statutory eligibility. | None |
| q-philippine-constitution-citizenship-and-suffrage-0020 | Citizen; qualified voter | Citizen; qualified voter | AGREE | Art IV §§1(2),2; V §1: birth and voting conditions are met. | None |
| q-philippine-constitution-the-articles-in-outline-0008 | Use Article XI | Use Article XI | AGREE | Art XI §1: public-office accountability belongs in Article XI. | None |
| q-philippine-constitution-the-articles-in-outline-0020 | Section 24 controls | Section 24 controls | AGREE | Art VI §24: revenue bills must originate in the House. | None |
| q-philippine-constitution-the-civil-service-commission-0012 | Automatic funding release | Automatic funding release | AGREE | Art IX-A §5: approved appropriations release automatically. | None |
| q-philippine-constitution-the-civil-service-commission-0018 | Too young at appointment | Too young at appointment | AGREE | Art IX-B §1(1): minimum age is 35 at appointment. | None |
| q-philippine-constitution-the-civil-service-commission-0020 | Exceeds personnel role | Exceeds personnel role | AGREE | Art IX-B §3: personnel mandate grants no such powers. | LANG: seven-year premise |
| q-philippine-constitution-the-three-branches-and-their-powers-0002 | Three years; three terms | Three years; three terms | AGREE | Art VI §7: three-year terms, three consecutive maximum. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0004 | Succession; election barred | Succession; election barred | AGREE | Art VII §§4,8: succession beyond four years bars election. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0005 | Pardon final; amnesty Congress | Pardon final; amnesty Congress | AGREE | Art VII §19: final conviction for pardon; Congress for amnesty. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0007 | Natural-born status | Natural-born status | AGREE | Art VI §3: Senators must be natural-born citizens. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0016 | Court review; joint revocation | Court review; joint revocation | AGREE | Art VII §18: Court review and joint-majority revocation. | None |
| q-philippine-constitution-the-three-branches-and-their-powers-0019 | President commands; Congress votes | President commands; Congress votes | AGREE | Art VII §18; VI §23(1): separate powers. | None |

## Law text, part 1
| q-philippine-constitution-bill-of-rights-0001 | III §§1–22 | “Section 22. No ex post facto law or bill of attainder shall be enacted.” | KEY OK | Article ends at 22. |
| q-philippine-constitution-bill-of-rights-0002 | III §1 | “without due process of law” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0003 | III §4 | “the freedom of speech, of expression, or of the press” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0004 | III §9 | “Private property shall not be taken for public use without just compensation.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0005 | III §10 | “No law impairing the obligation of contracts shall be passed.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0006 | III §15 | “The privilege of the writ of habeas corpus shall not be suspended” | AMBIGUOUS | Text does not explain the writ's function. |
| q-philippine-constitution-bill-of-rights-0007 | III §14(2) | “the accused shall be presumed innocent until the contrary is proved” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0008 | III §21 | “No person shall be twice put in jeopardy of punishment for the same offense.” | KEY OK | Key names the express protection. |
| q-philippine-constitution-bill-of-rights-0009 | III §22 | “No ex post facto law or bill of attainder shall be enacted.” | AMBIGUOUS | Text bans but does not define ex post facto laws. |
| q-philippine-constitution-bill-of-rights-0010 | III §22 | “No ex post facto law or bill of attainder shall be enacted.” | AMBIGUOUS | Text does not define bills of attainder. |
| q-philippine-constitution-bill-of-rights-0011 | III §20 | “No person shall be imprisoned for debt or non-payment of a poll tax.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0012 | III §12(1) | “his right to remain silent and to have competent and independent counsel” | AMBIGUOUS | Protections match; “Miranda rights” label is absent. |
| q-philippine-constitution-bill-of-rights-0013 | III §19(1) | “nor cruel, degrading or inhuman punishment inflicted” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0014 | III §2 | “probable cause to be determined personally by the judge” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0015 | III §17 | “No person shall be compelled to be a witness against himself.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0016 | III §13 | “offenses punishable by reclusion perpetua when evidence of guilt is strong” | KEY OK | Both conditions match. |
| q-philippine-constitution-bill-of-rights-0017 | III §11 | “shall not be denied to any person by reason of poverty” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0018 | III §8 | “for purposes not contrary to law” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0019 | III §4 | “petition the government for redress of grievances” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0020 | III §5 | “No religious test shall be required for the exercise of civil or political rights.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0021 | III §9 | “Private property shall not be taken for public use without just compensation.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0022 | III §7 | “subject to such limitations as may be provided by law” | KEY OK | Policy research data is expressly covered. |
| q-philippine-constitution-bill-of-rights-0023 | III §1 | “nor shall any person be denied the equal protection of the laws” | AMBIGUOUS | Classification criteria are not stated. |
| q-philippine-constitution-bill-of-rights-0024 | III §3(2) | “inadmissible for any purpose in any proceeding” | KEY OK | Administrative proceedings are included. |
| q-philippine-constitution-bill-of-rights-0025 | III §2 | “against unreasonable searches and seizures” | AMBIGUOUS | Consent requirements are not stated. |
| q-philippine-constitution-bill-of-rights-0026 | III §6 | “shall not be impaired except upon lawful order of the court” | KEY OK | Abode and travel have separate rules. |
| q-philippine-constitution-bill-of-rights-0027 | III §2 | “after examination under oath or affirmation of the complainant and the witnesses he may produce” | AMBIGUOUS | Records-only arrest-warrant doctrine needs another source. |
| q-philippine-constitution-bill-of-rights-0028 | III §2 | “against unreasonable searches and seizures” | AMBIGUOUS | Hot-pursuit conditions are absent. |
| q-philippine-constitution-bill-of-rights-0029 | III §12(1) | “These rights cannot be waived except in writing and in the presence of counsel.” | KEY OK | Matches both waiver conditions. |
| q-philippine-constitution-bill-of-rights-0030 | III §13 | “offenses punishable by reclusion perpetua when evidence of guilt is strong” | KEY OK | Penalty alone is insufficient. |
| q-philippine-constitution-bill-of-rights-0031 | III §§13,15 | “The right to bail shall not be impaired even when the privilege of the writ of habeas corpus is suspended.” | KEY OK | Both rules match. |
| q-philippine-constitution-bill-of-rights-0032 | III §21 | “conviction or acquittal under either shall constitute a bar to another prosecution for the same act” | KEY OK | Express law-and-ordinance rule. |
| q-philippine-constitution-bill-of-rights-0033 | III §22 | “No ex post facto law or bill of attainder shall be enacted.” | AMBIGUOUS | Definitions needed to distinguish the scenarios are absent. |
| q-philippine-constitution-bill-of-rights-0034 | III §2 | “against unreasonable searches and seizures” | AMBIGUOUS | Rules 113 and 126 are outside the authority. |
| q-philippine-constitution-bill-of-rights-0035 | VII §18 | “shall be judicially charged within three days, otherwise he shall be released” | KEY OK | Suspension does not legalize every detention. |
| q-philippine-constitution-bill-of-rights-0036 | III §2 | “against unreasonable searches and seizures” | AMBIGUOUS | Search-incident limits require Rule 126. |
| q-philippine-constitution-bill-of-rights-0037 | III §2 | “against unreasonable searches and seizures” | AMBIGUOUS | Hot-pursuit personal-knowledge rule is absent. |
| q-philippine-constitution-bill-of-rights-0038 | III §11 | “Free access to the courts and quasi-judicial bodies and adequate legal assistance” | KEY OK | Both protections are stated. |
| q-philippine-constitution-bill-of-rights-0039 | III §16 | “before all judicial, quasi-judicial, or administrative bodies” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0040 | III §17 | “No person shall be compelled to be a witness against himself.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0041 | III §20 | “No person shall be imprisoned for debt or non-payment of a poll tax.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-0042 | III §18(2) | “except as a punishment for a crime whereof the party shall have been duly convicted” | KEY OK | Accusation is insufficient. |
| q-philippine-constitution-bill-of-rights-0043 | III §21 | “No person shall be twice put in jeopardy of punishment for the same offense.” | AMBIGUOUS | Attachment requirements require Rule 117. |
| q-philippine-constitution-bill-of-rights-0044 | III §22 | “No ex post facto law or bill of attainder shall be enacted.” | AMBIGUOUS | Text does not define either prohibition. |
| q-philippine-constitution-amending-and-revising-the-constitution-0001 | XVII §§1–2 | “A constitutional convention.”; “directly proposed by the people through initiative” | KEY OK | With Congress, three routes. |
| q-philippine-constitution-amending-and-revising-the-constitution-0002 | XVII §1 | “Any amendment to, or revision of, this Constitution” | AMBIGUOUS | Text does not define amendment versus revision. |
| q-philippine-constitution-amending-and-revising-the-constitution-0003 | XVII §1 | “Any amendment to, or revision of, this Constitution” | AMBIGUOUS | Structural-change classification needs another source. |
| q-philippine-constitution-amending-and-revising-the-constitution-0004 | XVII §1 | “The Congress, upon a vote of three-fourths of all its Members” | KEY OK | Matches. |
| q-philippine-constitution-amending-and-revising-the-constitution-0005 | XVII §3 | “by a vote of two-thirds of all its Members, call a constitutional convention” | KEY OK | Matches. |
| q-philippine-constitution-amending-and-revising-the-constitution-0006 | XVII §3 | “by a majority vote of all its Members, submit to the electorate” | KEY OK | Matches minimum threshold. |
| q-philippine-constitution-amending-and-revising-the-constitution-0007 | XVII §2 | “at least twelve per centum of the total number of registered voters” | KEY OK | Matches. |
| q-philippine-constitution-amending-and-revising-the-constitution-0008 | XVII §2 | “every legislative district must be represented by at least three per centum” | KEY OK | Matches. |
| q-philippine-constitution-amending-and-revising-the-constitution-0009 | XVII §§1–2 | “Amendments to this Constitution may likewise be directly proposed by the people” | KEY OK | Initiative excludes revisions. |
| q-philippine-constitution-amending-and-revising-the-constitution-0010 | XVII §4 | “ratified by a majority of the votes cast in a plebiscite” | KEY OK | Voters ratify. |
| q-philippine-constitution-amending-and-revising-the-constitution-0011 | XVII §2 | “within five years following the ratification of this Constitution nor oftener than once every five years thereafter” | KEY OK | Both periods match. |
| q-philippine-constitution-amending-and-revising-the-constitution-0012 | XVII §2 | “at least three per centum of the registered voters therein” | KEY OK | 0.03 × 40,000 = 1,200. |
| q-philippine-constitution-amending-and-revising-the-constitution-0013 | XVII §4 | “a majority of the votes cast in a plebiscite” | KEY OK | Minimum majority of 600 is 301. |
| q-philippine-constitution-amending-and-revising-the-constitution-0014 | XVII §4 | “not earlier than sixty days nor later than ninety days after the approval” | KEY OK | Earliest is day 60. |
| q-philippine-constitution-amending-and-revising-the-constitution-0015 | XVII §4 | “not earlier than sixty days nor later than ninety days after the approval” | KEY OK | Latest is day 90. |
| q-philippine-constitution-amending-and-revising-the-constitution-0016 | XVII §4 | “after the certification by the Commission on Elections of the sufficiency of the petition” | KEY OK | Matches trigger. |
| q-philippine-constitution-amending-and-revising-the-constitution-0017 | XVII §1 | “three-fourths of all its Members” | KEY OK | ¾ × 240 = 180. |
| q-philippine-constitution-amending-and-revising-the-constitution-0018 | XVII §§1–4 | “Section 3. The Congress may”; “Section 4.Any amendment to, or revision of” | KEY OK | Section sequence matches. |
| q-philippine-constitution-amending-and-revising-the-constitution-0019 | XVII §§1–4 | “shall be valid when ratified by a majority of the votes cast in a plebiscite” | KEY OK | Ordinary statute omits required steps. |
| q-philippine-constitution-amending-and-revising-the-constitution-0020 | XVII §§1,4 | “not earlier than sixty days nor later than ninety days” | KEY OK | Convention, majority and day 70 match. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0001 | III §18 | “solely by reason of his political beliefs and aspirations”; “duly convicted” | KEY OK | Both protections match. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0002 | III §15 | “The privilege of the writ of habeas corpus” | AMBIGUOUS | Writ procedure and parole are not explained. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0003 | XIII §18(1) | “human rights violations involving civil and political rights” | KEY OK | CHR may investigate. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0004 | III §19(1) | “Any death penalty already imposed shall be reduced to reclusion perpetua.” | AMBIGUOUS | RA 9346 penalty distinction is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0005 | III §19(1) | “Any death penalty already imposed shall be reduced to reclusion perpetua.” | AMBIGUOUS | RA 9346 parole rule is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0006 | III §20 | “No person shall be imprisoned for debt” | KEY OK | Bars jail; does not cancel the stated valid loan. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0007 | III §21 | “twice put in jeopardy of punishment for the same offense” | AMBIGUOUS | Arraignment and plea conditions are absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0008 | III §21 | “for the same offense” | AMBIGUOUS | Included-offense rule is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0009 | III §21 | “conviction or acquittal under either shall constitute a bar” | KEY OK | Express same-act rule applies. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0010 | III §21 | “for the same offense” | AMBIGUOUS | Supervening graver-offense exception is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0011 | III §22 | “No ex post facto law or bill of attainder shall be enacted.” | AMBIGUOUS | Reduced-proof doctrine is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0012 | III §21 | “for the same offense” | AMBIGUOUS | Requested-dismissal rule is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0013 | III §21 | “No person shall be twice put in jeopardy of punishment” | AMBIGUOUS | Demurrer-as-acquittal rule is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0014 | III §§14,21 | “a speedy, impartial, and public trial” | AMBIGUOUS | Effect of requested speedy-trial dismissal is absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0015 | III §22 | “No ex post facto law or bill of attainder shall be enacted.” | AMBIGUOUS | Definitions needed to exclude both labels are absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0016 | III §18(2) | “except as a punishment for a crime whereof the party shall have been duly convicted” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0017 | III §19(1) | “unless, for compelling reasons involving heinous crimes, the Congress hereafter provides for it” | AMBIGUOUS | Key depends on RA 9346, absent here. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0018 | III §21 | “for the same offense” | AMBIGUOUS | RPC Article 6 and Rule 117 are absent. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0019 | III §19(1)–(2) | “nor cruel, degrading or inhuman punishment inflicted” | KEY OK | Evidence-checking answer fits stated protection. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0020 | III §18(1) | “No person shall be detained solely by reason of his political beliefs and aspirations.” | KEY OK | Effects follow from supplied facts. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0001 | III §9 | “without just compensation” | AMBIGUOUS | Text gives no valuation definition. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0002 | III §13 | “bailable by sufficient sureties” | AMBIGUOUS | Text does not define sureties' undertaking. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0003 | III §13 | “released on recognizance as may be provided by law” | AMBIGUOUS | Undertaking versus bond definition is absent. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0004 | III §11 | “Free access to the courts and quasi-judicial bodies” | KEY OK | Poverty cannot justify denial. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0005 | III §11 | “and adequate legal assistance shall not be denied to any person by reason of poverty” | KEY OK | Separate legal-help protection matches. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0006 | III §12(1) | “Any person under investigation for the commission of an offense” | AMBIGUOUS | Significant-restraint test is absent. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0007 | III §12(1) | “competent and independent counsel” | KEY OK | Investigators' control defeats independence. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0008 | III §12(1) | “cannot be waived except in writing and in the presence of counsel” | KEY OK | Oral waiver fails. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0009 | III §12(2) | “Secret detention places, solitary, incommunicado, or other similar forms of detention are prohibited.” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0010 | III §10 | “No law impairing the obligation of contracts shall be passed.” | AMBIGUOUS | Public-welfare qualification needs another source. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0011 | III §9 | “Private property shall not be taken for public use without just compensation.” | KEY OK | Mere regulation does not establish taking. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0012 | III §12(3) | “Any confession or admission obtained in violation of this or Section 17 hereof shall be inadmissible” | KEY OK | Admissions are expressly included. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0013 | III §17 | “No person shall be compelled to be a witness against himself.” | KEY OK | Not limited to full confessions. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0014 | III §13 | “offenses punishable by reclusion perpetua when evidence of guilt is strong” | KEY OK | Both conditions are required. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0015 | III §13 | “The right to bail shall not be impaired”; “Excessive bail shall not be required.” | KEY OK | Both protections remain. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0001 | III §16 | “before all judicial, quasi-judicial, or administrative bodies” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0002 | III §14(2) | “to be informed of the nature and cause of the accusation against him” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0003 | III §14(2) | “the right to be heard by himself and counsel” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0004 | III §14(2) | “compulsory process to secure the attendance of witnesses and the production of evidence in his behalf” | KEY OK | Matches. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0005 | III §14(2) | “a speedy, impartial, and public trial” | AMBIGUOUS | Permitted attendance restrictions are not stated. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0006 | III §14(2) | “a speedy, impartial, and public trial” | KEY OK | Favoritism conflicts with impartiality. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0007 | III §14(2) | “to meet the witnesses face to face” | AMBIGUOUS | Cross-examination entitlement needs interpretive authority. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0008 | III §14(2) | “Provided, that he has been duly notified and his failure to appear is unjustifiable.” | KEY OK | Missing notice defeats the stated rule. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0009 | III §14(2) | “after arraignment, trial may proceed notwithstanding the absence of the accused” | KEY OK | Conditions met; innocence presumption remains. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0010 | III §15 | “except in cases of invasion or rebellion, when the public safety requires it” | KEY OK | Paperwork is insufficient. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0011 | III §15 | “except in cases of invasion or rebellion, when the public safety requires it” | KEY OK | Storm alone is insufficient. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0012 | III §14(2) | “a speedy, impartial, and public trial” | AMBIGUOUS | Four-factor delay test is absent. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0013 | III §§14,16 | “In all criminal prosecutions”; “all judicial, quasi-judicial, or administrative bodies” | KEY OK | Coverage distinction matches. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0014 | III §16 | “before all judicial, quasi-judicial, or administrative bodies” | KEY OK | Body is covered; facts still need assessment. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0015 | III §17 | “No person shall be compelled to be a witness against himself.” | KEY OK | Protection is not limited to accused persons. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0016 | III §17 | “No person shall be compelled to be a witness against himself.” | AMBIGUOUS | Written-testimony versus physical-evidence doctrine is absent. |

## Law text, part 2
| q-philippine-constitution-the-three-branches-and-their-powers-0001 | VI §§2,4 | “No Senator shall serve for more than two consecutive terms.” | KEY OK | 24 elected at large; six-year terms. |
| q-philippine-constitution-the-three-branches-and-their-powers-0002 | VI §§5,7 | “shall constitute twenty per centum of the total number of representatives” | AMBIGUOUS | Key right. Ceiling and unfilled-seat claims need another source. |
| q-philippine-constitution-the-three-branches-and-their-powers-0003 | VI §24 | “shall originate exclusively in the House of Representatives” | KEY OK | Senate amendments expressly allowed. |
| q-philippine-constitution-the-three-branches-and-their-powers-0004 | VII §§4,8 | “has served as such for more than four years” | KEY OK | Five-year successor cannot later be elected President. |
| q-philippine-constitution-the-three-branches-and-their-powers-0005 | VII §19 | “after conviction by final judgment” | KEY OK | Amnesty needs majority concurrence of all Congress Members. |
| q-philippine-constitution-the-three-branches-and-their-powers-0006 | VI §6 | “a resident thereof for a period of not less than one year” | KEY OK | Eight months fails district residence. |
| q-philippine-constitution-the-three-branches-and-their-powers-0007 | VI §3 | “unless he is a natural-born citizen of the Philippines” | KEY OK | Naturalized status fails. |
| q-philippine-constitution-the-three-branches-and-their-powers-0008 | VII §§2,3 | “the same qualifications and term of office” | KEY OK | Vice-President also needs ten years of residence. |
| q-philippine-constitution-the-three-branches-and-their-powers-0009 | VII §16; VIII §§9,11 | “from a list of at least three nominees” | KEY OK | Ambassador needs consent; judges need no confirmation. |
| q-philippine-constitution-the-three-branches-and-their-powers-0010 | VIII §7 | “at least forty years of age” | KEY OK | Key also meets natural-born and 15-year requirements. |
| q-philippine-constitution-the-three-branches-and-their-powers-0011 | IX-C §1(1) | “a majority thereof, including the Chairman” | KEY OK | Chair must be among qualified lawyers. |
| q-philippine-constitution-the-three-branches-and-their-powers-0012 | IX-D §1(1) | “At no time shall all Members of the Commission belong to the same profession.” | KEY OK | Eleven-year lawyer meets both rules. |
| q-philippine-constitution-the-three-branches-and-their-powers-0013 | XI §§8,11 | “must not have been candidates for any elective office in the immediately preceding election” | KEY OK | Prior candidacy bars appointment. |
| q-philippine-constitution-the-three-branches-and-their-powers-0014 | VIII §4(1)-(2) | “shall be heard by the Supreme Court en banc” | KEY OK | Chief Justice plus 14 associates equals 15. |
| q-philippine-constitution-the-three-branches-and-their-powers-0015 | VII §18 | “for a period not exceeding sixty days” | KEY OK | Report required within 48 hours. |
| q-philippine-constitution-the-three-branches-and-their-powers-0016 | VII §18 | “voting jointly, by a vote of at least a majority of all its Members” | KEY OK | Citizen may also seek Supreme Court review. |
| q-philippine-constitution-the-three-branches-and-their-powers-0017 | VII §21 | “at least two-thirds of all the Members of the Senate” | KEY OK | 16 required; 15 insufficient. |
| q-philippine-constitution-the-three-branches-and-their-powers-0018 | VI §27(1) | “approved by two-thirds of all the Members of that House” | KEY OK | House passes threshold; Senate fails. |
| q-philippine-constitution-the-three-branches-and-their-powers-0019 | VI §23(1); VII §18 | “two-thirds of both Houses in joint session assembled, voting separately” | KEY OK | President commands armed forces. |
| q-philippine-constitution-the-three-branches-and-their-powers-0020 | VI §§21,24,25(1) | “may not increase the appropriations recommended by the President” | KEY OK | Published rules and rights also required. |
| q-philippine-constitution-the-three-branches-and-their-powers-0021 | VII §§1,17; VIII §1 | “He shall ensure that the laws be faithfully executed.” | KEY OK | Courts settle actual legal controversies. |
| q-philippine-constitution-the-three-branches-and-their-powers-0022 | VI §27(1) | “he shall veto it and return the same with his objections” | KEY OK | Provision also permits congressional override. |
| q-philippine-constitution-the-three-branches-and-their-powers-0023 | VIII §1 | “grave abuse of discretion amounting to lack or excess of jurisdiction” | KEY OK | Applies to government branches and instrumentalities. |
| q-philippine-constitution-the-three-branches-and-their-powers-0024 | VIII §7 | “Supreme Court or any lower collegiate court unless he is a natural-born citizen” | KEY OK | Congress sets further lower-court qualifications. |
| q-philippine-constitution-the-three-branches-and-their-powers-0025 | VII §3 | “Such appointment requires no confirmation.” | KEY OK | Express Cabinet exception for Vice-President. |
| q-philippine-constitution-the-civil-service-commission-0001 | IX-B §1(1) | “composed of a Chairman and two Commissioners” | KEY OK | Composition matches. |
| q-philippine-constitution-the-civil-service-commission-0002 | IX-B §1(1) | “shall be natural-born citizens of the Philippines” | KEY OK | Citizenship category matches. |
| q-philippine-constitution-the-civil-service-commission-0003 | IX-B §1(1) | “at least thirty-five years of age” | KEY OK | Measured at appointment. |
| q-philippine-constitution-the-civil-service-commission-0004 | IX-B §1(2) | “appointed by the President with the consent of the Commission on Appointments” | KEY OK | Both roles match. |
| q-philippine-constitution-the-civil-service-commission-0005 | IX-B §1(2) | “for a term of seven years without reappointment” | KEY OK | Regular term matches. |
| q-philippine-constitution-the-civil-service-commission-0006 | IX-B §1(1) | “candidates for any elective position in the elections immediately preceding their appointment” | KEY OK | Not limited to losing candidates. |
| q-philippine-constitution-the-civil-service-commission-0007 | IX-B heading | “B. THE CIVIL SERVICE COMMISSION” | KEY OK | Heading decides subdivision. |
| q-philippine-constitution-the-civil-service-commission-0008 | IX-B §1(2) | “seven years without reappointment” | KEY OK | Another full term barred. |
| q-philippine-constitution-the-civil-service-commission-0009 | IX-B §1(1) | “with proven capacity for public administration” | KEY OK | Required capacity matches. |
| q-philippine-constitution-the-civil-service-commission-0010 | IX-B §3 | “the central personnel agency of the Government” | KEY OK | Personnel role matches. |
| q-philippine-constitution-the-civil-service-commission-0011 | IX-B §1(2) | “seven years, a Commissioner for five years, and another Commissioner for three years” | KEY OK | Different initial expiration dates. |
| q-philippine-constitution-the-civil-service-commission-0012 | IX-A §5 | “approved annual appropriations shall be automatically and regularly released” | KEY OK | Funding pressure conflicts with release rule. |
| q-philippine-constitution-the-civil-service-commission-0013 | IX-B §1(2) | “with the consent of the Commission on Appointments” | KEY OK | Proposal omits required consent. |
| q-philippine-constitution-the-civil-service-commission-0014 | IX-B §1(1) | “at the time of their appointment” | KEY OK | Appointment is measuring date. |
| q-philippine-constitution-the-civil-service-commission-0015 | IX-A §1 | “are the Civil Service Commission, the Commission on Elections, and the Commission on Audit” | KEY OK | CSC expressly listed. |
| q-philippine-constitution-the-civil-service-commission-0016 | IX-B §1(1) | “a Chairman and two Commissioners” | KEY OK | Three total members. |
| q-philippine-constitution-the-civil-service-commission-0017 | IX-B §1(1) | “must not have been candidates for any elective position” | KEY OK | Other qualifications do not waive candidacy rule. |
| q-philippine-constitution-the-civil-service-commission-0018 | IX-B §1(1) | “at the time of their appointment, at least thirty-five years of age” | KEY OK | Age 34 fails. |
| q-philippine-constitution-the-civil-service-commission-0019 | IX-B §1(1) | “proven capacity for public administration” | KEY OK | Satisfies this requirement alone. |
| q-philippine-constitution-the-civil-service-commission-0020 | IX-B §3 | “the central personnel agency of the Government” | KEY OK | Does not confer other branches’ powers. |
| q-philippine-constitution-the-civil-service-commission-0021 | IX-B §2(1); XII §16 | “government-owned or controlled corporations with original charters” | KEY OK | XII §16 supports special-charter explanation. |
| q-philippine-constitution-the-civil-service-commission-0022 | IX-B §2(1) | “all branches, subdivisions, instrumentalities, and agencies of the Government” | KEY OK | Coverage extends beyond executive offices. |
| q-philippine-constitution-the-civil-service-commission-0023 | IX-A §2 | “Neither shall he engage in the practice of any profession” | KEY OK | Private legal practice barred during tenure. |
| q-philippine-constitution-the-civil-service-commission-0024 | IX-B §2(2) | “Appointments in the civil service shall be made only according to merit and fitness” | KEY OK | Exam success does not exhaust the rule. |
| q-philippine-constitution-the-civil-service-commission-0025 | IX-B §2(2) | “except to positions which are policy-determining” | KEY OK | Exception concerns competitive examinations. |
| q-philippine-constitution-the-civil-service-commission-0026 | IX-B §2(3) | “removed or suspended except for cause provided by law” | KEY OK | Lawful discipline remains possible. |
| q-philippine-constitution-the-civil-service-commission-0027 | IX-B §2(4); V §1 | “electioneering or partisan political campaign” | KEY OK | Campaign restriction does not itself prohibit voting. |
| q-philippine-constitution-accountability-and-impeachment-0001 | XI heading | “ACCOUNTABILITY OF PUBLIC OFFICERS” | KEY OK | Article title matches. |
| q-philippine-constitution-accountability-and-impeachment-0002 | XI §1 | “Public office is a public trust.” | KEY OK | Accountability explanation matches. |
| q-philippine-constitution-accountability-and-impeachment-0003 | XI §2 | “and the Ombudsman may be removed from office on impeachment” | KEY OK | Other choices absent from list. |
| q-philippine-constitution-accountability-and-impeachment-0004 | XI §2 | “All other public officers and employees may be removed from office as provided by law” | KEY OK | Senators excluded from impeachment list. |
| q-philippine-constitution-accountability-and-impeachment-0005 | XI §2 | “or betrayal of public trust” | KEY OK | Exact listed ground. |
| q-philippine-constitution-accountability-and-impeachment-0006 | XI §2 | “treason, bribery, graft and corruption, other high crimes, or betrayal of public trust” | KEY OK | Inefficiency not expressly listed. |
| q-philippine-constitution-accountability-and-impeachment-0007 | XI §2; IX-A §1 | “the Members of the Constitutional Commissions” | KEY OK | IX-A identifies CSC, COMELEC, COA. |
| q-philippine-constitution-accountability-and-impeachment-0008 | XI §2 | “the Members of the Supreme Court” | KEY OK | Trial-court judges excluded. |
| q-philippine-constitution-accountability-and-impeachment-0009 | XI §1 | “be accountable to the people” | KEY OK | Public service fits standard. |
| q-philippine-constitution-accountability-and-impeachment-0010 | XI §2 | “treason, bribery, graft and corruption” | AMBIGUOUS | Bribery is listed but not defined; payment test needs another source. |
| q-philippine-constitution-accountability-and-impeachment-0011 | XI §2 | “treason, bribery, graft and corruption” | AMBIGUOUS | Text does not define treason’s wartime or enemy-aid elements. |
| q-philippine-constitution-accountability-and-impeachment-0012 | XI §2 | “the Members of the Constitutional Commissions, and the Ombudsman” | KEY OK | Five categories under stated grouping. |
| q-philippine-constitution-accountability-and-impeachment-0013 | XI §2 | “culpable violation of the Constitution, treason, bribery, graft and corruption” | KEY OK | Six grounds with stated grouping. |
| q-philippine-constitution-accountability-and-impeachment-0014 | XI §2 | “the Members of the Supreme Court” | KEY OK | Express inclusion. |
| q-philippine-constitution-accountability-and-impeachment-0015 | XI §2 | “culpable violation of the Constitution” | AMBIGUOUS | Text names ground but does not define willful-intent test. |
| q-philippine-constitution-accountability-and-impeachment-0016 | XI §2 | “may be removed from office as provided by law, but not by impeachment” | KEY OK | Other lawful removal remains available. |
| q-philippine-constitution-accountability-and-impeachment-0017 | XI §2 | “other high crimes, or betrayal of public trust” | KEY OK | Unpopularity is not a named ground. |
| q-philippine-constitution-accountability-and-impeachment-0018 | XI §2 | “the Members of the Supreme Court” | KEY OK | Court of Appeals not included. |
| q-philippine-constitution-accountability-and-impeachment-0019 | XI §1 | “act with patriotism and justice, and lead modest lives” | KEY OK | Conduct matches required standards. |
| q-philippine-constitution-accountability-and-impeachment-0020 | XI §2 | “on impeachment for, and conviction of” | KEY OK | Provision limits both offices and grounds. |
| q-philippine-constitution-accountability-and-impeachment-0021 | XI §§2,3(6) | “The Senate shall have the sole power to try and decide all cases of impeachment.” | KEY OK | Naming a ground is not conviction. |
| q-philippine-constitution-accountability-and-impeachment-0022 | XI §2 | “graft and corruption” | AMBIGUOUS | Text does not define improper contract benefit as this ground. |
| q-philippine-constitution-accountability-and-impeachment-0023 | XI §3(4) | “the same shall constitute the Articles of Impeachment” | KEY OK | One-third direct filing triggers Senate trial. |
| q-philippine-constitution-accountability-and-impeachment-0024 | XI §3(2)-(3) | “by any citizen upon a resolution or endorsement by any Member thereof” | KEY OK | Committee and House route applies. |
| q-philippine-constitution-accountability-and-impeachment-0025 | XI §3(6) | “shall preside, but shall not vote” | KEY OK | Conviction requires two-thirds of all Senators. |
| q-philippine-constitution-accountability-and-impeachment-0026 | XI §3(7) | “liable and subject to prosecution, trial, and punishment, according to law” | KEY OK | Separate criminal prosecution remains possible. |
| q-philippine-constitution-accountability-and-impeachment-0027 | XI §13(1) | “Investigate on its own, or on complaint by any person” | KEY OK | Complaint is not mandatory. |
| q-philippine-constitution-accountability-and-impeachment-0028 | XI §13(2) | “to perform and expedite any act or duty required by law” | KEY OK | Directly addresses unfinished duty. |
| q-philippine-constitution-citizenship-and-suffrage-0001 | IV §1(4) | “Those who are naturalized in the accordance with law.” | AMBIGUOUS | Key supported; CA 473 marriage claims cannot be checked here. |
| q-philippine-constitution-citizenship-and-suffrage-0002 | IV §2 | “from birth without having to perform any act to acquire or perfect their Philippine citizenship” | KEY OK | Stem preserves election exception. |
| q-philippine-constitution-citizenship-and-suffrage-0003 | IV §4 | “Citizens of the Philippines who marry aliens shall retain their citizenship” | KEY OK | Stem excludes renunciation exception. |
| q-philippine-constitution-citizenship-and-suffrage-0004 | V §1 | “at least eighteen years of age” | KEY OK | Minimum age is 18. |
| q-philippine-constitution-citizenship-and-suffrage-0005 | V §1 | “No literacy, property, or other substantive requirement shall be imposed” | KEY OK | Land ownership requirement forbidden. |
| q-philippine-constitution-citizenship-and-suffrage-0006 | IV §§1(2),2 | “Those whose fathers or mothers are citizens of the Philippines” | KEY OK | Parentage establishes citizenship from birth. |
| q-philippine-constitution-citizenship-and-suffrage-0007 | IV §2 | “shall be deemed natural-born citizens” | KEY OK | Expressly covers proper §1(3) election. |
| q-philippine-constitution-citizenship-and-suffrage-0008 | IX-B §1(1); IV §2 | “shall be natural-born citizens of the Philippines” | KEY OK | Naturalization does not meet CSC requirement. |
| q-philippine-constitution-citizenship-and-suffrage-0009 | IV §3 | “may be lost or reacquired in the manner provided by law” | KEY OK | Both governed by law. |
| q-philippine-constitution-citizenship-and-suffrage-0010 | IV §3 | “in the manner provided by law” | AMBIGUOUS | RA 9225 oath requirement absent from supplied text. |
| q-philippine-constitution-citizenship-and-suffrage-0011 | V §1 | “at least one year”; “at least six months immediately preceding the election” | KEY OK | Age and both residence minimums met. |
| q-philippine-constitution-citizenship-and-suffrage-0012 | V §1 | “for at least six months immediately preceding the election” | KEY OK | Four local months insufficient. |
| q-philippine-constitution-citizenship-and-suffrage-0013 | V §2 | “securing the secrecy and sanctity of the ballot” | KEY OK | Forced disclosure conflicts with secrecy. |
| q-philippine-constitution-citizenship-and-suffrage-0014 | V §2 | “a system for absentee voting by qualified Filipinos abroad” | AMBIGUOUS | Constitutional duty supported; cited statutes and registration rules absent. |
| q-philippine-constitution-citizenship-and-suffrage-0015 | IV §3 | “in the manner provided by law” | AMBIGUOUS | RA 8171 classes, oath, registration, exclusions absent. |
| q-philippine-constitution-citizenship-and-suffrage-0016 | IV §5 | “Dual allegiance of citizens is inimical to the national interest” | AMBIGUOUS | Voluntary-loyalty definition and distinction not supplied. |
| q-philippine-constitution-citizenship-and-suffrage-0017 | V §2 | “Until then, they shall be allowed to vote under existing laws” | KEY OK | Interim voting and independent procedure both required. |
| q-philippine-constitution-citizenship-and-suffrage-0018 | IV §3 | “in the manner provided by law” | AMBIGUOUS | RA 9225 personal renunciation and filing deadline absent. |
| q-philippine-constitution-citizenship-and-suffrage-0019 | V §1 | “at least eighteen years of age” | AMBIGUOUS | Advance registration under RA 8189 cannot be decided here. |
| q-philippine-constitution-citizenship-and-suffrage-0020 | IV §§1(2),2; V §1 | “at least eighteen years of age” | EXPLANATION WRONG | Says “over eighteen”; stem permits exactly eighteen. Key right. |
| q-philippine-constitution-citizenship-and-suffrage-0021 | IV §1(4) | “Those who are naturalized in the accordance with law.” | AMBIGUOUS | RA 9139 and CA 473 age rules absent. |
| q-philippine-constitution-the-articles-in-outline-0001 | I–XVIII headings | “ARTICLE XVIII” | KEY OK | Eighteen numbered articles; Preamble unnumbered. |
| q-philippine-constitution-the-articles-in-outline-0002 | III heading | “BILL OF RIGHTS” | KEY OK | Article III, not IV. |
| q-philippine-constitution-the-articles-in-outline-0003 | IV heading | “CITIZENSHIP” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0004 | V heading | “SUFFRAGE” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0005 | VII heading | “EXECUTIVE DEPARTMENT” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0006 | IX heading; IX-A §1 | “CONSTITUTIONAL COMMISSION” | KEY OK | Article covers common rules and three commissions. |
| q-philippine-constitution-the-articles-in-outline-0007 | X heading | “LOCAL GOVERNMENT” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0008 | XI heading | “ACCOUNTABILITY OF PUBLIC OFFICERS” | KEY OK | Article XI is correct. |
| q-philippine-constitution-the-articles-in-outline-0009 | XIV heading | “EDUCATION, SCIENCE AND TECHNOLOGY, ARTS, CULTURE AND SPORTS” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0010 | XVII heading | “AMENDMENTS OR REVISIONS” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0011 | VIII heading | “JUDICIAL DEPARTMENT” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0012 | XII heading | “NATIONAL ECONOMY AND PATRIMONY” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0013 | XV heading | “THE FAMILY” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0014 | I heading | “NATIONAL TERRITORY” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0015 | VI heading | “THE LEGISLATIVE DEPARTMENT” | KEY OK | Heading matches. |
| q-philippine-constitution-the-articles-in-outline-0016 | IX-A heading | “A. COMMON PROVISIONS” | KEY OK | B, C, D name the commissions. |
| q-philippine-constitution-the-articles-in-outline-0017 | Preamble, no section | “a Government that shall embody our ideals and aspirations” | KEY OK | States purposes and aspirations. |
| q-philippine-constitution-the-articles-in-outline-0018 | VI–VIII headings | “THE LEGISLATIVE DEPARTMENT”; “EXECUTIVE DEPARTMENT”; “JUDICIAL DEPARTMENT” | KEY OK | Sequence matches. |
| q-philippine-constitution-the-articles-in-outline-0019 | XVIII heading | “TRANSITORY PROVISIONS” | KEY OK | Final numbered article. |
| q-philippine-constitution-the-articles-in-outline-0020 | VI §24 | “shall originate exclusively in the House of Representatives” | KEY OK | Specific rule controls revenue bills. |
| q-philippine-constitution-the-articles-in-outline-0021 | II §15 | “protect and promote the right to health of the people” | KEY OK | Policy contains no complete operating procedure. |
| q-philippine-constitution-the-articles-in-outline-0022 | XIII §18(1) | “human rights violations involving civil and political rights” | KEY OK | CHR investigation power located correctly. |
| q-philippine-constitution-the-articles-in-outline-0023 | XVI §1 | “red, white, and blue, with a sun and three stars” | KEY OK | Flag description matches. |

## Sources beyond the Constitution's text
| q-philippine-constitution-bill-of-rights-0006 | Salas v Bunyi-Medina, G.R.251693 | [Source](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/1/66992) | “relieve a person therefrom if such restraint is illegal” | SOURCE OK | Writ tests custody. |
| q-philippine-constitution-bill-of-rights-0009 | Abella v CSC, G.R.152574 | [Source](https://lawphil.net/judjuris/juri2004/nov2004/gr_152574_2004.html) | “innocent when done” | SOURCE OK | Retroactive criminalization. |
| q-philippine-constitution-bill-of-rights-0010 | Abella v CSC, G.R.152574 | [Source](https://lawphil.net/judjuris/juri2004/nov2004/gr_152574_2004.html) | “without judicial trial” | SOURCE OK | Legislative punishment. |
| q-philippine-constitution-bill-of-rights-0012 | People v Chavez, G.R.207950 | [Source](https://lawphil.net/judjuris/juri2014/sep2014/gr_207950_2014.html) | “Miranda rights” | SOURCE OK | Label supported. |
| q-philippine-constitution-bill-of-rights-0023 | CBEA v BSP, G.R.148208 | [Source](https://lawphil.net/judjuris/juri2004/dec2004/gr_148208_2004.html) | “must be germane to the purposes of the law” | SOURCE OK | Unrelated distinction fails. |
| q-philippine-constitution-bill-of-rights-0025 | People v Cogaed, G.R.200334 | [Source](https://lawphil.net/judjuris/juri2014/jul2014/gr_200334_2014.html) | “knowing, intelligent, and free from any coercion” | SOURCE OK | Submission is insufficient. |
| q-philippine-constitution-bill-of-rights-0027 | Rule112 §6(a) | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “personally evaluate” | SOURCE OK | Independent record review suffices. |
| q-philippine-constitution-bill-of-rights-0028 | Rule113 §5(b) | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “just been committed” | SOURCE OK | Both conditions absent. |
| q-philippine-constitution-bill-of-rights-0033 | Abella v CSC, G.R.152574 | [Source](https://lawphil.net/judjuris/juri2004/nov2004/gr_152574_2004.html) | “greater punishment” | SOURCE OK | Both definitions match. |
| q-philippine-constitution-bill-of-rights-0034 | Rules113 §5(a),126 §13 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “in his presence” | SOURCE OK | Arrest and search lawful. |
| q-philippine-constitution-bill-of-rights-0036 | Rule126 §13 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “dangerous weapons” | SOURCE OK | No unlimited search authority. |
| q-philippine-constitution-bill-of-rights-0037 | Rule113 §5(b) | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “personal knowledge” | SOURCE OK | Prompt action alone insufficient. |
| q-philippine-constitution-bill-of-rights-0043 | Rule117 §7 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “pleaded” | SOURCE OK | Filing alone insufficient. |
| q-philippine-constitution-bill-of-rights-0044 | Abella v CSC, G.R.152574 | [Source](https://lawphil.net/judjuris/juri2004/nov2004/gr_152574_2004.html) | “inflicts punishment on individuals” | SOURCE OK | Both prohibitions apply. |
| q-philippine-constitution-amending-and-revising-the-constitution-0002 | Lambino v COMELEC, G.R.174153 | [Source](https://lawphil.net/judjuris/juri2006/oct2006/gr_174153_2006.html) | “without altering the basic principle involved” | SOURCE OK | Amendment defined correctly. |
| q-philippine-constitution-amending-and-revising-the-constitution-0003 | Lambino v COMELEC, G.R.174153 | [Source](https://lawphil.net/judjuris/juri2006/oct2006/gr_174153_2006.html) | “A change in the structure of government is a revision” | SOURCE OK | Qualitative test applies. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0002 | Rule102 §1; Act4103 §1 | [Writ](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/1/66992) [Parole](https://lawphil.net/statutes/acts/act1933/act_4103_1933.html) | “minimum sentence” | SOURCE OK | Writ and parole distinguished. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0004 | RA9346 §§1–2 | [Source](https://lawphil.net/statutes/repacts/ra2006/ra_9346_2006.html) | “reclusion perpetua” | SOURCE OK | Nomenclature controls. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0005 | RA9346 §3 | [Source](https://lawphil.net/statutes/repacts/ra2006/ra_9346_2006.html) | “shall not be eligible for parole” | SOURCE OK | Restriction applies. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0007 | Rule117 §7 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “pleaded” | SOURCE OK | No plea, no attachment. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0008 | Rule117 §7 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “necessarily included” | SOURCE OK | Homicide included in murder. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0010 | Rule117 §7(a) | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “supervening facts” | SOURCE OK | Later death permits graver charge. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0011 | Abella v CSC, G.R.152574 | [Source](https://lawphil.net/judjuris/juri2004/nov2004/gr_152574_2004.html) | “less or different testimony” | SOURCE OK | Lower proof retroactively barred. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0012 | Rule117 §7 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “express consent” | SOURCE OK | General requested-dismissal rule. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0013 | Aytona v Paule, G.R.253649 | [Source](https://lawphil.net/judjuris/juri2022/nov2022/gr_253649_2022.html) | “insufficiency of evidence” | SOURCE OK | Granted demurrer is acquittal. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0014 | Aytona v Paule, G.R.253649 | [Source](https://lawphil.net/judjuris/juri2022/nov2022/gr_253649_2022.html) | “denial of the right to a speedy trial” | SOURCE OK | Requested dismissal still bars retrial. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0015 | Abella v CSC, G.R.152574 | [Source](https://lawphil.net/judjuris/juri2004/nov2004/gr_152574_2004.html) | “before the passing of the law” | SOURCE OK | Prospective law; judicial trial. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0017 | RA9346 §1 | [Source](https://lawphil.net/statutes/repacts/ra2006/ra_9346_2006.html) | “The imposition of the penalty of death is hereby prohibited.” | SOURCE OK | Statute controls. |
| q-philippine-constitution-bill-of-rights-punishment-detention-and-limits-on-laws-0018 | RPC Art6; Rule117 §7 | [RPC](https://lawphil.net/statutes/acts/act1930/act_3815_1930.html) [Rules](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “all the acts of execution” | SOURCE OK | Stage definitions match. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0001 | Heirs of Dimao v NGCP, G.R.254020 | [Source](https://lawphil.net/judjuris/juri2023/mar2023/gr_254020_2023.html) | “full and fair equivalent” | SOURCE OK | Definition matches. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0002 | Rule114 §§1–2 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “appearance” | SOURCE OK | Sureties guarantee appearance. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0003 | RA10389 §§3,6 | [Source](https://lawphil.net/statutes/repacts/ra2013/ra_10389_2013.html) | “unable to post bail” | SOURCE OK | Lawful recognizance release. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0006 | People v Marra, G.R.108494 | [Source](https://lawphil.net/judjuris/juri1994/sep1994/gr_108494_1994.html) | “deprived of his freedom of action in any significant way” | SOURCE OK | Restraint triggers safeguards. |
| q-philippine-constitution-bill-of-rights-property-courts-and-custody-0010 | Sangalang v IAC, G.R.L-71169 | [Source](https://lawphil.net/judjuris/juri1988/dec1988/gr_l-71169_1988.html) | “reconciled with the legitimate exercise of police power” | SOURCE OK | Validity needs examination. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0005 | Rule119 §21 | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “public morals” | SOURCE OK | Lawful exclusions allowed. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0007 | Rule115 §1(f) | [Source](https://lawphil.net/courts/rules/rc_110-127_crim.html) | “cross-examine” | SOURCE OK | Questioning witnesses protected. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0012 | Aytona v Paule, G.R.253649 | [Source](https://lawphil.net/judjuris/juri2022/nov2022/gr_253649_2022.html) | “the length of delay” | SOURCE OK | All four factors match. |
| q-philippine-constitution-bill-of-rights-the-accused-and-the-trial-0016 | People v Ang, G.R.231854 | [Source](https://lawphil.net/judjuris/juri2020/oct2020/gr_231854_2020.html) | “Being communicative” | SOURCE OK | Forced account is testimonial. |
| q-philippine-constitution-the-three-branches-and-their-powers-0002 | BANAT v COMELEC, G.R.179271 | [Source](https://lawphil.net/judjuris/juri2009/jul2009/gr_179271_2009.html) | “The filling-up of all available party-list seats is not mandatory.” | SOURCE OK | 20% is maximum; key unchanged. |
| q-philippine-constitution-accountability-and-impeachment-0010 | RPC Art210 | [Source](https://lawphil.net/statutes/acts/act1930/act_3815_1930b.html) | “offer, promise, gift or present” | SOURCE OK | Bribery label fits. |
| q-philippine-constitution-accountability-and-impeachment-0011 | RPC Art114 | [Source](https://lawphil.net/statutes/acts/act1930/act_3815_1930b.html) | “adheres to her enemies, giving them aid or comfort” | SOURCE OK | Treason scenario fits. |
| q-philippine-constitution-accountability-and-impeachment-0015 | Republic v Sereno, G.R.237428 (Carpio dissent) | [Source](https://lawphil.net/judjuris/juri2018/may2018/gr_237428_so_2018.html) | “willful and intentional violation” | SOURCE OK | Quotes framers; not majority holding. |
| q-philippine-constitution-accountability-and-impeachment-0022 | RA3019 §3(e) | [Source](https://lawphil.net/statutes/repacts/ra1960/ra_3019_1960.html) | “unwarranted benefits, advantage or preference” | SOURCE OK | Improper benefit fits. |
| q-philippine-constitution-citizenship-and-suffrage-0001 | Republic v Batugas, G.R.183110; CA473 §15 | [Source](https://lawphil.net/judjuris/juri2013/oct2013/gr_183110_2013.html) | “not disqualified” | SOURCE OK | Alien-wife qualification supported. |
| q-philippine-constitution-citizenship-and-suffrage-0010 | RA9225 §3 | [Source](https://lawphil.net/statutes/repacts/ra2003/ra_9225_2003.html) | “upon taking the following oath of allegiance” | SOURCE OK | Oath required. |
| q-philippine-constitution-citizenship-and-suffrage-0014 | RA9189 §§4–6, amended by RA10590 §§3–5 | [Source](https://lawphil.net/statutes/repacts/ra2013/ra_10590_2013.html) | “qualified to register and vote” | SOURCE OK | Eligibility and registration required. |
| q-philippine-constitution-citizenship-and-suffrage-0015 | RA8171 §§1–2 | [Source](https://lawphil.net/statutes/repacts/ra1995/ra_8171_1995.html) | “Filipino women who have lost their Philippine citizenship by marriage to aliens” | SOURCE OK | Class, oath, registration supported. |
| q-philippine-constitution-citizenship-and-suffrage-0016 | Mercado v Manzano, G.R.135083 | [Source](https://lawphil.net/judjuris/juri1999/may1999/gr_135083_1999.html) | “dual allegiance is the result of an individual's volition” | SOURCE OK | Birth citizenships alone insufficient. |
| q-philippine-constitution-citizenship-and-suffrage-0018 | RA9225 §5(2) | [Source](https://lawphil.net/statutes/repacts/ra2003/ra_9225_2003.html) | “at the time of the filing of the certificate of candidacy” | SOURCE OK | Personal sworn renunciation required. |
| q-philippine-constitution-citizenship-and-suffrage-0019 | RA8189 §§9–10 | [Source](https://lawphil.net/statutes/repacts/ra1996/ra_8189_1996.html) | “on the day of the election shall possess such qualifications” | SOURCE OK | Advance registration allowed. |
| q-philippine-constitution-citizenship-and-suffrage-0021 | RA9139 §3(a–b); CA473 §2 | [RA9139](https://lawphil.net/statutes/repacts/ra2001/ra_9139_2001.html) [CA473](https://lawphil.net/statutes/comacts/ca_473_1939.html) | “eighteen (18) years of age” | SOURCE OK | 18 at filing; 21 at hearing. |
