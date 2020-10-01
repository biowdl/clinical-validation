#!/usr/bin/env python3

import argparse
from functools import partial
from collections import defaultdict

import plotly.graph_objects as go

expected_header = ['Threshold', 'True-pos-baseline', 'True-pos-call',
                   'False-pos', 'False-neg', 'Precision', 'Sensitivity',
                   'F-measure']


def parse_summary(filename):
    no_data = '0 total baseline variants, no summary statistics available\n'
    with open(filename) as fin:
        header = next(fin)

        # Check to see if we got an empty file
        if header == no_data:
            return [{k: 0 for k in expected_header}]

        # Make sure the header matches
        header = header.strip().split()
        assert header == expected_header, header

        data = list()
        for line in fin:
            # Skip divider
            if line.strip() == '-'*100:
                continue
            spline = line.strip().split()
            data.append({key: value for key, value in zip(header, spline)})
        return data


def print_tsv(data, filename):
    """ Print data as tsv to filename """
    with open(filename, 'wt') as fout:
        writefile = partial(print, sep='\t', file=fout)
        writefile('Sample', *expected_header)
        for sample in data:
            for entry in data[sample]:
                writefile(sample, *(entry[field] for field in expected_header))


def plot_data(samples, snps, indels, filename):
    """ Plot the SNP and Indel data using plotly """
    categories = ['SNP Precision', 'SNP Sensitivity', 'Indel Precision',
                  'Indel Sensitivity']

    plot_data = defaultdict(list)
    for sample in samples:
        # Here we add the data, in the SAME ORDER as categories
        for data in snps[sample]:
            # We want to use the data without a threshold
            if data['Threshold'] == 'None':
                plot_data[sample].append(data['Precision'])
                plot_data[sample].append(data['Sensitivity'])
        for data in indels[sample]:
            # We want to use the data without a threshold
            if data['Threshold'] == 'None':
                plot_data[sample].append(data['Precision'])
                plot_data[sample].append(data['Sensitivity'])

    fig = go.Figure(data=[
        go.Bar(
            name=sample,
            x=categories,
            y=plot_data[sample]) for sample in samples])

    fig.update_layout(barmode='group')
    fig.write_html(filename)


def main(args):
    snps = dict()
    indels = dict()
    for sample, snp in zip(args.samples, args.snp_summary):
        snps[sample] = parse_summary(snp)

    for sample, indel in zip(args.samples, args.indel_summary):
        indels[sample] = parse_summary(indel)

    # Print indels to tsv
    if args.indel_tsv:
        print_tsv(indels, args.indel_tsv)

    if args.snp_tsv:
        print_tsv(snps, args.snp_tsv)

    if args.html_graph:
        plot_data(args.samples, snps, indels, args.html_graph)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--snp-summary', required=True,
                        help='RTG eval summary file for SNPs',
                        nargs='+')
    parser.add_argument('--indel-summary',
                        required=True, help='RTG eval summary file for indels',
                        nargs='+')
    parser.add_argument('--samples',
                        required=True,
                        help='Sample names, in the same order as '
                             '--indel-summary and --snp-summary',
                        nargs='+')
    parser.add_argument('--indel-tsv',
                        required=False,
                        help='TSV output file of indel statistics')
    parser.add_argument('--snp-tsv',
                        required=False,
                        help='TSV output file of SNP statistics')
    parser.add_argument('--html-graph',
                        required=False,
                        help='HTML graph of the sensitivity and specificity '
                             'without a threshold applied')

    args = parser.parse_args()
    assert len(args.snp_summary) == len(args.indel_summary)
    assert len(args.samples) == len(args.snp_summary)

    main(args)
