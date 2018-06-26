# AGAR_2018_sandbox

Sandbox private repo to share code, notes, and files in preparation for AGAR 2018 in Buffalo, NY

## Session 1: Version control, reproducibility, automation, and best-practices for bioinformatics
### Git

### Conda/Bioconda

### Make (or Snakemake)
Joanna -- are you familar with [Snakemake](https://snakemake.readthedocs.io/en/stable/)? It was designed based on Make, but it's written in Python, explicity designed for bioinformatics, and rapidly becoming the industry standard. I'm a fan because you can powerfully use normal Python code to make rules and pipelines more flexible and it's designed for cluster integration. It has a nice tutorial [here](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html).

## Sessions 2 and 3: Assembly, variant calling, variant filtering
### File formats to cover
fasta
fastq
sam/bam
vcf
bed (if there's time/need)

### Step 1 -- What is a reference genome?
- what is a reference?
- what is fasta format?
- how do we prepare a reference for read mapping?
  - bwa index, fai index (samtools faidx), sequence dictionary

### Step 2 -- Fastq quality control
- what is a fastq?
- basics of exploring a fastq
  - bioawk
- how do we explore fastq quality?
  - fastqc
  - multiqc
- how do we trim fastqs?
  - bbduk (also trimmomatic/trim galore/etc.)
  - why and when do we trim fastqs?
    - what is an adapter?

### Step 3 -- Mapping reads
 



