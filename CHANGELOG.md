Changelog
==========

<!--

Newest changes should be on top.

This document is user facing. Please word the changes in such a way
that users understand how the changes affect the new version.
-->

version 0.1.0-dev
-----------------
- The pipeline output now contains summary tables for the SNPs and indels for
  each sample, as well as an html report which plots the precision and
  sensitivity for each sample (the data used is from `Threshold=None`).
- It is now possible to set a single baseline vcf file for all samples, using
  `fallbackBaselineVcf`.
- The default behaviour is now to ignore filtered variants
- Index for the baseline VCF file is now optional.
