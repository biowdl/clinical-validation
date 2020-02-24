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

workflow ClinicalValidation {
    input {
        File referenceFasta
        File referenceFastaFai
        File referenceFastaDict
        File baselineVcf
        File baselineVcfIndex
        File callVcf
        File callVcfIndex
        String? sample
        String outputDir = "."
        File? highConfidenceIntervals
        File? regions
    }

    call gatk.SelectVariants as selectSNPsCall {
        input:
            referenceFasta = referenceFasta,
            referenceFastaFai = referenceFastaFai,
            referenceFastaDict = referenceFastaDict,
            inputVcf = callVcf,
            inputVcfIndex = callVcfIndex,
            selectTypeToInclude = "SNP",
            outputPath = outputDir + "/calledSnps.vcf.gz",
            intervals = select_all([highConfidenceIntervals])
    }

    call gatk.SelectVariants as selectIndelsCall {
        input:
            referenceFasta = referenceFasta,
            referenceFastaFai = referenceFastaFai,
            referenceFastaDict = referenceFastaDict,
            inputVcf = callVcf,
            inputVcfIndex = callVcfIndex,
            selectTypeToInclude = "INDEL",
            outputPath = outputDir + "/calledSnps.vcf.gz",
            intervals = select_all([highConfidenceIntervals])
    }

    call rtg.Format as formatReference {
        input:
            inputFiles = [referenceFasta],
            outputPath = outputDir + "/reference.sdf"
    }

    call rtg.VcfEval as evalSNPs {
        input:
            baseline = baselineVcf,
            baselineIndex = baselineVcfIndex,
            calls = selectSNPsCall.outputVcf,
            callsIndex = selectSNPsCall.outputVcfIndex,
            outputDir = outputDir + "/evalSNPs/",
            allRecords = true,
            decompose = true,
            bedRegions = regions
    }

    call rtg.VcfEval as evalIndels {
        input:
            baseline = baselineVcf,
            baselineIndex = baselineVcfIndex,
            calls = selectIndelsCall.outputVcf,
            callsIndex = selectIndelsCall.outputVcfIndex,
            outputDir = outputDir + "/evalIndels/",
            allRecords = true,
            decompose = true,
            bedRegions = regions
    }

    output {
        File indelSummary = evalIndels.summary
        File SNPSummary = evalSNPs.summary
    }

    parameter_meta {
        referenceFasta: { description: "The reference fasta file", category: "required" }
        referenceFastaFai: { description: "Fasta index (.fai) file of the reference", category: "required" }
        referenceFastaDict: { description: "Sequence dictionary (.dict) file of the reference", category: "required" }
        dockerImages: {description: "The docker images used.", category: "required"}
    }
}
