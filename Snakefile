configfile: "agar2018_assembly_config.json"

rule all:
	"multiqc/multiqc_report.html"

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
		os.path.join(fastq_directory, "{fq_prefix}.fastq.gz")
	output:
		"fastqc/{fq_prefix}_fastqc.html"
	params:
		fastqc = fastqc_path
	shell:
		"{params.fastqc} -o fastqc {input}"

rule multiqc_analysis:
	input:
		expand("fastqc/{fq_prefix}_fastqc.html", fq_prefix=fastq_prefixes)
	output:
		"multiqc/multiqc_report.html"
	params:
		multiqc = multiqc_path
	shell:
		"export LC_ALL=en_US.UTF-8 && export LANG=en_US.UTF-8 && "
		"{params.multiqc} -o multiqc fastqc"
