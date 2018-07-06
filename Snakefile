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
assemblies = ["human_v37_MT"]

# Tool paths (change if tools not in PATH)
bbduksh_path = "bbduk.sh"
bwa_path = "bwa"
fastqc_path = "fastqc"
multiqc_path = "multiqc"
samtools_path = "samtools"

rule all:
	input:
		"multiqc_results/multiqc_report.html",
		"multiqc_trimmed_results/multiqc_report.html",
		expand(
			"bams/{sample}.{assembly}.sorted.bam",
			sample=all_samples,
			assembly=assemblies)

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

rule trim_adapters_paired_bbduk:
	input:
		fq1 = "fastq/{sample}_MT.R1.fastq.gz",
		fq2 = "fastq/{sample}_MT.R2.fastq.gz"
	output:
		out_fq1 = "trimmed_fastqs/{sample}_trimmed_read1.fastq.gz",
		out_fq2 = "trimmed_fastqs/{sample}_trimmed_read2.fastq.gz"
	params:
		bbduksh = bbduksh_path
	shell:
		"{params.bbduksh} -Xmx1g in1={input.fq1} in2={input.fq2} "
		"out1={output.out_fq1} out2={output.out_fq2} "
		"ref=misc/adapter_sequence.fa ktrim=r k=21 mink=11 hdist=2 tbo tpe "
		"qtrim=rl trimq=15 minlen=50 maq=20"

rule fastqc_analysis_trimmed:
	input:
		fq1 = "trimmed_fastqs/{sample}_trimmed_read1.fastq.gz",
		fq2 = "trimmed_fastqs/{sample}_trimmed_read2.fastq.gz"
	output:
		html1 = "fastqc_trimmed_results/{sample}_trimmed_read1_fastqc.html",
		html2 = "fastqc_trimmed_results/{sample}_trimmed_read2_fastqc.html"
	params:
		fastqc = fastqc_path
	shell:
		"{params.fastqc} -o fastqc_trimmed_results {input.fq1} {input.fq2}"

rule multiqc_analysis_trimmed:
	input:
		expand(
			"fastqc_trimmed_results/{sample}_trimmed_{read}_fastqc.html",
			sample=all_samples, read=["read1", "read2"])
	output:
		"multiqc_trimmed_results/multiqc_report.html"
	params:
		multiqc = multiqc_path
	shell:
		"export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && "
		"{params.multiqc} -o multiqc_trimmed_results fastqc_trimmed_results"

rule map_and_process_trimmed_reads:
	input:
		fq1 = "trimmed_fastqs/{sample}_trimmed_read1.fastq.gz",
		fq2 = "trimmed_fastqs/{sample}_trimmed_read2.fastq.gz",
		ref = "reference/{assembly}.fasta",
		fai = "reference/{assembly}.fasta.fai"
	output:
		"bams/{sample}.{assembly}.sorted.bam"
	params:
		id = "{sample}",
		sm = "{sample}",
		bwa = bwa_path,
		samtools = samtools_path
	shell:
		" {params.bwa} mem -R "
	 	"'@RG\\tID:{params.id}\\tSM:{params.sm}' "
		"{input.ref} {input.fq1} {input.fq2}"
		"| {params.samtools} fixmate -O bam - - | {params.samtools} sort "
		"-O bam -o {output}"
