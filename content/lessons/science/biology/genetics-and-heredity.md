---
_id: "lesson-biology-genetics-and-heredity"
title: "Genetics and Heredity"
summary: "How genetic information is inherited and expressed, from Mendelian patterns to DNA, gene linkage, protein synthesis, and pedigrees."
subject: "subject-science"
topic: "topic-biology"
estimatedMinutes: 15
isActive: true
---
## Core Concept

**Genetics** is the study of heredity and genetic variation. A **gene** is a DNA sequence whose information contributes to a functional product, such as an RNA or protein. Genes can influence traits, but most traits are not controlled by a single gene acting alone. Different versions of a gene are called **alleles**.

An organism's **genotype** describes its genetic state at one or more loci; its **phenotype** is an observable characteristic produced by the interaction of genotype and environment.

In a simple diploid, complete-dominance model, a **dominant** allele can determine the heterozygote's phenotype, while a **recessive** phenotype appears when no dominant allele is present. Capital and lowercase letters are a classroom notation convention, not an intrinsic property of DNA.

### Mendelian Laws of Inheritance

The **Law of Segregation** says that the two alleles at a diploid locus separate during gamete formation, so a haploid gamete receives one allele from that pair.

The **Law of Independent Assortment** applies when genes assort independently—for example, genes on different chromosomes, or genes far enough apart on the same chromosome that recombination makes them behave as effectively unlinked. Genes physically close together on the same chromosome are **linked** and can violate simple independent-assortment ratios.

A **Punnett square** displays expected probabilities for offspring genotypes under a stated inheritance model. It does not guarantee that a small family will appear in those exact ratios.

| | $T$ | $t$ |
| --- | --- | --- |
| **$T$** | $TT$ | $Tt$ |
| **$t$** | $Tt$ | $tt$ |

### Extensions Beyond Simple Dominance

**Incomplete dominance**: the heterozygote has a phenotype intermediate between the two homozygotes in the characteristic being measured.

**Codominance**: both alleles contribute detectably to the heterozygote's phenotype. The human ABO blood group is a standard example: $I^A$ and $I^B$ are codominant.

**Multiple alleles**: a locus can have more than two alleles in a population even though a diploid individual ordinarily carries no more than two copies at that locus.

**Sex-linked inheritance** means a gene is on a sex chromosome. **X-linked** inheritance is especially important because individuals with only one X chromosome are hemizygous for most X-linked loci. Some forms of red-green color-vision deficiency and hemophilia are X-linked recessive.

### DNA, RNA, and Protein Synthesis

DNA uses the bases adenine ($A$), thymine ($T$), cytosine ($C$), and guanine ($G$). In double-stranded DNA, $A$ pairs with $T$ and $C$ pairs with $G$.

For a typical protein-coding gene, the main information-flow steps are:

**Transcription**: RNA polymerase uses DNA as a template to synthesize RNA. In eukaryotes, nuclear genes are transcribed in the nucleus; prokaryotes have no nucleus, so transcription occurs in the cytoplasmic region.

**Translation**: ribosomes read the mRNA sequence in three-nucleotide units called **codons**, each of which specifies an amino acid or a translation signal. Codons are not "gene-sized" units; a protein-coding gene ordinarily contains many codons.

The shorthand $DNA \rightarrow RNA \rightarrow protein$ is useful for protein-coding genes, but not every RNA is translated into protein, and biology also includes processes such as reverse transcription.

### Pedigrees

A **pedigree** charts the occurrence of a trait through a family. Under a specified simple Mendelian model, patterns can support hypotheses such as autosomal dominant, autosomal recessive, or X-linked inheritance. Real pedigrees can be complicated by small family size, incomplete penetrance, new mutations, variable expression, and non-Mendelian inheritance, so a pattern is evidence—not an infallible proof by itself.

## Examples

### #1: Basic Punnett Square Cross

Two heterozygous pea plants are crossed at a locus with complete dominance: $Tt \times Tt$, where $T$ produces the dominant tall phenotype and $t$ the recessive short phenotype. What is the expected probability that one offspring is tall?

**Solution:**

1. Possible offspring genotypes are $TT$, $Tt$, $Tt$, and $tt$.
2. Three of the four equally likely Punnett-square cells contain at least one $T$.
3. Expected probability of the tall phenotype:

$$P(\text{tall})=\frac{3}{4}$$

4. This is a probability for each offspring, not a promise that every set of four offspring contains exactly three tall individuals.

### #2: Incomplete Dominance vs. Codominance

A red snapdragon crossed with a white snapdragon produces heterozygous pink flowers. Separately, a person with genotype $I^AI^B$ has blood type AB. Identify the inheritance patterns.

**Solution:**

1. The intermediate pink heterozygote is incomplete dominance.
2. Expression of both A and B antigens in blood type AB is codominance.

### #3: DNA to Protein

Describe the basic information flow for a protein-coding eukaryotic nuclear gene.

$$DNA \xrightarrow{\text{transcription}} RNA \xrightarrow{\text{translation}} protein$$

**Solution:**

1. Transcription synthesizes an RNA copy from the DNA template in the nucleus.
2. After eukaryotic RNA processing, mature mRNA can leave the nucleus.
3. A ribosome translates mRNA codons into an amino-acid chain.
4. The polypeptide then folds and may undergo additional processing before becoming a functional protein.

### #4: Interpreting an Unaffected-Parents Pedigree

Two unaffected parents have an affected child. Under the explicit assumptions that the trait is rare, single-gene, fully penetrant, autosomal, and caused by either a completely dominant or completely recessive allele, which model fits better?

**Solution:**

1. Under the simple dominant model, an affected child would ordinarily have inherited the dominant allele from an affected parent.
2. Under the recessive model, two unaffected heterozygous carriers can each contribute the recessive allele to an affected child.
3. Therefore the pattern supports **autosomal recessive inheritance under the stated assumptions**.
4. Without those assumptions, alternatives such as a new dominant mutation or incomplete penetrance could also produce unaffected parents with an affected child.

## Speed Tricks & Shortcuts

For Punnett squares, translate the result as **probability**, not a guaranteed family ratio.

For independent assortment, ask where the genes are. Different chromosomes generally assort independently; closely linked genes on the same chromosome tend to be inherited together unless recombination separates them.

For terminology, remember: **genus/species-style letters are notation; dominance is a relationship between alleles and phenotype under a model**.

For pedigrees, never infer inheritance mode from one pattern without noticing the assumptions stated in the question.

## Traps to Watch For

### #1: Saying Every Gene Directly "Codes for a Trait"

> Genes encode functional products or regulate biological processes; phenotypes can depend on many genes plus the environment.

Single-gene Mendelian examples are models, not a description of all traits.

### #2: Applying Independent Assortment to Closely Linked Genes

> Genes close together on the same chromosome are more likely to be inherited together.

Recombination can separate linked alleles, with probability generally increasing as loci are farther apart.

### #3: Calling the Second Word of an mRNA Triplet a "Gene-Sized Codon"

> A codon is a three-nucleotide unit in mRNA; a coding sequence contains many codons.

Translation reads codons one after another.

### #4: Saying Unaffected Parents Can Never Have a Child with a Dominant Condition

> That conclusion holds only inside a simple inherited, fully penetrant dominant model.

Real genetics can include de novo mutations, penetrance effects, mosaicism, and other complications.
