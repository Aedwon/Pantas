# DCAT and USTET practice mocks

**FAIL end to end.** Both blueprints pass the local content checks. The staging web server cannot fill either paper with its current topic IDs.
Policy read from `origin/main` `4fe2f090f`. Code checked at staging `571eea1aa`, with questions from `d4674574a`.

| Exam and section | Questions / minutes and source | Draw / approved pool by topic |
| --- | --- | --- |
| DCAT Mental Ability | 40 / 40, reported [Chinoy TV][d] | Logical-verbal reasoning 13/81, spatial-abstract reasoning 13/62, verbal logic 14/54 |
| DCAT Reading Comprehension | 15 / 18 Pantas-set, scaled from the reported 25 / 30 [Chinoy TV][d] | Vocabulary 14/21, comprehension skills 1/189. Text types 0/1. |
| DCAT Writing Skills | 40 / 30, reported [Chinoy TV][d] | Grammar and structure 20/226, language application 20/57 |
| DCAT General Mathematics | 45 / 50, reported [Chinoy TV][d] | Arithmetic and number sense 15/187, algebra 15/195, geometry 15/97 |
| DCAT Statistics and Probability | 45 / 50, reported [Chinoy TV][d] | Statistics and probability 22/114, data interpretation 23/28 |
| DCAT Science Proficiency | 50 / 30, reported [Chinoy TV][d] | Earth science and astronomy 12/91, biology 13/138, chemistry 13/164, physics 12/342 |
| USTET Mental Ability | 80 reported [prepPH][u], 30 reported [EdgePrep][ut] | Logical-verbal reasoning 30/61, spatial-abstract reasoning 20/22, verbal logic 30/54 |
| USTET English | 80 reported [prepPH][u], 45 reported [EdgePrep][ut] | Vocabulary 27/50, grammar and structure 26/226, language application 26/57, comprehension skills 1/189 |
| USTET Mathematics | 60 reported [prepPH][u], 45 reported [EdgePrep][ut] | Arithmetic and number sense 10/166, algebra 10/280, geometry 10/168, trigonometry 10/49, statistics and probability 10/114, data interpretation 10/52 |
| USTET Science | 80 reported [prepPH][u], 45 reported [EdgePrep][ut] | Earth science and astronomy 20/217, biology 20/252, chemistry 20/298, physics 20/365 |

- DCAT totals 235 questions / 218 minutes, Pantas-set. The figures come from a 2019 test account. Retakes can leave larger passage draws short. [DLSU admissions][da], [firsthand report][d], [prepPH coverage][dc], [EdgePrep coverage][dt].
- USTET totals 300 questions / 165 minutes from the reported figures. EdgePrep gives a different English count. UST publishes the subtest names. [UST admissions FAQ][ua], [prepPH][u], [EdgePrep][ut].
- Label field is `name`, shown in native preparation and results and in USTET setup. DCAT setup uses a fixed title. Web results use a generic name. Both `sourceNote` fields also carry the label. The app has no dedicated field for it.
- Parser and topic check PASS. A throwaway Dart runner used the real parsers and checker because Flutter test could not bind a loopback socket. The sampler filled 512 papers per exam, including retakes, with no duplicate within a paper.
- Export PASS with all six blueprints on the staging content copy. Full CET-root export stops at a missing fractional distillation illustration credit in the staging exporter. The CET branch's exporter stops at a lesson with no minutes.
- Web sampler FAIL. The compiled sampler rejects both papers with the server's exam-prefixed topic IDs. It fills both with the shared `topic_upcat_*` IDs that the local topic check accepts.

[d]: https://www.chinoy.tv/chinoytips-for-college-entrance-tests/
[da]: https://old.dlsu.edu.ph/admissions/undergraduate/freshmen-procedures/
[dc]: https://prepph.com/blog/dcat-coverage
[dt]: https://edgeprep.ph/dcat-exam-guide
[ua]: https://ustet.ust.edu.ph/
[u]: https://prepph.com/blog/ustet-coverage
[ut]: https://edgeprep.ph/ustet-exam-guide
