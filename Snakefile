# Snakefile for running AGAR 2018 assembly pipeline
# Tim Webster, 2018

ceu = [
	"CEU_NA06984",
	"CEU_NA06985",
	"CEU_NA06986",
	"CEU_NA06989",
	"CEU_NA06994",
	"CEU_NA07000"]

pur = [
	"PUR_HG00551",
	"PUR_HG00553",
	"PUR_HG00554",
	"PUR_HG00637",
	"PUR_HG00638",
	"PUR_HG00640"]

yri = [
	"YRI_NA18486",
	"YRI_NA18488",
	"YRI_NA18489",
	"YRI_NA18498",
	"YRI_NA18499",
	"YRI_NA18501"]

all_samples = ceu + pur + yri

# Tool paths (change if tools not in PATH)
bwa_path = "bwa"
fastqc_path = "fastqc"
multiqc_path = "multiqc"
samtools_path = "samtools"

rule all:
	input:
		"multiqc_results/multiqc_report.html"

rule prepare_reference:
	input:
		ref = "reference/{assembly}.fasta"
	output:
		fai = "reference/{assembly}.fasta.fai",
		amb = "reference/{assembly}.fasta.amb",
		dict = "reference/{assembly}.dict"
	params:
		samtools = samtools_path,
		bwa = bwa_path
	run:
		# faidx
		shell(
			"{params.samtools} faidx {input.ref}")
		# .dict
		shell(
			"{params.samtools} dict -o {output.dict} {input.ref}")
		# bwa
		shell(
			"{params.bwa} index {input.ref}")

rule fastqc_analysis:
	input:
		"fastq/{sample}_MT.{read}.fastq.gz"
	output:
		"fastqc_results/{sample}_MT.{read}_fastqc.html"
	params:
		fastqc = fastqc_path
	shell:
		"{params.fastqc} -o fastqc_results {input}"

rule multiqc_analysis:
	input:
		expand(
			"fastqc_results/{sample}_MT.{read}_fastqc.html",
			sample=all_samples,
			read=["R1", "R2"])
	output:
		"multiqc_results/multiqc_report.html"
	params:
		multiqc = multiqc_path
	shell:
		"export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && "
		"{params.multiqc} --interactive "
		"-o multiqc_results fastqc_results"
