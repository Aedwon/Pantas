# Algebra answer verification (bite-sized, CSE Algebra and CET algebra)

Date: Nov 15, 2026. Content: `content/bite-sized-cse-algebra-r1` from 853456b46. 251 questions: 220 existing
(20 Word Problems, serving CSE and CET; 200 CET-only) and 31 new for part pool gaps. All checks were
separate Codex jobs, never the writers.

1. Independent re-solve of the 200 CET questions (GPT 6.1 Sol, medium, two jobs): 200 of 200 agree.
   One job reported that it saw the explanation before solving 20 questions.
2. Fresh blind re-solve of the 20 Word Problems questions and those 20 exposed questions: 40 of 40 agree.
3. Independent re-solve of the 31 new questions: 31 of 31 agree; one wording flag.
4. Independent audit (GPT 6 Astra, high) of 54 sampled questions (44 existing, 10 new), all 31 new
   questions' lesson alignment, three splits (Word Problems, Polynomials, Types of Functions) and 10
   table rows: no must-fix findings; one should-fix (the same wording flag).
5. Fix by the lead: q-algebra-linear-equations-inequalities-0022, the correct choice "Closed $-4$, shade
   right." became "Closed at $-4$, shaded right." to match the other choices. The key, the stem, the
   other choices and the explanation are unchanged.
Flags not acted on: answer-length ties only (the correct choice ties another choice's length).
Approved by the lead with `tool/content/approve.dart`.

## Audit (GPT 6 Astra, high)

SHOULD-FIX: `q-algebra-linear-equations-inequalities-0022`. The correct choice says “Closed $-4$, shade right.” “Closed” needs “at.” Use “Closed at $-4$, shaded right.”

NO MUST-FIX FINDINGS

Totals: 54/54 sampled questions checked; all 31 new questions checked, including lesson alignment; 3 splits checked; 10 verification rows matched. Must-fix: 0. Should-fix: 1.

## Re-solve, CET questions part A
| q-algebra-algebraic-expressions-0001 | $3x$ | $3x$ | AGREE | $x+x+x=3x$ | B |
| q-algebra-algebraic-expressions-0002 | $y-7$ | $y-7$ | AGREE | Subtract seven from $y$. | B |
| q-algebra-algebraic-expressions-0003 | $11$ | $11$ | AGREE | $2(4)+3=8+3=11$ | B |
| q-algebra-algebraic-expressions-0004 | $\dfrac{d}{4}$ | $\dfrac{d}{4}$ | AGREE | $d\div4=d/4$ | B |
| q-algebra-algebraic-expressions-0005 | $5a$ | $5a$ | AGREE | $(3+2)a=5a$ | B |
| q-algebra-algebraic-expressions-0006 | $2x+6$ | $2x+6$ | AGREE | $2(x+3)=2x+2(3)$ | B |
| q-algebra-algebraic-expressions-0007 | Step 1 | Step 1 | AGREE | $3(a+2)=3a+6$, not $3a+2$. | B |
| q-algebra-algebraic-expressions-0008 | $9$ | $9$ | AGREE | $3^2=3(3)=9$ | B |
| q-algebra-algebraic-expressions-0009 | $-4$ | $-4$ | AGREE | $-(2^2)=-4$ | B |
| q-algebra-algebraic-expressions-0010 | $7$ | $7$ | AGREE | $(-2)^2+3=4+3=7$ | B |
| q-algebra-algebraic-expressions-0011 | $3x+3$ | $3x+3$ | AGREE | $5x-2x+3=3x+3$ | B |
| q-algebra-algebraic-expressions-0012 | Step 1 | Step 1 | AGREE | $8-(3-x)=8-3+x=5+x$ | B |
| q-algebra-algebraic-expressions-0013 | $0.5n$ | $0.5n$ | AGREE | $(50/100)n=0.5n$ | B |
| q-algebra-algebraic-expressions-0014 | $10x-2$ | $10x-2$ | AGREE | $6x-2+4x=10x-2$ | B |
| q-algebra-algebraic-expressions-0015 | $10$ | $10$ | AGREE | $2(3)+(-2)^2=6+4=10$ | B |
| q-algebra-algebraic-expressions-0016 | $4x+5$ | $4x+5$ | AGREE | Multiply $4$ by $x$, then add $5$. | B |
| q-algebra-algebraic-expressions-0017 | Step 2 | Step 2 | AGREE | Six less than $2y$ is $2y-6$. | B |
| q-algebra-algebraic-expressions-0018 | $2x+6y$ | $2x+6y$ | AGREE | $(3-1)x+(2+4)y=2x+6y$ | B |
| q-algebra-algebraic-expressions-0019 | $5<x$ | $5<x$ | AGREE | Five is smaller than $x$. | B |
| q-algebra-algebraic-expressions-0020 | $\dfrac{S-6}{3}$ | $\dfrac{S-6}{3}$ | AGREE | $n+(n+2)+(n+4)=S$; $3n=S-6$. | B |
| q-algebra-exponents-and-logarithms-0001 | $x^8$ | $x^8$ | AGREE | $x^{3+5}=x^8$ | - |
| q-algebra-exponents-and-logarithms-0002 | $x^4$ | $x^4$ | AGREE | $x^{7-3}=x^4$ | - |
| q-algebra-exponents-and-logarithms-0003 | $x^6$ | $x^6$ | AGREE | $x^{3(2)}=x^6$ | - |
| q-algebra-exponents-and-logarithms-0004 | $\dfrac{1}{4}$ | $\dfrac{1}{4}$ | AGREE | $\sqrt[3]{8}=2$; $2^{-2}=1/4$. | - |
| q-algebra-exponents-and-logarithms-0005 | $\dfrac{1}{8}$ | $\dfrac{1}{8}$ | AGREE | $2^{-3}=1/2^3=1/8$ | - |
| q-algebra-exponents-and-logarithms-0006 | $\log_2(8)=3$ | $\log_2(8)=3$ | AGREE | $2^3=8$ | - |
| q-algebra-exponents-and-logarithms-0007 | $4$ | $4$ | AGREE | $3^4=81$ | - |
| q-algebra-exponents-and-logarithms-0008 | The exponents were multiplied. | The exponents were multiplied. | AGREE | $2^{3+4}=2^7$, not $2^{12}$. | - |
| q-algebra-exponents-and-logarithms-0009 | The exponents were added. | The exponents were added. | AGREE | $(2^2)^3=2^{2(3)}=2^6$. | - |
| q-algebra-exponents-and-logarithms-0010 | $\dfrac{x^5}{y^2}$ | $\dfrac{x^5}{y^2}$ | AGREE | Exponents: $3+4-2=5$; $2-1-3=-2$. | - |
| q-algebra-exponents-and-logarithms-0011 | $\log(x^2y)$ | $\log(x^2y)$ | AGREE | $\log(x^2)+\log(y)=\log(x^2y)$ | - |
| q-algebra-exponents-and-logarithms-0012 | $x=5$ | $x=5$ | AGREE | $2^{4x-2}=2^{3x+3}$; $x=5$. | - |
| q-algebra-exponents-and-logarithms-0013 | $2a+b$ | $2a+b$ | AGREE | $12=2^2(3)$; $\log(12)=2a+b$. | - |
| q-algebra-exponents-and-logarithms-0014 | The exponent was treated as a sign. | The exponent was treated as a sign. | AGREE | $3^{-2}=1/9$, not $-9$. | - |
| q-algebra-exponents-and-logarithms-0015 | $8$ | $8$ | AGREE | $\sqrt[4]{16}=2$; $2^3=8$. | - |
| q-algebra-exponents-and-logarithms-0016 | $b=0.5$ | $b=0.5$ | AGREE | A real logarithm requires $b>0$, $b\ne1$. | - |
| q-algebra-exponents-and-logarithms-0017 | The product rule. | The product rule. | AGREE | $\log20+\log30=\log600$, not $\log50$. | - |
| q-algebra-exponents-and-logarithms-0018 | $N2^t$ | $N2^t$ | AGREE | Each hour multiplies the count by $2$. | - |
| q-algebra-exponents-and-logarithms-0019 | $3<50^{1/3}<4$ | $3<50^{1/3}<4$ | AGREE | $3^3=27<50<64=4^3$ | - |
| q-algebra-exponents-and-logarithms-0020 | $x=500$ | $x=500$ | AGREE | $x/5=10^2=100$; $x=500$. | - |
| q-algebra-functions-and-relations-0001 | $\{(1,4),(2,5),(3,4)\}$ | $\{(1,4),(2,5),(3,4)\}$ | AGREE | Inputs $1,2,3$ each have one output. | - |
| q-algebra-functions-and-relations-0002 | $6$ | $6$ | AGREE | $(3x+8)-(3x+2)=6$ | - |
| q-algebra-functions-and-relations-0003 | $15$ | $15$ | AGREE | $2(-2)^2-3(-2)+1=8+6+1=15$ | - |
| q-algebra-functions-and-relations-0004 | $3$ | $3$ | AGREE | At $x=3$, the denominator is $3-3=0$. | - |
| q-algebra-functions-and-relations-0005 | $x\ge2$ | $x\ge2$ | AGREE | $x-2\ge0$ gives $x\ge2$. | - |
| q-algebra-functions-and-relations-0006 | The function that reverses $f$. | The function that reverses $f$. | AGREE | $f^{-1}(f(x))=x$ on its domain. | - |
| q-algebra-functions-and-relations-0007 | $3$ | $3$ | AGREE | $g(2)=4-3=1$; $f(1)=2+1=3$. | - |
| q-algebra-functions-and-relations-0008 | $50$ | $50$ | AGREE | $2(2+3)^2=2(25)=50$ | - |
| q-algebra-functions-and-relations-0009 | $\dfrac{5x+3}{2}$ | $\dfrac{5x+3}{2}$ | AGREE | $5y=2x-3$; $x=(5y+3)/2$; swap. | - |
| q-algebra-functions-and-relations-0010 | Negative outputs were included. | Negative outputs were included. | AGREE | $x^2\ge0$ for every real $x$. | - |
| q-algebra-functions-and-relations-0011 | No. | No. | AGREE | A function assigns one output to each input. | - |
| q-algebra-functions-and-relations-0012 | $3$ | $3$ | AGREE | $3u-2=7$; $3u=9$; $u=3$. | - |
| q-algebra-functions-and-relations-0013 | $x\ge-1,\ x\ne2$ | $x\ge-1,\ x\ne2$ | AGREE | $x+1\ge0$ and $x-2\ne0$. | - |
| q-algebra-functions-and-relations-0014 | $(3,2)$ | $(3,2)$ | AGREE | Input $3$ would have outputs $1$ and $2$. | - |
| q-algebra-functions-and-relations-0015 | $3$ | $3$ | AGREE | $(-3)^2+2(-3)=9-6=3$ | - |
| q-algebra-functions-and-relations-0016 | $\{4,9\}$ | $\{4,9\}$ | AGREE | Outputs are $4,4,9$; remove duplicates. | - |
| q-algebra-functions-and-relations-0017 | Each output comes from only one input. | Each output comes from only one input. | AGREE | Reversal then assigns one output per input. | - |
| q-algebra-functions-and-relations-0018 | $x\ge4$ | $x\ge4$ | AGREE | $f(g(x))=\sqrt{x-4}$; $x-4\ge0$. | - |
| q-algebra-functions-and-relations-0019 | A check for all allowed inputs. | A check for all allowed inputs. | AGREE | At $2$, $f(g(2))=4\ne2$. | - |
| q-algebra-functions-and-relations-0020 | $c(d(p))$ | $c(d(p))$ | AGREE | Discount then fee gives $0.8p+30$. | - |
| q-algebra-linear-equations-inequalities-0001 | $2$ | $2$ | AGREE | $2x=7-3=4$; $x=2$. | - |
| q-algebra-linear-equations-inequalities-0002 | $5$ | $5$ | AGREE | $3n-5=10$; $3n=15$; $n=5$. | - |
| q-algebra-linear-equations-inequalities-0003 | $x<5$ | $x<5$ | AGREE | $x<9-4=5$ | - |
| q-algebra-linear-equations-inequalities-0004 | Step 2 | Step 2 | AGREE | Dividing by $-2$ gives $x<-5$. | - |
| q-algebra-linear-equations-inequalities-0005 | $\dfrac{11}{7}$ | $\dfrac{11}{7}$ | AGREE | $9x-3=2x+8$; $7x=11$. | - |
| q-algebra-linear-equations-inequalities-0006 | $x<-1$ | $x<-1$ | AGREE | $-2x+8>3x+13$; $-5x>5$. | - |
| q-algebra-linear-equations-inequalities-0007 | $-\dfrac{2}{3}$ | $-\dfrac{2}{3}$ | AGREE | $3y=-2x+6$; slope $=-2/3$. | - |
| q-algebra-linear-equations-inequalities-0008 | Their slopes have product $-1$. | Their slopes have product $-1$. | AGREE | $3(-1/3)=-1$ | - |
| q-algebra-linear-equations-inequalities-0009 | $10$ | $10$ | AGREE | $800/80=10$ shirts. | - |
| q-algebra-linear-equations-inequalities-0010 | $2$ | $2$ | AGREE | $x+3=5$; $x=2$. | - |
| q-algebra-linear-equations-inequalities-0011 | Step 3 | Step 3 | AGREE | $-x>-3$ gives $x<3$. | - |
| q-algebra-linear-equations-inequalities-0012 | $2$ | $2$ | AGREE | $(6-2)/(3-1)=4/2=2$ | - |
| q-algebra-linear-equations-inequalities-0013 | $y=2x+1$ | $y=2x+1$ | AGREE | $3=2(1)+b$; $b=1$. | - |
| q-algebra-linear-equations-inequalities-0014 | $4$ | $4$ | AGREE | Set $x=0$: $3y=12$, $y=4$. | - |
| q-algebra-linear-equations-inequalities-0015 | $(3,2)$ | $(3,2)$ | AGREE | $2(3)+3(2)=6+6=12$ | - |
| q-algebra-linear-equations-inequalities-0016 | $x<5$ | $x<5$ | AGREE | $x=5$ is vertical; strict inequality is dashed. | - |
| q-algebra-linear-equations-inequalities-0017 | $6$ | $6$ | AGREE | $(1200-300)/150=900/150=6$ | - |
| q-algebra-linear-equations-inequalities-0018 | $16$ | $16$ | AGREE | $x/2=5+3=8$; $x=16$. | - |
| q-algebra-linear-equations-inequalities-0019 | $y=-2$ | $y=-2$ | AGREE | A horizontal line is perpendicular to $x=4$. | - |
| q-algebra-linear-equations-inequalities-0020 | $2x+y\le4$ | $2x+y\le4$ | AGREE | Boundary $y=-2x+4$; origin gives $0\le4$. | - |
| q-algebra-polynomials-0001 | $4x^2+2x-2$ | $4x^2+2x-2$ | AGREE | $(3+1)x^2+(-2+4)x+1-3$ | - |
| q-algebra-polynomials-0002 | $3x^2+2x-1$ | $3x^2+2x-1$ | AGREE | $(5-2)x^2+(3-1)x-1$ | - |
| q-algebra-polynomials-0003 | The last constant was not subtracted. | The last constant was not subtracted. | AGREE | The constant is $0-1=-1$, not $+1$. | - |
| q-algebra-polynomials-0004 | $x^2+5x+6$ | $x^2+5x+6$ | AGREE | $x^2+2x+3x+6=x^2+5x+6$ | - |
| q-algebra-polynomials-0005 | $x^2+6x+9$ | $x^2+6x+9$ | AGREE | $x^2+2(3)x+3^2=x^2+6x+9$ | - |
| q-algebra-polynomials-0006 | $6x$ | $6x$ | AGREE | Cross terms $3x+3x=6x$. | - |
| q-algebra-polynomials-0007 | $x^2-16$ | $x^2-16$ | AGREE | $x^2+4x-4x-16=x^2-16$ | - |
| q-algebra-polynomials-0008 | $(x-2)(x-3)$ | $(x-2)(x-3)$ | AGREE | $(-2)+(-3)=-5$; $(-2)(-3)=6$. | - |
| q-algebra-polynomials-0009 | $-9$ | $-9$ | AGREE | $P(2)=16-24+4-5=-9$ | - |
| q-algebra-polynomials-0010 | $3$ | $3$ | AGREE | $P(3)=27-9k+12-12=0$; $k=3$. | - |
| q-algebra-polynomials-0011 | $7x^2-8x+11$ | $7x^2-8x+11$ | AGREE | $6x^2-4x+10+x^2-4x+1$ | - |
| q-algebra-polynomials-0012 | $4x(x+2)$ | $4x(x+2)$ | AGREE | GCF is $4x$; division leaves $x+2$. | - |
| q-algebra-polynomials-0013 | $x^4-81$ | $x^4-81$ | AGREE | $(x^2-9)(x^2+9)=x^4-9^2$ | - |
| q-algebra-polynomials-0014 | $x^2+1$ | $x^2+1$ | AGREE | Exponents $2$ and $0$ are nonnegative integers. | - |
| q-algebra-polynomials-0015 | $(3x+1)(2x-3)$ | $(3x+1)(2x-3)$ | AGREE | $6x^2-9x+2x-3=6x^2-7x-3$ | - |
| q-algebra-polynomials-0016 | The box needs the zero of the divisor. | The box needs the zero of the divisor. | AGREE | $x-5=0$ gives $5$, not $-5$. | - |
| q-algebra-polynomials-0017 | $-1$ | $-1$ | AGREE | Linear terms: $-4x+3x=-x$. | - |
| q-algebra-polynomials-0018 | $P(2)=0$ | $P(2)=0$ | AGREE | $P(2)=8-12+4=0$ | - |
| q-algebra-polynomials-0019 | $x^2-x-6$ | $x^2-x-6$ | AGREE | Synthetic $1$: coefficients $1,-1,-6$; remainder $0$. | - |
| q-algebra-polynomials-0020 | $-6$ | $-6$ | AGREE | $(x^2-x-2)(2x+3)$ gives $a=1,b=-7$. | - |

## Re-solve, CET questions part B
| q-algebra-quadratic-equations-0001 | x=3 or x=5 | x=3 or x=5 | AGREE | (x−3)(x−5)=0. | |
| q-algebra-quadratic-equations-0002 | −3 | −3 | AGREE | (x+2)(x+3)=0; other root −3. | |
| q-algebra-quadratic-equations-0003 | x=−1/2 or x=−3 | x=−1/2 or x=−3 | AGREE | (2x+1)(x+3)=0. | |
| q-algebra-quadratic-equations-0004 | x=5 | x=5 | AGREE | x²−10x+25=(x−5)². | |
| q-algebra-quadratic-equations-0005 | x=0 or x=4 | x=0 or x=4 | AGREE | x²−4x=x(x−4)=0. | |
| q-algebra-quadratic-equations-0006 | A zero root was discarded. | A zero root was discarded. | AGREE | Dividing by x excludes x=0, which satisfies x²=4x. | |
| q-algebra-quadratic-equations-0007 | 5 | 5 | AGREE | D=3²−4(1)(1)=5. | |
| q-algebra-quadratic-equations-0008 | One repeated negative root. | One repeated negative root. | AGREE | (x+3)²=0 gives repeated root −3. | |
| q-algebra-quadratic-equations-0009 | 4 | 4 | AGREE | Sum=−b/a=12/3=4. | |
| q-algebra-quadratic-equations-0010 | 7/3 | 7/3 | AGREE | Product=c/a=7/3. | |
| q-algebra-quadratic-equations-0011 | Six was removed from only one side. | Six was removed from only one side. | AGREE | Factoring gives x(x−5)=6, not 0. | |
| q-algebra-quadratic-equations-0012 | x=−5 | x=−5 | AGREE | x²=25 gives x=±5; −5 is missing. | |
| q-algebra-quadratic-equations-0013 | x²−16=0 | x²−16=0 | AGREE | (x−4)(x+4)=x²−16. | |
| q-algebra-quadratic-equations-0014 | x=2 or x=−4 | x=2 or x=−4 | AGREE | x=(−2±√36)/2=2,−4. | L-tie |
| q-algebra-quadratic-equations-0015 | x²+x+1=0 | x²+x+1=0 | AGREE | D=1−4=−3<0. | |
| q-algebra-quadratic-equations-0016 | Both roots are negative. | Both roots are negative. | AGREE | (x+2)(x+3)=0 gives −2,−3. | |
| q-algebra-quadratic-equations-0017 | 2 cm | 2 cm | AGREE | w(w+3)=10; (w+5)(w−2)=0; w>0. | |
| q-algebra-quadratic-equations-0018 | k=±6 | k=±6 | AGREE | D=k²−36=0 gives k=±6. | |
| q-algebra-quadratic-equations-0019 | (x+2)²=9 | (x+2)²=9 | AGREE | Divide by 2: x²+4x=5; add 4. | |
| q-algebra-quadratic-equations-0020 | 6 | 6 | AGREE | (r+s)/(rs)=3/(1/2)=6. | |
| q-algebra-radicals-and-rationalization-0001 | 6√2 | 6√2 | AGREE | √72=√(36·2)=6√2. | |
| q-algebra-radicals-and-rationalization-0002 | 7<√50<8 | 7<√50<8 | AGREE | 7²=49<50<64=8². | |
| q-algebra-radicals-and-rationalization-0003 | 3√5 | 3√5 | AGREE | 3√20−√45=6√5−3√5=3√5. | |
| q-algebra-radicals-and-rationalization-0004 | The radicands were added. | The radicands were added. | AGREE | √9+√16=3+4=7, not √25=5. | |
| q-algebra-radicals-and-rationalization-0005 | √5 | √5 | AGREE | 5/√5=5√5/5=√5. | |
| q-algebra-radicals-and-rationalization-0006 | It is defined and equals 2√5. | It is defined and equals 2√5. | AGREE | √5≠0; 10√5/5=2√5. | |
| q-algebra-radicals-and-rationalization-0007 | 3+√5 | 3+√5 | AGREE | 4(3+√5)/(9−5)=3+√5. | |
| q-algebra-radicals-and-rationalization-0008 | 6xy²√(2x) | 6xy²√(2x) | AGREE | √(36x²y⁴·2x)=6xy²√(2x), since x≥0. | |
| q-algebra-radicals-and-rationalization-0009 | 5 | 5 | AGREE | The principal square root of 25 is 5. | |
| q-algebra-radicals-and-rationalization-0010 | 5√2 | 5√2 | AGREE | √18+√8=3√2+2√2=5√2. | |
| q-algebra-radicals-and-rationalization-0011 | −1 | −1 | AGREE | (√3+2)(√3−2)=3−4=−1. | |
| q-algebra-radicals-and-rationalization-0012 | The denominator is ∛(x²). | The denominator is ∛(x²). | AGREE | ∛x·∛x=∛(x²), not x. | |
| q-algebra-radicals-and-rationalization-0013 | 2√3 | 2√3 | AGREE | 2√12−√27+√3=(4−3+1)√3=2√3. | L-tie |
| q-algebra-radicals-and-rationalization-0014 | √100=10, t=±10 | √100=10, t=±10 | AGREE | Principal root is 10; both ±10 square to 100. | |
| q-algebra-radicals-and-rationalization-0015 | √x | √x | AGREE | √x·√x=x, a positive rational denominator. | |
| q-algebra-radicals-and-rationalization-0016 | 10·abs(x)·√2 | 10·abs(x)·√2 | AGREE | √(200x²)=10√2·√(x²)=10·abs(x)·√2. | |
| q-algebra-radicals-and-rationalization-0017 | The constant product has the wrong sign. | The constant product has the wrong sign. | AGREE | (x+√y)(x−√y)=x²−y. | |
| q-algebra-radicals-and-rationalization-0018 | 2−√2 | 2−√2 | AGREE | 2(2−√2)/(4−2)=2−√2. | |
| q-algebra-radicals-and-rationalization-0019 | 5 | 5 | AGREE | L²=20+L; (L−5)(L+4)=0; L≥0 gives 5. | |
| q-algebra-radicals-and-rationalization-0020 | ∛(2x²)/x | ∛(2x²)/x | AGREE | Multiply by ∛(2x²); denominator ∛(8x³)=2x. | |
| q-algebra-sets-and-set-notation-0001 | {3,5} | {3,5} | AGREE | Only 3 and 5 occur in both sets. | |
| q-algebra-sets-and-set-notation-0002 | 5∈S | 5∈S | AGREE | 5 is listed as an element of S. | |
| q-algebra-sets-and-set-notation-0003 | {1,3,5,7} | {1,3,5,7} | AGREE | Remove 2,4,6,8 from U. | |
| q-algebra-sets-and-set-notation-0004 | The empty set ∅ is a subset of every set. | The empty set ∅ is a subset of every set. | AGREE | ∅ has no element outside any set. | |
| q-algebra-sets-and-set-notation-0005 | {a,b,c,d,e} | {a,b,c,d,e} | AGREE | Collect all distinct elements from A and B. | |
| q-algebra-sets-and-set-notation-0006 | 35 | 35 | AGREE | Union=25+20−10=35. | L-tie |
| q-algebra-sets-and-set-notation-0007 | 10 | 10 | AGREE | Union=50−8=42; both=30+22−42=10. | L-tie |
| q-algebra-sets-and-set-notation-0008 | 16 | 16 | AGREE | A four-element set has 2⁴=16 subsets. | L-tie |
| q-algebra-sets-and-set-notation-0009 | 27 | 27 | AGREE | Both=28+18−45=1; Filipino only=28−1=27. | L-tie |
| q-algebra-sets-and-set-notation-0010 | A∩B′ | A∩B′ | AGREE | Membership requires being in A and outside B. | |
| q-algebra-sets-and-set-notation-0011 | 93 | 93 | AGREE | 50+40+35−15−12−10+5=93. | |
| q-algebra-sets-and-set-notation-0013 | {3} | {3} | AGREE | A={−2,…,3}; B={−2,…,2}; difference={3}. | |
| q-algebra-sets-and-set-notation-0014 | (A∪B)′=A′∩B′ | (A∪B)′=A′∩B′ | AGREE | Outside the union means outside both sets. | |
| q-algebra-sets-and-set-notation-0015 | 8 | 8 | AGREE | Choir only=20−8−7+3=8. | |
| q-algebra-sets-and-set-notation-0016 | {6} | {6} | AGREE | A∪B={1,2,3,4,5}; only 6 remains in U. | |
| q-algebra-sets-and-set-notation-0017 | 61 | 61 | AGREE | Exactly one=120−2(15+10+12)+3(5)=61. | |
| q-algebra-sets-and-set-notation-0018 | It counts students in both clubs too. | It counts students in both clubs too. | AGREE | Exactly one=30+20−16=34; 42 includes both. | L-tie |
| q-algebra-sets-and-set-notation-0019 | {2,6} | {2,6} | AGREE | Both 2 and 6 belong to A; 8 does not. | L-tie |
| q-algebra-sets-and-set-notation-0020 | {2,3,4} | {2,3,4} | AGREE | B must contain 2,3,4 and exclude 1. | |
| q-algebra-sets-and-set-notation-0021 | 40 | 40 | AGREE | At least one=30 exactly one+10 both=40. | L-tie |
| q-algebra-systems-of-equations-0001 | (3, 4) | (3, 4) | AGREE | x+(x+1)=7 gives x=3,y=4. | L-tie |
| q-algebra-systems-of-equations-0002 | (3, 2) | (3, 2) | AGREE | Add: 6x=18; x=3; 6+3y=12 gives y=2. | |
| q-algebra-systems-of-equations-0003 | (4, 2) | (4, 2) | AGREE | 5(first)−2(second): 11x=44; y=2. | |
| q-algebra-systems-of-equations-0004 | 30 | 30 | AGREE | 100a+60(50−a)=4200; 40a=1200. | L-tie |
| q-algebra-systems-of-equations-0005 | No solution | No solution | AGREE | Subtracting gives 0=4, a contradiction. | |
| q-algebra-systems-of-equations-0006 | Infinite | Infinite | AGREE | The second equation is twice the first. | |
| q-algebra-systems-of-equations-0007 | 2 | 2 | AGREE | x²−4=3x−6 gives (x−1)(x−2)=0. | |
| q-algebra-systems-of-equations-0008 | 50 | 50 | AGREE | 0.2a+0.6(100−a)=40 gives a=50 kg. | |
| q-algebra-systems-of-equations-0009 | Wrong sign on the second 10y. | Wrong sign on the second 10y. | AGREE | −(4x+10y)=−4x−10y. | |
| q-algebra-systems-of-equations-0010 | 2x+5(3x+1)=14 | 2x+5(3x+1)=14 | AGREE | Replace y with the whole expression 3x+1. | |
| q-algebra-systems-of-equations-0011 | 10 | 10 | AGREE | n=80−4p; 3(80−4p)+2p=140 gives p=10. | |
| q-algebra-systems-of-equations-0012 | 3 | 3 | AGREE | First−2(second): −3y=−9 gives y=3. | |
| q-algebra-systems-of-equations-0013 | 4 | 4 | AGREE | Add equations: 4x+4y=16; x+y=4. | |
| q-algebra-systems-of-equations-0014 | (3, 1) | (3, 1) | AGREE | Add: 3x=9; x=3 and y=1. | L-tie |
| q-algebra-systems-of-equations-0015 | 2 | 2 | AGREE | Add: 4x=8; x=2,y=1; xy=2. | L-tie |
| q-algebra-systems-of-equations-0016 | 3 | 3 | AGREE | 3x+2(2x−5)=4 gives x=2,y=−1; x−y=3. | |
| q-algebra-systems-of-equations-0017 | Division by x loses the root 0. | Division by x loses the root 0. | AGREE | x²=x gives x(x−1)=0; (0,0) also works. | |
| q-algebra-systems-of-equations-0018 | 15 | 15 | AGREE | v−c=80/8=10; v+c=100/5=20; 2v=30. | L-tie |
| q-algebra-systems-of-equations-0019 | Step 2 | Step 2 | AGREE | Step 1 gives 3x+2=8, so 3x=6, not 10. | |
| q-algebra-systems-of-equations-0020 | 14 | 14 | AGREE | Second left side is twice first; k=2·7=14. | |
| q-algebra-types-of-functions-0001 | 7 | 7 | AGREE | f(4)=3(4)−5=7. | |
| q-algebra-types-of-functions-0002 | f(x)=4^x | f(x)=4^x | AGREE | The variable is in the exponent of constant base 4. | |
| q-algebra-types-of-functions-0003 | (3, 4) | (3, 4) | AGREE | Vertex form (x−h)²+k gives h=3,k=4. | |
| q-algebra-types-of-functions-0004 | All real numbers except x=5 | All real numbers except x=5 | AGREE | x−5≠0 requires x≠5. | |
| q-algebra-types-of-functions-0005 | 3 | 3 | AGREE | 3³=27, so log₃27=3. | |
| q-algebra-types-of-functions-0006 | x=3 | x=3 | AGREE | 2x−6=0 gives x=3; numerator there is 7. | |
| q-algebra-types-of-functions-0007 | x=2 | x=2 | AGREE | Vertex x=−b/(2a)=8/4=2. | |
| q-algebra-types-of-functions-0008 | 11 | 11 | AGREE | At x=3 use x≥3 branch: 2(3)+5=11. | L-tie |
| q-algebra-types-of-functions-0009 | f is exponential; g is polynomial. | f is exponential; g is polynomial. | AGREE | 5^x has variable exponent; x⁵ has fixed integer power. | |
| q-algebra-types-of-functions-0010 | y≥3 | y≥3 | AGREE | abs(x−2)≥0; minimum 3 occurs at x=2. | |
| q-algebra-types-of-functions-0011 | y=2 | y=2 | AGREE | Equal degrees give leading-coefficient ratio 4/2=2. | |
| q-algebra-types-of-functions-0012 | 13 | 13 | AGREE | x+3=2⁴=16 gives x=13. | L-tie |
| q-algebra-types-of-functions-0013 | Excludes 3; has a hole there. | Excludes 3; has a hole there. | AGREE | Cancel x−3 to get x+3, retaining x≠3. | |
| q-algebra-types-of-functions-0014 | x=5 | x=5 | AGREE | 2^x+1=33 gives 2^x=32=2⁵. | |
| q-algebra-types-of-functions-0015 | Yes, because both have the form y=mx+b. | Yes, because both have the form y=mx+b. | AGREE | Both have constant slopes, 3 and −1/3. | |
| q-algebra-types-of-functions-0016 | f | f | AGREE | Base 1/2 lies between 0 and 1, so f decreases globally. | L-tie |
| q-algebra-types-of-functions-0017 | The case 2x−5=−7. | The case 2x−5=−7. | AGREE | Negative branch gives 2x=−2, so x=−1 also works. | |
| q-algebra-types-of-functions-0018 | x=5 | x=5 | AGREE | Log argument x−4>0 requires x>4; only 5 qualifies. | |
| q-algebra-types-of-functions-0019 | 85 | 85 | AGREE | C(5)=40+15(5−2)=85 pesos. | |
| q-algebra-types-of-functions-0020 | A graph may cross it. | A graph may cross it. | AGREE | x/(x²+1) has asymptote y=0 and crosses it at x=0. | |

## Blind re-solve, Word Problems and exposed rows
| q-algebra-word-problems-0001 | $10\text{ years old}$ | $10\text{ years old}$ | AGREE | 2M+4=24; M=10 | T |
| q-algebra-word-problems-0002 | $1.5\text{ hours}$ | $1.5\text{ hours}$ | AGREE | 45/30=1.5 hours | None |
| q-algebra-word-problems-0003 | $2\text{ hours}$ | $2\text{ hours}$ | AGREE | 1/6+1/3=1/2 wall/hour; time=2 | None |
| q-algebra-word-problems-0004 | $1\text{ liter}$ | $1\text{ liter}$ | AGREE | 10(0.10)=1 liter | None |
| q-algebra-word-problems-0005 | $8$ | $8$ | AGREE | 5n+(15-n)=47; 4n=32; n=8 | None |
| q-algebra-word-problems-0006 | $5f+10t=160$ | $5f+10t=160$ | AGREE | Coin values are 5f and 10t; sum=160 | T |
| q-algebra-word-problems-0007 | $12\text{ years old}$ | $12\text{ years old}$ | AGREE | 4a+6=3(a+6); a=12 | T |
| q-algebra-word-problems-0008 | $2\text{ hours}$ | $2\text{ hours}$ | AGREE | 60t=40(t+1); 20t=40; t=2 | None |
| q-algebra-word-problems-0009 | $4.8\text{ hours}$ | $4.8\text{ hours}$ | AGREE | 1/B=1/3-1/8=5/24; B=4.8 | None |
| q-algebra-word-problems-0010 | $10\text{ liters}$ | $10\text{ liters}$ | AGREE | 0.30x+0.10(20-x)=4; x=10 | None |
| q-algebra-word-problems-0011 | $16\text{ years old}$ | $16\text{ years old}$ | AGREE | 52-c=3(c-4); 64=4c; c=16 | T |
| q-algebra-word-problems-0012 | $12$ | $12$ | AGREE | 5(2n+8)+10n=280; n=12 | None |
| q-algebra-word-problems-0013 | $10\text{ years old}$ | $10\text{ years old}$ | AGREE | F=5M-20=2M+10; M=10 | T |
| q-algebra-word-problems-0014 | $3\text{ hours}$ | $3\text{ hours}$ | AGREE | 180/(25+35)=3 hours | None |
| q-algebra-word-problems-0015 | $3\text{ hours}$ | $3\text{ hours}$ | AGREE | 1/4+1/12=1/3 tank/hour; time=3 | None |
| q-algebra-word-problems-0016 | $18\text{ liters}$ | $18\text{ liters}$ | AGREE | 12(0.25)=0.10(12+w); w=18 | T |
| q-algebra-word-problems-0017 | $20\text{ km/h}$ | $20\text{ km/h}$ | AGREE | 24/(12/15+12/30)=24/1.2=20 | None |
| q-algebra-word-problems-0018 | $39\text{ coins}$ | $39\text{ coins}$ | AGREE | 35n-60=430; n=14; 3n-3=39 | T |
| q-algebra-word-problems-0019 | $84$ | $84$ | AGREE | t=2u; 3u=12; u=4; 10t+u=84 | None |
| q-algebra-word-problems-0020 | Use $8+x$ as final volume. | Use $8+x$ as final volume. | AGREE | Final volume=8+x; solute=0.30(8+x) | None |
| q-algebra-algebraic-expressions-0001 | $3x$ | $3x$ | AGREE | Three times x=3*x=3x | None |
| q-algebra-algebraic-expressions-0002 | $y - 7$ | $y - 7$ | AGREE | Subtract 7 from y: y-7 | T |
| q-algebra-algebraic-expressions-0003 | $11$ | $11$ | AGREE | 2(4)+3=8+3=11 | T |
| q-algebra-algebraic-expressions-0004 | $\dfrac{d}{4}$ | $\dfrac{d}{4}$ | AGREE | d divided by 4=d/4 | T |
| q-algebra-algebraic-expressions-0005 | $5a$ | $5a$ | AGREE | 3a+2a=(3+2)a=5a | None |
| q-algebra-algebraic-expressions-0006 | $2x + 6$ | $2x + 6$ | AGREE | 2(x+3)=2x+2(3)=2x+6 | T |
| q-algebra-algebraic-expressions-0007 | Step 1 | Step 1 | AGREE | 3(a+2)=3a+6; Step 1 gives 3a+2 | None |
| q-algebra-algebraic-expressions-0008 | $9$ | $9$ | AGREE | 3²=3*3=9 | None |
| q-algebra-algebraic-expressions-0009 | $-4$ | $-4$ | AGREE | -(2²)=-4 | T |
| q-algebra-algebraic-expressions-0010 | $7$ | $7$ | AGREE | (-2)²+3=4+3=7 | None |
| q-algebra-algebraic-expressions-0011 | $3x + 3$ | $3x + 3$ | AGREE | 5x-2x+3=3x+3 | T |
| q-algebra-algebraic-expressions-0012 | Step 1 | Step 1 | AGREE | 8-(3-x)=8-3+x; Step 1 changes x's sign | None |
| q-algebra-algebraic-expressions-0013 | $0.5n$ | $0.5n$ | AGREE | (50/100)n=0.5n | None |
| q-algebra-algebraic-expressions-0014 | $10x - 2$ | $10x - 2$ | AGREE | 6x-2+4x=10x-2 | T |
| q-algebra-algebraic-expressions-0015 | $10$ | $10$ | AGREE | 2(3)+(-2)²=6+4=10 | T |
| q-algebra-algebraic-expressions-0016 | $4x + 5$ | $4x + 5$ | AGREE | Product=4*x; adding 5 gives 4x+5 | None |
| q-algebra-algebraic-expressions-0017 | Step 2 | Step 2 | AGREE | Twice y=2y; subtract 6 gives 2y-6 | None |
| q-algebra-algebraic-expressions-0018 | $2x + 6y$ | $2x + 6y$ | AGREE | (3-1)x+(2+4)y=2x+6y | T |
| q-algebra-algebraic-expressions-0019 | $5 < x$ | $5 < x$ | AGREE | “5 is less than x” means 5<x | T |
| q-algebra-algebraic-expressions-0020 | $\dfrac{S-6}{3}$ | $\dfrac{S-6}{3}$ | AGREE | n+(n+2)+(n+4)=S; n=(S-6)/3 | T |

## Re-solve, new questions
| q-algebra-algebraic-expressions-0021 | $3p$ | $3p$ | AGREE | $(p/h)(3h)=3p$ | None |
| q-algebra-algebraic-expressions-0022 | $\dfrac{60n}{t}$ | $\dfrac{60n}{t}$ | AGREE | Hourly output $=60(n/t)$ | T |
| q-algebra-algebraic-expressions-0023 | $\dfrac{S-4}{4}$ | $\dfrac{S-4}{4}$ | AGREE | $S=4x+12$; second $=x+2=(S-4)/4$ | None |
| q-algebra-exponents-and-logarithms-0021 | $7$ | $7$ | AGREE | $2x-5=3^2=9$; $x=7$ | None |
| q-algebra-exponents-and-logarithms-0022 | $3b-2a$ | $3b-2a$ | AGREE | $\log(27/4)=3\log3-2\log2$ | None |
| q-algebra-linear-equations-inequalities-0021 | Undefined; $0$ | Undefined; $0$ | AGREE | Slopes: $6/0$ undefined; $0/5=0$ | None |
| q-algebra-linear-equations-inequalities-0022 | Closed $-4$, shade right. | Closed $-4$, shade right. | AGREE | $-2x\le8$ gives $x\ge-4$ | E: “Closed” needs “at” |
| q-algebra-linear-equations-inequalities-0023 | $(2,-1)$ | $(2,-1)$ | AGREE | $3(2)-2(-1)=8>6$; others give $6,0,-7$ | T |
| q-algebra-polynomials-0021 | $(3x+2)(9x^2-6x+4)$ | $(3x+2)(9x^2-6x+4)$ | AGREE | Sum of cubes: $a=3x,b=2$; $ab=6x$ | None |
| q-algebra-polynomials-0022 | $(2x-5y)(4x^2+10xy+25y^2)$ | $(2x-5y)(4x^2+10xy+25y^2)$ | AGREE | Difference of cubes: $a=2x,b=5y$; $ab=10xy$ | None |
| q-algebra-polynomials-0023 | $x^2-4x+16$ | $x^2-4x+16$ | AGREE | $x^3+64=(x+4)(x^2-4x+16)$ | None |
| q-algebra-polynomials-0024 | $(x-8)(x+3)$ | $(x-8)(x+3)$ | AGREE | $-8+3=-5$; $(-8)(3)=-24$ | None |
| q-algebra-polynomials-0025 | $(3x-2)(4x+3)$ | $(3x-2)(4x+3)$ | AGREE | Product $=12x^2+9x-8x-6$ | None |
| q-algebra-polynomials-0026 | $Q=x^2+1,\ R=2$ | $Q=x^2+1,\ R=2$ | AGREE | $(x^2+1)^2+2=x^4+2x^2+3$ | None |
| q-algebra-polynomials-0027 | $Q=x^2+\dfrac{5}{2},\ R=\dfrac{13}{2}$ | $Q=x^2+\dfrac{5}{2},\ R=\dfrac{13}{2}$ | AGREE | Subtract $(2x-1)x^2$; $5x+4=(2x-1)(5/2)+13/2$ | None |
| q-algebra-polynomials-0028 | $3$ | $3$ | AGREE | $a+b=-7$, $2a-b=1$; $a=-2,b=-5$; $a-b=3$ | None |
| q-algebra-polynomials-0029 | $3$ | $3$ | AGREE | Difference $=-x^3+2x^2+7$; degree $3$ | None |
| q-algebra-polynomials-0030 | $27$ | $27$ | AGREE | $P(-2)=32+8-6-7=27$ | None |
| q-algebra-types-of-functions-0021 | $y=-3\|x+1\|+4$ | $y=-3\|x+1\|+4$ | AGREE | $a=(-2-4)/2=-3$; vertex gives $x+1$ | T |
| q-algebra-types-of-functions-0022 | $-\dfrac{4}{3}$ | $-\dfrac{4}{3}$ | AGREE | $x=8/3,-4$; sum $=8/3-4=-4/3$ | None |
| q-algebra-types-of-functions-0023 | $-\dfrac{1}{2}$ | $-\dfrac{1}{2}$ | AGREE | $a=2/4=1/2$; $y(0)=3/2-2=-1/2$ | T |
| q-algebra-types-of-functions-0024 | Reflect and compress. | Reflect and compress. | AGREE | Negative coefficient reflects; magnitude $1/3$ compresses | None |
| q-algebra-types-of-functions-0025 | $7$ | $7$ | AGREE | Absolute value is nonnegative; $f(x)\le7$, with $f(-4)=7$ | None |
| q-algebra-types-of-functions-0026 | $y=-3\|x+2\|+5$ | $y=-3\|x+2\|+5$ | AGREE | Vertical factor $=-3$; left shift gives $x+2$; add $5$ | None |
| q-algebra-types-of-functions-0027 | $f$ shows decay. | $f$ shows decay. | AGREE | $a^2=9/16$; positive $a=3/4<1$ | None |
| q-algebra-types-of-functions-0028 | $y=2x+1$ | $y=2x+1$ | AGREE | Numerator $=(x+1)(2x+1)+3$; remainder term tends to $0$ | T |
| q-algebra-types-of-functions-0029 | $y=x+2$ | $y=x+2$ | AGREE | Numerator $=(x^2+1)(x+2)-x-1$; remainder ratio tends to $0$ | T |
| q-algebra-types-of-functions-0030 | $-2$ | $-2$ | AGREE | Cancel $x-3$; $(x+3)/(x+2)$ has pole $-2$ and hole $3$ | T |
| q-algebra-types-of-functions-0031 | $y=0$ | $y=0$ | AGREE | Numerator degree $1<2$; ratio tends to $0$ | None |
| q-algebra-word-problems-0021 | $72\text{ km}$ | $72\text{ km}$ | AGREE | Lead $=48(0.5)=24$; catch time $=24/(72-48)=1$; distance $72$ | None |
| q-algebra-word-problems-0022 | $18\text{ km}$ | $18\text{ km}$ | AGREE | Meeting time $=42/(18+24)=1$ hour; slower distance $=18$ km | None |
