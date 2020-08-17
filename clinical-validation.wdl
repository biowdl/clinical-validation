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
    File baselineVcf
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
        Map[String, String] dockerImages = {
            "gatk4": "quay.io/biocontainers/gatk4:4.1.2.0--1",
            "vt": "quay.io/biocontainers/vt:0.57721--hdf88d34_2",
            "tabix": "quay.io/biocontainers/tabix:0.2.6--ha92aebf_0",
            "rtg-tools": "quay.io/biocontainers/rtg-tools:3.10.1--0"
        }
    }

    scatter (unit in validationUnit) {
        # Index the VCF files
        call samtools.Tabix as indexBaseline {
            input:
                inputFile = unit.baselineVcf
        }
        call samtools.Tabix as indexCall {
            input:
                inputFile = unit.callVcf
        }

        # Normalize and decompose the call vcf. Otherwise select variants will
        # not work properly
        call vt.Normalize as normalizeAndDecompose {
            input:
                inputVCF = indexCall.indexedFile,
                inputVCFIndex = indexCall.index,
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                outputPath = unit.outputPrefix + "_normalizedCalls.vcf",
                dockerImage = dockerImages["vt"]
        }

        call samtools.BgzipAndIndex as indexCallVcf {
            input:
                inputFile = normalizeAndDecompose.outputVcf,
                outputDir = unit.outputPrefix,
                type = "vcf",
                dockerImage = dockerImages["tabix"]
        }


        call gatk.SelectVariants as selectSNPsCall {
            input:
                referenceFasta = referenceFasta,
                referenceFastaFai = referenceFastaFai,
                referenceFastaDict = referenceFastaDict,
                inputVcf = indexCallVcf.compressed,
                inputVcfIndex = indexCallVcf.index,
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
                inputVcf = indexCallVcf.compressed,
                inputVcfIndex = indexCallVcf.index,
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
                inputVcf = indexBaseline.indexedFile,
                inputVcfIndex = indexBaseline.index,
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
                inputVcf = indexBaseline.indexedFile,
                inputVcfIndex = indexBaseline.index,
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
                allRecords = true,
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
                allRecords = true,
                bedRegions = regions,
                sample = unit.sampleNameVcf,
                dockerImage = dockerImages["rtg-tools"]
        }
    }

    output {
        Array[Array[File]] indelStats = evalIndels.allStats
        Array[Array[File]] SNPStats = evalSNPs.allStats
        Array[File] indelVcf = selectIndelsCall.outputVcf
        Array[File] indelVcfIndex = selectIndelsCall.outputVcfIndex
        Array[File] SNPVcf = selectSNPsCall.outputVcf
        Array[File] SNPVcfIndex = selectSNPsCall.outputVcfIndex

        Array[File] normalizedVcf = indexCallVcf.compressed
        Array[File] normalizedVcfIndex = indexCallVcf.index

        Array[File] BaselineIndelVcf = selectIndelsBaseline.outputVcf
        Array[File] BaselineIndelVcfIndex = selectIndelsBaseline.outputVcfIndex
        Array[File] BaselineSNPVcf = selectSNPsBaseline.outputVcf
        Array[File] BaselineSNPVcfIndex = selectSNPsBaseline.outputVcfIndex
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
        regions: {description: "perform rtg vcfeval on these regions.", category: "common"}
        dockerImages: {description: "The docker images used.", category: "required"}
    }
}
