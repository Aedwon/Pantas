# Arithmetic and Number Sense answer verification (bite-sized, CSE stream)

Date: Nov 15, 2026. Content: `content/bite-sized-cse-r2d` at ce28126ac. 210 questions (180 existing, 30 new;
2 rewritten because they tested methods the lesson does not teach). All checks were separate Codex jobs
(GPT 6.1 Sol, medium), never the writers.

1. Independent re-solve: 208 agree, 2 disagree; the checker found both were its own arithmetic slips.
   It reported that it saw the explanation before solving 24 questions (including those 2).
2. A separate writer fixed 22 flagged items (fragmentary stems, answer-length clues); keys, ids and tags
   unchanged.
3. Fresh re-solve of the 36 questions that were edited or exposed, with explanations hidden until after
   solving: 36 of 36 agree.
Approved by the lead with `tool/content/approve.dart`.

## First re-solve
| q-arithmetic-number-sense-business-math-0001 | ₱1,000.00 | = | AGREE | 800×1.25=1000 | E |
| q-arithmetic-number-sense-business-math-0002 | Php 115 | = | AGREE | 640×0.25−45=115 | E |
| q-arithmetic-number-sense-business-math-0003 | ₱900.00 | = | AGREE | 15000×0.08×9/12=900 | E,N |
| q-arithmetic-number-sense-business-math-0004 | ₱2,280.00 | = | AGREE | 2400×0.95=2280 | E,N |
| q-arithmetic-number-sense-business-math-0005 | ₱2,800.00 | = | AGREE | 6×400+0.04×10000=2800 | E,N |
| q-arithmetic-number-sense-business-math-0006 | 20% | = | AGREE | (25−20)/25×100=20% | E,N |
| q-arithmetic-number-sense-business-math-0007 | ₱17.40 | = | AGREE | (13+5×1.75)×0.8=17.40 | E |
| q-arithmetic-number-sense-business-math-0008 | ₱53,750.00 | = | AGREE | 50000×(1+0.06×15/12)=53750 | E,N |
| q-arithmetic-number-sense-business-math-0009 | ₱4,275.00 | = | AGREE | 5000×0.9×0.95=4275 | E,N |
| q-arithmetic-number-sense-business-math-0010 | ₱120.00 | = | AGREE | 30×90×1.2/(30−3)=120 | E |
| q-arithmetic-number-sense-business-math-0011 | 12% | = | AGREE | 3600/(20000×1.5)=0.12 | E,N |
| q-arithmetic-number-sense-business-math-0012 | ₱7,200.00 | = | AGREE | 50000×0.03+50000×0.05+40000×0.08=7200 | E,N |
| q-arithmetic-number-sense-business-math-0013 | 25% | = | AGREE | 0.20/0.80×100=25% | E,N |
| q-arithmetic-number-sense-business-math-0014 | 20% | = | AGREE | Cost=1500/1.25=1200; 300/1500=20% | E |
| q-arithmetic-number-sense-business-math-0015 | ₱27,400.00 | = | AGREE | Interest=2400; 40000−(15000−2400)=27400 | E,N |
| q-arithmetic-number-sense-business-math-0016 | 1210 | = | AGREE | 1000×1.1²=1210 | E |
| q-arithmetic-number-sense-business-math-0017 | 600 | = | AGREE | 480/0.8=600 | E |
| q-arithmetic-number-sense-business-math-0018 | 1.02 | = | AGREE | 1+0.08/4=1.02 | E |
| q-arithmetic-number-sense-business-math-0019 | The equivalent discount is 28%. | = | AGREE | 1−0.9×0.8=0.28 | E |
| q-arithmetic-number-sense-business-math-0020 | 8 years | = | AGREE | 72/9=8 years | E |
| q-arithmetic-number-sense-business-math-0021 | Php 3,180 | = | AGREE | 8×375×1.06=3180 | E |
| q-arithmetic-number-sense-business-math-0022 | Php 200 | = | AGREE | 8000−7500×1.04=200 | E |
| q-arithmetic-number-sense-divisibility-rules-0001 | 0 is divisible by all nonzero integers. | = | AGREE | 0/n=0 for every integer n≠0 | — |
| q-arithmetic-number-sense-divisibility-rules-0002 | Use the last two digits; it passes. | = | AGREE | Last two digits=16; 16/4=4 | — |
| q-arithmetic-number-sense-divisibility-rules-0003 | 6 | = | AGREE | Digit sum=21+x; 21+6=27 | — |
| q-arithmetic-number-sense-divisibility-rules-0004 | 24,534 | = | AGREE | Even; digit sum=18, divisible by 3 | — |
| q-arithmetic-number-sense-divisibility-rules-0005 | Use 3 and 8; they are coprime. | = | AGREE | lcm(4,6)=12; lcm(3,8)=24 | — |
| q-arithmetic-number-sense-divisibility-rules-0006 | d=4 | = | AGREE | (7+d+1)−(3+5+4)=d−4=0 | — |
| q-arithmetic-number-sense-divisibility-rules-0007 | k=6 | = | AGREE | Last three digits=672=8×84 | — |
| q-arithmetic-number-sense-divisibility-rules-0008 | It skips groups of digits whose sum is a multiple of 9; here the number is not divisible by 9. | = | AGREE | Sum=25; 9∤25 | L |
| q-arithmetic-number-sense-divisibility-rules-0009 | 7 | = | AGREE | 3960=7×565+5; divides by 8,9,11 | — |
| q-arithmetic-number-sense-divisibility-rules-0010 | a=2, b=2 | = | AGREE | Sum=18; alternating sum=b−a=0 | — |
| q-arithmetic-number-sense-divisibility-rules-0011 | A number is divisible by 12 if and only if it is divisible by both 2 and 6. | = | AGREE | 6 passes 2 and 6 but fails 12 | — |
| q-arithmetic-number-sense-divisibility-rules-0012 | 0 | 45 | DISAGREE | Initially misadded digits as 18+x when y=5; chose x=0 | C: key correct |
| q-arithmetic-number-sense-divisibility-rules-0013 | 16 | 8 | DISAGREE | Initially used wrong alternating sum x+y−5; chose sum 16 | C: key correct |
| q-arithmetic-number-sense-divisibility-rules-0014 | 11 | = | AGREE | y=0 or 8; 16+x+y multiple of 9 gives max x+y=11 | — |
| q-arithmetic-number-sense-divisibility-rules-0015 | I and IV only | = | AGREE | 0/n=0; 12 refutes II; 6 refutes III; IV is 11-test | — |
| q-arithmetic-number-sense-divisibility-rules-0016 | 28 | = | AGREE | 34−2×3=28 | — |
| q-arithmetic-number-sense-divisibility-rules-0017 | 0 | = | AGREE | 518=7×74 | — |
| q-arithmetic-number-sense-divisibility-rules-0018 | Use (1+3)−(2+4). | = | AGREE | Alternate positions: 4−6=−2 | — |
| q-arithmetic-number-sense-divisibility-rules-0019 | Divisible by both 3 and 10. | = | AGREE | lcm(3,10)=30 | — |
| q-arithmetic-number-sense-divisibility-rules-0020 | 1 | = | AGREE | d even; 5+d divisible by 3; only d=4 | — |
| q-arithmetic-number-sense-divisibility-rules-0021 | 9 | = | AGREE | Number even; digit sum=15+d; greatest d=9 | — |
| q-arithmetic-number-sense-divisibility-rules-0022 | 5 | = | AGREE | Multiple of 5 ends 0 or 5; exclude 0 | — |
| q-arithmetic-number-sense-divisibility-rules-0023 | 7 | = | AGREE | 7843+7=7850, divisible by 10 and 5 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0001 | 37.5% | = | AGREE | 3/8×100=37.5 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0002 | 1 | = | AGREE | (6/15+5/15)/(11/15)=1 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0003 | 17/20 | = | AGREE | 1−15/100=85/100=17/20 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0004 | 2/3 | = | AGREE | 4/9+2/9=6/9=2/3 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0005 | ₱981.75 | = | AGREE | 850×1.10×1.05=981.75 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0006 | 1 | = | AGREE | 0.6×(7/12)/0.35=0.35/0.35=1 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0007 | 20% | = | AGREE | (15−12.5)/12.5=0.20 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0008 | 11 1/9% | = | AGREE | Increase=10/90×100=100/9% | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0009 | 7 | = | AGREE | 0.75/0.125+2.5×0.4=6+1=7 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0010 | ₱990 | = | AGREE | 12000×0.055×18/12=990 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0011 | ₱350 | = | AGREE | 3000×(1/3)×0.2+3000×(1/2)×0.1=350 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0012 | 55% | = | AGREE | (3/8+1/12)/(5/6)=11/20=55% | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0013 | ₱750 | = | AGREE | 672/(0.8×1.12)=750 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0014 | 24.375% | = | AGREE | 0.65×(1−5/8)×100=24.375 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0015 | −5% | = | AGREE | 1.25×0.8×0.95−1=−0.05 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0016 | 4.5% | = | AGREE | 0.045×100=4.5 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0017 | 40% | = | AGREE | 1−0.35−0.25=0.40 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0018 | Divide 2.5 by 100. | = | AGREE | 2.5%=2.5/100=0.025 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0019 | Their multipliers are 1.20 and 2.20. | = | AGREE | 120/100=1.2; 1+120/100=2.2 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0020 | 27 | = | AGREE | Total=72/0.4=180; 180×0.15=27 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0021 | 7/20 | = | AGREE | 3/5×7/12=21/60=7/20 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0022 | 1/16 | = | AGREE | 625/10000=1/16 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0023 | 51/40 | = | AGREE | 1275/1000÷25/25=51/40 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0024 | 0.4375 and 43.75% | = | AGREE | 7÷16=0.4375; ×100=43.75% | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0025 | 1.0 | = | AGREE | 1.25−0.375+0.125=1.0 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0026 | 0.036 | = | AGREE | 0.48×0.075=0.036 | — |
| q-arithmetic-number-sense-fractions-decimals-percentages-0027 | 2.82 | = | AGREE | 2.35×1.2=2.82 | — |
| q-arithmetic-number-sense-order-of-operations-0001 | 12 | = | AGREE | 18÷3×2=6×2=12 | — |
| q-arithmetic-number-sense-order-of-operations-0002 | 14 | = | AGREE | 15−5+4=10+4=14 | — |
| q-arithmetic-number-sense-order-of-operations-0003 | −7 | = | AGREE | −16+9=−7 | — |
| q-arithmetic-number-sense-order-of-operations-0004 | 100 | = | AGREE | 4×(8−3)²=4×25=100 | — |
| q-arithmetic-number-sense-order-of-operations-0005 | 2 | = | AGREE | 24÷6×2÷4=4×2÷4=2 | — |
| q-arithmetic-number-sense-order-of-operations-0006 | Step 1 | = | AGREE | 20−8 precedes +5; correct total=15 | — |
| q-arithmetic-number-sense-order-of-operations-0007 | Subtract 12, subtract 6, then add 9. | = | AGREE | 30−12−6+9=18−6+9=21 | — |
| q-arithmetic-number-sense-order-of-operations-0008 | 35 | = | AGREE | 2×4−3×(−6)+9=8+18+9=35 | — |
| q-arithmetic-number-sense-order-of-operations-0009 | 7 | = | AGREE | (16+12)/(10−6)=28/4=7 | — |
| q-arithmetic-number-sense-order-of-operations-0010 | Step 1 | = | AGREE | 36÷4 must precede ×3; correct result=35 | — |
| q-arithmetic-number-sense-order-of-operations-0011 | 8 | = | AGREE | 50−2×(3+2×9)=50−42=8 | — |
| q-arithmetic-number-sense-order-of-operations-0012 | ₱200 | = | AGREE | (500+12×15−80)/3=600/3=200 | — |
| q-arithmetic-number-sense-order-of-operations-0013 | 21 | = | AGREE | (−9−12)/(−1)³=21 | — |
| q-arithmetic-number-sense-order-of-operations-0014 | −5 | = | AGREE | (16−36)/(12−8)=−20/4=−5 | — |
| q-arithmetic-number-sense-order-of-operations-0015 | (350+24(13)+10(10)−400)/2 | = | AGREE | Cash=350+312+100−400=362; share=181 | — |
| q-arithmetic-number-sense-order-of-operations-0016 | 15 | = | AGREE | √49+2³=7+8=15 | — |
| q-arithmetic-number-sense-order-of-operations-0017 | Step 2 | = | AGREE | 3×6²=3×36=108; cannot square 18 | — |
| q-arithmetic-number-sense-order-of-operations-0018 | A<B | = | AGREE | A=48/8=6; B=48/6+2=10 | — |
| q-arithmetic-number-sense-order-of-operations-0019 | Evaluate equal-priority operations from left to right. | = | AGREE | 18÷3×2=(18÷3)×2=12 | — |
| q-arithmetic-number-sense-order-of-operations-0020 | 50 | = | AGREE | (4×35+2×20−30)/3=150/3=50 | — |
| q-arithmetic-number-sense-order-of-operations-0021 | 5 | = | AGREE | −28/7−3(−5)−6=−4+15−6=5 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0001 | 2²×3²×5 | = | AGREE | 180=18×10=2²×3²×5; 1 is not prime | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0002 | 36 | = | AGREE | 72=2×36; 108=3×36 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0003 | 72 | = | AGREE | 24=2³×3; 36=2²×3²; LCM=72 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0004 | Factor 35 into 5×7. | = | AGREE | 210=2×3×5×7 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0005 | 60 | = | AGREE | gcd(120,180,240)=60 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0006 | 7:00 AM | = | AGREE | lcm(15,20)=60 minutes; 6AM+1h=7AM | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0007 | 72 | = | AGREE | Common minimum powers=2³×3²=72 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0008 | 5 | = | AGREE | gcd(144,96)=48; (144+96)/48=5 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0009 | 3 | = | AGREE | LCM=180min; departures 11AM,2PM,5PM | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0010 | 84 | = | AGREE | Other=14×420/70=84 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0011 | ₱1,450 | = | AGREE | GCF=105; 3×150+4×250=1450 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0012 | 1:00 PM | = | AGREE | lcm(16,24,40)=240min; 9AM+4h=1PM | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0013 | 72 | = | AGREE | 36×216/108=72 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0014 | 2 | = | AGREE | gcd(180,300)=60 packs; ceil(60/35)=2 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0015 | ₱2,700 | = | AGREE | LCM=225min; 5×300+3×400=2700 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0016 | 2 is the only even prime. | = | AGREE | Every even integer above 2 has divisor 2 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0017 | Use each prime with its largest exponent across the factorizations. | = | AGREE | LCM=2×3×5=30 | L |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0018 | 123 | = | AGREE | lcm(6,8,10)+3=120+3=123 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0019 | ab/gcd(a,b) | = | AGREE | GCF×LCM=ab, so LCM=ab/GCF | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0020 | Use 2²×3. | = | AGREE | Minimum common exponents give 4×3=12 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0021 | N=36k+2 | = | AGREE | N−2 multiple of lcm(4,6,9)=36 | — |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0022 | 24 | = | AGREE | Counts=24k+4; consecutive difference=24 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0001 | 7+12=12+7 | = | AGREE | Addends swap order; grouping stays unchanged | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0002 | −7/4 | = | AGREE | (−4/7)(−7/4)=1 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0003 | 12x+28 | = | AGREE | 4×3x+4×7=12x+28 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0004 | Subtraction is not commutative because 5−3≠3−5. | = | AGREE | 5−3=2; 3−5=−2 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0005 | Associative, then commutative. | = | AGREE | 1+(2+3)→(1+2)+3→(2+1)+3 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0006 | −2x+10 | = | AGREE | −2×x+(−2)(−5)=−2x+10 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0007 | −11a−12b | = | AGREE | −6a−12b−5a=−11a−12b | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0008 | 34,200 | = | AGREE | 342(28+72)=342×100=34200 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0009 | x+(−x)=0 for every real x. | = | AGREE | A number and its additive inverse sum to 0 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0010 | Division is not associative, so changing the grouping alters the result. | = | AGREE | (12/4)/2=1.5; 12/(4/2)=6 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0011 | −2y | = | AGREE | −12x+8y−10y+12x=−2y | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0012 | a−(b−c)=(a−b)−c | = | AGREE | Left=a−b+c; right=a−b−c | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0013 | 0 | = | AGREE | 87(−14+114−100)=87×0=0 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0014 | Commutative property | = | AGREE | 5+2x becomes 2x+5 by swapping addends | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0015 | −8x+12y | = | AGREE | (−6+3−5)x+(9−2+5)y=−8x+12y | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0016 | 17(99+1) | = | AGREE | 99×17+1×17=17(99+1) | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0017 | Multiply the constant by 5 too. | = | AGREE | 5(2x−3)=10x−15 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0018 | (2×3)×5=2×(3×5) | = | AGREE | Factors keep order; only grouping changes | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0019 | 3/2 | = | AGREE | Reciprocal=−3/2; additive inverse=3/2 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0020 | There is no such real number. | = | AGREE | 0r=0 for every real r; cannot equal 1 | L |
| q-arithmetic-number-sense-properties-of-real-numbers-0021 | a=0, b=1 | = | AGREE | (x+0)×1=x for every real x | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0022 | −17+0=−17; (−17)(1)=−17 | = | AGREE | Adding 0 and multiplying by 1 preserve −17 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0023 | 3a²−3a−5 | = | AGREE | (9−6)a²+(−4+1)a+(7−12)=3a²−3a−5 | — |
| q-arithmetic-number-sense-properties-of-real-numbers-0024 | 8xy+5x² | = | AGREE | yx=xy; (6+5−3)xy+(−2+7)x² | — |
| q-arithmetic-number-sense-ratio-and-proportion-0001 | 5 cups | = | AGREE | 3×20/12=5 cups | — |
| q-arithmetic-number-sense-ratio-and-proportion-0002 | 8 liters | = | AGREE | 12×2/3=8 liters | N |
| q-arithmetic-number-sense-ratio-and-proportion-0003 | 67.5 km | = | AGREE | 4.5×15=67.5 km | — |
| q-arithmetic-number-sense-ratio-and-proportion-0004 | 27 passengers | = | AGREE | 15/5=3 per part; 9×3=27 | N |
| q-arithmetic-number-sense-ratio-and-proportion-0005 | 1,500 grams | = | AGREE | 450/3×(5+3+2)=1500 | N |
| q-arithmetic-number-sense-ratio-and-proportion-0006 | 1/2 | = | AGREE | 6×20/(10×12+6×20)=120/240 | N |
| q-arithmetic-number-sense-ratio-and-proportion-0007 | 48 sq km | = | AGREE | (3×2)(4×2)=6×8=48 | N |
| q-arithmetic-number-sense-ratio-and-proportion-0008 | 6 liters | = | AGREE | Red=24, white=6; 24/2−6=6 | N |
| q-arithmetic-number-sense-ratio-and-proportion-0009 | 12/5 g/mL | = | AGREE | 600/250=12/5 g/mL | — |
| q-arithmetic-number-sense-ratio-and-proportion-0010 | 60 minutes | = | AGREE | Speed factor=0.75; time=45/0.75=60 | — |
| q-arithmetic-number-sense-ratio-and-proportion-0011 | 9:11 | = | AGREE | Blue=3+6=9; yellow=9+2=11 | — |
| q-arithmetic-number-sense-ratio-and-proportion-0012 | 48 minutes | = | AGREE | Distance=36km; 36/45×60=48min | N |
| q-arithmetic-number-sense-ratio-and-proportion-0013 | 7.2 kg | = | AGREE | 2.25/15×40×1.2=7.2 | N |
| q-arithmetic-number-sense-ratio-and-proportion-0014 | ₱4720 | = | AGREE | a:b:c=15:20:24; 720/9×59=4720 | — |
| q-arithmetic-number-sense-ratio-and-proportion-0015 | 21/19 | = | AGREE | Yellow=30×0.7=21; red=9+10=19 | N |
| q-arithmetic-number-sense-ratio-and-proportion-0016 | y=3x | = | AGREE | y/x=3, a constant | — |
| q-arithmetic-number-sense-ratio-and-proportion-0017 | 12 hours | = | AGREE | Required pump-hours=6×10=60; 60/5=12 | — |
| q-arithmetic-number-sense-ratio-and-proportion-0018 | 2(8)≠4(6) | = | AGREE | Products=16 and 24; inverse products must match | L |
| q-arithmetic-number-sense-ratio-and-proportion-0019 | 16 days | = | AGREE | Remaining work=8×(15−5)=80; 80/5=16 | — |
| q-arithmetic-number-sense-ratio-and-proportion-0020 | 77 meters | = | AGREE | One part=21/(7−4)=7; total=11×7=77 | — |
| q-arithmetic-number-sense-ratio-and-proportion-0021 | 18 days | = | AGREE | Remaining work=12×12=144; 144/8=18 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0001 | 0 | = | AGREE | Whole numbers include 0; stated naturals start at 1 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0002 | √7 | = | AGREE | 7 is not a perfect square; other choices are rational | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0003 | −1 | = | AGREE | By definition, i²=−1 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0004 | 7+3i | = | AGREE | (4+3)+(5−2)i=7+3i | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0005 | 4+5i | = | AGREE | (10+2i)−(6−3i)=4+5i | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0006 | i | = | AGREE | 57=4×14+1; i⁵⁷=i | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0007 | They used the real-root product rule. | = | AGREE | √−16×√−25=4i×5i=−20, not 20 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0008 | 22−7i | = | AGREE | 12−15i+8i−10i²=22−7i | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0009 | 34 | = | AGREE | (5−3i)(5+3i)=25+9=34 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0010 | Every real number has form a+0i. | = | AGREE | Set imaginary coefficient b=0 to represent any real a | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0011 | 1+i | = | AGREE | (4+2i)(3+i)/10=(10+10i)/10 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0012 | −1 | = | AGREE | First 96 powers sum to 0; i−1−i=−1 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0013 | 0 | = | AGREE | (3−4i)−(8−4i)+5=0 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0014 | 3i | = | AGREE | (6i×2i)/(4i)=−12/(4i)=3i | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0015 | 2−5i | = | AGREE | (23−14i)(4−3i)/25=(50−125i)/25 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0016 | −4 | = | AGREE | In 3−4i=a+bi, b=−4 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0017 | When n is odd. | = | AGREE | Odd powers alternate i and −i; even powers are ±1 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0018 | 6 | = | AGREE | (3+4i)+(3−4i)=6 | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0019 | 12i | = | AGREE | Missing cross term=2×2×3i=12i | — |
| q-arithmetic-number-sense-real-imaginary-numbers-0020 | √2 and √8 | = | AGREE | Both irrational; √2×√8=√16=4 | — |
| q-arithmetic-number-sense-sequences-and-series-0001 | 61 | = | AGREE | a₁₅=5+14×4=61 | — |
| q-arithmetic-number-sense-sequences-and-series-0002 | Geometric, ratio 2 | = | AGREE | 6/3=12/6=24/12=48/24=2 | — |
| q-arithmetic-number-sense-sequences-and-series-0003 | 175 | = | AGREE | a₁₀=31; S₁₀=10(4+31)/2=175 | — |
| q-arithmetic-number-sense-sequences-and-series-0004 | 96 | = | AGREE | a₆=3×2⁵=96 | — |
| q-arithmetic-number-sense-sequences-and-series-0005 | 18 | = | AGREE | Ratio=1/3; sum=12/(1−1/3)=18 | — |
| q-arithmetic-number-sense-sequences-and-series-0006 | 3 | = | AGREE | d=(31−11)/5=4; a₁=11−2×4=3 | — |
| q-arithmetic-number-sense-sequences-and-series-0007 | 16−8+4−2+… | = | AGREE | Ratio=−1/2; absolute value below 1 | — |
| q-arithmetic-number-sense-sequences-and-series-0008 | 605 | = | AGREE | S₅=5(3⁵−1)/(3−1)=605 | — |
| q-arithmetic-number-sense-sequences-and-series-0009 | 16 | = | AGREE | d=(28−4)/4=6; second mean=4+2×6 | — |
| q-arithmetic-number-sense-sequences-and-series-0010 | 870 | = | AGREE | Last row=72; 20(15+72)/2=870 | — |
| q-arithmetic-number-sense-sequences-and-series-0011 | 4 | = | AGREE | (x+5)²=(x−1)(7x−1); roots 4,−1 | — |
| q-arithmetic-number-sense-sequences-and-series-0012 | 70336 | = | AGREE | 105…994 has 128 terms; 64×(105+994)=70336 | — |
| q-arithmetic-number-sense-sequences-and-series-0013 | 112 m | = | AGREE | 16+2×12/(1−3/4)=112 | — |
| q-arithmetic-number-sense-sequences-and-series-0014 | 5 | = | AGREE | (5+2d)²=5(5+8d); d(d−5)=0; d≠0 | — |
| q-arithmetic-number-sense-sequences-and-series-0015 | 33 | = | AGREE | a₈=S₈−S₇=152−119=33 | — |
| q-arithmetic-number-sense-sequences-and-series-0016 | 1/15 | = | AGREE | Reciprocal sequence=3,7,11,15; invert 15 | — |
| q-arithmetic-number-sense-sequences-and-series-0017 | Take the reciprocal of 17. | = | AGREE | Arithmetic reciprocal term=17; harmonic term=1/17 | — |
| q-arithmetic-number-sense-sequences-and-series-0018 | 19 | = | AGREE | Terms=2,5,7,12,19 | — |
| q-arithmetic-number-sense-sequences-and-series-0019 | The sum is 84. | = | AGREE | Arithmetic mean equals middle term; 7×12=84 | — |
| q-arithmetic-number-sense-sequences-and-series-0020 | 3/4 | = | AGREE | First two=120; total=80/(1−1/2)=160 | — |
| q-arithmetic-number-sense-sequences-and-series-0021 | 39 | = | AGREE | (246−18)/6+1=39 | — |
| q-arithmetic-number-sense-sequences-and-series-0022 | 11 | = | AGREE | Third=47−29=18; second=29−18=11 | — |
| q-arithmetic-number-sense-sequences-and-series-0023 | 61 | = | AGREE | Differences=5,8,11,14; next=17; 44+17=61 | — |
| q-arithmetic-number-sense-sequences-and-series-0024 | 150 | = | AGREE | Alternate ×4 and −2; 152−2=150 | — |
| q-arithmetic-number-sense-sequences-and-series-0025 | 57 | = | AGREE | Increases=1²,2²,3²,4²; next 32+5²=57 | — |
| q-arithmetic-number-sense-sequences-and-series-0026 | 90 | = | AGREE | Ratio 1 makes every term 18; 5×18=90 | — |
| q-arithmetic-number-sense-sequences-and-series-0027 | Php 62,000 | = | AGREE | 2000×(1+2+4+8+16)=62000 | — |
| q-arithmetic-number-sense-sequences-and-series-0028 | 120 | = | AGREE | 64+32+16+8=120 | — |
| q-arithmetic-number-sense-sequences-and-series-0029 | 32,3 | = | AGREE | Odd positions double; even positions divide by 3 | — |
| q-arithmetic-number-sense-sequences-and-series-0030 | 36 | = | AGREE | Even positions=50,43,36,29; difference −7 | — |

## Fresh re-solve of edited or exposed questions
| q-arithmetic-number-sense-business-math-0001 | ₱1,000.00 | ₱1,000.00 | AGREE | 800×1.25=1,000 | Longest tie |
| q-arithmetic-number-sense-business-math-0002 | Php 115 | Php 115 | AGREE | 640×0.25−45=115 | Longest tie |
| q-arithmetic-number-sense-business-math-0003 | ₱900.00 | ₱900.00 | AGREE | 15,000×0.08×9/12=900 | None |
| q-arithmetic-number-sense-business-math-0004 | ₱2,280.00 | ₱2,280.00 | AGREE | 2,400×0.95=2,280 | Longest tie |
| q-arithmetic-number-sense-business-math-0005 | ₱2,800.00 | ₱2,800.00 | AGREE | 400×6+0.04×(35,000−25,000)=2,800 | Longest tie |
| q-arithmetic-number-sense-business-math-0006 | 20% | 20% | AGREE | (25−20)/25×100=20% | Longest tie |
| q-arithmetic-number-sense-business-math-0007 | ₱17.40 | ₱17.40 | AGREE | [13+(9−4)×1.75]×0.8=17.40 | Longest tie |
| q-arithmetic-number-sense-business-math-0008 | ₱53,750.00 | ₱53,750.00 | AGREE | 50,000×(1+0.06×15/12)=53,750 | Longest tie |
| q-arithmetic-number-sense-business-math-0009 | ₱4,275.00 | ₱4,275.00 | AGREE | 5,000×0.9×0.95=4,275 | Longest tie |
| q-arithmetic-number-sense-business-math-0010 | ₱120.00 | ₱120.00 | AGREE | 30×90×1.2/(30−3)=120 | Longest tie |
| q-arithmetic-number-sense-business-math-0011 | 12% | 12% | AGREE | (23,600−20,000)/(20,000×1.5)=0.12 | None |
| q-arithmetic-number-sense-business-math-0012 | ₱7,200.00 | ₱7,200.00 | AGREE | 50,000×0.03+50,000×0.05+40,000×0.08=7,200 | None |
| q-arithmetic-number-sense-business-math-0013 | 25% | 25% | AGREE | Selling price=480/0.8=600; 120/480=25% | None |
| q-arithmetic-number-sense-business-math-0014 | 20% | 20% | AGREE | Cost=1,500/1.25=1,200; 300/1,500=20% | None |
| q-arithmetic-number-sense-business-math-0015 | ₱27,400.00 | ₱27,400.00 | AGREE | Interest=40,000×0.09×8/12=2,400; 40,000−12,600=27,400 | Longest tie |
| q-arithmetic-number-sense-business-math-0016 | 1210 | 1210 | AGREE | 1,000×1.1²=1,210 | Longest tie |
| q-arithmetic-number-sense-business-math-0017 | 600 | 600 | AGREE | 480/0.8=600 | None |
| q-arithmetic-number-sense-business-math-0018 | 1.02 | 1.02 | AGREE | 1+0.08/4=1.02 | Longest tie |
| q-arithmetic-number-sense-business-math-0019 | The equivalent discount is 28%. | The equivalent discount is 28%. | AGREE | 1−0.9×0.8=0.28 | Longest tie |
| q-arithmetic-number-sense-business-math-0020 | 8 years | 8 years | AGREE | Rule of 72: 72/9=8 years | None |
| q-arithmetic-number-sense-business-math-0021 | Php 3,180 | Php 3,180 | AGREE | 8×375×1.06=3,180 | None |
| q-arithmetic-number-sense-business-math-0022 | Php 200 | Php 200 | AGREE | 8,000−7,500×1.04=200 | Longest tie |
| q-arithmetic-number-sense-divisibility-rules-0008 | Drop groups summing to multiples of 9; not divisible. | Drop groups summing to multiples of 9; not divisible. | AGREE | Digit sum=25; remainder=7 | None |
| q-arithmetic-number-sense-divisibility-rules-0012 | 45 | 45 | AGREE | y=0 or 5; y=5 gives 18+x divisible by 9; x=9 maximizes xy=45 | Longest tie |
| q-arithmetic-number-sense-divisibility-rules-0013 | 8 | 8 | AGREE | 8-test: y=1,5,9; 11-test leaves (x,y)=(3,5),(7,9); minimum sum=8 | None |
| q-arithmetic-number-sense-prime-factorization-gcf-lcm-0017 | Use each prime's highest exponent. | Use each prime's highest exponent. | AGREE | LCM=2×3×5=30, not 900 | None |
| q-arithmetic-number-sense-properties-of-real-numbers-0020 | No real number exists. | No real number exists. | AGREE | 0r=0 for every real r; 0≠1 | None |
| q-arithmetic-number-sense-ratio-and-proportion-0002 | 8 liters | 8 liters | AGREE | 12×2/3=8 liters | None |
| q-arithmetic-number-sense-ratio-and-proportion-0004 | 27 passengers | 27 passengers | AGREE | 15/5×(4+5)=27 passengers | None |
| q-arithmetic-number-sense-ratio-and-proportion-0005 | 1,500 grams | 1,500 grams | AGREE | 450/3×(5+3+2)=1,500 grams | Longest tie |
| q-arithmetic-number-sense-ratio-and-proportion-0006 | $\dfrac{1}{2}$ | $\dfrac{1}{2}$ | AGREE | 6×20/(10×12+6×20)=120/240=1/2 | Longest tie |
| q-arithmetic-number-sense-ratio-and-proportion-0007 | 48 sq km | 48 sq km | AGREE | (3×2)×(4×2)=48 sq km | Longest tie |
| q-arithmetic-number-sense-ratio-and-proportion-0008 | 6 liters | 6 liters | AGREE | Red=24, white=6; added white=24/2−6=6 liters | None |
| q-arithmetic-number-sense-ratio-and-proportion-0012 | 48 minutes | 48 minutes | AGREE | 14.4×250,000/100,000=36 km; 36/45×60=48 minutes | Longest tie |
| q-arithmetic-number-sense-ratio-and-proportion-0013 | 7.2 kg | 7.2 kg | AGREE | 2.25/15×40×1.2=7.2 kg | Longest tie |
| q-arithmetic-number-sense-ratio-and-proportion-0015 | $\dfrac{21}{19}$ | $\dfrac{21}{19}$ | AGREE | Yellow=30×0.7=21; red=30×0.3+10=19; ratio=21/19 | Longest tie |
