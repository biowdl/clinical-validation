version 1.0

# Copyright (c) 2020 Leiden University Medical Center
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import "tasks/gatk.wdl" as gatk
import "tasks/rtg.wdl" as rtg
import "tasks/samtools.wdl" as samtools
import "tasks/vt.wdl" as vt

struct ValidationUnit {
    File callVcf
    File? baselineVcf
    String outputPrefix
    String? sampleNameVcf
}

workflow ClinicalValidation {
    input {
        File referenceFasta
        File referenceFastaFai
        File referenceFastaDict
        Array[ValidationUnit]+ validationUnit
        File? highConfidenceIntervals
        File? regions
        File? fallbackBaselineVcf
        Map[String, String] dockerImages = {
            "gatk4": "quay.io/biocontainers/gatk4:4.1.2.0--1",
            "vt": "quay.io/biocontainers/vt:0.57721--hdf88d34_2",
            "tabix": "quay.io/biocontainers/tabix:0.2.6--ha92aebf_0",
            "rtg-tools": "quay.io/biocontainers/rtg-tools:3.10.1--0",
            "plotly": "lumc/plotly:4.10.0"
        }
        Boolean allRecords = false
    }

    scatter (unit in validationUnit) {
        # This is needed for the summary report
        String sampleName = unit.outputPrefix

        # Index the VCF files
        call samtools.Tabix as indexBaseline {
            input:
                inputFile = select_first([unit.baselineVcf, fallbackBaselineVcf])
        }
        call samtools.Tabix as indexCall {
            input:
                inputFile = unit.callVcf
        }

        # Normalize and decompose the baseline vcf.
        call vt.Normalize as normalizeAndDecomposeBaseline {
            input:
                inputVCF = indexBaseline.indexedFile,
                inputVCFIndex = indexBaseline.index,
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                outputPath = unit.outputPrefix + "_baseline_normalizedCalls.vcf",
                dockerImage = dockerImages["vt"]
        }

        call samtools.BgzipAndIndex as indexBaselineVcf {
            input:
                inputFile = normalizeAndDecomposeBaseline.outputVcf,
                outputDir = unit.outputPrefix,
                type = "vcf",
                dockerImage = dockerImages["tabix"]
        }

        # Normalize and decompose the call vcf. Otherwise select variants will
        # not work properly
        call vt.Normalize as normalizeAndDecomposeCall {
            input:
                inputVCF = indexCall.indexedFile,
                inputVCFIndex = indexCall.index,
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                outputPath = unit.outputPrefix + "_normalizedCalls.vcf",
                dockerImage = dockerImages["vt"]
        }

        call samtools.BgzipAndIndex as indexNormalizedCall{
            input:
                inputFile = normalizeAndDecomposeCall.outputVcf,
                outputDir = unit.outputPrefix,
                type = "vcf",
                dockerImage = dockerImages["tabix"]
        }


        call gatk.SelectVariants as selectSNPsCall {
            input:
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                referenceFastaDict = referenceFastaDict,
                inputVcf = indexNormalizedCall.compressed,
                inputVcfIndex = indexNormalizedCall.index,
                selectTypeToInclude = "SNP",
                outputPath = unit.outputPrefix + "/calledSnps.vcf.gz",
                intervals = select_all([highConfidenceIntervals]),
                dockerImage = dockerImages["gatk4"]
        }

        call gatk.SelectVariants as selectIndelsCall {
            input:
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                referenceFastaDict = referenceFastaDict,
                inputVcf = indexNormalizedCall.compressed,
                inputVcfIndex = indexNormalizedCall.index,
                selectTypeToInclude = "INDEL",
                outputPath = unit.outputPrefix + "/calledIndels.vcf.gz",
                intervals = select_all([highConfidenceIntervals]),
                dockerImage = dockerImages["gatk4"]
        }

        call gatk.SelectVariants as selectSNPsBaseline {
            input:
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                referenceFastaDict = referenceFastaDict,
                inputVcf = indexBaselineVcf.compressed,
                inputVcfIndex = indexBaselineVcf.index,
                selectTypeToInclude = "SNP",
                outputPath = unit.outputPrefix + "/baselineSnps.vcf.gz",
                intervals = select_all([highConfidenceIntervals]),
                dockerImage = dockerImages["gatk4"]
        }

        call gatk.SelectVariants as selectIndelsBaseline {
            input:
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                referenceFastaDict = referenceFastaDict,
                inputVcf = indexBaselineVcf.compressed,
                inputVcfIndex = indexBaselineVcf.index,
                selectTypeToInclude = "INDEL",
                outputPath = unit.outputPrefix + "/baselineIndels.vcf.gz",
                intervals = select_all([highConfidenceIntervals]),
                dockerImage = dockerImages["gatk4"]
        }

        call rtg.Format as formatReference {
            input:
                inputFiles = [referenceFasta],
                outputPath = unit.outputPrefix + "/reference.sdf",
                dockerImage = dockerImages["rtg-tools"]
        }

        call rtg.VcfEval as evalSNPs {
            input:
                baseline = selectSNPsBaseline.outputVcf,
                baselineIndex = selectSNPsBaseline.outputVcfIndex,
                calls = selectSNPsCall.outputVcf,
                callsIndex = selectSNPsCall.outputVcfIndex,
                outputDir = unit.outputPrefix + "/evalSNPs/",
                template = formatReference.sdf,
                allRecords = allRecords,
                bedRegions = regions,
                sample = unit.sampleNameVcf,
                dockerImage = dockerImages["rtg-tools"]
        }

        call rtg.VcfEval as evalIndels {
            input:
                baseline = selectIndelsBaseline.outputVcf,
                baselineIndex = selectIndelsBaseline.outputVcfIndex,
                calls = selectIndelsCall.outputVcf,
                callsIndex = selectIndelsCall.outputVcfIndex,
                outputDir = unit.outputPrefix + "/evalIndels/",
                template = formatReference.sdf,
                allRecords = allRecords,
                bedRegions = regions,
                sample = unit.sampleNameVcf,
                dockerImage = dockerImages["rtg-tools"]
        }
    }

    call parseSummary as parseSummary {
        input:
            snpSummary = evalSNPs.summary,
            indelSummary = evalIndels.summary,
            sampleNames = sampleName,
            htmlGraph = "summary.html",
            indelTSV = "indel_summary.tsv",
            snpTSV = "snp_summary.tsv",
            dockerImage = dockerImages["plotly"]
    }


    output {
        Array[File] indelStats = flatten(evalIndels.allStats)
        Array[File] SNPStats = flatten(evalSNPs.allStats)
        Array[File] indelVcf = selectIndelsCall.outputVcf
        Array[File] indelVcfIndex = selectIndelsCall.outputVcfIndex
        Array[File] SNPVcf = selectSNPsCall.outputVcf
        Array[File] SNPVcfIndex = selectSNPsCall.outputVcfIndex

        Array[File] normalizedVcf = indexNormalizedCall.compressed
        Array[File] normalizedVcfIndex = indexNormalizedCall.index

        Array[File] BaselineIndelVcf = selectIndelsBaseline.outputVcf
        Array[File] BaselineIndelVcfIndex = selectIndelsBaseline.outputVcfIndex
        Array[File] BaselineSNPVcf = selectSNPsBaseline.outputVcf
        Array[File] BaselineSNPVcfIndex = selectSNPsBaseline.outputVcfIndex

        File? indelTSV = parseSummary.IndelTSV
        File? snpTSV = parseSummary.SnpTSV
        File? htmlGraph = parseSummary.HtmlGraph
    }

    parameter_meta {
        referenceFasta: { description: "The reference fasta file", category: "required" }
        referenceFastaFai: { description: "Fasta index (.fai) file of the reference.", category: "required" }
        referenceFastaDict: { description: "Sequence dictionary (.dict) file of the reference.", category: "required" }
        baselineVcfIndex: {description: "The baseline VCF's index.", category: "common"}
        sampleName: {description:  "the name of the sample to select. Use <baseline_sample>,<calls_sample> to select different sample names for baseline and calls. (Required when using multi-sample VCF files.)",
        category: "common"}
        highConfidenceIntervals: {description: "Only select SNPs from these intervals for comparison. Useful for Genome In A Bottle samples.",
                                  category: "common" }
        allRecords: {description: "Use all VCF records regardless of FILTER status.", category: "common"}
        regions: {description: "Perform rtg vcfeval on these regions.", category: "common"}
        fallbackBaselineVcf: {description: "Fallback baseline VCF file to use when the baselineVcf has not been set in the struct.", category: "common"}
        validationUnit: {description: "Struct containing the call and baseline VCF files for each sample", category: "required"}
        dockerImages: {description: "The docker images used.", category: "required"}
    }
}

task parseSummary {
    input {
        Array[File]+ snpSummary
        Array[File]+ indelSummary
        Array[String]+ sampleNames
        String? htmlGraph
        String? indelTSV
        String? snpTSV

        String memory = "4G"
        String dockerImage = "lumc/plotly:4.10.0"
    }

    runtime {
        docker: dockerImage
        memory: memory
    }

    command {
        parse_summary \
            --snp-summary  ~{sep=" " snpSummary} \
            --indel-summary  ~{sep=" " indelSummary} \
            --samples  ~{sep=" " sampleNames} \
            ~{"--indel-tsv " + indelTSV} \
            ~{"--snp-tsv " + snpTSV} \
            ~{"--html-graph " + htmlGraph}
    }

    output {
        File? IndelTSV = indelTSV
        File? SnpTSV = snpTSV
        File? HtmlGraph = htmlGraph
    }

    parameter_meta {
        # Input
        sampleNames: {description:  "The names of the samples, in the same order as snpSummary and indelSummary", category: "common"}
        snpSummary: {description: "One or more summary files for the SNP comparison", category: "required"}
        indelSummary: {description: "One or more summary files for the indel comparison", category: "required"}
        dockerImage: {description: "The docker images used.", category: "advanced"}
        memory: {description: "The amount of memory to use.", category: "advanced"}
        # output
        htmlGraph: {description: "Output filename for the html comparison graph", category: "common"}
        indelTSV: {description: "Output filename for the indel comparison table", category: "common"}
        snpTSV: {description: "Output filename for the SNP comparison table", category: "common"}
    }
}
