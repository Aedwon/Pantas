# Data Interpretation answer verification (bite-sized pilot)

Date: Nov 14, 2026. Content: `content/bite-sized-pilot` after ec9ac28c1, plus the lead's wording fix to
q-data-interpretation-tables-and-charts-0008 ("attended" replaced by "did ... have", because the table
gives applicant counts, not attendance; the solve below is on applicant counts).
Checker: separate Codex job (GPT 6.1 Sol, medium, read-only), not the writer. It solved each question
from the stem and choices before reading the key. A first run that gave only a summary was rejected
and rerun.
Result: 52 questions, 52 agree, 0 disagree. Flags: 18 with a tied-longest correct choice (allowed:
the rule forbids the correct choice being the single longest); 1 wording defect (0008, fixed).
Approved by the lead with `tool/content/approve.dart`.

## Checker table (verbatim)

| id | Your answer (choice text) | Keyed answer | Result | Working before key | Flags |
|---|---|---|---|---|---|
| q-data-interpretation-rates-ratios-and-percentages-in-context-0001 | 25% | 25% | AGREE | (50−40)/40×100=25% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0002 | 2:3 | 2:3 | AGREE | 50:75=2:3 | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0003 | 15% | 15% | AGREE | 1200/8000×100=15% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0004 | 9:46 | 9:46 | AGREE | 3600:(22000−3600)=3600:18400=9:46 | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0005 | 8⅓ points | 8⅓ points | AGREE | 30/120×100−30/180×100=8⅓ | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0006 | 60% | 60% | AGREE | 180/(120+180)×100=60% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0007 | 28% | 28% | AGREE | (64−50)/50×100=28% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0008 | 2/9 | 2/9 | AGREE | (28−20)/36=8/36=2/9 | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0009 | 2/3 | 2/3 | AGREE | 300/(300+150)=2/3 | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0010 | 35 points | 35 points | AGREE | 450/600×100−200/500×100=35 | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0011 | The motorcycle increase is five times the automobile increase. | Same | AGREE | 1000/200=5 | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0012 | 33.33% | 33.33% | AGREE | 2000/6000×100≈33.33% | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0013 | Undefined: the starting count is zero. | Same | AGREE | (12−0)/0 is undefined | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0014 | Use $80$ as the denominator. | Same | AGREE | (100−80)/80×100=25% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0015 | 40% | 40% | AGREE | (30+10)/(50+50)×100=40% | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0016 | New count is $1.20$ times the old count. | Same | AGREE | N+0.20N=1.20N | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0017 | 20% | 20% | AGREE | 103/498×100≈20.68%; nearest 20% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0018 | 2:1 | 2:1 | AGREE | 1500000:750000=2:1 | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0019 | 25% increase | 25% increase | AGREE | (100−80)/80×100=25% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0020 | 18% | 18% | AGREE | (80×0.10+20×0.50)/100×100=18% | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0021 | 420 pages | 420 pages | AGREE | 315/45×60=420 | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0022 | 6.30 pesos | 6.30 pesos | AGREE | 1260/(8×25)=6.30 | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0023 | 1,470 pesos | 1,470 pesos | AGREE | 840/120×(180+30)=1470 | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0024 | 675 liters | 675 liters | AGREE | 450/12×18=675 | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0025 | 13⅓ hours | 13⅓ hours | AGREE | (8×15−8×5)/6=80/6=13⅓ | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0026 | 3 machines | 3 machines | AGREE | 9×8/6−9=3 | None |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0027 | 48,000 pesos | 48,000 pesos | AGREE | (96000−12000)×4/7=48000 | TL |
| q-data-interpretation-rates-ratios-and-percentages-in-context-0028 | 80 folders | 80 folders | AGREE | 360×(4−2)/9=80 | None |
| q-data-interpretation-tables-and-charts-0001 | 38000 | 38000 | AGREE | 12000+15000+11000=38000 | TL |
| q-data-interpretation-tables-and-charts-0002 | 45000 | 45000 | AGREE | 15000+22000+8000=45000 | TL |
| q-data-interpretation-tables-and-charts-0003 | Region B | Region B | AGREE | A=1350; B=1550; C=1290; B largest | None |
| q-data-interpretation-tables-and-charts-0004 | 360 metric tons | 360 metric tons | AGREE | (450+520+380)−(300+280+410)=360 | None |
| q-data-interpretation-tables-and-charts-0005 | 7 million pesos | 7 million pesos | AGREE | (6+8+5+9)/4=7 | None |
| q-data-interpretation-tables-and-charts-0006 | 7,000,000 pesos | 7,000,000 pesos | AGREE | (21−14)×1000000=7000000 | None |
| q-data-interpretation-tables-and-charts-0007 | 550 | 550 | AGREE | (1500+950+750)−(1200+800+650)=550 | None |
| q-data-interpretation-tables-and-charts-0008 | 1300 | 1300 | AGREE | (1200+1500)−(650+750)=1300 applicants | TL; attendance counts missing |
| q-data-interpretation-tables-and-charts-0009 | 320 | 320 | AGREE | (400+480)−(250+310)=320 | TL |
| q-data-interpretation-tables-and-charts-0010 | 860 | 860 | AGREE | 520+340=860 | None |
| q-data-interpretation-tables-and-charts-0011 | Medical | Medical | AGREE | Medical=15; Surgical=10; Pediatric=10 | None |
| q-data-interpretation-tables-and-charts-0012 | Afternoon | Afternoon | AGREE | Surgical counts: 30,40,20; maximum 40 | None |
| q-data-interpretation-tables-and-charts-0013 | 25000 | 25000 | AGREE | (12+8+5)×1000=25000 | None |
| q-data-interpretation-tables-and-charts-0014 | March to April | March to April | AGREE | Changes: 15,−5,20; maximum 20 | None |
| q-data-interpretation-tables-and-charts-0015 | 23 | 23 | AGREE | 65−18−24=23 | TL |
| q-data-interpretation-tables-and-charts-0016 | 10 | 10 | AGREE | (0+12+18)/3=10 | TL |
| q-data-interpretation-tables-and-charts-0017 | 8000000 pesos | 8000000 pesos | AGREE | (3.2+4.8)×1000000=8000000 | None |
| q-data-interpretation-tables-and-charts-0018 | It represents $240$ visitors. | Same | AGREE | 2.4×100=240 | None |
| q-data-interpretation-tables-and-charts-0019 | Afternoon has the most units. | Same | AGREE | 150>120>90 | None |
| q-data-interpretation-tables-and-charts-0020 | Teams A and C | Teams A and C | AGREE | A=45−30=15; B=10; C=40−25=15 | None |
| q-data-interpretation-tables-and-charts-0021 | 54,000 pesos | 54,000 pesos | AGREE | 360000×(0.40−0.25)=54000 | None |
| q-data-interpretation-tables-and-charts-0022 | 120,000 pesos | 120,000 pesos | AGREE | 480000×(1−0.45−0.30)=120000 | TL |
| q-data-interpretation-tables-and-charts-0023 | 100 applications | 100 applications | AGREE | (3.5−2.5)×100=100 | TL |
| q-data-interpretation-tables-and-charts-0024 | 15,000 liters | 15,000 liters | AGREE | (50−35)×1000=15000 | TL |

Totals: questions 52; agree 52; disagree 0; flagged 18. All 18 have tied-longest choices. One also lacks attendance data. No multiple defensible choices or unrealistic exam-English issues found.
