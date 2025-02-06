#!/bin/env/python
from demuxalot import Demultiplexer, BarcodeHandler, ProbabilisticGenotypes, count_snps
import sys

sample = sys.argv[1]
barcodes = sys.argv[2]
bam = sys.argv[3]
genos = sys.argv[4]
donor_path = sys.argv[5]
outdir = sys.argv[6]

with open(donor_path, 'r') as fin:
    donors = fin.read().splitlines()

donors = sorted(donors)

# genos
genotypes = ProbabilisticGenotypes(genotype_names=donors)
genotypes.add_vcf(genos)

# barcodes
barcode_handler = BarcodeHandler.from_file(barcodes)

# bam
snps = count_snps(
    bamfile_location=bam,
    chromosome2positions=genotypes.get_chromosome2positions(),
    barcode_handler=barcode_handler, 
)

# returns two dataframes with likelihoods and posterior probabilities 
likelihoods, posts = Demultiplexer.predict_posteriors(
    snps,
    genotypes=genotypes,
    barcode_handler=barcode_handler)

lik_out = f'{outdir}/{sample}_likelihoods.csv'
post_out = f'{outdir}/{sample}_posteriors.csv'

likelihoods.to_csv(lik_out, sep='\t', header=True, index=True)
posts.to_csv(post_out, sep='\t', header=True, index=True)

### genotype refinement
# refined_genotypes.save_betas(f'{outdir}/{sample}_learnt_genotypes.parquet')
# refined_genotypes = ProbabilisticGenotypes(genotype_names='')
# refined_genotypes.add_prior_betas(f'{outdir}/learnt_genotypes.parquet')
