---
layout: default
title: "Inputs: ClinicalValidation"
---

# Inputs for ClinicalValidation

The following is an overview of all available inputs in
ClinicalValidation.


## Required inputs
<dl>
<dt id="ClinicalValidation.referenceFasta"><a href="#ClinicalValidation.referenceFasta">ClinicalValidation.referenceFasta</a></dt>
<dd>
    <i>File </i><br />
    The reference fasta file
</dd>
<dt id="ClinicalValidation.referenceFastaDict"><a href="#ClinicalValidation.referenceFastaDict">ClinicalValidation.referenceFastaDict</a></dt>
<dd>
    <i>File </i><br />
    Sequence dictionary (.dict) file of the reference.
</dd>
<dt id="ClinicalValidation.referenceFastaFai"><a href="#ClinicalValidation.referenceFastaFai">ClinicalValidation.referenceFastaFai</a></dt>
<dd>
    <i>File </i><br />
    Fasta index (.fai) file of the reference.
</dd>
<dt id="ClinicalValidation.validationUnit"><a href="#ClinicalValidation.validationUnit">ClinicalValidation.validationUnit</a></dt>
<dd>
    <i>Array[struct(baselineVcf : File?, callVcf : File, outputPrefix : String, sampleNameVcf : String?)]+ </i><br />
    Struct containing the call and baseline VCF files for each sample
</dd>
</dl>

## Other common inputs
<dl>
<dt id="ClinicalValidation.allRecords"><a href="#ClinicalValidation.allRecords">ClinicalValidation.allRecords</a></dt>
<dd>
    <i>Boolean </i><i>&mdash; Default:</i> <code>false</code><br />
    Use all VCF records regardless of FILTER status.
</dd>
<dt id="ClinicalValidation.evalIndels.decompose"><a href="#ClinicalValidation.evalIndels.decompose">ClinicalValidation.evalIndels.decompose</a></dt>
<dd>
    <i>Boolean </i><i>&mdash; Default:</i> <code>false</code><br />
    decompose complex variants into smaller constituents to allow partial credit
</dd>
<dt id="ClinicalValidation.evalIndels.refOverlap"><a href="#ClinicalValidation.evalIndels.refOverlap">ClinicalValidation.evalIndels.refOverlap</a></dt>
<dd>
    <i>Boolean </i><i>&mdash; Default:</i> <code>false</code><br />
    allow alleles to overlap where bases of either allele are same-as-ref (Default is to only allow VCF anchor base overlap)
</dd>
<dt id="ClinicalValidation.evalIndels.squashPloidy"><a href="#ClinicalValidation.evalIndels.squashPloidy">ClinicalValidation.evalIndels.squashPloidy</a></dt>
<dd>
    <i>Boolean </i><i>&mdash; Default:</i> <code>false</code><br />
    treat heterozygous genotypes as homozygous ALT in both baseline and calls, to allow matches that ignore zygosity differences
</dd>
<dt id="ClinicalValidation.evalSNPs.decompose"><a href="#ClinicalValidation.evalSNPs.decompose">ClinicalValidation.evalSNPs.decompose</a></dt>
<dd>
    <i>Boolean </i><i>&mdash; Default:</i> <code>false</code><br />
    decompose complex variants into smaller constituents to allow partial credit
</dd>
<dt id="ClinicalValidation.evalSNPs.refOverlap"><a href="#ClinicalValidation.evalSNPs.refOverlap">ClinicalValidation.evalSNPs.refOverlap</a></dt>
<dd>
    <i>Boolean </i><i>&mdash; Default:</i> <code>false</code><br />
    allow alleles to overlap where bases of either allele are same-as-ref (Default is to only allow VCF anchor base overlap)
</dd>
<dt id="ClinicalValidation.evalSNPs.squashPloidy"><a href="#ClinicalValidation.evalSNPs.squashPloidy">ClinicalValidation.evalSNPs.squashPloidy</a></dt>
<dd>
    <i>Boolean </i><i>&mdash; Default:</i> <code>false</code><br />
    treat heterozygous genotypes as homozygous ALT in both baseline and calls, to allow matches that ignore zygosity differences
</dd>
<dt id="ClinicalValidation.fallbackBaselineVcf"><a href="#ClinicalValidation.fallbackBaselineVcf">ClinicalValidation.fallbackBaselineVcf</a></dt>
<dd>
    <i>File? </i><br />
    Fallback baseline VCF file to use when the baselineVcf has not been set in the struct.
</dd>
<dt id="ClinicalValidation.highConfidenceIntervals"><a href="#ClinicalValidation.highConfidenceIntervals">ClinicalValidation.highConfidenceIntervals</a></dt>
<dd>
    <i>File? </i><br />
    Only select SNPs from these intervals for comparison. Useful for Genome In A Bottle samples.
</dd>
<dt id="ClinicalValidation.indexBaseline.outputFilePath"><a href="#ClinicalValidation.indexBaseline.outputFilePath">ClinicalValidation.indexBaseline.outputFilePath</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"indexed.vcf.gz"</code><br />
    The location where the file should be written to. The index will appear alongside this link to the file.
</dd>
<dt id="ClinicalValidation.indexBaseline.type"><a href="#ClinicalValidation.indexBaseline.type">ClinicalValidation.indexBaseline.type</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"vcf"</code><br />
    The type of file (eg. vcf or bed) to be indexed.
</dd>
<dt id="ClinicalValidation.indexCall.outputFilePath"><a href="#ClinicalValidation.indexCall.outputFilePath">ClinicalValidation.indexCall.outputFilePath</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"indexed.vcf.gz"</code><br />
    The location where the file should be written to. The index will appear alongside this link to the file.
</dd>
<dt id="ClinicalValidation.indexCall.type"><a href="#ClinicalValidation.indexCall.type">ClinicalValidation.indexCall.type</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"vcf"</code><br />
    The type of file (eg. vcf or bed) to be indexed.
</dd>
<dt id="ClinicalValidation.regions"><a href="#ClinicalValidation.regions">ClinicalValidation.regions</a></dt>
<dd>
    <i>File? </i><br />
    Perform rtg vcfeval on these regions.
</dd>
</dl>

## Advanced inputs
<details>
<summary> Show/Hide </summary>
<dl>
<dt id="ClinicalValidation.dockerImages"><a href="#ClinicalValidation.dockerImages">ClinicalValidation.dockerImages</a></dt>
<dd>
    <i>Map[String,String] </i><i>&mdash; Default:</i> <code>{"gatk4": "quay.io/biocontainers/gatk4:4.1.2.0--1", "vt": "quay.io/biocontainers/vt:0.57721--hdf88d34_2", "tabix": "quay.io/biocontainers/tabix:0.2.6--ha92aebf_0", "rtg-tools": "quay.io/biocontainers/rtg-tools:3.10.1--0", "plotly": "lumc/plotly:4.10.0"}</code><br />
    The docker images used.
</dd>
<dt id="ClinicalValidation.evalIndels.evaluationRegions"><a href="#ClinicalValidation.evalIndels.evaluationRegions">ClinicalValidation.evalIndels.evaluationRegions</a></dt>
<dd>
    <i>File? </i><br />
    if set, evaluate within regions contained in the supplied BED file, allowing transborder matches. To be used for truth-set high-confidence regions or other regions of interest where region boundary effects should be minimized
</dd>
<dt id="ClinicalValidation.evalIndels.memory"><a href="#ClinicalValidation.evalIndels.memory">ClinicalValidation.evalIndels.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"16G"</code><br />
    The amount of memory this job will use.
</dd>
<dt id="ClinicalValidation.evalIndels.outputMode"><a href="#ClinicalValidation.evalIndels.outputMode">ClinicalValidation.evalIndels.outputMode</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"split"</code><br />
    output reporting mode. Allowed values are [split, annotate, combine, ga4gh, roc-only] (Default is split)
</dd>
<dt id="ClinicalValidation.evalIndels.rtgMem"><a href="#ClinicalValidation.evalIndels.rtgMem">ClinicalValidation.evalIndels.rtgMem</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"8G"</code><br />
    The amount of memory rtg will allocate to the JVM
</dd>
<dt id="ClinicalValidation.evalIndels.threads"><a href="#ClinicalValidation.evalIndels.threads">ClinicalValidation.evalIndels.threads</a></dt>
<dd>
    <i>Int </i><i>&mdash; Default:</i> <code>1</code><br />
    Number of threads. Default is 1
</dd>
<dt id="ClinicalValidation.evalSNPs.evaluationRegions"><a href="#ClinicalValidation.evalSNPs.evaluationRegions">ClinicalValidation.evalSNPs.evaluationRegions</a></dt>
<dd>
    <i>File? </i><br />
    if set, evaluate within regions contained in the supplied BED file, allowing transborder matches. To be used for truth-set high-confidence regions or other regions of interest where region boundary effects should be minimized
</dd>
<dt id="ClinicalValidation.evalSNPs.memory"><a href="#ClinicalValidation.evalSNPs.memory">ClinicalValidation.evalSNPs.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"16G"</code><br />
    The amount of memory this job will use.
</dd>
<dt id="ClinicalValidation.evalSNPs.outputMode"><a href="#ClinicalValidation.evalSNPs.outputMode">ClinicalValidation.evalSNPs.outputMode</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"split"</code><br />
    output reporting mode. Allowed values are [split, annotate, combine, ga4gh, roc-only] (Default is split)
</dd>
<dt id="ClinicalValidation.evalSNPs.rtgMem"><a href="#ClinicalValidation.evalSNPs.rtgMem">ClinicalValidation.evalSNPs.rtgMem</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"8G"</code><br />
    The amount of memory rtg will allocate to the JVM
</dd>
<dt id="ClinicalValidation.evalSNPs.threads"><a href="#ClinicalValidation.evalSNPs.threads">ClinicalValidation.evalSNPs.threads</a></dt>
<dd>
    <i>Int </i><i>&mdash; Default:</i> <code>1</code><br />
    Number of threads. Default is 1
</dd>
<dt id="ClinicalValidation.formatReference.format"><a href="#ClinicalValidation.formatReference.format">ClinicalValidation.formatReference.format</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"fasta"</code><br />
    Format of input. Allowed values are [fasta, fastq, fastq-interleaved, sam-se, sam-pe] (Default is fasta)
</dd>
<dt id="ClinicalValidation.formatReference.memory"><a href="#ClinicalValidation.formatReference.memory">ClinicalValidation.formatReference.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"16G"</code><br />
    The amount of memory this job will use.
</dd>
<dt id="ClinicalValidation.formatReference.rtgMem"><a href="#ClinicalValidation.formatReference.rtgMem">ClinicalValidation.formatReference.rtgMem</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"8G"</code><br />
    The amount of memory rtg will allocate to the JVM
</dd>
<dt id="ClinicalValidation.indexBaseline.dockerImage"><a href="#ClinicalValidation.indexBaseline.dockerImage">ClinicalValidation.indexBaseline.dockerImage</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"quay.io/biocontainers/tabix:0.2.6--ha92aebf_0"</code><br />
    The docker image used for this task. Changing this may result in errors which the developers may choose not to address.
</dd>
<dt id="ClinicalValidation.indexCall.dockerImage"><a href="#ClinicalValidation.indexCall.dockerImage">ClinicalValidation.indexCall.dockerImage</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"quay.io/biocontainers/tabix:0.2.6--ha92aebf_0"</code><br />
    The docker image used for this task. Changing this may result in errors which the developers may choose not to address.
</dd>
<dt id="ClinicalValidation.normalizeAndDecomposeBaseline.memory"><a href="#ClinicalValidation.normalizeAndDecomposeBaseline.memory">ClinicalValidation.normalizeAndDecomposeBaseline.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"4G"</code><br />
    The memory required to run the programs
</dd>
<dt id="ClinicalValidation.normalizeAndDecomposeCall.memory"><a href="#ClinicalValidation.normalizeAndDecomposeCall.memory">ClinicalValidation.normalizeAndDecomposeCall.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"4G"</code><br />
    The memory required to run the programs
</dd>
<dt id="ClinicalValidation.parseSummary.memory"><a href="#ClinicalValidation.parseSummary.memory">ClinicalValidation.parseSummary.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"4G"</code><br />
    The amount of memory to use.
</dd>
<dt id="ClinicalValidation.selectIndelsBaseline.javaXmx"><a href="#ClinicalValidation.selectIndelsBaseline.javaXmx">ClinicalValidation.selectIndelsBaseline.javaXmx</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"4G"</code><br />
    The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.
</dd>
<dt id="ClinicalValidation.selectIndelsBaseline.memory"><a href="#ClinicalValidation.selectIndelsBaseline.memory">ClinicalValidation.selectIndelsBaseline.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"16G"</code><br />
    The amount of memory this job will use.
</dd>
<dt id="ClinicalValidation.selectIndelsCall.javaXmx"><a href="#ClinicalValidation.selectIndelsCall.javaXmx">ClinicalValidation.selectIndelsCall.javaXmx</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"4G"</code><br />
    The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.
</dd>
<dt id="ClinicalValidation.selectIndelsCall.memory"><a href="#ClinicalValidation.selectIndelsCall.memory">ClinicalValidation.selectIndelsCall.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"16G"</code><br />
    The amount of memory this job will use.
</dd>
<dt id="ClinicalValidation.selectSNPsBaseline.javaXmx"><a href="#ClinicalValidation.selectSNPsBaseline.javaXmx">ClinicalValidation.selectSNPsBaseline.javaXmx</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"4G"</code><br />
    The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.
</dd>
<dt id="ClinicalValidation.selectSNPsBaseline.memory"><a href="#ClinicalValidation.selectSNPsBaseline.memory">ClinicalValidation.selectSNPsBaseline.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"16G"</code><br />
    The amount of memory this job will use.
</dd>
<dt id="ClinicalValidation.selectSNPsCall.javaXmx"><a href="#ClinicalValidation.selectSNPsCall.javaXmx">ClinicalValidation.selectSNPsCall.javaXmx</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"4G"</code><br />
    The maximum memory available to the program. Should be lower than `memory` to accommodate JVM overhead.
</dd>
<dt id="ClinicalValidation.selectSNPsCall.memory"><a href="#ClinicalValidation.selectSNPsCall.memory">ClinicalValidation.selectSNPsCall.memory</a></dt>
<dd>
    <i>String </i><i>&mdash; Default:</i> <code>"16G"</code><br />
    The amount of memory this job will use.
</dd>
</dl>
</details>




