---
layout: default
title: Home
---

This is a pipeline for validating the results of clinical pipelines.

This pipeline is part of [BioWDL](https://biowdl.github.io/)
developed by the SASC team at [Leiden University Medical Center](https://www.lumc.nl/).

## Usage
You can run the pipeline using
[Cromwell](http://cromwell.readthedocs.io/en/stable/):
```bash
java -jar cromwell-<version>.jar run -i inputs.json clinical-validation.wdl
```

### Inputs
Inputs are provided through a JSON file. The important inputs are
described below, but additional inputs are available.
A template containing all possible inputs can be generated using
Womtool as described in the
[WOMtool documentation](http://cromwell.readthedocs.io/en/stable/WOMtool/).
For an overview of all available inputs, see [this page](./inputs.html)

```json
{
  "ClinicalValidation.referenceFasta": "The reference fasta file",
  "ClinicalValidation.referenceFastaFai": "The path to the fasta index file of the reference",
  "ClinicalValidation.referenceFastaDict": "Picard dictionary of the reference",
  "ClinicalValidation.validationUnit": [
    {
      "callVcf": "VCF File of the test sample",
      "baselineVcf": "VCF File with truthset for the test sample (optional)",
      "outputPrefix": "Name of the folder to put results for this sample",
      "sampleNameVcf": "(Optional) Name of the sample in the VCF"
    }
  ],
  "ClinicalValidation.HighConfidenceIntervals": "(Optional) File with high confidence intervals from the baseline to select from the baseline",
  "ClinicalValidation.regions": "(Optional) Regions of interest for validation (for example a bed file containing exomic regions).",
  "ClinicalValidation.fallbackBaselineVcf": "Baseline to use for all callVcfs that do not have a baseline defined",
  "ClinicalValidation.allRecords": "(Boolean) Use all VCF records regardless of FILTER status."
}
```

#### Example
The following is an example of what an inputs JSON might look like:
```json
{
  "ClinicalValidation.referenceFasta": "/data/reference.fasta",
  "ClinicalValidation.referenceFastaFai": "/data/reference.fasta.fai",
  "ClinicalValidation.referenceFastaDict": "/data/reference.dict",
  "ClinicalValidation.allRecords": true,
  "ClinicalValidation.validationUnit": [
    {
          "callVcf": "/data/multisample.vcf.gz",
          "baselineVcf": "/data/expected.vcf.gz",
          "sampleNameVcf": "male",
          "outputPrefix": "sample1"
    },
    {
          "callVcf": "/data/multisample.vcf.gz",
          "baselineVcf": "/data/expected.vcf.gz",
          "sampleNameVcf": "female",
          "outputPrefix": "sample2"
    }
  ]
}
```

### Dependency requirements and tool versions
Biowdl pipelines use docker images to ensure  reproducibility. This
means that biowdl pipelines will run on any system that has docker
installed. Alternatively they can be run with singularity.

For more advanced configuration of docker or singularity please check
the [cromwell documentation on containers](
https://cromwell.readthedocs.io/en/stable/tutorials/Containers/).

Images from [biocontainers](https://biocontainers.pro) are preferred for
biowdl pipelines. The list of default images for this pipeline can be
found in the default for the `dockerImages` input.

### Output
This pipeline produces no output.

## Contact
<p>
  <!-- Obscure e-mail address for spammers -->
For any questions about running this pipeline and feature request (such as
adding additional tools and options), please use the
<a href='https://github.com/biowdl/clinical-validation/issues'>github issue tracker</a>
or contact the SASC team directly at: 
<a href='&#109;&#97;&#105;&#108;&#116;&#111;&#58;&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;'>
&#115;&#97;&#115;&#99;&#64;&#108;&#117;&#109;&#99;&#46;&#110;&#108;</a>.
</p>
